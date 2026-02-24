#!/bin/bash

# Directory setup
SRC_DIR="src"
TB_DIR="tb"
BIN_DIR="bin"
WAVE_DIR="waves"

# Create directories if they don't exist
mkdir -p $BIN_DIR
mkdir -p $WAVE_DIR

# Loop through all testbench files
for tb_file in $TB_DIR/*.v; do
    tb_name=$(basename "$tb_file" .v)
    
    echo "--------------------------------------------------"
    echo "Compiling: $tb_name"
    
    # Compile
    iverilog -g2012 -I "$SRC_DIR" -o "$BIN_DIR/$tb_name.vvp" "$SRC_DIR"/*.v "$tb_file"
    
    if [ $? -eq 0 ]; then
        echo "Running simulation: $tb_name"
        # Run simulation
        vvp "$BIN_DIR/$tb_name.vvp"
        
        # Move the VCD file to the waveforms directory if it was created
        # Note: This assumes your TB naming matches or you use a generic name
        if [ -f "$tb_name.vcd" ]; then
            mv "$tb_name.vcd" "$WAVE_DIR/"
        elif [ -f "simulation.vcd" ]; then
            mv "simulation.vcd" "$WAVE_DIR/$tb_name.vcd"
        fi
        
        echo "Waveform saved to $WAVE_DIR/$tb_name.vcd"
    else
        echo "Compilation failed for $tb_name"
    fi
done

echo "--------------------------------------------------"
echo "All tasks complete."