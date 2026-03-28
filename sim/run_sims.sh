#!/bin/bash
# Run from repo root so RAM's $readmemh("currentcase.hex", ...) resolves correctly.

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

SRC_DIR="src"
TB_REL="sim/tb_cpu.v"
BIN_DIR="sim/bin"
WAVE_DIR="sim/waves"
CASE_HEX="cases/tb_cpu.hex"

mkdir -p "$BIN_DIR" "$WAVE_DIR"

if [ -f "$CASE_HEX" ]; then
    echo "Using testcase: $CASE_HEX"
    cp "$CASE_HEX" currentcase.hex
else
    echo "Warning: $CASE_HEX not found; RAM uses existing currentcase.hex."
fi

tb_name="tb_cpu"
echo "--------------------------------------------------"
echo "Compiling: $tb_name"

iverilog -g2012 -I "$SRC_DIR" -o "$BIN_DIR/${tb_name}.vvp" "$SRC_DIR"/*.v "$TB_REL"

echo "Running simulation: $tb_name"
vvp "$BIN_DIR/${tb_name}.vvp"

if [ -f "${tb_name}.vcd" ]; then
    mv "${tb_name}.vcd" "$WAVE_DIR/"
elif [ -f "simulation.vcd" ]; then
    mv "simulation.vcd" "$WAVE_DIR/${tb_name}.vcd"
fi

echo "Waveform: $WAVE_DIR/${tb_name}.vcd"
echo "--------------------------------------------------"
echo "Done."
