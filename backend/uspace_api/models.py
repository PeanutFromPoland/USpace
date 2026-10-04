"""Public API models. Field names deliberately match the Flutter JSON contract."""

from __future__ import annotations

import re
from datetime import date, datetime, time
from math import isfinite
from typing import Literal
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


class ApiModel(BaseModel):
    model_config = ConfigDict(extra="forbid")


class Rating(ApiModel):
    """Open set of dimensions until the product catalogue is approved.

    The client may send an average for display compatibility, but the server
    does not infer a formula or award points based on it.
    """

    model_config = ConfigDict(extra="allow")
    average_rating: float | None = Field(default=None, ge=1, le=5)

    @model_validator(mode="after")
    def validate_dimensions(self) -> Rating:
        dimensions = self.model_extra or {}
        if not dimensions:
            raise ValueError("At least one rating dimension is required")
        if len(dimensions) > 20:
            raise ValueError("Too many rating dimensions")
        for name, value in dimensions.items():
            if re.fullmatch(r"[a-z][a-z0-9_]{0,63}", name) is None:
                raise ValueError("Rating dimensions must use stable identifiers")
            if name == "average_rating" or isinstance(value, bool) or not isinstance(value, int):
                raise ValueError("Rating dimensions must be integer values")
            if not 1 <= value <= 5:
                raise ValueError("Rating dimensions must be between 1 and 5")
        if self.average_rating is not None and not isfinite(self.average_rating):
            raise ValueError("Average rating must be finite")
        return self


class Appearance(ApiModel):
    avatarId: str | None = None
    frameId: str | None = None
    titleId: str | None = None


class Register(ApiModel):
    email: str = Field(min_length=3, max_length=254)
    password: str = Field(min_length=12, max_length=256)
    displayName: str = Field(min_length=1, max_length=80)

    @field_validator("email")
    @classmethod
    def validate_email(cls, value: str) -> str:
        if not re.fullmatch(r"[^\s@]+@[^\s@]+\.[^\s@]+", value):
            raise ValueError("Invalid email")
        return value


class Login(ApiModel):
    email: str
    password: str


class ProfilePatch(ApiModel):
    displayName: str | None = Field(default=None, min_length=1, max_length=80)
    appearance: Appearance | None = None


class Rule(ApiModel):
    featureId: str
    importance: Literal["required", "preferred", "ignored"]
    minRating: int | None = Field(default=None, ge=1, le=5)

    @model_validator(mode="after")
    def validate_threshold(self) -> Rule:
        if self.minRating is not None and self.importance != "required":
            raise ValueError("minRating requires a required rule")
        return self


class NamedFilter(ApiModel):
    name: str = Field(min_length=1, max_length=60)
    rules: list[Rule] = Field(default_factory=list)
    includeUnknownRequired: bool = False

    @field_validator("name", mode="before")
    @classmethod
    def nonblank_name(cls, value: object) -> object:
        if not isinstance(value, str):
            return value
        name = value.strip()
        if not name:
            raise ValueError("Name must not be blank")
        return name


class Preferences(ApiModel):
    needIds: list[str] = Field(default_factory=list)
    presetIds: list[str] = Field(default_factory=list)
    rules: list[Rule] = Field(default_factory=list)
    namedFilters: list[NamedFilter] = Field(default_factory=list, max_length=50)

    @model_validator(mode="after")
    def unique_filter_names(self) -> Preferences:
        names = [item.name.casefold() for item in self.namedFilters]
        if len(names) != len(set(names)):
            raise ValueError("Duplicate filter name")
        return self


class PrivacyPatch(ApiModel):
    needsVisibility: Literal["private", "public"]


class UiSettings(ApiModel):
    colorThemeId: str = "green"
    darkMode: bool = False
    highContrast: bool = False
    reduceMotion: bool = False
    textScale: float = Field(default=1, ge=1, le=2)
    simpleLanguage: bool = False


class Bbox(ApiModel):
    west: float = Field(ge=-180, le=180)
    south: float = Field(ge=-90, le=90)
    east: float = Field(ge=-180, le=180)
    north: float = Field(ge=-90, le=90)

    @model_validator(mode="after")
    def validate_order(self) -> Bbox:
        if self.east <= self.west or self.north <= self.south:
            raise ValueError("Invalid bounding box")
        return self


class PlaceSearch(ApiModel):
    q: str | None = Field(default=None, max_length=120)
    cityId: str | None = None
    bbox: Bbox | None = None
    rules: list[Rule] = Field(default_factory=list)
    includeUnknownRequired: bool = False
    sort: Literal["recommended", "name", "best_rated", "review_count"] = "recommended"
    cursor: str | None = None
    limit: int = Field(default=20, ge=1, le=100)

    @model_validator(mode="after")
    def validate_area(self) -> PlaceSearch:
        if not (self.cityId or self.bbox or self.q):
            raise ValueError("Choose a city, area, or query")
        return self


class NewPart(ApiModel):
    clientId: str = Field(min_length=1, max_length=80)
    kind: Literal["entrance", "other"]
    name: str = Field(min_length=1, max_length=120)
    description: str | None = Field(default=None, max_length=500)


class ReviewAnswerCreate(ApiModel):
    clientId: str = Field(min_length=1, max_length=80)
    featureId: str
    targetId: str | None = None
    targetClientId: str | None = None
    presence: Literal["present", "absent", "unknown"]
    operationalState: Literal["working", "not_working", "limited", "unknown"] | None = None
    rating: Rating | None = None
    comment: str | None = Field(default=None, max_length=2000)

    @model_validator(mode="after")
    def validate_answer(self) -> ReviewAnswerCreate:
        if self.targetId and self.targetClientId:
            raise ValueError("An answer can target only one part")
        if self.presence != "present" and (self.rating or self.operationalState):
            raise ValueError("Absent or unknown features cannot have a rating or state")
        return self


class TemporaryIssueCreate(ApiModel):
    featureId: str
    targetId: str | None = None
    targetClientId: str | None = None
    kind: Literal["construction", "outage", "other"]
    description: str = Field(min_length=1, max_length=1000)

    @model_validator(mode="after")
    def validate_target(self) -> TemporaryIssueCreate:
        if self.targetId and self.targetClientId:
            raise ValueError("An issue can target only one part")
        return self


class ReviewCreate(ApiModel):
    mode: Literal["quick", "detailed"]
    visitedOn: date
    visitedAtLocalTime: time | None = None
    timeZone: str
    recommendation: int | None = Field(default=None, ge=1, le=5)
    newParts: list[NewPart] = Field(default_factory=list, max_length=10)
    answers: list[ReviewAnswerCreate] = Field(min_length=1, max_length=50)
    temporaryIssues: list[TemporaryIssueCreate] = Field(default_factory=list)

    @model_validator(mode="after")
    def validate_review(self) -> ReviewCreate:
        if not any(answer.presence != "unknown" for answer in self.answers):
            raise ValueError("At least one substantive answer is required")
        if len({answer.clientId for answer in self.answers}) != len(self.answers):
            raise ValueError("Duplicate answer clientId")
        part_ids = {part.clientId for part in self.newParts}
        if len(part_ids) != len(self.newParts):
            raise ValueError("Duplicate part clientId")
        if any(answer.targetClientId not in part_ids for answer in self.answers if answer.targetClientId):
            raise ValueError("Unknown targetClientId")
        if any(issue.targetClientId not in part_ids for issue in self.temporaryIssues if issue.targetClientId):
            raise ValueError("Unknown issue targetClientId")
        try:
            zone = ZoneInfo(self.timeZone)
        except ZoneInfoNotFoundError as exc:
            raise ValueError("Unknown timeZone") from exc
        if self.visitedOn > datetime.now(zone).date():
            raise ValueError("Visit date cannot be in the future")
        return self


class AssistanceRequest(ApiModel):
    placeId: str
    draft: ReviewCreate


class CardVerificationCreate(ApiModel):
    cityId: str
    cardTypeId: str
    cardNumber: str = Field(min_length=12, max_length=64, pattern=r"^DEMO-[A-Z0-9-]+$")


class VoteCreate(ApiModel):
    verdict: Literal["confirm", "dispute"]
    reason: str | None = Field(default=None, max_length=500)


class ReportCreate(ApiModel):
    reasonCode: Literal["suspected_false", "offensive", "spam", "other"]
    description: str | None = Field(default=None, max_length=1000)


class RedemptionCreate(ApiModel):
    rewardId: str
    expectedCostPoints: int = Field(ge=0)
    deliveryMethod: Literal["account_item", "pickup_code", "city_card"]
