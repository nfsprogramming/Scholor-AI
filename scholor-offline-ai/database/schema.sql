CREATE TABLE IF NOT EXISTS books (
    id TEXT PRIMARY KEY,
    class TEXT,
    subject TEXT,
    medium TEXT
);

CREATE TABLE IF NOT EXISTS paragraphs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id TEXT,
    class TEXT,
    subject TEXT,
    medium TEXT,
    chapter TEXT,
    section TEXT,
    page_or_location TEXT,
    content TEXT
);

CREATE INDEX IF NOT EXISTS idx_paragraphs_book_id ON paragraphs(book_id);
CREATE INDEX IF NOT EXISTS idx_paragraphs_class ON paragraphs(class);
CREATE INDEX IF NOT EXISTS idx_paragraphs_subject ON paragraphs(subject);
