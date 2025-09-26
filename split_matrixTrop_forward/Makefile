NVCC        = /usr/local/cuda/bin/nvcc
NVCC_FLAGS  = -O3 -arch=sm_70 -gencode=arch=compute_70,code=sm_70
NVCC_SPEC_FLAGS = --default-stream per-thread
LD_FLAGS    = 
EXE1	    	= msplit-alg1
EXE2		= split_matrixTrop_forward

OBJ1	    	= main1.o common.o TimingCPU.o TimingGPU.o
OBJ2		= main2.o common.o TimingCPU.o TimingGPU.o

default: $(EXE1)

1: $(EXE1)

2: $(EXE2)

all: $(EXE1) $(EXE2) 

main1.o: main1.cu kernel1.cu common.h  
	$(NVCC) -c -o $@ main1.cu -DKERNEL1=0 -DMENSAJES $(NVCC_FLAGS) 

main2.o: main2.cu kernel1.cu common.h  
	$(NVCC) -c -o $@ main2.cu -DKERNEL1=0 -DMENSAJES $(NVCC_FLAGS) 

common.o: common.h common.cu
	$(NVCC) -c -o $@ common.cu $(NVCC_FLAGS)

TimingCPU.o: TimingCPU.h TimingCPU.cpp
	$(NVCC) -c -o $@ TimingCPU.cpp $(NVCC_FLAGS)

TimingGPU.o: TimingGPU.cuh TimingGPU.cu
	$(NVCC) -c -o $@ TimingGPU.cu $(NVCC_FLAGS)

$(EXE1): $(OBJ1)
	$(NVCC) $(OBJ1) -o $(EXE1) $(LD_FLAGS)

$(EXE2): $(OBJ2)
	$(NVCC) $(OBJ2) -o $(EXE2) $(LD_FLAGS)

clean:
	rm -rf *.o $(EXE1) $(EXE2)

