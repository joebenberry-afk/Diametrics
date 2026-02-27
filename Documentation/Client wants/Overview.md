Here is a comprehensive, full-scope description of the project.

**Project Overview and Purpose**
The project is a **Proof of Concept (PoC) Diabetes Management App** developed as a research initiative for the BIRD Lab and Dr. Rocke, with long-term goals of demonstrating value to policymakers (such as the Ministry of Health, WHO, and World Bank) for future national scale-up. It is currently in Phase 1 (demonstration), so it is not yet intended for commercial deployment. 

**Target Audience and Accessibility**
The app is designed for individuals with various forms of diabetes, including Type 1, Type 2, LADA, MODY, and Gestational diabetes. Because many older diabetic patients are visually impaired, **accessibility is a major priority**; the app must feature high readability, ease of use, and simple interaction flows. 

**Core Features and Functionality**

*   **User Profiles & Medical Context:** 
    *   Collects baseline data: age, gender, height, weight, target weight, and timezone.
    *   Captures specific diabetes information, including diagnosis year, insulin dependency/sensitivity, use of pills, and whether the user uses a Continuous Glucose Monitor (CGM) or specific blood glucose meters.
    *   Allows users to set glucose targets (min/max thresholds) based on preferred clinical guidelines (ADA, WHO, or custom).
*   **Glucose Monitoring & Trends:**
    *   **CGM integration is critical** to automatically log glucose alongside user events. 
    *   Must track and graph glucose levels before and after eating, long-term trends, and identify specific diabetic phenomena like the "Dawn Effect".
    *   Allows manual logging of blood glucose values, measurement context (fasting, before/after meals), and contextual explanations for unusual spikes.
*   **Advanced Food & Nutrition Logging:**
    *   Users can log meals via text, voice, or food images.
    *   **AI Integration:** The app uses AI to extract information from voice/text inputs to determine portion sizes/volume and whether the food was completely finished, capturing details not visible in images.
    *   Tracks eating behaviors, including the order in which food is eaten and digestion delays (e.g., delayed sugar spikes from certain foods).
    *   Supports tracking of carbohydrates (grams/exchanges), calories, dietary preferences (vegan, keto, etc.), and food allergies.
*   **Activity & Lifestyle Tracking:**
    *   Logs daily physical activity, sleep, stress/mood, and monthly weight changes.
    *   Capable of connecting with external fitness apps like Google Fit, Samsung Health, Fitbit, and Garmin.
*   **Alerts, Reminders, & Safety:**
    *   Customizable alarms for critical high/low glucose thresholds, with the ability to **notify family members** in emergencies.
    *   Push notifications for missed readings, medication/insulin reminders, meals, and water intake.
    *   Must include a mandatory medical disclaimer stating the app does not replace professional medical advice.
*   **Analytics & Reporting:**
    *   Generates daily, weekly, or monthly summaries.
    *   Allows users to export data (CSV or premium PDF) to share with healthcare professionals.

**Technical & Security Constraints**
*   **Data Security:** The app must store data on a secure cloud platform using industry-standard security. While full HIPAA compliance and custom encryption are recommended for future production stages, they are not strictly required for this PoC, which just needs to demonstrate how security *could* be implemented.
*   **Event Flow Architecture:** The core loop relies on the user logging an event (like a meal or exercise), followed by the CGM automatically logging the resulting glucose levels for AI and trend analysis.