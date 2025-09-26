#!/bin/sh

# This script runs the split_matrixTrop_forward program with different input matrices and parameters.
# For each matrix, it measures the execution time and writes the output to a corresponding file.


time ./split_matrixTrop_forward matriz_6.bin 256 100 1 > salida_6.txt
time ./split_matrixTrop_forward matriz_7.bin 608 100 1 > salida_7.txt
time ./split_matrixTrop_forward matriz_8.bin 1408 100 1 > salida_8.txt
time ./split_matrixTrop_forward matriz_9.bin 3392 100 1 > salida_9.txt
time ./split_matrixTrop_forward matriz_10.bin 8128 100 1 > salida_10.txt
time ./split_matrixTrop_forward matriz_11.bin 19616 100 1 > salida_11.txt
time ./split_matrixTrop_forward matriz_12.bin 47328 100 1 > salida_12.txt
time ./split_matrixTrop_forward matriz_13.bin 114272 100 8 > salida_13.txt




