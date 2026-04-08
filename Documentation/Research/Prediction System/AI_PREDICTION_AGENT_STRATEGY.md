# AI Blood Glucose Prediction Agent: Operational Strategy

This document serves as the "Source of Truth" for the AI Agent’s prediction logic, consolidating clinical research, physiological models, and FDA regulatory requirements.

---

## 1. Regulatory & Safety Mandate (SaMD)
The agent operates as **Software as a Medical Device (SaMD)** under **FDA Product Code QRX** (Class II). It must adhere to **21 CFR 862.1358 Special Controls**:
- **Algorithmic Transparency:** Must explain why a specific prediction or dose recommendation was made.
- **Dosing Error Mitigation:** Implement "hard-coded" safety limits (MPC) to prevent insulin stacking or over-dosing, regardless of AI model outputs.
- **Clinical Validity:** Predictions must maintain a Root Mean Square Error (RMSE) < 20 mg/dL for 30-minute horizons.

---

## 2. Core Prediction Logic: The Tiered Approach

### Tier 1: Initial Postprandial Heuristics (Pre-Meal)
Upon receiving meal input (via NLP/Vision), the agent calculates the initial baseline curve using:
- **Sieradzki Equation (Primary Baseline):** 
  - $Insulin_{CHO} = \frac{Carbs(g)}{ICR}$
  - $Insulin_{Extended} = 0.30 	imes Insulin_{CHO}$ (triggered if Fat > 40g or Protein > 25g).
  - *Distribution:* Immediate bolus + 4-hour extended wave.
- **Warsaw Method (Secondary/Complex):** 
  - Converts Fat/Protein into Fat-Protein Units (FPU = 100 kcal).
  - Calculates extended bolus duration based on FPU count (3h to 8h).

### Tier 2: Physiological State Estimation (Continuous)
The agent maps inputs into a minute-by-minute simulation:
- **Hovorka Compartmental Model:** Models the rate of glucose appearance ($R_a$) from the gut.
  - **Adjustment:** If meal is High-Fat/High-Protein, the agent must shift $t_{max,G}$ (time-to-peak) by $t_d$ (20-60 mins) to account for delayed gastric emptying.
- **Bergman Minimal Model:** Simulates the interaction between plasma glucose ($G$) and insulin action ($X$).
- **Dalla Man (DM) Model:** Used to track **endogenous glucose production** ($k_{p1}$) and basal insulin secretion ($m_6$), critical for accurate overnight/fasting predictions.

---

## 3. Real-Time Trajectory Correction (Mid-Course)
At **T+30 minutes** post-meal, the agent MUST ingest a ground-truth CGM reading and recalibrate:
- **Recursive Least Squares (RLS):**
  - Uses a **forgetting factor** ($\lambda = 0.95$ to $0.99$) to weight the 30-minute reading more heavily than historical data.
  - Instantly updates the ARMAX model coefficients to correct the predicted curve for the next 3 hours.
- **Unscented Kalman Filter (UKF):**
  - If the 30-min reading deviates significantly from the Tier 2 forecast, the UKF "repaints" the peak by inferring a faster/slower gastric emptying rate.

---

## 4. Longitudinal Personalization (Learning Over Time)
The agent updates the user’s clinical profile (ICR/ISF) daily/weekly:
- **Run-to-Run (R2R) Control:** 
  - Evaluates the "batch" performance of each meal.
  - If 2-hour postprandial BG is consistently $>180$ mg/dL, it proposes a lower ICR (more aggressive).
  - If any hypo ($<70$ mg/dL) occurs, it immediately increases ICR by 10-20%.
- **Deep Reinforcement Learning (DRL):**
  - Uses PPO/TD3 agents to optimize dosing policies.
  - Reward Function: $+1$ for Time in Range (70-180 mg/dL), $-10$ for hypoglycemia.

---

## 5. Agent Operational Constraints (Safety Caging)
1. **Insulin On Board (IOB):** Never recommend a correction dose without deducting active insulin from previous boluses.
2. **Confidence Scoring:** For Caribbean food inputs (e.g., "Doubles", "Rice and Peas"), if confidence is $<0.85$, the agent must prompt for portion clarification before predicting.
3. **Hypoglycemia Alert:** If the UKF predicts BG $<65$ mg/dL within 60 minutes, trigger an audible alert that overrides "Do Not Disturb" (if OS permitted).

---

## 6. Caribbean Dietary Adaptation
- **Context Injection:** When analyzing meals, the agent must prioritize regional prep-methods (e.g., recognizing that "fried plantain" has a significantly higher glycemic impact than "boiled plantain" due to fat-induced delays).
- **RAG Implementation:** Use the local vector database of Caribbean nutritional profiles to supplement general-purpose knowledge.
