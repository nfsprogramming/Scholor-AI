# Scholor Offline AI - Training Dataset Report

## Generation Strategy
The dataset is exclusively sourced from the local Scholor SQLite textbook database. No external APIs or pre-existing instruct datasets (OpenWebText, etc.) are utilized.

## Final Dataset Statistics

| Task Type | ACTUAL (12 Books) | ESTIMATED (144 Books) |
|-----------|------------------|----------------------|
| **QA** | 1,142 examples | ~13,700 examples |
| **Explanation** | 1,142 examples | ~13,700 examples |
| **Summary** | 473 examples | ~5,600 examples |
| **Definitions** | 208 examples | ~2,500 examples |
| **Quiz (MCQ)** | 424 examples | ~5,000 examples |
| **Total** | **3,389 examples** | **~40,500 examples** |

## Storage Footprint
- **Current JSONL Size**: 1.59 MB
- **Estimated 144-Book Size**: ~19 MB

This dataset is used strictly for PyTorch LoRA fine-tuning in Phase 5 and is not bundled with the mobile application.
