import os
import sqlite3
import ebooklib
from ebooklib import epub
from bs4 import BeautifulSoup

def init_db(db_path):
    os.makedirs(os.path.dirname(db_path), exist_ok=True)
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS books (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            class_name TEXT,
            term TEXT,
            title TEXT,
            file_name TEXT
        )
    ''')
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS chapters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id INTEGER,
            title TEXT,
            content TEXT,
            chapter_order INTEGER,
            FOREIGN KEY(book_id) REFERENCES books(id)
        )
    ''')
    conn.commit()
    return conn

from markdownify import markdownify as md

def get_toc_mapping(toc, mapping=None):
    if mapping is None:
        mapping = {}
    for item in toc:
        if isinstance(item, tuple) or isinstance(item, list):
            # A section contains a tuple (Section, [subitems])
            if len(item) == 2 and isinstance(item[0], ebooklib.epub.Section):
                section, sub_toc = item
                mapping[section.href.split('#')[0]] = section.title
                get_toc_mapping(sub_toc, mapping)
        elif isinstance(item, ebooklib.epub.Link):
            mapping[item.href.split('#')[0]] = item.title
    return mapping

def parse_epub(epub_path):
    print(f"Parsing: {epub_path}")
    book = epub.read_epub(epub_path)
    chapters = []
    
    # Extract real titles from the Table of Contents
    toc_mapping = get_toc_mapping(book.toc)
    
    spine_ids = [item[0] for item in book.spine]
    order = 0
    
    for item_id in spine_ids:
        item = book.get_item_with_id(item_id)
        if item is not None and item.get_type() == ebooklib.ITEM_DOCUMENT:
            file_name = item.get_name()
            
            # Check if this file is in the TOC
            if file_name in toc_mapping:
                chapter_title = toc_mapping[file_name]
                html_content = item.get_content().decode('utf-8')
                
                # Convert HTML to Markdown
                markdown_text = md(html_content, heading_style="ATX").strip()
                
                # Only add if there is substantial content
                if len(markdown_text) > 20:
                    chapters.append({
                        'title': chapter_title.strip(),
                        'content': markdown_text,
                        'order': order
                    })
                    order += 1
                
    return chapters

def main():
    base_dir = r"d:\NFS Projects\Scholor\Scholor AI\Books"
    db_path = r"d:\NFS Projects\Scholor\Scholor AI\assets\books.db"
    
    conn = init_db(db_path)
    cursor = conn.cursor()
    
    # Walk through the directory structure: Books / Class X / Term Y / book.epub
    for class_name in os.listdir(base_dir):
        class_path = os.path.join(base_dir, class_name)
        if not os.path.isdir(class_path): continue
        
        for term_name in os.listdir(class_path):
            term_path = os.path.join(class_path, term_name)
            if not os.path.isdir(term_path): continue
            
            for file_name in os.listdir(term_path):
                if file_name.endswith('.epub'):
                    file_path = os.path.join(term_path, file_name)
                    
                    # Insert book record
                    cursor.execute('''
                        INSERT INTO books (class_name, term, title, file_name)
                        VALUES (?, ?, ?, ?)
                    ''', (class_name, term_name, file_name.replace('.epub', ''), file_name))
                    book_id = cursor.lastrowid
                    
                    # Parse chapters
                    try:
                        chapters = parse_epub(file_path)
                        for ch in chapters:
                            cursor.execute('''
                                INSERT INTO chapters (book_id, title, content, chapter_order)
                                VALUES (?, ?, ?, ?)
                            ''', (book_id, ch['title'], ch['content'], ch['order']))
                    except Exception as e:
                        print(f"Failed to parse {file_name}: {e}")
                    
    conn.commit()
    conn.close()
    print("Database generation complete!")

if __name__ == "__main__":
    main()
