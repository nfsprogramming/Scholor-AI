# Scholor Offline AI - Model Strategy & Benchmarks

## Current Baseline Constraint
The current maximum threshold for the model size has been explicitly set to **78 MB** to strictly fit the complete Android application under the 100 MB budget.

## Evaluated Foundation Model
Based on the parameter and size constraints, we are evaluating:
- **Base Architecture**: `roneneldan/TinyStories-33M`
- **Parameters**: 33 Million
- **Raw FP32 Size**: ~130 MB
- **Quantized INT8/ONNX Size**: **78.22 MB**

> [!WARNING]
> We will NOT use massive foundational models (e.g., LLaMA-8B or TinyLlama-1.1B). They completely violate the 100 MB storage and 512 MB RAM strict budgets.

## Local Inference Runtimes Evaluated
- ONNX Runtime Mobile (Selected for Android)
- llama.cpp (GGUF) (Alternative)

## Projected Quality Trade-offs
If the 78.22 MB model pushes the 144-book application over 100 MB, we will quantize to **INT4**, dropping the model to ~20 MB. We will closely monitor **Tamil Quality** and **Response Accuracy** to ensure educational integrity is not severely degraded by INT4 quantization.
