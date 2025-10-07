# DominationCylinders


**DominationCylinders** is a research-oriented software suite for studying domination problems in cylindrical graphs. This repository provides tools and libraries for generating words, constructing matrices, and performing advanced computations related to domination in cylindrical graph structures.

To appear in: 

- ARS MATHEMATICA CONTEMPORANEA : The Journal Ars Mathematica Contemporanea (AMC) is a diamond (platinum) open access journal in which neither the authors nor the readers incur any costs. Since 2025, the journal is available in electronic format only. (Until 2025, it was published in both print and electronic formats.)


## Features

- Efficient generation of word representations for cylindrical graphs.
- Matrix construction and manipulation for domination analysis.
- GPU-accelerated algorithms for large-scale computations (CUDA support).
- Modular codebase for easy extension and experimentation.

## Getting Started

Follow the instructions below to compile the core libraries and programs:


1. **Compile the variation library:**

```bash
example@server ~/ $ cd DominationCylinders
example@server ~/DominationCylinders $ gcc -c vari_rep_lex.c -o vari_rep_lex.o
example@server ~/DominationCylinders $
```

2. **Compile the words generator program:**

```bash
example@server ~/ $ cd DominationCylinders
example@server ~/DominationCylinders $ gcc vari_rep_lex.o words_generator.c -o words_generator
example@server ~/DominationCylinders $
```

3. **Compile the matrix generator program:**

```bash
example@server ~/ $ cd DominationCylinders
example@server ~/DominationCylinders $ gcc matrix_generator.c -o matrix_generator
example@server ~/DominationCylinders $
```

4. **Compile split matrix tropical fordward program:**

```bash
example@server ~/DominationCylinders $ cd split_matrixTrop_forward
example@server ~/DominationCylinders/split_matrixTrop_forward $ make 
/usr/local/cuda/bin/nvcc -c -o main1.o main1.cu -DKERNEL1=0 -DMENSAJES -O3 -arch=sm_70 -gencode=arch=compute_70,code=sm_70
/usr/local/cuda/bin/nvcc -c -o common.o common.cu -O3 -arch=sm_70 -gencode=arch=compute_70,code=sm_70
/usr/local/cuda/bin/nvcc -c -o TimingCPU.o TimingCPU.cpp -O3 -arch=sm_70 -gencode=arch=compute_70,code=sm_70
/usr/local/cuda/bin/nvcc -c -o TimingGPU.o TimingGPU.cu -O3 -arch=sm_70 -gencode=arch=compute_70,code=sm_70
/usr/local/cuda/bin/nvcc main1.o common.o TimingCPU.o TimingGPU.o -o msplit-alg1
example@server ~/DominationCylinders/split_matrixTrop_forward $ less Makefile
example@server ~/DominationCylinders/split_matrixTrop_forward $

```
