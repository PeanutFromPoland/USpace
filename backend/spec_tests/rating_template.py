"""Test-local template for the evolving rating response shape."""

from pydantic import BaseModel, ConfigDict, Field


class RatingTemplate(BaseModel):
    model_config = ConfigDict(extra="allow")
    __pydantic_extra__: dict[str, float | None] = Field(init=False)
    average_rating: float | None


class ReviewAnswerTemplate(BaseModel):
    featureId: str
    rating: RatingTemplate | None


class FeatureSummaryTemplate(BaseModel):
    featureId: str
    rating: RatingTemplate | None
