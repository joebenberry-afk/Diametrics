"""Pytest bootstrap for the DiaMetrics backend.

`app.config.Settings` is instantiated at import time and requires a few keys
with no defaults. Set them here — before any `app.*` module is imported — so
the routers can be unit-tested without a real `.env` file.
"""
import os

os.environ.setdefault("GEMINI_API_KEY", "test-gemini-key")
os.environ.setdefault("BACKEND_API_KEY", "test-backend-key")
