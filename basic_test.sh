#! /usr/bin/env bash
set -e
set -x

# Cd into directory holding this script
cd "${BASH_SOURCE[0]%/*}"


export UCX_DIR="$PWD/ucx-1.15.0/install"
export PATH=$UCX_DIR/bin:$PATH
export LD_LIBRARY_PATH=$UCX_DIR/lib:$LD_LIBRARY_PATH

mkdir -p ./FlexFlow/inference/output/basic_test

# Create test prompt file
mkdir -p ./FlexFlow/inference/prompt
echo '["Three tips for staying healthy are: "]' > ./FlexFlow/inference/prompt/test.json

ncpus=8
ngpus=1
bs=1
llm_model_name="huggyllama/llama-7b"
ssm_model_name="JackFram/llama-68m"

echo "Running single node test..."
# Incremental decoding
echo ">>> Incremental decoding test..."
./FlexFlow/build/inference/incr_decoding/incr_decoding -ll:cpu $ncpus -ll:util $ncpus -ll:gpu $ngpus -ll:fsize 20000 -ll:zsize 80000 -llm-model $llm_model_name -prompt ./FlexFlow/inference/prompt/test.json --max-requests-per-batch $bs -tensor-parallelism-degree $ngpus --fusion -output-file ./FlexFlow/inference/output/basic_test/1_machine-${ngpus}_gpu-${bs}_batchsize-incr_dec.txt > ./FlexFlow/inference/output/basic_test/1_machine-${ngpus}_gpu-${bs}_batchsize-incr_dec.out
echo ">>> Sequence-based speculative decoding test..."
# Sequence-based speculative decoding
./FlexFlow/build/inference/spec_infer/spec_infer -ll:cpu $ncpus -ll:util $ncpus -ll:gpu $ngpus -ll:fsize 21800 -ll:zsize 80000 -llm-model $llm_model_name -ssm-model $ssm_model_name -prompt ./FlexFlow/inference/prompt/test.json --max-requests-per-batch $bs --expansion-degree -1 -tensor-parallelism-degree $ngpus --fusion -output-file ./FlexFlow/inference/output/basic_test/1_machine-${ngpus}_gpu-${bs}_batchsize-sequence_specinfer.txt > ./FlexFlow/inference/output/basic_test/1_machine-${ngpus}_gpu-${bs}_batchsize-sequence_specinfer.out
# Tree-based speculative decoding
echo ">>> Tree-based speculative decoding test..."
./FlexFlow/build/inference/spec_infer/spec_infer -ll:cpu $ncpus -ll:util $ncpus -ll:gpu $ngpus -ll:fsize 20000 -ll:zsize 80000 -llm-model $llm_model_name -ssm-model $ssm_model_name -prompt ./FlexFlow/inference/prompt/test.json --max-requests-per-batch $bs -tensor-parallelism-degree $ngpus --fusion -output-file ./FlexFlow/inference/output/basic_test/1_machine-${ngpus}_gpu-${bs}_batchsize-tree_specinfer.txt > ./FlexFlow/inference/output/basic_test/1_machine-${ngpus}_gpu-${bs}_batchsize-tree_specinfer.out
echo "Single node test passed!"

echo "Running offloading test..."
./FlexFlow/build/inference/spec_infer/spec_infer -ll:cpu $ncpus -ll:util $ncpus -ll:gpu $ngpus -ll:fsize 21800 -ll:zsize 80000 -llm-model $ssm_model_name  -prompt ./FlexFlow/inference/prompt/test.json -offload -offload-reserve-space-size 1000 --max-requests-per-batch $bs --fusion -output-file ./FlexFlow/inference/output/basic_test/offloading.txt > ./FlexFlow/inference/output/basic_test/offloading.out
echo "Offloading test passed!"

echo "Running multinode test..."
mpirun -N 1 --hostfile ~/hostfile hostname
echo "Multinode test passed..."

echo ""
echo ""
echo "Test passed!"
