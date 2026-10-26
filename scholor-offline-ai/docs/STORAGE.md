# Scholor Offline AI - Storage Budget Report

## 1. SOURCE STORAGE (Not deployed to Android)

| Resource | ACTUAL (12 Books) | ESTIMATED (144 Books) |
|----------|-------------------|----------------------|
| **Raw EPUB Files** | 288 MB | ~3.45 GB |
| **Extracted HTML** | ~25 MB | ~300 MB |
| **Raw Clean Text** | 321 KB | ~3.85 MB |

> [!IMPORTANT]
> The source data will NEVER be deployed into the Android application. It is strictly used in the Python pipeline to build the deployment artifacts.

## 2. DEPLOYMENT STORAGE (Android APK Payload)

Our strict target application size is **<100 MB**. 
The current AI baseline model size constraint is **78 MB**. 

| Component | ACTUAL (33M Model) | ESTIMATED (144 Books) |
|-----------|--------------------|----------------------|
| **SQLite Database** | 1.22 MB | ~14.6 MB |
| **Quantized Model (INT8/4)** | 78.22 MB | 78.22 MB |
| **Tokenizer** | ~2.1 MB | ~2.1 MB |
| **ONNX Runtime Engine** | ~4.5 MB | ~4.5 MB |
| **Flutter App Code & Assets**| ~12.0 MB | ~12.0 MB |
| **Total Projected APK Size** | **~98 MB** | **~111 MB** |

> [!TIP]
> **Resolution for scale:** As the database scales to 144 books, it may add ~13 MB. If the total APK exceeds 100 MB, we will utilize deeper INT4 quantization on the model or gzip the SQLite database at rest to remain under the 100 MB strict threshold.
