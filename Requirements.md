# PROJECT REQUIREMENTS & DOMAIN KNOWLEDGE
*Source: Dr. Rocke Meeting Notes & Standard Intake Forms*

## 1. STAKEHOLDERS & GOALS
- **Client:** Dr. Rocke (BIRD Lab) & Ministry of Health (Trinidad).
- **Phase 1:** Proof of Concept (PoC) to demonstrate value to policy makers.
- **Phase 2:** Pilot study with real patients.
- **Target Audience:** Elderly Diabetics (Type 1 & 2), potential visual impairments.

## 2. DATA COLLECTION REQUIREMENTS
The App must capture the following specific data points:

### A. Glucose Entry
- Value (mg/dL or mmol/L).
- Context: [Fasting, Before Meal, After Meal, Bedtime].
- Subjective Feeling: [Good, Normal, Bad, Dizzy/Shaky].
- **CRITICAL:** Start identifying "Dawn Effect" (High glucose 6-9 AM).

### B. Food & Nutrition
- **Input Methods:** Voice, Text, or Photo.
- **Critical Data to Extract (AI Task):**
  1. **Volume/Quantity:** (e.g., "Fist size", "One cup").
  2. **Completion:** Did the user finish the meal? (Yes/No/%).
  3. **Carb Estimation:** AI should estimate carbs based on description.
- **Dietary Context:** Trinidadian cuisine (Roti, Doubles, Callaloo) must be recognized.

### C. Medical Safety
- **Hypoglycemia Threshold:** < 70 mg/dL (Trigger "Red" Alert).
- **Severe Low:** < 54 mg/dL (Trigger Emergency Warning).
- **Disclaimer:** "App does not replace medical advice."

## 3. USER INTERACTION FLOW
1. **Onboarding:**
   - Ask: Age, Diabetes Type (1, 2, Gestational), Insulin Use (Pen/Pump).
   - Ask: Target Range (Default: ADA Guidelines 70-180 mg/dL).
2. **Daily Logging:**
   - Simple "Big Button" interface.
   - Voice-First interaction preferred for seniors.
3. **Reporting:**
   - Export to CSV/PDF for Dr. Rocke.
   - Graphs: Show trends (Spikes after specific foods).

## 4. TECHNICAL CONSTRAINTS
- **Privacy:** No central server storage of patient data (HIPAA avoidance strategy).
- **Storage:** Local SQLite database + User's personal Google Drive Backup.
- **Connectivity:** Must work 100% Offline (Rural areas).