# Stochastic Computing ALU for Tiny Tapeout
  
> *Stochastic computing ALU with real-time confidence estimation, fabricated via open shuttle.*

## Overview
This project implements an 8-bit ALU based on stochastic computing. Numbers are represented as probabilistic bitstreams, and complex operations reduce to minimal logic gates:
- MUL -> `AND` gate
- ADD -> `MUX` with random selection
- AND/OR/XOR -> Directly over streams

### Main Innovation
- Real-time Confidence Flag: Output bit 7 indicates whether the estimated variance is within acceptable limits.
- Fabricable design: Synthesized for SkyWater 130nm, within the ~1000-gate limit per tile.

## Detailed Pinout
| Signal | Direction | Function |
| ui_in[7:0] | Input | Operand A |
| uio[3:0] | Input | Operand B |
| uio[6:4] | Input | Opcode: 0=MUL, 1=ADD, 2=AND, 3=OR, 4=XOR |
| uio[7] | Input | Mode: 0=exact, 1=stochastic |
| uo_out[6:0] | Output | Result |
| uo_out[7] | Output | Confidence Flag (1=reliable) |
| clk | Input | 25 MHz |
| rst_n | Input | Active-low reset |

## Local Simulation
```bash
iverilog -o sim testbench/tb_stoch_alu.v verilog/rtl/user_proj.v
vvp sim
gtkwave sim.vcd
