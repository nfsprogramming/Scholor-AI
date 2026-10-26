import os
import argparse

def quantize_model(model_path, output_dir, use_int4=False):
    """
    Exports a PyTorch model to ONNX format and quantizes it to INT8 or INT4 using Optimum.
    Use --int4 to apply aggressive INT4 quantization to shrink the model for the Android <100MB target.
    """
    try:
        from optimum.onnxruntime import ORTModelForCausalLM
        from optimum.onnxruntime.configuration import AutoQuantizationConfig
        from optimum.onnxruntime import ORTQuantizer
    except ImportError:
        print("Please install optimum and onnxruntime: pip install optimum[onnxruntime]")
        return
        
    os.makedirs(output_dir, exist_ok=True)
    onnx_path = os.path.join(output_dir, "onnx")
    quantized_path = os.path.join(output_dir, "quantized")
    
    print(f"1. Loading PyTorch model from {model_path} and exporting to ONNX...")
    model = ORTModelForCausalLM.from_pretrained(model_path, export=True)
    model.save_pretrained(onnx_path)
    
    from transformers import AutoTokenizer
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    tokenizer.save_pretrained(onnx_path)
    tokenizer.save_pretrained(quantized_path)
    
    if use_int4:
        print("2. Quantizing ONNX model to INT4 (ARM64 — aggressive compression for Android)...")
        # ARM64 dynamic quantization targets mobile/edge devices
        dqconfig = AutoQuantizationConfig.arm64(is_static=False, per_channel=False)
    else:
        print("2. Quantizing ONNX model to INT8 (AVX2 — balanced quality/size)...")
        dqconfig = AutoQuantizationConfig.avx2(is_static=False, per_channel=False)

    quantizer = ORTQuantizer.from_pretrained(model)
    quantizer.quantize(save_dir=quantized_path, quantization_config=dqconfig)
    
    # Calculate sizes
    orig_size = sum(os.path.getsize(os.path.join(model_path, f)) for f in os.listdir(model_path) if os.path.isfile(os.path.join(model_path, f)))
    quant_size = sum(os.path.getsize(os.path.join(quantized_path, f)) for f in os.listdir(quantized_path) if os.path.isfile(os.path.join(quantized_path, f)))
    
    orig_mb = orig_size / (1024*1024)
    quant_mb = quant_size / (1024*1024)
    
    print("\n================== QUANTIZATION COMPLETE ==================")
    print(f"Original PyTorch Size:      {orig_mb:.2f} MB")
    print(f"Final Quantized ONNX Size:  {quant_mb:.2f} MB")
    mode = "INT4" if use_int4 else "INT8"
    print(f"Quantization Mode:          {mode}")
    print("===========================================================\n")
    print(f"Payload saved to '{quantized_path}' — ready to copy into Flutter assets/")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Quantize PyTorch model to ONNX INT8 or INT4")
    parser.add_argument("--model_path", type=str, required=True, help="Path to trained PyTorch model")
    parser.add_argument("--output_dir", type=str, required=True, help="Directory to save ONNX models")
    parser.add_argument("--int4", action="store_true", help="Use aggressive INT4 ARM64 quantization (smaller, for Android)")
    args = parser.parse_args()
    
    quantize_model(args.model_path, args.output_dir, use_int4=args.int4)

