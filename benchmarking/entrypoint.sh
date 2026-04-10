#!/bin/bash
set -e

DOCKER_USERNAME=${DOCKER_USERNAME:-hannya}
HOME_DIR=/home/$DOCKER_USERNAME
OPENCODE_MODEL=${OPENCODE_MODEL:-opencode/big-pickle}

setup_skills() {
    mkdir -p "$HOME_DIR/.config/opencode/skills"
}

check_plugin() {
    local plugin=$1
    local result=""
    
    case "$plugin" in
        oh-my-openagent)
            if [ -f "$HOME_DIR/.config/opencode/oh-my-openagent.json" ]; then
                AGENT_COUNT=$(grep -c '"model"' "$HOME_DIR/.config/opencode/oh-my-openagent.json" 2>/dev/null || echo 0)
                if [ "$AGENT_COUNT" -gt 0 ]; then
                    result="[OK] oh-my-openagent: plugin loaded, $AGENT_COUNT agents registered"
                else
                    result="[WARN] oh-my-openagent: plugin loaded but no agents found"
                fi
            else
                result="[FAIL] oh-my-openagent: not initialized (missing config)"
            fi
            ;;
        superpowers)
            if grep -q "superpowers" "$HOME_DIR/.config/opencode/opencode.json" 2>/dev/null; then
                result="[OK] superpowers: registered in opencode.json"
            else
                result="[FAIL] superpowers: not in plugin list"
            fi
            ;;
        graphify)
            if [ -f "$HOME_DIR/.config/opencode/skills/graphify/SKILL.md" ]; then
                if command -v graphify &> /dev/null; then
                    result="[OK] graphify: skill + CLI available"
                else
                    result="[OK] graphify: skill available"
                fi
            else
                result="[FAIL] graphify: skill not found"
            fi
            ;;
        gstack)
            if [ -d "$HOME_DIR/.config/opencode/skills/gstack" ]; then
                SKILL_COUNT=$(find "$HOME_DIR/.config/opencode/skills/gstack" -maxdepth 1 -name "*.md" | wc -l)
                result="[OK] gstack: $SKILL_COUNT skill files available"
            else
                result="[FAIL] gstack: not installed"
            fi
            ;;
        *)
            result="[UNKNOWN] $plugin: unknown plugin"
            ;;
    esac
    
    echo "$result"
}

test_skill_loading() {
    local all_results=""
    local has_fail=false
    
    echo "Triggering plugin init..."
    timeout 30 "$HOME_DIR/.opencode/bin/opencode" --pure run "list skills" > /dev/null 2>&1 || true
    
    # Get skill list from opencode
    OUTPUT=$(echo "what skills are loaded? list all" | timeout 60 "$HOME_DIR/.opencode/bin/opencode" --pure run 2>&1 || true)
    
    echo "Opencode skill list:"
    echo "$OUTPUT" | head -20
    echo ""
    
    SKILLS="brainstorming systematic-debugging test-driven-development writing-plans receiving-code-review subagent-driven-development dispatching-parallel-agents executing-plans using-git-worktrees verification-before-completion finishing-a-development-branch requesting-code-review writing-skills gstack graphify playwright frontend-ui-ux dev-browser review-work ai-slop-remover"
    
    echo "Testing all known skills:"
    echo ""
    
    for skill in $SKILLS; do
        OUTPUT=$(echo "load $skill" | timeout 45 "$HOME_DIR/.opencode/bin/opencode" --pure run 2>&1 || true)
        
        echo "- $skill:"
        
        if echo "$OUTPUT" | grep -qi "not found\|not available\|no skills"; then
            echo "  FAIL: NOT available"
            all_results="$all_results
  [FAIL] $skill: NOT available"
            has_fail=true
        elif echo "$OUTPUT" | grep -qi "loaded\|Skill"; then
            echo "  OK"
            all_results="$all_results
  [OK] $skill: loads correctly"
        else
            echo "  WARN: uncertain"
            all_results="$all_results
  [WARN] $skill: uncertain"
        fi
    done
    
    echo ""
    echo "Summary:"
    echo "$all_results"
}

run_benchmark() {
    echo "========================================"
    echo "Benchmark: ${BENCH_NAME:-default}"
    echo "Plugins: ${PLUGINS:-none}"
    echo "========================================"
    
    cd "$HOME_DIR/workspace/benchmarking"
    mkdir -p results
    
    > "results/${BENCH_NAME:-default}_results.txt"
    
    echo "=== Benchmark Configuration ===" > "results/${BENCH_NAME:-default}_results.txt"
    echo "Benchmark: ${BENCH_NAME:-default}" >> "results/${BENCH_NAME:-default}_results.txt"
    echo "Plugins: ${PLUGINS:-none}" >> "results/${BENCH_NAME:-default}_results.txt"
    echo "" >> "results/${BENCH_NAME:-default}_results.txt"
    
    echo "=== Plugin Compatibility Check ===" >> "results/${BENCH_NAME:-default}_results.txt"
    
    PLUGINS_STR="${PLUGINS:-}"
    COMPATIBLE=true
    
    echo "" >> "results/${BENCH_NAME:-default}_results.txt"
    echo "Plugin Status:" >> "results/${BENCH_NAME:-default}_results.txt"
    
    for plugin in $(echo "$PLUGINS_STR" | tr ',' '\n'); do
        if [ -n "$plugin" ]; then
            result=$(check_plugin "$plugin")
            echo "  $result" >> "results/${BENCH_NAME:-default}_results.txt"
            
            if echo "$result" | grep -q "\[FAIL\]"; then
                COMPATIBLE=false
            fi
        fi
    done
    
    echo "" >> "results/${BENCH_NAME:-default}_results.txt"
    echo "Runtime Skill Loading Test:" >> "results/${BENCH_NAME:-default}_results.txt"
    
    result=$(test_skill_loading "$PLUGINS_STR")
    echo "$result" >> "results/${BENCH_NAME:-default}_results.txt"
    
    if echo "$result" | grep -q "\[FAIL\]"; then
        COMPATIBLE=false
    fi
    
    echo "" >> "results/${BENCH_NAME:-default}_results.txt"
    if [ "$COMPATIBLE" = true ]; then
        echo "Compatibility: PASS" >> "results/${BENCH_NAME:-default}_results.txt"
        echo "PASS: $BENCH_NAME" >> "results/${BENCH_NAME:-default}_results.txt"
    else
        echo "Compatibility: FAIL" >> "results/${BENCH_NAME:-default}_results.txt"
        echo "FAIL: $BENCH_NAME" >> "results/${BENCH_NAME:-default}_results.txt"
    fi
    
    echo "" >> "results/${BENCH_NAME:-default}_results.txt"
    echo "=== Environment ===" >> "results/${BENCH_NAME:-default}_results.txt"
    "$HOME_DIR/.opencode/bin/opencode" --version 2>&1 >> "results/${BENCH_NAME:-default}_results.txt" || echo "not available" >> "results/${BENCH_NAME:-default}_results.txt"
    
    echo ""
    echo "========================================"
    echo "Benchmark Complete"
    echo "Results saved to results/"
    echo "========================================"
    
    cat "results/${BENCH_NAME:-default}_results.txt"
}

if [ "$(id -u)" = "0" ]; then
    chown -R ${MYUID:-1000}:${MYGID:-1000} $HOME_DIR
    
    setup_skills
    
    exec su -l $DOCKER_USERNAME -c "
        cd $HOME_DIR/workspace/benchmarking
        bash
    "
else
    setup_skills
    
    if [ "$RUN_BENCHMARK" = "true" ]; then
        run_benchmark
    fi
    
    exec bash
fi