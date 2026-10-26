import os
import json
import torch
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    TrainingArguments,
    Trainer,
    DataCollatorForLanguageModeling
)
from datasets import Dataset

def load_jsonl(filepath):
    data = []
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            data.append(json.loads(line))
    return data

def format_prompt(example):
    # Format the prompt using the standard Alpaca/Instruction format
    return f"Below is an instruction that describes a task, paired with context from a textbook. Write a response that appropriately completes the request.\n\n### Instruction:\n{example['instruction']}\n\n### Context:\n{example['context']}\n\n### Response:\n{example['response']}"

def train(dataset_path, output_dir, model_name="roneneldan/TinyStories-33M"):
    print(f"Loading dataset from {dataset_path}...")
    raw_data = load_jsonl(dataset_path)
    
    # Optional: limit dataset size for quick prototyping
    formatted_data = [{"text": format_prompt(item)} for item in raw_data]
    dataset = Dataset.from_list(formatted_data)
    
    print(f"Loading Tokenizer: {model_name}")
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    # TinyStories model might not have a pad_token set by default
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
    
    def tokenize_function(examples):
        return tokenizer(examples["text"], padding="max_length", truncation=True, max_length=256)
        
    print("Tokenizing dataset...")
    tokenized_dataset = dataset.map(tokenize_function, batched=True)
    
    # Check for GPU
    device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"Training on device: {device}")
    if device == "cuda":
        print(f"GPU: {torch.cuda.get_device_name(0)}")
        
    print(f"Loading Model: {model_name}")
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        device_map="auto" if device == "cuda" else None
    )
    
    training_args = TrainingArguments(
        output_dir=output_dir,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=4,
        num_train_epochs=1,
        learning_rate=2e-5,
        logging_steps=10,
        save_strategy="epoch",
        fp16=False, # Disabled FP16 to fix the unscale_grads error
        optim="adamw_torch"
    )
    
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=tokenized_dataset,
        data_collator=DataCollatorForLanguageModeling(tokenizer, mlm=False)
    )
    
    print("Starting Training...")
    trainer.train()
    
    print(f"Saving final model to {output_dir}/final")
    model.save_pretrained(os.path.join(output_dir, "final"))
    tokenizer.save_pretrained(os.path.join(output_dir, "final"))
    print("Training complete!")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Fine-tune a tiny LLM for Scholor")
    parser.add_argument("--dataset_path", type=str, required=True, help="Path to train.jsonl")
    parser.add_argument("--output_dir", type=str, required=True, help="Directory to save model weights")
    parser.add_argument("--model_name", type=str, default="roneneldan/TinyStories-33M", help="Base model")
    args = parser.parse_args()
    
    train(args.dataset_path, args.output_dir, args.model_name)
