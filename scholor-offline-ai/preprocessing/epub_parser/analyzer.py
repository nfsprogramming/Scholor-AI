import os
import sys
import glob
import ebooklib
from ebooklib import epub
from bs4 import BeautifulSoup
import tiktoken
import hashlib
from tqdm import tqdm

def analyze_epubs(base_dir, output_dir):
    print(f"Starting analysis of directory: {base_dir}")
    
    total_epubs = 0
    total_original_size = 0
    total_html_size = 0
    total_clean_size = 0
    total_tokens = 0
    
    unique_hashes = set()
    total_paragraphs = 0
    
    books = set()
    classes = set()
    subjects = set()
    
    enc = tiktoken.get_encoding("cl100k_base")
    
    epub_files = glob.glob(os.path.join(base_dir, "**/*.epub"), recursive=True)
    total_epubs = len(epub_files)
    print(f"Found {total_epubs} EPUB files.")
    
    for filepath in tqdm(epub_files, desc="Processing EPUBs"):
        file_size = os.path.getsize(filepath)
        total_original_size += file_size
        
        # Simple extraction of class/subject from path for estimation
        parts = filepath.split(os.sep)
        # Assumes structure like .../Books/Class 1/...
        for part in parts:
            if "Class" in part:
                classes.add(part)
        
        books.add(os.path.basename(filepath))
        
        try:
            book = epub.read_epub(filepath)
        except Exception as e:
            print(f"Error reading {filepath}: {e}")
            continue
            
        for item in book.get_items():
            if item.get_type() == ebooklib.ITEM_DOCUMENT:
                html_content = item.get_content()
                total_html_size += len(html_content)
                
                soup = BeautifulSoup(html_content, 'html.parser')
                
                # Remove scripts and styles
                for element in soup(["script", "style"]):
                    element.decompose()
                    
                text = soup.get_text(separator='\n')
                clean_text = '\n'.join([line.strip() for line in text.splitlines() if line.strip()])
                
                total_clean_size += len(clean_text.encode('utf-8'))
                
                # Tokenize
                tokens = enc.encode(clean_text)
                total_tokens += len(tokens)
                
                # Deduplication check by hashing paragraphs
                paragraphs = clean_text.split('\n')
                for p in paragraphs:
                    if len(p) > 10:  # Only hash substantial paragraphs
                        total_paragraphs += 1
                        p_hash = hashlib.md5(p.encode('utf-8')).hexdigest()
                        unique_hashes.add(p_hash)
                        
    duplicate_percentage = 0
    if total_paragraphs > 0:
        duplicate_percentage = (1 - (len(unique_hashes) / total_paragraphs)) * 100
        
    unique_tokens_estimate = int(total_tokens * (len(unique_hashes) / total_paragraphs)) if total_paragraphs > 0 else 0
    
    # Generate Reports
    os.makedirs(output_dir, exist_ok=True)
    
    data_analysis_path = os.path.join(output_dir, "DATA_ANALYSIS.md")
    with open(data_analysis_path, "w", encoding="utf-8") as f:
        f.write(f"""# Data Analysis Report

## Dataset Metrics
- **Total EPUB files:** {total_epubs}
- **Total books (unique filenames):** {len(books)}
- **Total classes identified:** {len(classes)}

## Size Metrics
- **Original EPUB size:** {total_original_size / (1024**2):.2f} MB
- **Extracted HTML size:** {total_html_size / (1024**2):.2f} MB
- **Clean text size:** {total_clean_size / (1024**2):.2f} MB

## Token Metrics
- **Estimated token count:** {total_tokens:,}
- **Unique token count (estimate):** {unique_tokens_estimate:,}
- **Duplicate content percentage:** {duplicate_percentage:.2f}%
""")

    storage_path = os.path.join(output_dir, "STORAGE.md")
    db_size_estimate = (total_clean_size * 1.5) / (1024**2) # Rough estimate for SQLite overhead
    with open(storage_path, "w", encoding="utf-8") as f:
        f.write(f"""# Storage Report

## Target Budget
- Entire Scholor application: <100 MB

## Estimates based on analysis
- **Clean text size:** {total_clean_size / (1024**2):.2f} MB
- **Estimated SQLite database size (uncompressed):** {db_size_estimate:.2f} MB
- **Training dataset estimate:** {(total_clean_size * 0.8) / (1024**2):.2f} MB

Assuming SQLite compression (e.g. sqlean or simply zip compression for bundle), the DB can be reduced to ~30-40% of its size.
""")

    model_path = os.path.join(output_dir, "MODEL.md")
    with open(model_path, "w", encoding="utf-8") as f:
        f.write(f"""# Model Strategy Report

## Target Parameters
- 30M–80M parameters

## Analysis Implications
With an estimated {total_tokens:,} tokens of textbook knowledge, the knowledge base is substantial.
Retrieval-Augmented Generation (RAG) is essential.

## Expected Sizes (Estimates for 50M parameter model)
- **FP16 size:** ~100 MB
- **INT8 size:** ~50 MB
- **INT4 size:** ~25-30 MB

## Memory Target
- AI RAM Usage: ≤512 MB
- Peak Application RAM: ≤1.5 GB
""")

    print(f"Analysis complete. Reports saved to {output_dir}")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Analyze EPUB collection for Scholor AI")
    parser.add_argument("--books_dir", type=str, required=True, help="Path to Books directory")
    parser.add_argument("--output_dir", type=str, required=True, help="Path to output docs directory")
    args = parser.parse_args()
    
    analyze_epubs(args.books_dir, args.output_dir)
