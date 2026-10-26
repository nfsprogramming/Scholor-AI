import os
import sys
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

# Add retrieval module path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))
from retrieval.bm25.retriever import TextbookRetriever

class RAGPipeline:
    def __init__(self, db_path, model_path):
        print("Initializing Retrieval Engine...")
        self.retriever = TextbookRetriever(db_path)
        
        print(f"Loading Fine-Tuned Model from {model_path}...")
        self.tokenizer = AutoTokenizer.from_pretrained(model_path)
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.model = AutoModelForCausalLM.from_pretrained(model_path).to(self.device)
        self.model.eval()
        
    def generate_answer(self, query):
        print(f"\n[User Query]: {query}")
        
        # 1. Retrieve Context
        results = self.retriever.search(query, top_k=2)
        if not results:
            return "I couldn't find enough information about this in your Scholor textbooks."
            
        context = "\n".join([res['content'] for res in results])
        
        # 2. Format Prompt (Matches our training dataset format)
        prompt = f"Below is an instruction that describes a task, paired with context from a textbook. Write a response that appropriately completes the request.\n\n### Instruction:\nAnswer the following question based on the context: {query}\n\n### Context:\n{context}\n\n### Response:\n"
        
        # 3. Generate Inference
        inputs = self.tokenizer(prompt, return_tensors="pt").to(self.device)
        
        with torch.no_grad():
            outputs = self.model.generate(
                **inputs,
                max_new_tokens=100,
                temperature=0.7,
                do_sample=True,
                pad_token_id=self.tokenizer.eos_token_id
            )
            
        # Decode only the generated response portion
        input_length = inputs.input_ids.shape[1]
        generated_tokens = outputs[0][input_length:]
        response = self.tokenizer.decode(generated_tokens, skip_special_tokens=True).strip()
        
        return response

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Test RAG Pipeline")
    parser.add_argument("--db_path", type=str, required=True, help="Path to SQLite database")
    parser.add_argument("--model_path", type=str, required=True, help="Path to trained model")
    parser.add_argument("--query", type=str, required=True, help="Question to ask")
    args = parser.parse_args()
    
    pipeline = RAGPipeline(args.db_path, args.model_path)
    answer = pipeline.generate_answer(args.query)
    
    print("\n================== SCHOLOR AI ==================")
    print(answer)
    print("================================================\n")
