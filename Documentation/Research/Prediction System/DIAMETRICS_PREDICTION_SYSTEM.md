# DiaMetrics Glucose Prediction System
## Technical Architecture Document

**Version:** 4.1  
**Date:** April 2026  
**Status:** Clinical Implementation (Phase 4)

---

## 1. Executive Summary

DiaMetrics uses a **multi-compartment physiological simulation** to predict post-meal blood glucose curves. The Phase 4 engine introduces an Extended Kalman Filter for adaptive tuning, Dawn Phenomenon circadian correction, meal superposition for overlapping events, and localised Caribbean dietary heuristics.

**Key design decisions:**
- **Deterministic Dual-Kernel model** (separated carb/protein kinetics)
- **Dynamic Walsh Bilinear IOB** (insulin-specific action curves)
- **Extended Kalman Filter** (replaces gradient descent for state estimation)
- **Dawn Phenomenon** (circadian baseline correction, 4-8 AM)
- **Meal Superposition** (learning through overlapping meal events)
- **Caribbean Dietary Heuristics** (regional absorption multipliers)
- **Uncertainty Quantification** (time-varying sine envelope confidence bands)

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
- `lib/services/glucose_projection_service.dart` -- Core Phase 4 simulation engine
- `lib/services/ekf_tuning_service.dart` -- Extended Kalman Filter feedback loop
- `lib/services/caribbean_food_heuristics.dart` -- Regional dietary multipliers
- `lib/services/adaptive_tuning_service.dart` -- Deprecated (delegates to EKF)
- `lib/models/projection_result.dart` -- Output model (with sine-envelope bands)
- `lib/models/meal_log.dart` -- Input model (with post-exercise flag)
- `lib/models/user_profile.dart` -- Personalised parameters + EKF covariance state
- `lib/viewmodels/logging_wizard_viewmodel.dart` -- Dynamic DIA lookup logic
- `lib/views/projection/projection_result_view.dart` -- Visualisation (FL Chart)

---

## 3. Phase 3: Dual-Kernel Projection (Enhanced Clinical Roadmap)

### 3.1 Overview

The Phase 4 projection engine enhances the minute-by-minute simulation with an Extended Kalman Filter, circadian baseline correction (Dawn Phenomenon), meal superposition for overlapping events, and localised Caribbean food absorption heuristics.

The Phase 2 projection engine simulates **minute-by-minute glucose dynamics** using two separate metabolic pathways. This prevents the "carb-washing" effect where protein and fats are blended into a single curve, leading to over-prediction in the first hour and under-prediction in the fourth.

1. **Fast Pathway:** Rapidly absorbed carbohydrates and immediate metabolic effects.
2. **Slow Pathway:** Delayed protein gluconeogenesis (starts 60 min post-meal).
3. **IOB Correction:** Walsh Bilinear insulin action (peaking at ~72 min).
4. **Adaptive Clearance:** Bergman's Minimal Model-derived disposal.

### 3.2 Input Parameters

| Parameter | Source | Description |
|---|---|---|
| `baselineGlucose` | Pre-meal log | Starting point (mg/dL) |
| `carbs`, `fiber` | Meal log | Net carbs = Carbs - Fiber |
| `proteins` | Meal log | Delayed glucose source (58% conversion) |
| `fats` | Meal log | Absorption delay modifier (10% conversion) |
| `foodFormFactor` | Meal log | `liquid`, `highFiber`, `processed`, `standard` |
| `weightKg` | Profile | Distribution volume calculation |
| `p1`, `isf`, `tMax` | Profile | Adaptive ML-refined constants |
| `fastingSetpoint` | Profile | User's personal clearance equilibrium (mg/dL) |
| `postExercise` | Meal log | Binary flag for 2-hour post-activity window |
| `mealCount` | Profile | Determines confidence band width |
| `mealTimestamp` | System | Real-world time for circadian correction |
| `mealName` | Meal log | For regional Caribbean food heuristic lookup |

### 3.3 Step-by-Step Algorithm (Phase 2)

#### STEP 1: Decoupled TAG Calculation

Instead of a single Total Available Glucose (TAG) value, we split the meal into two kinetic components:

```
fastTAG    = netCarbs + (0.10 x fatGrams)
proteinTAG = 0.58 x proteinGrams
totalTAG   = fastTAG + proteinTAG
```

#### STEP 2: Food-Form Heuristics (GI Proxy)

Since local food databases lack reliable Glycemic Index (GI) data, we use **Food-Form Heuristics** to adjust the absorption delay (`tMax`):

| Factor | tMax Adjustment | Clinical Rationale |
|---|---|---|
| **Liquid** | -15 minutes | No gastric breakdown required (e.g., juice) |
| **Processed** | -10 minutes | Refined starches absorb significantly faster |
| **High Fiber** | +10 minutes | Fiber matrix slows starch hydrolysis |
| **High Fat/Protein** | +30 minutes | "Pizza effect" — delays gastric emptying |
| **Caribbean** | Regional Scaling | Applied via `CaribbeanFoodHeuristics` |
| **Alcohol** | +20 minutes | Inhibits gastric emptying and glucose release |

#### STEP 3: Metabolic Modifiers

1. **Post-Exercise Disposal Boost:** If the `postExercise` flag is active, $p_1$ is multiplied by **1.35x** (+35%) and $tMax$ is reduced by **10 minutes**.
2. **Caffeine Spike:** If `containsCaffeine` is true, the overall glucose rise rate is multiplied by **1.10x** (+10%) to reflect transient adrenaline-driven resistance.
3. **Alcohol Suppression:** If `containsAlcohol` is true, a linear drop of **3.0 mg/dL/hr** is applied starting at $t=60$, modelling the liver's inhibition of gluconeogenesis.

#### STEP 4: Dual-Kernel Gamma Distribution

We pre-compute two separate **gamma-distribution kernels** ($t \cdot e^{-t/tMax}$):

1. **Fast Kernel:** Peaks at the adjusted `tMax`. Handles the `fastTAG`.
2. **Slow Kernel:** Uses an offset $t - 60$ and a fixed $tMax = 120$. This models the metabolic delay in converting protein to glucose via hepatic gluconeogenesis.

#### STEP 4: Minute-by-Minute Simulation Loop

For each minute $t \in [1, 240]$:

1.  **Fast Rise:** `fastBgEquiv * fastGamma(t) / fastGammaSum`
2.  **Protein Rise:** `proteinBgEquiv * proteinGamma(t-60) / proteinGammaSum` (if $t > 60$)
3.  **Endogenous Clearance:** Based on distance from the user's **effective fasting setpoint** (see Dawn Phenomenon), scaled by current absorption fraction.
4.  **Dawn Phenomenon:** Between 4:00-8:00 AM, the fasting setpoint is elevated by up to +15 mg/dL (sine-wave peak at 6:00 AM) to simulate cortisol-driven insulin resistance.
5.  **Dynamic Walsh IOB:** Uses the drug-specific DIA (see Section 5) to calculate insulin delta.
6.  **Net Change:** $G_{t} = G_{t-1} + Rise_{fast} + Rise_{protein} - Clearance - WalshIOB$

Every 5 minutes, we emit a point including the calculated value and the **Time-Varying Confidence Band** (sine envelope).

### 3.4 Risk Classification & Metrics

| Metric | Calculation |
|---|---|
| **Peak Glucose** | Max $G_{t}$ |
| **Time to Peak** | $t$ at Max $G_{t}$ |
| **2nd-Hour Val** | $G_{120}$ |
| **Confidence** | Narrowing $\pm$ range based on `mealCount` |

| Risk Level | Logic |
|---|---|
| `hypo_risk` | Any $G_{t} < 70$ mg/dL |
| `high` | Peak > 250 mg/dL |
| `elevated` | Peak > 180 mg/dL |
| `normal` | Within target range [70, 180] |

---

## 4. Phase 4: Extended Kalman Filter (EKF) Adaptive Tuning

### 4.1 Overview

The Phase 4 tuning engine replaces gradient descent with an **Extended Kalman Filter (EKF)**, a recursive Bayesian state estimator designed for non-linear systems. The EKF mathematically balances "trust" between the deterministic model prediction and the noisy sensor measurement.

**State Vector:** `x = [p1, ISF, tMax]`
**Covariance:** Diagonal `P = [ekfCovP1, ekfCovISF, ekfCovTMax]`
**Measurement Noise (R):** 100.0 (finger-stick meter variance, ~10 mg/dL std dev)

### 4.2 EKF vs Gradient Descent

| Dimension | Gradient Descent (Phase 2) | EKF (Phase 4) |
|---|---|---|
| Noise handling | Fixed learning rate -- vulnerable | Kalman gain adapts to uncertainty |
| Bad reading impact | Can severely skew parameters | Naturally down-weighted by R |
| Convergence tracking | Implicit (meal count) | Explicit (covariance diagonal) |
| Overlapping meals | Aborts tuning | Superposition engine continues |

### 4.3 Update Equations (Simplified Scalar Per Parameter)

```
Innovation:    y = actual_glucose - projected_glucose
Kalman Gain:   K = P / (P + R)
State Update:  x_new = x + K * y * sensitivity
Cov Update:    P_new = (1 - K) * P
Process Noise: P += Q  (injected each cycle to prevent covariance collapse)
```

**Empirical Jacobians (Sensitivities):**
- **tMax Sensitivity:** -0.3 (higher delay = lower early glucose)
- **p1 Sensitivity:** -0.001 (higher clearance = lower late glucose)
- **ISF Sensitivity:** 0.1 (higher sensitivity = lower resulting glucose)

### 4.4 Decoupled Context (Preserved from Phase 2)

| Reading Context | Timing | Parameter Updated | Rationale |
|---|---|---|---|
| `post_meal_30` | ~30 min | `tMax` (Absorption) | Early error is dominated by delivery speed, not clearance. |
| `post_meal_120` | ~120 min | `p1` & `ISF` (Clearance) | Absorption is mostly complete; error reflects disposal efficiency. |
| `post_meal` | Any | `p1` & `ISF` | Default to clearance tuning for late-stage readings. |

### 4.5 Uncertainty Quantifier

The EKF covariance diagonal serves as a direct measure of estimation quality:
- **High covariance** (new user): Wide confidence bands, large Kalman gains
- **Low covariance** (established user): Narrow bands, small gains (resistant to noise)

Additionally, `tuningMealCount` is still incremented for backward-compatible confidence band width calculation.

### 4.6 Meal Superposition (Replaces Overlap Guard)

Instead of aborting tuning when overlapping meals are detected, the Phase 4 engine calculates the **residual glucose contribution** from each overlapping meal to isolate the metabolic signal.

**Algorithm:**
1. Detect meals logged between the primary meal and the glucose reading.
2. If <= 2 overlapping meals:
   - Re-project each overlapping meal from a **zero baseline** ($G_0 = 0$).
   - Calculate its contribution at the reading time.
   - Sum these contributions to get the `residualContribution`.
3. Subtract the `residualContribution` from the actual reading to isolate the primary meal's signal.
4. Continue with the EKF update using the adjusted innovation ($y = (Actual - Residual) - Predicted$).
5. If > 2 overlapping meals: abort (signal-to-noise ratio too low).

### 4.7 Safety & Convergence

- **Convergence:** Typical convergence within 15-20 high-quality log pairs (same as Phase 2).
- **Process noise (Q):** Small constant injected each cycle to track slow physiological drift.
- **Physiological clamps:** All ADA/Hovorka bounds preserved.

## 5. Insulin on Board (IOB) Calculation (Profile-Level Walsh Bilinear)

Phase 3 implements **Profile-Level Dynamic Walsh Bilinear** modeling, where the Duration of Insulin Action (DIA) is configured **once during onboarding** rather than per-dose. This aligns with the clinical reality that most patients use a single type of rapid-acting insulin.

### 5.1 Two-Question Insulin Wizard (UX)

The onboarding flow uses a tiered approach to minimize cognitive load:

**Q1: "Do you take insulin for meals?"**
- **Yes, I take a shot/dose before eating** → Show bolus type picker (Q2)
- **Yes, but only a background/daily dose** → Set category to `basal_only`, skip IOB
- **No** → Set category to `none`, skip IOB entirely

**Q2: "Which type?" (if bolus)**
| Option | DIA | Insulin Category |
|---|---|---|
| Ultra-fast (Fiasp, Lyumjev, Afrezza) | 180 min | `ultra_fast` |
| Standard rapid (Humalog, NovoLog, Apidra) | 240 min | `standard_rapid` |
| Regular / short-acting (Humulin R) | 360 min | `regular` |
| I'm not sure | 240 min | `standard_rapid` (safe default) |

### 5.2 Basal-Only Guard

If `insulinCategory` is `basal_only` or `none`, the IOB calculation returns **0.0 units immediately**. This prevents a user who only takes long-acting basal insulin (e.g., Lantus, Tresiba) from having "phantom insulin" incorrectly suppress their projected glucose curve. The system assumes basal insulin reaches a steady-state equilibrium which is captured by the user's `fastingSetpoint` rather than dynamic IOB.

### 5.3 The Walsh Curve

The Walsh model uses a sigmoid (S-curve) approximation where $t$ is the fraction of the user's configured `insulinDiaMinutes` from their **UserProfile**:

```
t = elapsedMinutes / profile.insulinDiaMinutes
iobFraction = 1.0 - (t^2 * (3.0 - 2.0 * t))
```

**Clinical Properties:**
- **Smooth Onset:** Action starts slowly, mimicking subcutaneous absorption.
- **Accurate Peak:** Peak insulin action occurs at approximately 30% of the DIA (~72 minutes for a 4-hour DIA).
- **Realistic Tail:** Insulin action tapers off gradually rather than cutting off abruptly.

### 5.2 Minute-by-Minute Impact

In the simulation loop, the insulin impact for each minute is calculated as the differential of the Walsh curve:

```
iobMinute = (iobFraction(t-1) - iobFraction(t)) * (units * ISF)
```

This ensures that the total area under the insulin action curve equals the total dose multiplied by the user's Insulin Sensitivity Factor (ISF).

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
  upperBand: List<ProjectionPoint>,    // +Confidence width
  lowerBand: List<ProjectionPoint>,    // -Confidence width
  confidenceWidth: double,             // Half-width in mg/dL
)
```

### 8.1 Uncertainty Quantification (Sine Envelope Confidence Bands)

Phase 3 introduces **Time-Varying Sine Envelope** bands to more accurately reflect the probability distribution of glucose outcomes.

- **Phase 1/2:** Constant uniform band width.
- **Phase 3:** Cone-shaped "fan" envelope using a sine function.

**Band Logic:**
```
Phase = elapsedMinute / 240.0
Envelope = sin(Phase * PI)
currentWidth = maxWidth * Envelope
```

**Interpretation:**
- **t=0:** Zero band width (the starting point is a known fact).
- **t=120:** Maximum band width (peak uncertainty during active digestion).
- **t=240:** Zero band width (re-convergence upon the predicted fasting baseline).

The `maxWidth` itself continues to narrow from $\pm$ 25 to $\pm$ 10 mg/dL as the `mealCount` increases.

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

| Dimension | DiaMetrics Phase 4 Approach |
|---|---|
| **Model type** | Deterministic Dual-Kernel (Hovorka based) |
| **Training data required** | Zero-start (population defaults) |
| **Personalisation method** | **Extended Kalman Filter (EKF)** |
| **Prediction horizon** | 4 hours (240 minutes) |
| **Macronutrient handling** | **Decoupled TAG** (Separate Carb/Protein kernels) |
| **GI weighting** | **Food-Form Heuristics + Regional Multipliers** |
| **Caffeine/Alcohol** | **Mechanistic model (Inhibition/Resistance)** |
| **Insulin modeling** | **Profile-Level Walsh Bilinear** |
| **Circadian modeling** | **Dawn Phenomenon** (sine-wave 4-8 AM) |
| **Overlapping meals** | **Superposition Engine** (Residual subtraction) |
| **Confidence tracking** | **Sine Envelope + EKF Covariance** |
| **Explainability** | Full (deterministic metabolic kernels) |
| **Known limitations** | No stress/illness modeling |

---

## 11. Academic References

1. **Hovorka R. et al. (2004)** — "Nonlinear model predictive control of glucose concentration in subjects with type 1 diabetes." _Diabetic Medicine._
2. **Bergman R.N. (1981)** — "Minimal Model: Glucose effectiveness parameter (p1)." _J Clin Invest._
3. **Sieradzki J. (2010)** — "Total Available Glucose and fat/protein delay in mixed meals." _Nutrition and Diabetes._
4. **American Diabetes Association (ADA)** — Clinical parameter ranges for ISF, CIR, and DIA.

---

## 12. Known Limitations

1. **No direct stress/illness modeling** — Cortisol and inflammatory responses can raise glucose independent of meals.
2. **Generic Defaults** — Non-Type-1/Type-2 users may experience high initial error until the adaptive loop completes ~15 tuning events.

### 12.1 Addressed Limitations (from Phase 1, 2, & 3)

- Fixed: Dynamic Walsh Bilinear IOB (Insulin-specific DIA).
- Fixed: Post-Exercise disposal boosts (1.35x p1).
- Fixed: Time-Varying Confidence Bands (Cone/Sine Envelope).
- Fixed: Meal Overlap Guard -> upgraded to Superposition Engine.
- Fixed: Personalized Fasting Setpoints.
- Fixed: Dawn Phenomenon circadian correction (4-8 AM).
- Fixed: Noise-resistant tuning via EKF (replaces gradient descent).
- Fixed: Caribbean regional dietary heuristics.
- Fixed: Single-meal assumption (superposition handles overlapping meals).
