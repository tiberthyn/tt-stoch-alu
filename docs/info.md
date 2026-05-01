# Stochastic Computing ALU

## Description
8-bit ALU implementing arithmetic and logic operations using stochastic computing.  
Includes an exact mode as fallback and real-time confidence estimation for approximate results.

### Supported Operations:
| Opcode | Operation | Stochastic Mode      | Exact Mode              |
|--------|----------|----------------------|--------------------------|
| 000    | MUL      | Stream AND           | 8-bit Multiplication     |
| 001    | ADD      | Random MUX           | 8-bit Addition           |
| 010    | SUB      | Not available        | 8-bit Subtraction        |
| 011    | AND      | Stream AND           | Bitwise AND              |
| 100    | OR       | Stream OR            | Bitwise OR               |
| 101    | XOR      | Stream XOR           | Bitwise XOR              |

## How it works

### Stochastic Computing
1. Stream Generation (SNG): Each operand is compared with an 8-bit LFSR to generate random bits with probability proportional to its value.
2. Bitwise Operation: Operations are performed bit-by-bit on the streams (e.g., MUL = AND, ADD = random MUX).
3. Binary Conversion: A population counter accumulates results over 64 clock cycles.
4. Scaling: The result is scaled by \( \times 4 \) to compensate for the counter resolution.

### Confidence Estimation
The confidence flag (bit 7 of the output) is asserted when:
- \( \text{pop\_count} < 10 \) or \( \text{pop\_count} > 54 \) → Result near range extremes, high confidence  
- Intermediate values → Possible error due to correlation or noise  

## How to test

### Local simulation with Icarus Verilog:
```bash
# Compile
iverilog -o sim testbench/tb_stoch_alu.v verilog/rtl/user_proj.v

# Run
vvp sim

# View waveforms
gtkwave sim.vcd
