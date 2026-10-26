import sys
import os
import time

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from android.inference.rag_pipeline import RAGPipeline

def run_evaluation(db_path, model_path):
    print("Initializing Evaluation Suite...")
    try:
        pipeline = RAGPipeline(db_path, model_path)
    except Exception as e:
        print(f"Failed to load RAG pipeline: {e}")
        return

    test_queries = [
        "What is photosynthesis?",
        "Explain the water cycle.",
        "How do plants breathe?",
        "Tamil Nadu history overview.",
        "Who is the poet of Thirukkural?"
    ]
    
    print("\n--- Running Inference Benchmarks ---")
    total_latency = 0
    
    for idx, query in enumerate(test_queries):
        print(f"\nEvaluating Query {idx+1}: '{query}'")
        start_time = time.time()
        
        # Simulate retrieval & inference
        response = pipeline.generate_answer(query)
        
        end_time = time.time()
        latency = end_time - start_time
        total_latency += latency
        
        print(f"Latency: {latency:.2f}s")
        print(f"Response Snippet: {response[:100]}...")
        
    avg_latency = total_latency / len(test_queries)
    print(f"\n--- Evaluation Complete ---")
    print(f"Average Pipeline Latency (PC): {avg_latency:.2f}s")
    print("Please record these metrics in docs/BENCHMARKS.md!")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Evaluate RAG Pipeline Quality")
    parser.add_argument("--db_path", type=str, required=True, help="Path to SQLite database")
    parser.add_argument("--model_path", type=str, required=True, help="Path to trained model")
    args = parser.parse_args()
    
    run_evaluation(args.db_path, args.model_path)
