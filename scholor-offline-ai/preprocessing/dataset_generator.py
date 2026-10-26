import os
import sqlite3
import json
import random
from tqdm import tqdm

def get_db_connection(db_path):
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn

def generate_dataset(db_path, output_dir):
    conn = get_db_connection(db_path)
    cursor = conn.cursor()
    
    # We will generate a basic heuristic dataset to demonstrate the pipeline
    cursor.execute("SELECT * FROM paragraphs WHERE length(content) > 50")
    rows = cursor.fetchall()
    
    qa_data = []
    explanation_data = []
    summary_data = []
    definition_data = []
    quiz_data = []
    
    print(f"Generating synthetic dataset from {len(rows)} paragraphs...")
    
    for row in tqdm(rows):
        content = row['content']
        chapter = row['chapter']
        
        # 1. Summary
        if len(content.split()) > 40:
            summary_data.append({
                "instruction": f"Summarize the key points about this topic from {chapter}.",
                "context": content,
                "response": "Here is a brief summary: " + " ".join(content.split()[:20]) + "..."
            })
            
        # 2. Explanation
        explanation_data.append({
            "instruction": "Explain this concept simply.",
            "context": content,
            "response": f"Based on the text, {content}"
        })
        
        # 3. QA
        sentences = content.split('.')
        for sentence in sentences:
            sentence = sentence.strip()
            if len(sentence) > 20:
                # Naive question generation
                qa_data.append({
                    "instruction": f"What does the text say about this topic?",
                    "context": content,
                    "response": sentence + "."
                })
                break
                
        # 4. Definition
        if " is " in content or " defined as " in content or " known as " in content:
            definition_data.append({
                "instruction": "Provide a definition based on the text.",
                "context": content,
                "response": content
            })
            
        # 5. Quiz
        if len(sentences) >= 2:
            quiz_data.append({
                "instruction": "Create a multiple-choice question from this text.",
                "context": content,
                "response": {
                    "question": f"According to the text, which is true?",
                    "options": [sentences[0][:30] + "...", "None of the above", "All of the above", "Incorrect option"],
                    "answer": sentences[0][:30] + "..."
                }
            })
            
    conn.close()
    
    # Save the datasets
    os.makedirs(os.path.join(output_dir, 'qa'), exist_ok=True)
    os.makedirs(os.path.join(output_dir, 'explanation'), exist_ok=True)
    os.makedirs(os.path.join(output_dir, 'summary'), exist_ok=True)
    os.makedirs(os.path.join(output_dir, 'definitions'), exist_ok=True)
    os.makedirs(os.path.join(output_dir, 'quiz'), exist_ok=True)
    os.makedirs(os.path.join(output_dir, 'final'), exist_ok=True)
    
    datasets = {
        'qa': qa_data,
        'explanation': explanation_data,
        'summary': summary_data,
        'definitions': definition_data,
        'quiz': quiz_data
    }
    
    total_examples = 0
    final_dataset = []
    
    for name, data in datasets.items():
        if data:
            filepath = os.path.join(output_dir, name, f'{name}_dataset.jsonl')
            with open(filepath, 'w', encoding='utf-8') as f:
                for item in data:
                    f.write(json.dumps(item) + '\n')
            final_dataset.extend(data)
            total_examples += len(data)
            
    random.shuffle(final_dataset)
    final_filepath = os.path.join(output_dir, 'final', 'train.jsonl')
    with open(final_filepath, 'w', encoding='utf-8') as f:
        for item in final_dataset:
            f.write(json.dumps(item) + '\n')
            
    dataset_size = os.path.getsize(final_filepath) / (1024 * 1024)
            
    print(f"\nGenerated {total_examples} training examples.")
    print(f"Final Dataset Size: {dataset_size:.2f} MB")
    
    # Generate DATASET.md
    docs_dir = os.path.join(os.path.dirname(os.path.dirname(output_dir)), 'docs')
    os.makedirs(docs_dir, exist_ok=True)
    docs_path = os.path.join(docs_dir, 'DATASET.md')
    
    with open(docs_path, 'w', encoding='utf-8') as f:
        f.write(f"""# Training Dataset Report

## Overview
This report summarizes the textbook-derived training dataset generated for the tiny language model.

## Dataset Metrics
- **Total Training Examples:** {total_examples}
  - **QA:** {len(qa_data)}
  - **Explanation:** {len(explanation_data)}
  - **Summary:** {len(summary_data)}
  - **Definition:** {len(definition_data)}
  - **Quiz:** {len(quiz_data)}

## Size Metrics
- **Final Dataset Size (train.jsonl):** {dataset_size:.2f} MB

## Formatting
All examples are formatted as instruction-context-response tuples to train the model to answer queries using retrieved textbook context.
""")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Generate Training Dataset from SQLite Database")
    parser.add_argument("--db_path", type=str, required=True, help="Path to SQLite database")
    parser.add_argument("--output_dir", type=str, required=True, help="Path to output dataset directory")
    args = parser.parse_args()
    
    generate_dataset(args.db_path, args.output_dir)
