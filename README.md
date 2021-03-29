# ULSoC
A minicore with three-stage pipeline based on RISC-V

Designed with three-stage pipeline,  Cache will not be considered to added into this project.

## Characteristic

+ Haval Architecture.
+ Support RISCV-32I instruction set(C,A,M would be considered to added in future job).

+ Single core.
+ Support hazard processing.
+ Support branch prediction.
+ Eazy Bus design (No cache would be used so I dont need to use burst transactions, an eazy bus can satisfy my design).

## TODO:

- [x] IF unit basic design
- [x] ID unit basic design
- [x] EX unit basic design
- [] Control unit design
- [] Memory/Bus unit design
- [] Branch Prediction unit design
- [] Complete instruction set
- [] Verification
- [] Peripherals