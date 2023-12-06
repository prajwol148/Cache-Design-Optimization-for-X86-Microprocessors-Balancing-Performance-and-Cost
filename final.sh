#!/bin/bash

# Set constants 
BENCHMARKS=(401.bzip2 429.mcf 456.hmmer 458.sjeng 470.lbm)
BASE_DIR="/mnt/e/OS_Project_main/gem5/build/x86" 
DATA_DIR="$BASE_DIR/data"

# Define config arrays
configs=(
	"32kB 16kB 64kB 4 8 2 32"
	"32kB 16kB 64kB 4 8 2 32"
	"16kB 32kB 64kB 8 4 2 32"
	"64kB 16kB 64kB 2 8 2 32"
	"128kB 16kB 64kB 2 8 2 32"
	"64kB 16kB 64kB 4 8 2 32"
	"32kB 64kB 64kB 4 4 2 32"
	"32kB 64kB 64kB 4 2 2 32"
	"32kB 128kB 64kB 4 2 2 32"
	"64kB 128kB 64kB 4 2 2 32"
	"64kB 64kB 64kB 2 2 2 32"
	"32kB 32kB 32kB 2 2 2 32"
	"128kB 128kB 128kB 8 8 2 32"
	"128kB 128kB 128kB 2 2 2 32"
	"128kB 128kB 128kB 4 4 2 32"
	"64kB 64kB 32kB 4 4 8 32"
	"64kB 64kB 32kB 4 4 4 32"
	"64kB 64kB 64kB 4 4 8 32"
	"64kB 64kB 64kB 4 4 4 32"
	"64kB 64kB 128kB 4 4 8 32"
	"64kB 64kB 256kB 4 4 8 32"
	"64kB 64kB 512kB 4 4 4 32"
	"64kB 64kB 512kB 4 4 8 32"
	"64kB 64kB 1MB 4 4 8 32"
	"64kB 64kB 1MB 4 4 16 32"
	"64kB 64kB 1MB 4 4 2 32"
	"128kB 128kB 1MB 2 2 1 64"
	"16kB 32kB 64kB 8 4 2 64"
	"64kB 16kB 64kB 2 8 2 64"
	"128kB 16kB 64kB 2 8 2 64"
	"64kB 16kB 64kB 4 8 2 64"
	"32kB 64kB 64kB 4 4 2 64"
	"32kB 64kB 64kB 4 2 2 64"
	"32kB 128kB 64kB 4 2 2 64"
	"64kB 128kB 64kB 4 2 2 64"
	"64kB 64kB 64kB 2 2 2 64"
	"32kB 32kB 32kB 2 2 2 64"
	"128kB 128kB 128kB 8 8 2 64"
	"128kB 128kB 128kB 2 2 2 64"
	"128kB 128kB 128kB 4 4 2 64"
	"64kB 64kB 32kB 4 4 8 64"
	"64kB 64kB 32kB 4 4 4 64"
)

# Function to update run script 
function update_run_script() {
  local script_path="$1"
  local benchmark_name="$2"
  local l1_d_cache_size="${CONF[0]}"
  local l1_i_cache_size="${CONF[1]}"
  local l2_cache_size="${CONF[2]}"
  local l1_d_associative="${CONF[3]}"
  local l1_i_associative="${CONF[4]}"
  local l2_associative="${CONF[5]}"
  local block_size="${CONF[6]}"
  
  # Check if the script file exists
  if [ ! -f "$script_path" ]; then
      echo "Script file not found: $script_path"
      return 1
  fi

  # Check if the benchmark is 470.lbm
  if [ "$benchmark_name" == "470.lbm" ]; then
    # Use the special sed command for 470.lbm
    sed -i "s|time.*$|time \$GEM5_DIR/build/X86/gem5.opt -d ./m5out \$GEM5_DIR/configs/deprecated/example/se.py -c \$BENCHMARK -o '19 reference.dat 0 1 $BASE_DIR/Project1_SPEC/470.lbm/data/100_100_130_cf_a.of' -I 500000000 --cpu-type=TimingSimpleCPU --caches --l2cache --l1d_size=${l1_d_cache_size} --l1i_size=${l1_i_cache_size} --l2_size=${l2_cache_size} --l1d_assoc=${l1_d_associative} --l1i_assoc=${l1_i_associative} --l2_assoc=${l2_associative} --cacheline_size=${block_size}|g" "$script_path"
  else
    # Use the general sed command for other benchmarks
    sed -i "s|time.*$|time \$GEM5_DIR/build/X86/gem5.opt -d ./m5out \$GEM5_DIR/configs/deprecated/example/se.py -c \$BENCHMARK -o \$ARGUMENT -I 500000000 --cpu-type=TimingSimpleCPU --caches --l2cache --l1d_size=${l1_d_cache_size} --l1i_size=${l1_i_cache_size} --l2_size=${l2_cache_size} --l1d_assoc=${l1_d_associative} --l1i_assoc=${l1_i_associative} --l2_assoc=${l2_associative} --cacheline_size=${block_size}|g" "$script_path"
  fi
}




# Function to run benchmark
function run_benchmark() {
  local benchmark="$1"
  echo "Running $benchmark"  
  cd "$BASE_DIR/Project1_SPEC/$benchmark"
  
  update_run_script runGem5.sh 
  rm -rf m5out
  sh runGem5.sh

  cd "$BASE_DIR"
}

# Loop through configs
for i in "${!configs[@]}"; do

  # Set config
  IFS=' ' read -ra CONF <<< "${configs[$i]}"
  
  # Update run scripts
  for benchmark in "${BENCHMARKS[@]}"; do
    update_run_script "$BASE_DIR/Project1_SPEC/$benchmark/runGem5.sh" "$benchmark"
  done

  # Run benchmarks
  for benchmark in "${BENCHMARKS[@]}"; do
    run_benchmark "$benchmark"
  done

  # Collect results
  echo -e "\n\n*** RUNNING THE OUTPUT DATA ***\n" > "$DATA_DIR/output_$i.txt"
  echo -e "Analysis Results for Benchmarks with Configuration: ${configs[$i]}\n\n" >> "$DATA_DIR/output_$i.txt"
  
  for benchmark in "${BENCHMARKS[@]}"; do  
    cd "$BASE_DIR/Project1_SPEC/$benchmark/m5out"
    echo "**************************************************" >> "$DATA_DIR/output_$i.txt"
    echo "Benchmark: $benchmark" >> "$DATA_DIR/output_$i.txt"
    echo "--------------------------------------------------" >> "$DATA_DIR/output_$i.txt"
    
    # Add all the required grep commands
    grep "simInsts" stats.txt >> "$DATA_DIR/output_$i.txt"
    grep "system.cpu.dcache.overallMisses::total" stats.txt >> "$DATA_DIR/output_$i.txt"
    grep "system.cpu.dcache.overallAccesses::total" stats.txt >> "$DATA_DIR/output_$i.txt"
    grep "system.cpu.icache.overallMisses::total" stats.txt >> "$DATA_DIR/output_$i.txt"
    grep "system.cpu.icache.overallAccesses::total" stats.txt >> "$DATA_DIR/output_$i.txt"
    grep "system.l2.overallMisses::total" stats.txt >> "$DATA_DIR/output_$i.txt"
    grep "system.l2.overallAccesses::total" stats.txt >> "$DATA_DIR/output_$i.txt"
    echo "**************************************************" >> "$DATA_DIR/output_$i.txt"
    echo "" >> "$DATA_DIR/output_$i.txt"
  done
  echo -e "\n\n" >> "$DATA_DIR/output_$i.txt"
done