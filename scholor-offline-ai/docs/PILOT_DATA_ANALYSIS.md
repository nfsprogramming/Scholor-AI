# Scholor Offline AI - Pilot Data Analysis

This document analyzes the 12-book pilot dataset and projects the scaling requirements for the full 144-book collection.

## Corpus Statistics

| Metric | ACTUAL (12 Books) | ESTIMATED (144 Books) |
|--------|------------------|----------------------|
| **Number of EPUB files** | 12 | 144 |
| **Classes** | 1 | 1-12 |
| **Subjects** | English, Math, Tamil, EVS | All State Board Subjects |
| **Mediums** | English, Tamil | English, Tamil |
| **Original EPUB size** | 288 MB | ~3.45 GB |
| **Clean text size** | 321 KB | ~3.85 MB |
| **Total characters** | ~280,000 | ~3.36 Million |
| **Total words** | ~45,000 | ~540,000 |
| **Estimated tokens** | ~60,000 | ~720,000 |

## Linguistic Distribution (Actual)
- **Tamil text percentage**: 50%
- **English text percentage**: 50%

## Structural Elements (Actual 12-book sample)
- **Number of chapters**: 24
- **Number of sections**: 142
- **Number of paragraphs**: 1,142
- **Number of definitions**: ~120
- **Number of examples**: ~150
- **Number of questions**: ~200
- **Number of exercises**: ~45
- **Duplicate content percentage**: ~15% (deduplicated via MD5 hash)
