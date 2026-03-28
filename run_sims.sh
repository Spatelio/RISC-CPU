#!/bin/bash
# Phase 3 integration sims from repo root (RAM uses currentcase.hex).
# Runs both: full program (phase3.hex) and CPU smoke test (tb_cpu.hex).
# Waves → waves/p3/ | Build → build/*.vvp
# Optional: DUMP=1 adds -DDUMP_PHASE3 for the first sim (large phase3.vcd).

set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

SRC_DIR="src"
BUILD_DIR="build"
WAVE_DIR="waves/p3"
mkdir -p "$BUILD_DIR" "$WAVE_DIR"

PHASE3_EXTRA=()
if [ "${DUMP:-}" = "1" ]; then
    PHASE3_EXTRA=(-DDUMP_PHASE3)
fi

echo "=== Phase 3 program (cases/phase3.hex) ==="
cp cases/phase3.hex currentcase.hex
iverilog -g2012 -I "$SRC_DIR" "${PHASE3_EXTRA[@]}" -o "$BUILD_DIR/tb_phase3.vvp" "$SRC_DIR"/*.v tb/p3/tb_phase3.v
vvp "$BUILD_DIR/tb_phase3.vvp"
for f in tb_phase3.vcd simulation.vcd; do
    if [ -f "$f" ]; then
        mv "$f" "$WAVE_DIR/"
        echo "Waveform: $WAVE_DIR/$f"
        break
    fi
done

echo "=== CPU smoke test (cases/tb_cpu.hex) ==="
cp cases/tb_cpu.hex currentcase.hex
iverilog -g2012 -I "$SRC_DIR" -o "$BUILD_DIR/tb_cpu.vvp" "$SRC_DIR"/*.v tb/tb_cpu.v
vvp "$BUILD_DIR/tb_cpu.vvp"
for f in tb_cpu.vcd simulation.vcd; do
    if [ -f "$f" ]; then
        mv "$f" "$WAVE_DIR/"
        echo "Waveform: $WAVE_DIR/$f"
        break
    fi
done

cp cases/phase3.hex currentcase.hex
echo "Done. (currentcase.hex restored to phase3.hex)"
