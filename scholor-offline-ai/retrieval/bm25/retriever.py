import sqlite3
import json
import time
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

class TextbookRetriever:
    def __init__(self, db_path):
        self.db_path = db_path
        self.vectorizer = TfidfVectorizer(stop_words='english', max_features=10000)
        self.corpus = []
        self.metadata = []
        self.tfidf_matrix = None
        self._load_corpus()
        
    def _load_corpus(self):
        print(f"Loading textbook corpus from {self.db_path}...")
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute("SELECT id, book_id, chapter, content FROM paragraphs WHERE length(content) > 30")
        rows = cursor.fetchall()
        
        for row in rows:
            self.corpus.append(row['content'])
            self.metadata.append({
                'id': row['id'],
                'book_id': row['book_id'],
                'chapter': row['chapter']
            })
            
        print(f"Building TF-IDF matrix for {len(self.corpus)} paragraphs...")
        t0 = time.time()
        self.tfidf_matrix = self.vectorizer.fit_transform(self.corpus)
        t1 = time.time()
        print(f"Matrix built in {t1-t0:.3f}s. Shape: {self.tfidf_matrix.shape}")
        
    def search(self, query, top_k=3):
        query_vec = self.vectorizer.transform([query])
        similarities = cosine_similarity(query_vec, self.tfidf_matrix).flatten()
        
        # Get top K indices
        top_indices = similarities.argsort()[-top_k:][::-1]
        
        results = []
        for idx in top_indices:
            score = similarities[idx]
            if score > 0.05: # Minimum confidence threshold
                results.append({
                    'score': score,
                    'content': self.corpus[idx],
                    'metadata': self.metadata[idx]
                })
        return results

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Test Textbook Retrieval")
    parser.add_argument("--db_path", type=str, required=True, help="Path to SQLite database")
    parser.add_argument("--query", type=str, required=True, help="Search query")
    args = parser.parse_args()
    
    retriever = TextbookRetriever(args.db_path)
    print(f"\nQuery: '{args.query}'\n")
    
    t0 = time.time()
    results = retriever.search(args.query)
    t1 = time.time()
    
    print(f"Retrieval took {((t1-t0)*1000):.1f}ms\n")
    
    if not results:
        print("I couldn't find enough information about this in your Scholor textbooks.")
    else:
        for i, res in enumerate(results):
            print(f"--- Result {i+1} (Score: {res['score']:.3f}) ---")
            print(f"Book: {res['metadata']['book_id']} | Chapter: {res['metadata']['chapter']}")
            print(f"Content: {res['content']}\n")
