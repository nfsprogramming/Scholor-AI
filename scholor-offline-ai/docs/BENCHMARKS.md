# Scholor Offline AI - Hardware Benchmark Report

This document records the official on-device (Android 4 GB RAM) benchmarks for the 12-book pilot implementation.

## 1. Storage Benchmarks

| Component | Target Constraint | Measured Actual |
|-----------|-------------------|-----------------|
| **Total APK Size** | < 100 MB | _[User to fill]_ MB |
| **Model Size** | Baseline 78 MB | 78.22 MB |
| **SQLite DB Size** | Minimize | 1.22 MB |

## 2. Memory (RAM) Benchmarks
_Note: Measured on physical 4GB RAM Android device using Android Studio Profiler._

| Metric | Target Constraint | Measured Actual |
|--------|-------------------|-----------------|
| **Peak AI Subsystem RAM** | ≤ 512 MB | _[User to fill]_ MB |
| **Peak Application RAM** | ≤ 1.5 GB | _[User to fill]_ MB |

## 3. Latency & Inference Benchmarks

| Metric | Measured Actual |
|--------|-----------------|
| **Cold Start (Model Load Time)** | _[User to fill]_ ms |
| **Retrieval Latency (SQLite)** | _[User to fill]_ ms |
| **First Token Latency** | _[User to fill]_ ms |
| **Generation Speed (Tokens/sec)** | _[User to fill]_ tok/s |

## 4. Quality & Hallucination Metrics
_Note: Sourced from `evaluation/benchmark.py` testing against the held-out validation set._

| Metric | Measured Actual |
|--------|-----------------|
| **Question Answering Accuracy** | _[User to fill]_ % |
| **Retrieval Accuracy (Top-K=3)** | _[User to fill]_ % |
| **Hallucination Rate** | _[User to fill]_ % |
| **Tamil Response Quality** | _[User to fill]_ / 10 |
| **English Response Quality** | _[User to fill]_ / 10 |
| **Tanglish Response Quality**| _[User to fill]_ / 10 |
