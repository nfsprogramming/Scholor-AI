import os
import sys
import glob
import sqlite3
import hashlib
import ebooklib
from ebooklib import epub
from bs4 import BeautifulSoup
from tqdm import tqdm

def get_db_connection(db_path):
    conn = sqlite3.connect(db_path)
    return conn

def init_db(conn, schema_path):
    with open(schema_path, 'r', encoding='utf-8') as f:
        schema = f.read()
    conn.executescript(schema)
    conn.commit()

def extract_metadata_from_path(filepath):
    # E.g., Books\Class 1\Subject\BookName.epub
    parts = filepath.split(os.sep)
    class_name = "Unknown Class"
    for p in parts:
        if "Class" in p:
            class_name = p
            break
            
    # Naive extraction for subject based on filename or parent dir
    subject = "General"
    medium = "English" # Defaulting for now
    
    book_id = os.path.basename(filepath).replace(".epub", "").lower().replace(" ", "_")
    return book_id, class_name, subject, medium

def process_epubs(base_dir, db_path, schema_path):
    print(f"Initializing database at {db_path}")
    conn = get_db_connection(db_path)
    init_db(conn, schema_path)
    
    epub_files = glob.glob(os.path.join(base_dir, "**/*.epub"), recursive=True)
    print(f"Found {len(epub_files)} EPUB files to ingest.")
    
    unique_hashes = set()
    
    for filepath in tqdm(epub_files, desc="Ingesting Books"):
        book_id, class_name, subject, medium = extract_metadata_from_path(filepath)
        
        # Insert book
        conn.execute(
            "INSERT OR IGNORE INTO books (id, class, subject, medium) VALUES (?, ?, ?, ?)",
            (book_id, class_name, subject, medium)
        )
        
        try:
            book = epub.read_epub(filepath)
        except Exception as e:
            print(f"Error reading {filepath}: {e}")
            continue
            
        chapter_counter = 1
        
        for item in book.get_items():
            if item.get_type() == ebooklib.ITEM_DOCUMENT:
                html_content = item.get_content()
                soup = BeautifulSoup(html_content, 'html.parser')
                
                # Remove scripts and styles
                for element in soup(["script", "style"]):
                    element.decompose()
                
                # Attempt to find a chapter title in the current document
                chapter_title = f"Chapter {chapter_counter}"
                h1 = soup.find('h1')
                h2 = soup.find('h2')
                if h1 and h1.text.strip():
                    chapter_title = h1.text.strip()
                elif h2 and h2.text.strip():
                    chapter_title = h2.text.strip()
                else:
                    chapter_counter += 1
                
                section_title = "" # Simplified for now
                
                text = soup.get_text(separator='\n')
                paragraphs = [line.strip() for line in text.splitlines() if len(line.strip()) > 20]
                
                for p in paragraphs:
                    # Deduplication
                    p_hash = hashlib.md5(p.encode('utf-8')).hexdigest()
                    if p_hash in unique_hashes:
                        continue
                    unique_hashes.add(p_hash)
                    
                    conn.execute(
                        """
                        INSERT INTO paragraphs 
                        (book_id, class, subject, medium, chapter, section, page_or_location, content) 
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                        (book_id, class_name, subject, medium, chapter_title, section_title, item.get_name(), p)
                    )
        conn.commit()
        
    conn.close()
    
    db_size = os.path.getsize(db_path) / (1024 * 1024)
    print(f"\nDatabase built successfully: {db_path}")
    print(f"Final Database Size: {db_size:.2f} MB")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Build SQLite Database from EPUBs")
    parser.add_argument("--books_dir", type=str, required=True, help="Path to Books directory")
    parser.add_argument("--db_path", type=str, required=True, help="Path to output SQLite database")
    parser.add_argument("--schema_path", type=str, required=True, help="Path to schema.sql")
    args = parser.parse_args()
    
    process_epubs(args.books_dir, args.db_path, args.schema_path)
