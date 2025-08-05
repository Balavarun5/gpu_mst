# GPU Streams MST

A GPU-accelerated implementation of Minimum Spanning Tree using CUDA streams for efficient parallel processing.

## Overview

This implementation addresses GPU memory limitations by processing graphs in chunks using CUDA streams. When graphs exceed available GPU memory, the mst can be computed by splitting the graph into smaller chunks that fit within memory constraints. CUDA streams enable overlapping of data transfers (CPU ↔ GPU) with kernel execution, allowing computation on one chunk while simultaneously transferring data for subsequent chunks. This streaming approach maximizes GPU utilization and enables processing of arbitrarily large graphs without running out of memory. Standalone gpu version of PHEM work to be published in icpp grand. Work inspired by multicore version [Zhou]([url](https://ae.iti.kit.edu/documents/theses/msThesisZhou.pdf)) which I wrote in cuda. Wanted to check out the performance of cuda atomics in newer machines and was performing decently. Code can run for very large graphs too(assuming vertex set can fit onto device). Ran till Agatha and moliere graphs on DGX, work could be extended for multi-gpu scenarios too. 

Work to appear in ICPP-2025, Grand

## Usage

```bash
nvcc ../main.cu -arch=sm_75 -Xcompiler -fopenmp -std=c++17 -extended-lambda -lcudart -o mst
CUDA_MODULE_LOADING=EAGER ./mst --filename <input_file> --result-file <output_file> [options]
```

## Input Parameters

### Required
- `--filename <input_file>`: Path to the input graph file
- `--result-file <output_file>`: Path to save the MST results

### Optional
- `--cpu-only`: Force CPU-only processing (for verification)
- `--generate-random-weights`: Generate random weights for edges
- `--save-weighted-graph`: Save the weighted graph to file
- `--num-chunks-ideal <num>`: Number of processing chunks (default: 4)

## Output

The program outputs:
- Processing configuration details
- Input/output file paths
- Number of chunks and processing mode
- Completion status message
- MST results written to the specified result file

## Verification

To verify GPU results against CPU implementation:

1. **Run GPU Streams version:**
   Compute mst by calculating chunk by chunk and iteratively finding the final msf. Data transfer streams overlap with kernel execution streams.
   ```bash
   CUDA_MODULE_LOADING=EAGER ./mst --filename input.mtx --result-file gpu_result.txt
   ```
3. **Run GPU single chunk (monolithic) version:**
   Compute mst by transferring entire edgelist to device and compute and transfer back
   ```bash
   ./mst --filename input.mtx --result-file cpu_result.txt --gpu-monolithic
   ```

4. **Run CPU verification:**
   Run the PBBS suite mst implementation
   ```bash
   ./mst --filename input.mtx --result-file cpu_result.txt --cpu-only
   ```

5. **Compare results:**
   ```bash
   sort gpu_result.txt > sorted_gpu.txt
   sort cpu_result.txt > sorted_cpu.txt
   diff sorted_cpu.txt sorted_gpu.txt
   ```
   NB: This would only work if there is a unique MST/MSF. Otherwise, a weight comparison and node coverage method would be required.

The MST weights should be identical between GPU and CPU implementations.

## Data
The data required is in a .mtx format, no need for any binary conversion etc. For example to calculate for [cnr-2000]([url](https://sparse.tamu.edu/LAW/cnr-2000)). Download the .mtx file and run 
```bash
CUDA_MODULE_LOADING=EAGER ./mst --filename cnr-2000.mtx --result-file gpu_result.txt --generate-random-weights   #For streams approach
./mst --filename cnr-2000.mtx --result-file gpu_result_monolithic.txt --generate-random-weights --gpu-monolithic #For single chunk(monolithic) approach
./mst --filename cnr-2000.mtx --result-file gpu_result.txt --generate-random-weights --cpu-only                  #For pbbs cpu approach
```
## Performance

- Default configuration optimized for GPU streams processing
- Uses CUDA streams for overlapping computation and memory transfers
- Chunk-based processing for handling large graphs efficiently 
