################################################################################
# Author: SONIC3D
# E-mail: sonic3d@gmail.com
# 2020.May.12
#
# makefile template for WonderSwan application
#
# usage:
#       make all
# 	 	make clean
#
################################################################################

.SUFFIXES: .bin .obj .p86 .a86 .c

NASM=nasm
RM=rm		# set RM=del on windows

all: 	puzzle_bobble_j_sram.ws
	@echo done

clean:
	RM puzzle_bobble_j_sram.ws

# $< the first prerequisite
# $@ is the name of the file being generated
# For example, consider the following declaration:
#   all: library.cpp main.cpp
# In this case:
#   $@ evaluates to all
#   $< evaluates to library.cpp
#   $^ evaluates to library.cpp main.cpp
puzzle_bobble_j_sram.ws: 	main_puzzle_bobble_j.asm Puzzle\ Bobble\ (Japan).ws
	NASM -f bin -o $@ main_puzzle_bobble_j.asm
