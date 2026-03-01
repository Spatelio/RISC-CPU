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

 ## Phase Checklist
 ### Phase 1
 #### Modules
- [x] General Purpose Registers: 16 registers (R0 – R15), 32-bit width. 

- [x] Special Registers: PC, IR, Y, Z, MAR, HI, LO. 

- [x] Bidirectional Bus: Implemented (e.g., using 32:1 Multiplexer and Encoder) to connect registers. 

- [x] MDR Unit: Memory Data Register connected to the Bus (Memory chip connection not required yet). 

- [x] ALU (Arithmetic Logic Unit):

- [x] Logic/Add/Sub: Handles AND, OR, NEG, NOT, ADD, SUB. 

- [x] Multiplication: Implements Booth’s Algorithm (with bit-pair recoding) OR Carry-Save Adders. Note: Simple * operator is forbidden. 

- [x] Division: Implements division logic. 

- [x] Shifts/Rotates: Handles SHR, SHRA, SHL, ROR, ROL
#### Testbenches
- [x] AND: and R2, R5, R6 (Verify R2 receives R5 & R6). 

- [x] OR: or R2, R5, R6 (Verify R2 receives R5 | R6). 

- [x] ADD: add R2, R5, R6 (Verify R2 receives R5 + R6). 

- [x] SUB: sub R2, R5, R6 (Verify R2 receives R5 - R6). 

- [x] NEG: neg R4, R7 (Verify R4 receives -R7). 

- [x] NOT: not R4, R7 (Verify R4 receives ~R7). 

Multiplication & Division

- [x] MUL: mul R3, R1 (Verify Z/HI/LO receive R3 * R1). 

- [x] DIV: div R3, R1 (Verify Z/HI/LO receive R3 / R1). 

Shifts & Rotates

- [x] SHR: shr R7, R0, R4 (Shift Right). 

- [x] SHRA: shra R7, R0, R4 (Arithmetic Shift Right). 

- [x] SHL: shl R7, R0, R4 (Shift Left). 

- [x] ROR: ror R7, R0, R4 (Rotate Right). 

- [x] ROL: rol R7, R0, R4 (Rotate Left).
 ### Phase 2
 #### Modules
- [x] Memory Subsystem:

- [x] RAM: 512 x 32-bit memory (Synchronous recommended). 

- [x] MDR (Memory Data Register): Updated to handle data from both Bus (BusMuxOut) and Memory (Mdatain). 

- [x] MAR (Memory Address Register): Outputs address to RAM. 

- [x] Select and Encode Logic:

- [x] Internal Decoding: Generates R0in-R15in and R0out-R15out internally using Gra, Grb, Grc, Rin, Rout, BAout. 

- [x] C Sign Extension: Logic to sign-extend IR<18..0> to 32 bits (C_sign_extended). 

- [x] Revised Register R0:

- [x] BAout Logic: Gates 0s onto the bus if R0 is selected and BAout is active; otherwise puts R0 content. 

- [x] CON FF Logic:

- [x] Branch Logic: Decodes IR<22..19> (C2 field) and Bus data to determine if branch condition (Zero, NonZero, Positive, Negative) is met. 

- [x] Input/Output Ports:

- [x] Input Port: 32-bit register with connection to Bus (BusMuxIn_In.Port). 

- [x] Output Port: 32-bit register capturing data from Bus (BusMuxOut).
 #### Testbenches
 - [ ] ld (Load Direct): ld R7, 0x65 (Preload Mem[0x65]=0x84). Verify R7 gets 0x84. 

- [ ] ld (Load Indexed): ld R0, 0x72(R2) (Preload R2=0x57, Mem[0xC9]=0x2B). Verify R0 gets 0x2B. 

- [ ] ldi (Load Immediate): ldi R7, 0x65. Verify R7 gets 0x65 (sign-extended). 

- [ ] st (Store Direct): st 0x1F, R6 (Preload R6=0x63). Verify Mem[0x1F] becomes 0x63. 

- [ ] st (Store Indexed): st 0x1F(R6), R6 (Preload R6=0x63). Verify Mem[0x82] becomes 0x63. 

ALU Immediate Instructions

- [ ] addi: addi R7, R4, -9. Verify R7 = R4 + (-9). 

- [ ] andi: andi R7, R4, 0x71. Verify R7 = R4 & 0x71. 

- [ ] ori: ori R7, R4, 0x71. Verify R7 = R4 | 0x71. 

Branch Instructions (CON FF Tests)

- [ ] brzr: brzr R3, 48. Test taken/not taken cases. 

- [ ] brnz: brnz R3, 48. Test taken/not taken cases. 

- [ ] brpl: brpl R3, 48. Test taken/not taken cases. 

- [ ] brmi: brmi R3, 48. Test taken/not taken cases. 

Jump & Special Instructions

- [ ] jr: jr R12. Verify PC takes value from R12. 

- [ ] jal: jal R4. Verify PC takes R4, and R12 (RA) gets PC+1. 

- [ ] mfhi: mfhi R5. Verify R5 gets HI. 

- [ ] mflo: mflo R1. Verify R1 gets LO. 

Input/Output Instructions

- [ ] out: out R7. Verify Output Port gets R7 value. 

- [ ] in: in R5. Verify R5 gets Input Port value.