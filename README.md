# ALU for IEEE-754 Floating-Point Numbers
A complete hardware-software co-design project implementing a Floating Point Arithmetic Logic Unit according to the IEEE-754 standard, realized in VHDL on FPGA Zynq platform.
This project demonstrates advanced digital design capabilities including sequential and combinational arithmetic operations and PS-PL communication through AXI interface.
## Key Features
-	IEEE-754 Compliance
-	Complete Arithmetic Suite: Addition, Subtraction, Multiplication, Division implemented using CLA (Carry Look-ahead Adders) for mantissa/exponent operations, Shift-And-Add Multiplier for mantissa multiplication and Restoring Division Algorithm for mantissa division
-	Exception Handling: Proper handling of NaN, Infinity, Overflow, Underflow, and Zero cases
-	Hardware-Software Co-Design: Control logic in VHDL (PL) with C software control (PS)
-	AXI Communication: PS-PL data exchange through AXI GPIO interface
-	Test Coverage: Comprehensive testbenches for all operations with assertion-based verification
## Technologies Used
-	Hardware Description: VHDL
-	Software: C (Vitis)
-	Standard: IEEE-754 Single Precision (32-bit)
-	Verification: VHDL Testbenches with assertions
