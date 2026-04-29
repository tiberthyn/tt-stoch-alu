# Stochastic Computing ALU for Tiny Tapeout
  
> *ALU de computación estocástica con estimación de confianza en tiempo real, fabricada vía shuttle abierto.*

## Overview
Este proyecto implementa una **ALU de 8 bits basada en computación estocástica**. Los números se representan como flujos de bits probabilísticos y las operaciones complejas se reducen a puertas lógicas mínimas:
- **MUL** → `AND` gate
- **ADD** → `MUX` con selección aleatoria
- **AND/OR/XOR** → Directos sobre streams

### Innovación Principal
- **Confidence Flag en tiempo real**: El bit 7 de salida indica si la varianza estimada está dentro de límites aceptables.
- **Diseño fabricable**: Sintetizado para SkyWater 130nm, dentro del límite de ~1000 puertas por tile.

## 🔌 Pinout Detallado
| Señal | Dirección | Función |
|-------|-----------|---------|
| `ui_in[7:0]` | Entrada | Operando A |
| `uio[3:0]` | Entrada | Operando B |
| `uio[6:4]` | Entrada | Opcode: `0`=MUL, `1`=ADD, `2`=AND, `3`=OR, `4`=XOR |
| `uio[7]` | Entrada | Mode: `0`=exacto, `1`=estocástico |
| `uo_out[6:0]` | Salida | Resultado |
| `uo_out[7]` | Salida | Confidence Flag (`1`=confiable) |
| `clk` | Entrada | 25 MHz |
| `rst_n` | Entrada | Reset activo bajo |

## Simulación Local
```bash
iverilog -o sim testbench/tb_stoch_alu.v verilog/rtl/user_proj.v
vvp sim
gtkwave sim.vcd
