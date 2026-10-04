"""Small PoC catalogue. Ownership is backed by purchases or explicit server awards."""
from uspace_api.errors import ApiError

COSMETICS = [
    {"id": "avatar_default", "kind": "avatar", "label": "Domyślny awatar", "rewardId": None},
    {"id": "frame_default", "kind": "frame", "label": "Bez ramki", "rewardId": None},
    {"id": "title_default", "kind": "title", "label": "Bez publicznego tytułu", "rewardId": None},
    {"id": "avatar_lemur", "kind": "avatar", "label": "Lemur", "rewardId": "reward_avatar_lemur"},
    {"id": "avatar_cat", "kind": "avatar", "label": "Kot", "rewardId": "reward_avatar_cat"},
    {"id": "frame_bow", "kind": "frame", "label": "Obręcz z kokardą", "rewardId": "reward_frame"},
    {"id": "explorer", "kind": "theme", "label": "Odkrywca", "rewardId": "reward_theme_explorer"},
    {"id": "gardener", "kind": "theme", "label": "Ogrodnik", "rewardId": "reward_theme_gardener"},
]
REWARD_COSMETICS = {row["rewardId"]: row for row in COSMETICS if row["rewardId"]}
REWARD_THEMES = {"explorer", "gardener"}
FIELD_KINDS = {"avatarId": "avatar", "frameId": "frame", "titleId": "title"}
# Legacy frame_reward remains equip-compatible, but has the same single bow design.
LEGACY_FRAME = {"id": "frame_reward", "kind": "frame", "label": "Obręcz z kokardą", "rewardId": "reward_frame"}


def inventory(purchased: set[str], titles: list[dict]) -> list[dict]:
    rows = [{**row, "imageUrl": None} for row in COSMETICS
            if row["rewardId"] is None or row["rewardId"] in purchased]
    rows.extend({"id": row["title_id"], "kind": "title", "label": row["label"],
                 "rewardId": None, "imageUrl": None} for row in titles)
    return rows


def validate_appearance(changes: dict, owned: list[dict]) -> None:
    by_id = {row["id"]: row["kind"] for row in owned}
    if "frame_bow" in by_id:
        by_id["frame_reward"] = "frame"
    if any(by_id.get(value) != FIELD_KINDS.get(field) for field, value in changes.items()):
        raise ApiError(403, "NOT_ELIGIBLE", "Ten element nie należy do konta lub nie pasuje do pola.")


async def owned_cosmetics(conn, user_id: str) -> list[dict]:
    purchases = await (await conn.execute(
        """SELECT reward_id FROM redemptions WHERE user_id=%s
        AND status IN ('ready','fulfilled') AND points_status='charged'""", (user_id,))).fetchall()
    titles = await earned_titles(conn, user_id)
    return inventory({row["reward_id"] for row in purchases}, titles)


async def earned_titles(conn, user_id: str) -> list[dict]:
    return await (await conn.execute(
        "SELECT title_id,label,earned_at FROM earned_titles WHERE user_id=%s ORDER BY earned_at,title_id",
        (user_id,))).fetchall()


def reward_category(reward: dict) -> str:
    cosmetic = REWARD_COSMETICS.get(reward["id"])
    return cosmetic["kind"] if cosmetic else ("city" if reward["kind"] == "city_benefit" else "other")


async def public_title(conn, user: dict) -> dict | None:
    selected = user["appearance"].get("titleId")
    if not selected or selected == "title_default":
        return None
    title = await (await conn.execute(
        "SELECT title_id,label FROM earned_titles WHERE user_id=%s AND title_id=%s",
        (user["id"], selected))).fetchone()
    return {"id": title["title_id"], "label": title["label"]} if title else None
