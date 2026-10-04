"""Local, deterministic review vectors for 48-hour duplicate signals.

These hashed text features are an inexpensive demo signal. They do not infer
accessibility or replace moderation. pgvector performs the similarity query.
"""

from __future__ import annotations

import hashlib
import math
import re

DIMENSIONS = 128


def review_vector(feature_id: str, presence: str, comment: str | None) -> str:
    tokens = re.findall(r"\w+", f"{feature_id} {presence} {comment or ''}".lower())
    values = [0.0] * DIMENSIONS
    for token in tokens:
        digest = hashlib.blake2b(token.encode("utf-8"), digest_size=8).digest()
        index = int.from_bytes(digest[:4], "big") % DIMENSIONS
        sign = 1 if digest[4] % 2 else -1
        values[index] += sign
    norm = math.sqrt(sum(value * value for value in values)) or 1
    return "[" + ",".join(f"{value / norm:.8f}" for value in values) + "]"
