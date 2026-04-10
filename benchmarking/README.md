# OpenCode Plugin Benchmarking

Test plugin compatibility in OpenCode environments.

## Plugins Tested

| Plugin | Type | Skills Tested |
|--------|------|---------------|
| oh-my-openagent | Plugin | playwright, frontend-ui-ux, dev-browser, review-work, ai-slop-remover |
| superpowers | Plugin | brainstorming, systematic-debugging, TDD, writing-plans, etc. |
| graphify | Skill | graphify |
| gstack | Skill | gstack |

## Running

Build:
```bash
cd benchmarking
docker build -f Dockerfile.benchmark -t opencode-benchmark:latest .
```

Run single benchmark:
```bash
docker run --rm \
  -e RUN_BENCHMARK=true \
  -e BENCH_NAME=bench-05 \
  -e PLUGINS=oh-my-openagent,superpowers \
  -v $(pwd)/results:/home/hannya/workspace/benchmarking/results \
  opencode-benchmark:latest /entrypoint.sh
```

Run all (uses tokens!):
```bash
cd benchmarking
./scripts/run-all-benchmarks.sh
```

## Warnings

- Running benchmarks CONSUMES API TOKENS - each skill test makes an OpenCode call
- Runtime tests may timeout in containers
- oh-my-openagent + superpowers may have skill loading conflicts

## Results

Saved in `results/bench-XX_results.txt`