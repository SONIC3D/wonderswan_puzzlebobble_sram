# Wonderswan EEPROM to SRAM patch code for "Puzzle Bobble (Japan)"

## What is this?
* This is an asm patch project for "Puzzle Bobble (Japan).ws".
* All patched contents are provided as asm code and ready to be built with nasm.

## How to build
* Install nasm assembler.(https://nasm.us/)
* Install gnu make for your OS.(e.g. MinGW for Windows)
* Put the original "Puzzle Bobble" ROM file to the project root directory.
    * The file name should be "Puzzle Bobble (Japan).ws".
    * The file size should be 524288 bytes.
    * The CRC32 hash of the correct rom should be "302499B9".
* Run `make all` command in the project root directory.
* Grab the result file "puzzle_bobble_j_sram.ws".
