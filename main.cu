#include "src/new_boruvka.cu"
#include "src/common/parseCommandLine.h"
#include <omp.h>

int main(int argc, char* argv[]){
  commandLine P(argc, argv,
    "--filename <input_file> --result-file <output_file> [options]\n"
    "GPU Streams MST - GPU-only stream processing version\n"
    "Options:\n"
    "  --cpu-only                      Use CPU-only processing instead of GPU\n"
    "  --generate-random-weights       Generate random weights for edges\n"
    "  --save-weighted-graph          Save the weighted graph\n"
    "  --num-chunks-ideal <num>       Number of ideal chunks (default: 4)");

  // Required arguments
  std::string filename = P.getOptionValue("--filename", "");
  std::string result_file = P.getOptionValue("--result-file", "");
  
  if (filename.empty() || result_file.empty()) {
    std::cout << "Error: --filename and --result-file are required arguments" << std::endl;
    P.badArgument();
  }

  // Optional arguments with defaults optimized for GPU streams
  bool cpu_only = P.getOption("--cpu-only");
  bool generate_random_weights = P.getOption("--generate-random-weights");
  bool save_weighted_graph = P.getOption("--save-weighted-graph");
  
  vertex chunk_size = 100;//
  int num_chunks_ideal = P.getOptionIntValue("--num-chunks-ideal", 4);

  // GPU streams only configuration
  bool use_malloc_managed = false;      // Not using unified memory
  bool use_streamline = true;           
  if(cpu_only){
    use_streamline = false;
  }
  bool use_cpu_only = cpu_only;         // Use CPU-only based on command line flag
  bool cpu_gpu_streamline = false;      // Not using hybrid CPU-GPU

  std::cout << "Running GPU Streams MST with:" << std::endl;
  std::cout << "  Input file: " << filename << std::endl;
  std::cout << "  Output file: " << result_file << std::endl;
  std::cout << "  Number of chunks: " << num_chunks_ideal << std::endl;
  std::cout << "  Generate random weights: " << (generate_random_weights ? "Yes" : "No") << std::endl;
  std::cout << "  Processing mode: " << (cpu_only ? "CPU Only" : "GPU Streams Only") << std::endl;

  new_boruvka(filename, result_file, cpu_only, chunk_size, num_chunks_ideal,
              generate_random_weights, use_malloc_managed, use_streamline, 
              use_cpu_only, cpu_gpu_streamline, save_weighted_graph);
              
  std::cout << "GPU Streams MST computation completed!" << std::endl;
  return 0;
} 
