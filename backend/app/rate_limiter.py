"""
DiaMetrics Backend — In-Memory Rate Limiter

Sliding-window rate limiter keyed by the bearer token.
Prevents a single client from exceeding third-party API quotas.
"""
import time
from collections import defaultdict, deque

from fastapi import HTTPException, status


class RateLimiter:
    """Sliding-window counter: allows at most `max_requests` in `window_seconds`."""

    def __init__(self, max_requests: int, window_seconds: int) -> None:
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._timestamps: dict[str, deque[float]] = defaultdict(deque)

    def check(self, key: str) -> None:
        """Raise HTTP 429 if the key has exceeded its request quota."""
        now = time.monotonic()
        window = self._timestamps[key]

        # Evict entries outside the current window
        while window and window[0] < now - self.window_seconds:
            window.popleft()

        if len(window) >= self.max_requests:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=(
                    f"Rate limit exceeded: max {self.max_requests} requests "
                    f"per {self.window_seconds} seconds."
                ),
            )

        window.append(now)


# One limiter instance per endpoint (shared across requests)
gemini_limiter = RateLimiter(max_requests=10, window_seconds=60)
usda_limiter = RateLimiter(max_requests=20, window_seconds=60)
barcode_limiter = RateLimiter(max_requests=30, window_seconds=60)
