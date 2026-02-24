# DiaMetrics: Fine-Tuning Proposal (Future Development)

## Executive Summary

This proposal outlines a roadmap for fine-tuning a custom Gemini model specialised for Caribbean dietary analysis. The goal is to transition from the current prompt-engineering + RAG approach to a permanently trained model that natively understands regional foods, portion sizes, and diabetic nutritional requirements, eliminating the need for context injection at runtime.

---

## Problem Statement

The current Gemini 2.5 Flash model is a general-purpose LLM. While our RAG system supplements it with local food data, it still:
- Occasionally misidentifies Caribbean dishes (e.g., confusing doubles with tacos).
- Lacks nuanced understanding of local portion conventions (e.g., a "plate" of rice and peas in Trinidad vs. a US serving size).
- Cannot natively produce GI/GL values calibrated to Caribbean food preparation methods (e.g., fried vs. boiled plantain).

A fine-tuned model would internalise this knowledge permanently.

---

## Phase 1: Data Collection (Estimated: 4-6 weeks)

### 1.1 Dataset Requirements
- **Minimum 500 labeled examples** (target: 1,000+)
- Each example = a food image paired with a verified JSON nutritional analysis

### 1.2 Data Sources
| Source | Description | Est. Samples |
|---|---|---|
| User-submitted scans | Collect from DiaMetrics beta users (with consent) | 200-400 |
| Caribbean recipe databases | CARICOM nutritional guides, UWI Food Science data | 200-300 |
| Manual photography | Team photographs common local meals | 100-200 |
| Synthetic augmentation | Rotate, crop, and relight existing images | 200-300 |

### 1.3 Label Format
Each training example must follow this exact JSON schema:
```json
{
  "image": "path/to/food_image.jpg",
  "analysis": {
    "food_name": "Doubles",
    "portion_size": "1 serving (2 bara + channa)",
    "estimated_calories": 280,
    "estimated_carbs_grams": 42,
    "estimated_protein_grams": 8,
    "estimated_fat_grams": 10,
    "estimated_fiber_grams": 4,
    "glycemic_index": 62,
    "glycemic_load": 26,
    "diabetic_suitability": "Moderate - high GI, consume with protein",
    "confidence": 0.95
  }
}
```

### 1.4 Data Validation
- All nutritional values must be verified by at least one of:
  - A registered dietitian
  - Published CARICOM/USDA nutritional reference
  - Cross-referenced against 2+ reliable databases

---

## Phase 2: Fine-Tuning (Estimated: 1-2 weeks)

### 2.1 Platform
- **Google Vertex AI** (required for Gemini fine-tuning)
- Requires a Google Cloud billing account

### 2.2 Estimated Costs
| Item | Cost |
|---|---|
| Vertex AI fine-tuning (per run) | $10-50 (depends on dataset size) |
| Fine-tuned model hosting | ~$0.002/1K input tokens, ~$0.008/1K output tokens |
| Cloud storage for dataset | < $1/month |
| **Total initial cost** | **~$50-100** |
| **Monthly operational cost** | **~$5-20** (depends on usage) |

### 2.3 Training Configuration
```yaml
base_model: gemini-2.5-flash
training_method: supervised_fine_tuning
epochs: 3-5
learning_rate: auto
evaluation_split: 0.2  # 20% held out for validation
```

### 2.4 Success Criteria
| Metric | Target |
|---|---|
| Food identification accuracy | > 90% on Caribbean dishes |
| Nutritional estimate error | < 15% deviation from reference values |
| GI classification accuracy | > 85% (Low/Medium/High) |
| Latency | < 3 seconds per analysis |

---

## Phase 3: Integration (Estimated: 1 week)

### 3.1 Code Changes
- Update `food_analyzer.dart` to point to the fine-tuned model endpoint
- Simplify the system prompt (the model now "knows" Caribbean foods natively)
- Maintain RAG as a fallback for foods outside the training set
- Keep the local cache layer for offline support

### 3.2 A/B Testing
- Run both the base Gemini model (with RAG) and the fine-tuned model in parallel
- Compare accuracy on 50 test images
- Switch to the fine-tuned model only if it outperforms the RAG approach

---

## Phase 4: Continuous Improvement

### 4.1 Feedback Loop
1. Users flag incorrect analyses via a "Report" button in the app
2. Flagged items are reviewed and added to the training dataset
3. The model is re-fine-tuned quarterly with the expanded dataset

### 4.2 Scaling Milestones
| Users | Action |
|---|---|
| 1-50 | Free tier + RAG (current) |
| 50-500 | Fine-tuned model on Vertex AI Pay-as-you-go |
| 500-5,000 | Dedicated endpoint with auto-scaling |
| 5,000+ | Evaluate self-hosted open-source alternative (e.g., Llama-based) |

---

## Risk Assessment

| Risk | Impact | Mitigation |
|---|---|---|
| Insufficient training data | Low accuracy | Start with RAG, collect data organically from beta users |
| High API costs at scale | Budget overrun | Aggressive local caching, rate limiting per user |
| Model hallucination | Dangerous dietary advice | Always display confidence scores, add medical disclaimer |
| Google API changes | Breaking changes | Abstract API layer (already done in `food_analyzer.dart`) |

---

## Recommendation

**Do not pursue fine-tuning until the app has 50+ active users generating real food scan data.** The current RAG approach is sufficient for the university project and initial deployment. Fine-tuning should be triggered when:
1. The training dataset reaches 500+ verified examples
2. User feedback indicates consistent misidentification of local foods
3. There is budget allocated for ongoing Vertex AI costs (~$20/month)

The RAG system being implemented now serves as both the immediate solution AND the data collection pipeline for future fine-tuning.
