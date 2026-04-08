# DiaMetrics Glucose Prediction System
## Technical Architecture Document

**Version:** 1.0  
**Date:** April 2026  
**Status:** Production (Phase 1)

---

## 1. Executive Summary

DiaMetrics uses a **deterministic physiological simulation** to predict post-meal blood glucose curves. Unlike machine learning approaches that require thousands of training samples, this system produces clinically meaningful projections from a single meal entry and improves its accuracy over time through a lightweight **adaptive gradient descent loop** that personalises three metabolic parameters to the individual user.

**Key design decisions:**
- Deterministic model (reproducible, explainable, auditable)
- Offline-first (runs entirely on-device, no cloud dependency)
- Personalisation through feedback, not population statistics
- No Glycemic Index dependency (no available food database provides it)

---

## 2. System Architecture Overview

```
User logs meal         User logs post-meal glucose
      |                          |
      v                          v
 [MealLog model]           [GlucoseLog model]
      |                          |
      v                          |
 [Pre-meal glucose gate]         |
      |                          |
      v                          v
 [GlucoseProjectionService] <-- [AdaptiveTuningService]
      |                          |
      v                          v
 [ProjectionResult]          [Updated UserProfile]
      |                     (p1, ISF, tMax refined)
      v
 [ProjectionResultView]
 (4-hour curve + metrics)
```

**Source files:**
- `lib/services/glucose_projection_service.dart` — Core simulation engine
- `lib/services/adaptive_tuning_service.dart` — Feedback loop
- `lib/models/projection_result.dart` — Output data model
- `lib/models/meal_log.dart` — Meal input model
- `lib/models/user_profile.dart` — Personalisation parameters
- `lib/viewmodels/logging_wizard_viewmodel.dart` — Orchestration
- `lib/views/projection/projection_result_view.dart` — Visualisation

---

## 3. Phase 1: Feed-Forward Projection (Hovorka Gut Absorption Model)

### 3.1 Overview

The projection engine simulates **minute-by-minute glucose dynamics** over a 240-minute (4-hour) window. Each minute, it computes:

1. How much glucose is being absorbed from the gut into the bloodstream
2. How much glucose the body is clearing naturally (endogenous clearance)
3. How much insulin-on-board is lowering glucose
4. Any modifiers (alcohol, caffeine)

The net of these four forces produces the glucose value at each minute.

### 3.2 Input Parameters

| Parameter | Source | Description |
|---|---|---|
| `baselineGlucose` | Pre-meal glucose reading (mg/dL) | Starting point for the curve |
| `carbsGrams` | Meal log | Total carbohydrates in grams |
| `fiberGrams` | Meal log | Dietary fiber in grams |
| `proteinGrams` | Meal log | Total protein in grams |
| `fatGrams` | Meal log | Total fat in grams |
| `containsAlcohol` | Meal log (boolean) | Inhibits gluconeogenesis |
| `containsCaffeine` | Meal log (boolean) | Can amplify glucose spike |
| `weightKg` | User profile | Used for glucose distribution volume |
| `insulinOnBoard` | Calculated from medication logs | Active rapid-acting insulin (units) |
| `p1` | User profile (adaptive) | Metabolic clearance rate |
| `isf` | User profile (adaptive) | Insulin sensitivity factor (mg/dL per unit) |
| `tMaxBase` | User profile (adaptive) | Gut absorption delay base (minutes) |

### 3.3 Step-by-Step Algorithm

#### STEP 1: Total Available Glucose (TAG)

Not all macronutrients raise blood glucose equally.

```
netCarbs = max(0, carbsGrams - fiberGrams)
TAG = netCarbs + (0.58 x proteinGrams) + (0.10 x fatGrams)
```

**Rationale:**
- **Fiber** is subtracted because it is not digestible and does not raise blood glucose.
- **Protein** contributes ~58% of its weight to glucose via gluconeogenesis (3-6 hour delayed effect).
- **Fat** contributes ~10% of its weight to glucose via glycerol backbone metabolism.

**Reference:** Nutrition and Diabetes, Sieradzki (2010).

If `TAG < 0.01`, the service returns a flat baseline (no projection needed).

#### STEP 2: Hovorka Gut Absorption Parameters

```
aG = 0.8              (bioavailability factor — 80% of ingested glucose reaches blood)
tMax = tMaxBase        (time-to-peak absorption in minutes, default 40)
vG = 0.16 x weightKg  (glucose distribution volume in litres)
```

**Absorption delay modifiers:**
- If `fat > 40g` OR `protein > 25g`: `tMax += 30` minutes (the "pizza effect" — high fat/protein delays gastric emptying)
- If `containsAlcohol`: `tMax += 20` minutes (alcohol delays gastric emptying)

**Blood glucose equivalent rise** (total possible rise if all TAG were absorbed instantly):
```
bgEquivalent = aG x TAG x 100 / vG
```

This converts grams of glucose into mg/dL rise for the individual's body volume.

**Reference:** Hovorka R. et al. (2004), "Nonlinear model predictive control of glucose concentration in subjects with type 1 diabetes."

#### STEP 3: Gamma Distribution Absorption Curve

The gut does not release glucose all at once. The Hovorka model uses a **gamma-distribution kernel** to model the gradual absorption:

```
f(t) = t x exp(-t / tMax)
```

This curve:
- Starts at zero (no glucose absorbed at time 0)
- Peaks at `t = tMax` minutes
- Decays exponentially after the peak

The kernel is **normalised** so that the total area under the curve equals `bgEquivalent`:

```
gammaSum = sum(t=1 to 240) of [t x exp(-t / tMax)]
riseRate(t) = bgEquivalent x [t x exp(-t / tMax)] / gammaSum
```

This guarantees that the total glucose delivered to the bloodstream over 4 hours matches the TAG-derived estimate — no more, no less.

#### STEP 4: Minute-by-Minute Simulation Loop

For each minute `t` from 1 to 240:

```
// 1. Absorption rise
gammaWeight = t x exp(-t / tMax)
riseRate = bgEquivalent x gammaWeight / gammaSum
if (containsCaffeine) riseRate *= 1.10    // +10% amplification

// 2. Endogenous clearance (body's natural glucose disposal)
// Only applies ABOVE the body's fasting equilibrium (~90 mg/dL).
// Scaled by absorption fraction so clearance is minimal when
// the meal is barely absorbed (prevents premature drops).
absorptionFraction = gammaWeight / (gammaSum / 240)
clearanceFraction = clamp(absorptionFraction / (absorptionFraction + 1), 0.1, 1.0)
rawClearance = max(0, gCurrent - 90) x p1
clearanceRate = min(rawClearance x clearanceFraction, 1.5)

// 3. Insulin on Board (linear decay over 4 hours)
iobMinute = (gCurrent > 70) ? totalInsulinDrop / 240 : 0

// 4. Alcohol effect (delayed gluconeogenesis suppression)
alcoholDrop = (containsAlcohol AND t > 60) ? 3.0/60 : 0

// 5. Net change
gCurrent += riseRate - clearanceRate - iobMinute - alcoholDrop
gCurrent = clamp(gCurrent, 40, 500)    // physiological safety bounds
```

Every 5 minutes, a `ProjectionPoint(timeMinutes, glucoseValue)` is emitted to the output curve.

**Key design details:**
- **Clearance gating:** The `clearanceFraction` mechanism prevents the body from "clearing" glucose that hasn't arrived yet. Without this, the curve would dip below baseline before the food is absorbed.
- **Hypo guard:** IOB is only subtracted when glucose is above 70 mg/dL, preventing the simulation from driving glucose into dangerous lows.
- **Caffeine:** A flat +10% multiplier on absorption rate. Conservative estimate based on clinical literature showing caffeine can impair glucose uptake.
- **Alcohol:** After 60 minutes, alcohol suppresses hepatic glucose output at ~3 mg/dL per hour.

#### STEP 5: Output Extraction

From the generated curve:

| Metric | How it's computed |
|---|---|
| **Peak Glucose** | Maximum `glucoseValue` across all points |
| **Time to Peak** | `timeMinutes` of the peak point |
| **2-Hour Glucose** | `glucoseValue` at `timeMinutes == 120` |
| **TAG** | The Total Available Glucose value from Step 1 |
| **Risk Level** | Classified from peak value (see below) |
| **Summary** | Human-readable string with all metrics |

**Risk Classification:**

| Risk Level | Condition |
|---|---|
| `hypo_risk` | Any point below 70 mg/dL |
| `high` | Peak > 250 mg/dL |
| `elevated` | Peak > 180 mg/dL |
| `normal` | All other cases |

---

## 4. Phase 2: Adaptive Parameter Tuning (Gradient Descent Feedback Loop)

### 4.1 Overview

The projection from Phase 1 uses three personal metabolic constants. These start at population-average defaults and are **refined automatically** each time the user logs a post-meal glucose reading. No user action is required — the tuning runs silently in the background.

### 4.2 Parameters Tuned

| Parameter | Symbol | Default | Bounds | What it represents |
|---|---|---|---|---|
| Metabolic Clearance Rate | `p1` | 0.010 | [0.002, 0.020] | How fast the body removes glucose from the bloodstream per minute |
| Insulin Sensitivity Factor | `ISF` | 50.0 | [20.0, 150.0] | mg/dL drop per unit of insulin |
| Absorption Delay Base | `tMax` | 40.0 | [20.0, 90.0] | Minutes to peak gut absorption |

### 4.3 Trigger

Tuning fires when the user logs a glucose reading with context `post_meal`, `post_meal_120`, or `post_meal_30`. The service:

1. Finds the most recent meal logged **within 3 hours before** the glucose reading
2. Finds the pre-meal glucose reading **within 30 minutes before** that meal
3. Re-runs the projection using current profile parameters
4. Interpolates the projected value at the exact elapsed time
5. Computes the signed error: `delta = actual - predicted`

### 4.4 Update Rules

```
Learning rate (lr) = 0.0001

newP1   = clamp(p1   - delta x lr,       [0.002, 0.020])
newISF  = clamp(ISF  + delta x lr x 10,  [20.0, 150.0])
newTMax = clamp(tMax  - delta x lr x 2,  [20.0, 90.0])
```

**Intuition:**
- If `actual > predicted` (spike was worse than expected):
  - `p1` decreases (body clears glucose slower than we assumed)
  - `tMax` decreases (food absorbed faster than we assumed)
- If `actual < predicted` (spike was milder than expected):
  - `p1` increases (body clears glucose faster than we assumed)
  - `ISF` increases (insulin is more effective than we assumed)

**Safety:**
- All parameters are hard-clamped to clinically valid ranges per ADA/Hovorka guidance.
- Changes are only persisted if they exceed a noise threshold (`p1 > 1e-6`, `ISF > 0.01`, `tMax > 0.01`).
- The learning rate is deliberately conservative — convergence takes ~15-20 meals to resist single-day anomalies (e.g., unexpected exercise).
- The entire tuning block is wrapped in `try/catch` with silent failure — tuning never crashes the app.

### 4.5 Convergence Properties

| Property | Value |
|---|---|
| Expected convergence | ~15-20 logged meals |
| Max single-meal adjustment (p1) | 0.0001 x delta |
| Max single-meal adjustment (tMax) | 0.0002 x delta |
| Anomaly resistance | High (lr = 0.0001 with clamped bounds) |
| Data requirement | Minimum 1 pre-meal glucose + 1 meal + 1 post-meal glucose |

---

## 5. Insulin on Board (IOB) Calculation

When a meal is logged, the system queries all rapid-acting insulin doses from the last 4 hours and computes remaining active insulin using a **linear decay model**:

```
For each rapid-acting insulin dose:
    elapsedMinutes = now - dose.timestamp
    remaining = clamp(1.0 - elapsedMinutes / 240, 0, 1)
    iob += dose.units x remaining

Duration of Insulin Action (DIA) = 240 minutes (4 hours)
```

The total IOB is multiplied by ISF to get the expected glucose drop, which is spread evenly across the projection window.

---

## 6. Unit Handling

The projection engine operates **exclusively in mg/dL** internally. Unit conversion happens at two boundaries:

| Boundary | Conversion |
|---|---|
| **Input** (viewmodel) | If user's preferred unit is mmol/L, baseline is multiplied by 18.0182 before entering the service |
| **Output** (view) | All displayed values are divided by 18.0182 if user prefers mmol/L |

This ensures the physiological constants (clamp bounds, clearance equilibrium at 90 mg/dL, hypo threshold at 70 mg/dL) remain valid regardless of user preference.

---

## 7. Data Flow (End to End)

### 7.1 Meal Logging Flow

```
1. User opens Meal Wizard
2. System checks for recent pre-meal glucose (last 30 min)
   - Found: auto-populates, skips manual entry
   - Not found: user enters pre-meal glucose manually
3. User enters macros (manually, via barcode scan, or via AI camera)
4. User taps "Save"
5. System saves pre-meal glucose to DB (if manual)
6. System saves MealLog to DB
7. System calculates IOB from recent medication logs
8. System loads UserProfile (for weight + ML params)
9. System normalises baseline glucose to mg/dL
10. System calls GlucoseProjectionService.project(...)
11. System navigates to ProjectionResultView with result + unit
```

### 7.2 Adaptive Tuning Flow

```
1. User logs a post-meal glucose reading (any context: post_meal, post_meal_120, post_meal_30)
2. System saves the glucose log
3. System fires AdaptiveTuningService.tuneFromGlucoseLog() (background, non-blocking)
4. Service finds the associated meal (within 3 hours before)
5. Service finds the pre-meal glucose (within 30 min before meal)
6. Service re-runs projection with current parameters
7. Service interpolates projected value at elapsed time
8. Service computes delta (actual - predicted)
9. Service applies gradient descent updates to p1, ISF, tMax
10. Service saves updated UserProfile (immutable copyWith)
```

---

## 8. Output: ProjectionResult

```dart
ProjectionResult(
  points: List<ProjectionPoint>,       // 49 points (every 5 min for 240 min)
  peakGlucose: double,                 // Highest value on the curve (mg/dL)
  peakTimeMinutes: int,                // When the peak occurs
  twoHourGlucose: double,             // Value at t=120 min (mg/dL)
  totalAvailableGlucose: double,       // TAG in grams
  riskLevel: String,                   // 'normal' | 'elevated' | 'high' | 'hypo_risk'
  summary: String,                     // Human-readable summary
)
```

---

## 9. Visualisation

The `ProjectionResultView` renders:

1. **4-hour glucose curve** (fl_chart `LineChart`) with the peak dot highlighted
2. **Three metric tiles:** Peak value, Time to Peak, 2-Hour value
3. **TAG info row** showing grams of glucose-equivalent
4. **Risk banner** with colour-coded severity and actionable text
5. **Clinical reference lines** at 70, 140, and 180 mg/dL (dashed)
6. **Medical disclaimer** at the bottom

---

## 10. Comparison Reference Points

For comparing this system against alternative approaches:

| Dimension | DiaMetrics Approach |
|---|---|
| **Model type** | Deterministic compartmental (Hovorka) |
| **Training data required** | None (starts from population defaults) |
| **Personalisation method** | Online gradient descent on 3 physiological parameters |
| **Prediction horizon** | 4 hours (240 minutes) |
| **Output granularity** | Minute-by-minute (displayed every 5 min) |
| **Macronutrient handling** | TAG formula (carbs, protein at 58%, fat at 10%) |
| **Fiber handling** | Subtracted from total carbs (net carbs) |
| **Fat/protein delay** | Absorption delay shift (+30 min for high fat/protein meals) |
| **Insulin modeling** | Linear IOB decay over 4-hour DIA |
| **Runs on-device** | Yes (no cloud dependency) |
| **Computational cost** | O(240) — single loop, sub-millisecond |
| **Explainability** | Full (every variable is traceable) |
| **Known limitations** | No GI weighting, no exercise modeling, linear IOB decay |

---

## 11. Academic References

1. **Hovorka R. et al. (2004)** — "Nonlinear model predictive control of glucose concentration in subjects with type 1 diabetes." _Diabetic Medicine._
2. **Bergman R.N. (1981)** — "Minimal Model: Glucose effectiveness parameter (p1)." _J Clin Invest._
3. **Sieradzki J. (2010)** — "Total Available Glucose and fat/protein delay in mixed meals." _Nutrition and Diabetes._
4. **American Diabetes Association (ADA)** — Clinical parameter ranges for ISF, CIR, and DIA.

---

## 12. Known Limitations

1. **No Glycemic Index weighting** — All carbohydrates are treated equally. No available local food database provides GI values.
2. **Linear IOB decay** — Real insulin action follows a curvilinear profile. A trapezoidal or exponential model would be more accurate.
3. **No exercise modeling** — Physical activity significantly affects glucose disposal but is not captured.
4. **No stress/illness modeling** — Cortisol and inflammatory responses can raise glucose independent of meals.
5. **Single-meal assumption** — The projection assumes only one meal is being digested. Overlapping meals are not modeled.
6. **Population-average starting parameters** — New users receive generic defaults until enough meals are logged for the adaptive loop to converge.
