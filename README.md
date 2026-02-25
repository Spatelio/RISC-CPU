# ELEC 374 CPU Design Project

## Setup
### MacOS/Linux
Requires Icarus Verilog
on Mac
```bash
brew install icarus-verilog
```
on Ubuntu
```bash
sudo apt install iverilog
```
Most distros will have a package with the same name

Once installed
```bash
chmod +x run_sims.sh
./run_sims.sh
```
Should create a bin folder for testbench results as well as a waves folder for the waveforms in the simulation

The script compiles everything in the ```/src``` folder and creates a wave for every testbench in the ```/tb``` folder.

### Compatibility
Since on Mac I am only inspecting the final waveforms created by iverilog, my testbench format uses 
```verilog
$finish 
 ```
 as the final state. When modelsim runs into this symbol it will try to close the window and end the simulation. replacing with
 ```verilog
 $stop
 ```
 should solve this issue