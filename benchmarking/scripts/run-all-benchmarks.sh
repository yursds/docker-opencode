#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
MAX_PARALLEL=4

mkdir -p "$RESULTS_DIR"

echo "========================================"
echo "Building Docker image (one time)"
echo "========================================"

docker build -f "$SCRIPT_DIR/../Dockerfile.benchmark" -t opencode-benchmark:latest "$SCRIPT_DIR/../"

echo ""
echo "========================================"
echo "Running Benchmarks in Parallel (max $MAX_PARALLEL)"
echo "========================================"

BENCHMARKS=(
  "bench-00:"
  "bench-01:oh-my-openagent"
  "bench-02:superpowers"
  "bench-03:gstack"
  "bench-04:graphify"
  "bench-05:oh-my-openagent,superpowers"
  "bench-06:oh-my-openagent,gstack"
  "bench-07:oh-my-openagent,graphify"
  "bench-08:gstack,graphify"
  "bench-09:superpowers,gstack"
  "bench-10:oh-my-openagent,superpowers,gstack,graphify"
)

run_benchmark() {
    local name=$1
    local plugins=$2
    
    echo "[$name] Starting (plugins: $plugins)..."
    
    docker run --rm \
        -e RUN_BENCHMARK=true \
        -e BENCH_NAME=$name \
        -e PLUGINS="$plugins" \
        -v "$RESULTS_DIR:/home/hannya/workspace/benchmarking/results" \
        opencode-benchmark:latest /entrypoint.sh > "$RESULTS_DIR/${name}_results.txt" 2>&1 || true
    
    if grep -q "PASS:" "$RESULTS_DIR/${name}_results.txt"; then
        echo "[$name] PASS"
    elif grep -q "FAIL:" "$RESULTS_DIR/${name}_results.txt"; then
        echo "[$name] FAIL"
    else
        echo "[$name] (no result)"
    fi
}

TOTAL=${#BENCHMARKS[@]}
RUNNING=0

for bench in "${BENCHMARKS[@]}"; do
    name="${bench%%:*}"
    plugins="${bench#*:}"
    
    run_benchmark "$name" "$plugins" &
    RUNNING=$((RUNNING + 1))
    
    echo "Started: $name (running: $RUNNING/$TOTAL)"
    
    if [ $RUNNING -ge $MAX_PARALLEL ]; then
        wait
        RUNNING=0
    fi
done

wait

echo ""
echo "========================================"
echo "All Benchmarks Complete"
echo "========================================"

echo ""
echo "Summary:"
for bench in "${BENCHMARKS[@]}"; do
    name="${bench%%:*}"
    if grep -q "PASS:" "$RESULTS_DIR/${name}_results.txt" 2>/dev/null; then
        echo "  $name: PASS"
    elif grep -q "FAIL:" "$RESULTS_DIR/${name}_results.txt" 2>/dev/null; then
        echo "  $name: FAIL"
    else
        echo "  $name: (no result)"
    fi
done

echo ""
echo "Results saved to: $RESULTS_DIR/"