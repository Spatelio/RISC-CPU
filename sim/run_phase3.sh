#!/bin/bash
set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

SRC_DIR="src"
BIN_DIR="sim/bin"
WAVE_DIR="sim/waves"
CASE_HEX="cases/phase3.hex"

mkdir -p "$BIN_DIR" "$WAVE_DIR"

cp "$CASE_HEX" currentcase.hex
echo "Using $CASE_HEX -> currentcase.hex"

iverilog -g2012 -I "$SRC_DIR" -o "$BIN_DIR/tb_phase3.vvp" "$SRC_DIR"/*.v sim/tb_phase3.v
# Optional waves: add -DDUMP_PHASE3 to iverilog above, then: vvp ... -lxt2
vvp "$BIN_DIR/tb_phase3.vvp"

if [ -f "tb_phase3.vcd" ]; then
    mv tb_phase3.vcd "$WAVE_DIR/"
fi
echo "Waveform: $WAVE_DIR/tb_phase3.vcd"
