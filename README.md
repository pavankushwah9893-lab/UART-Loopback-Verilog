# UART Loopback using Verilog

This project implements a simple UART loopback using Verilog HDL.

The main idea is to receive data from a PC through UART RX and send the same
data back through UART TX.

The same UART loopback concept is implemented on two different FPGA boards:

- Xilinx Basys 3 (Artix-7)
- Altera DE0 (Cyclone III)

The main difference between the two implementations is the FPGA board and
the system clock frequency.

## UART Configuration

- Baud Rate: 9600
- Data Bits: 8
- Start Bit: 1
- Stop Bit: 1
- Data Order: LSB first

The receiver uses oversampling for receiving the UART data.

## Xilinx Basys 3

- FPGA: Artix-7
- System Clock: 100 MHz
- Tool: Xilinx Vivado
- HDL: Verilog
- UART Baud Rate: 9600

The UART receiver and transmitter are designed according to the 100 MHz
system clock.

## Altera DE0

- FPGA: Cyclone III
- Device: EP3C16F484C6
- System Clock: 50 MHz
- Tool: Quartus II 13.1
- HDL: Verilog
- UART Baud Rate: 9600

The same UART loopback functionality is implemented for the 50 MHz clock
of the DE0 board.

## How It Works

The UART receiver receives the serial data from the PC through the RX pin.

The receiver detects the start bit, receives the 8 data bits and checks the
stop bit. After receiving a complete byte, the data is stored in the receive
buffer.

The transmitter takes the received 8-bit data and sends it back to the PC
through the TX pin.

The basic operation is:

- PC sends a character.
- FPGA receives the character through UART RX.
- The receiver converts the serial data into an 8-bit byte.
- The received byte is passed to the transmitter.
- UART TX sends the same byte back to the PC.

For example, if the PC sends a character, the same character is received
back through the UART connection.

## UART Receiver

The receiver is implemented using Verilog.

For the DE0 implementation, 16x oversampling is used to sample the incoming
UART signal.

The receiver detects the start bit and then receives the data bits one by
one. After a complete byte is received, the `rx_done` signal indicates that
new data is available.

## UART Transmitter

The transmitter converts the 8-bit parallel data into serial UART data.

The transmitted UART frame contains:

- Start bit
- 8 data bits
- Stop bit

The baud timing is generated from the FPGA system clock.

## Project Structure

The repository contains separate folders for the two FPGA implementations.

The Basys 3 implementation contains the Verilog RTL files and XDC
constraints.

The DE0 implementation contains the Verilog RTL files and QSF constraints.

## Tools Used

### Xilinx Basys 3

- Xilinx Vivado
- Verilog HDL

### Altera DE0

- Quartus II 13.1
- Verilog HDL
- ModelSim-Altera

## Hardware Used

- Xilinx Basys 3 FPGA Board
- Altera DE0 FPGA Board
- PC for UART communication

## What I Learned

Working on this project helped me understand:

- UART communication
- Verilog RTL design
- UART RX and TX
- Baud rate generation
- Clock-based timing
- UART oversampling
- Serial-to-parallel conversion
- Parallel-to-serial conversion
- FPGA pin constraints
- Vivado
- Quartus II
- Hardware testing

## Result

The UART loopback was implemented on both FPGA platforms.

The same UART functionality was adapted for two different system clock
frequencies:

- Basys 3: 100 MHz
- DE0: 50 MHz

The FPGA receives UART data from the PC and transmits the received data
back through the TX line.
