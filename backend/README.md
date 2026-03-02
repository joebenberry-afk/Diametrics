# DiaMetrics Backend

A lightweight Python FastAPI server that acts as a **secure proxy** between the
DiaMetrics Flutter app and third-party APIs.

## Why a backend?

Without this server, the Gemini and USDA API keys would need to be compiled into
the Flutter APK, where they can be extracted by reverse-engineering the binary.
This backend keeps all secrets on the server side.

```
Flutter App (no third-party keys)
  │  Authorization: Bearer <BACKEND_API_KEY>
  ↓
This FastAPI Server (keys in .env only)
  ├──→ Gemini AI API         (GEMINI_API_KEY)
  ├──→ USDA FoodData API     (USDA_API_KEY)
  └──→ Open Food Facts       (no key needed)

Device SQLite (never leaves the device)
  glucose_logs, meal_logs, medication_logs, user_profiles
```

---

## Patient Privacy Boundary

| Data | Where it stays | Notes |
|---|---|---|
| Glucose readings | Device only | Never sent to backend |
| Medication logs | Device only | Never sent to backend |
| User profile (name, age, weight) | Device only | Never sent to backend |
| Meal logs | Device only | Never sent to backend |
| **Food image** | Sent to backend → Gemini | Photo of plate/food, no health metrics |
| **Food name** | Sent to backend → USDA | Generic string, e.g. "chicken breast" |
| **Barcode** | Sent to backend → Open Food Facts | EAN-13/UPC-A product code, not personal |

---

## Setup

### 1. Install Python dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Create your `.env` file

```bash
cp .env.example .env
```

Then edit `.env` and fill in your real values:

```env
# Get from: https://aistudio.google.com/apikey
GEMINI_API_KEY=your_gemini_key_here

# Free registration: https://fdc.nal.usda.gov/api-guide.html
# Leave as DEMO_KEY for development (30 req/hr)
USDA_API_KEY=DEMO_KEY

# A strong random secret shared with the Flutter app.
# Generate one:  python -c "import secrets; print(secrets.token_hex(32))"
BACKEND_API_KEY=your_strong_random_secret_here
```

> **Important:** Never commit your `.env` file. It is listed in `.gitignore`.

### 3. Start the server

```bash
uvicorn app.main:app --reload --port 8000
```

Visit `http://localhost:8000/docs` for the interactive API documentation.

Verify it is running:
```bash
curl http://localhost:8000/health
# {"status":"ok","service":"DiaMetrics Food API"}
```

---

## Running Flutter with the backend

### Android Emulator
The emulator uses `10.0.2.2` as its alias for your machine's `localhost`:

```bash
flutter run \
  --dart-define=BACKEND_URL=http://10.0.2.2:8000 \
  --dart-define=BACKEND_API_KEY=your_strong_random_secret_here
```

### Real Device (on the same Wi-Fi network)
Find your machine's LAN IP address (e.g. `192.168.1.42`) and use it:

```bash
flutter run \
  --dart-define=BACKEND_URL=http://192.168.1.42:8000 \
  --dart-define=BACKEND_API_KEY=your_strong_random_secret_here
```

---

## API Endpoints

All endpoints require the header:
```
Authorization: Bearer <BACKEND_API_KEY>
```

| Method | Path | Description |
|---|---|---|
| `GET` | `/health` | Health check — no auth required |
| `POST` | `/api/v1/food/analyze-image` | Gemini food image analysis |
| `GET` | `/api/v1/food/usda-search?query=<name>` | USDA macro lookup by food name |
| `GET` | `/api/v1/food/barcode/{barcode}` | Open Food Facts barcode lookup |

Full interactive docs available at `/docs` when the server is running.

---

## Rate Limits (per client token)

| Endpoint | Limit |
|---|---|
| `/api/v1/food/analyze-image` | 10 requests / minute |
| `/api/v1/food/usda-search` | 20 requests / minute |
| `/api/v1/food/barcode/{barcode}` | 30 requests / minute |

---

## Project Structure

```
backend/
├── app/
│   ├── main.py          # FastAPI app, CORS, router registration
│   ├── config.py        # Settings from .env (pydantic-settings)
│   ├── auth.py          # Bearer token validation
│   ├── rate_limiter.py  # Sliding-window rate limiter
│   └── routers/
│       ├── food_analysis.py  # POST /api/v1/food/analyze-image
│       ├── usda.py           # GET  /api/v1/food/usda-search
│       └── barcode.py        # GET  /api/v1/food/barcode/{barcode}
├── .env                 # NOT committed — your real secrets
├── .env.example         # Committed — placeholder template
├── requirements.txt
└── README.md
```

---

## Production Deployment

Before deploying to a production server:

1. **Use HTTPS** — never run over plain HTTP in production (API keys can be intercepted)
2. **Use a strong `BACKEND_API_KEY`** — at least 32 random bytes (`secrets.token_hex(32)`)
3. **Restrict CORS** — change `allow_origins=["*"]` in `main.py` to your app's domain
4. **Set real API keys** — replace `DEMO_KEY` with a registered USDA key for higher limits
5. **Use a process manager** — run with `gunicorn` + `uvicorn` workers for production:
   ```bash
   gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker
   ```

---

## Security Notes

- The `BACKEND_API_KEY` in `.env` must **exactly match** the `--dart-define=BACKEND_API_KEY`
  value passed when building the Flutter app
- The Gemini API key is sent to Google via the `x-goog-api-key` **header** (not a URL
  query parameter), which prevents it from appearing in server access logs
- No patient health data is ever received by this server — see the privacy boundary
  table above
