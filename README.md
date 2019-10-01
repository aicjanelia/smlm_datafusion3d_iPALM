# Software for Template-Free 3D Particle Fusion in Localization Microscopy.

This software implements a template-free particle fusion algorithm based on 
an all-to-all registration, which provides robustness against individual 
mis-registrations and underlabeling. The method does not assume any prior
knowledge about the structure to be reconstructed (template-free) and directly
works on localization data not pixelated images.

## Requirements

This code is built for a Linux enviroment. It might or might not work on a mac. 
For Windows a Linux shell environment could work.
For the CPU only code, no special libaries are needed for the compilation of 
the C code other than a C compiler.
For the GPU code, a CUDA compiler and libraries must be present and the 
CUB library, which can be specified to cmake. 

## Installation on Linux

### Get the sources

The Git repository uses submodules. Include them in a _git clone_ action using the _--recursive_ option.
```bash

git clone --single-branch --branch develop git@github.com:berndrieger/alltoall3D.git --recursive
````
### Compile the code
In the following

- BUILD_DIRECTORY is the directory where the project will be built
- SOURCE_DIRECTORY is the root directory of the sources
- CUB_DIRECTORY is the root directory of the downloaded [CUB library](https://nvlabs.github.io/cub/) sources
- MATLAB_DIRECTORY is the root of MATLAB installation directory (e.g. /usr/local/MATLAB/R2019a)

Use the following commands to build the necessary libraries for this software:

```bash

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_COMPILER=gcc-5 -DCUB_ROOT_DIR=CUB_DIRECTORY SOURCE_DIRECTORY
make
````
### Use the code
Next, we need to locate the built libraries for MATLAB:
```bash

cd ..
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:MATLAB_DIRECTORY/runtime/glnxa64:MATLAB_DIRECTORY/bin/glnxa64:MATLAB_DIRECTORY/sys/os/glnxa64:MATLAB_DIRECTORY/sys/opengl/lib/glnxa64:BUILD_DIRECTORY/mex
``` 
Then, run MATLAB
```bash
matlab
```
## Installation on Windows

To be written.

## Example Usage

The DIPImage toolbox for MATLAB is required, please see http://www.diplib.org 
for installation instructions.

An example of how to use the code on experimental and simulated data is shown
in the MATLAB script `demo_all2all.m`. 


## Installation instructions for GPU Version

The mex files that call GPU functions will only be compiled by the Makefile 
if you have *nvcc* (the Nvidia CUDA compiler) installed. Just type `make` in 
the top-level directory after you've made sure that you've installed CUDA 
and the CUB library, see the instructions below.

### CUDA

The GPU code requires a CUDA-capable GPU as well as the CUDA toolkit to be 
installed. Please see Nvidia's website for installation fo the CUDA toolkit 
(https://developer.nvidia.com/cuda-downloads).

### CUB Library

The GPU code currently has one dependency, which is the CUB library. You can 
download it from: https://nvlabs.github.io/cub/index.html The easiest way to 
install CUB is to add the directory where you unpack CUB to your ``$CPATH`` 
environment variable. The path to the CUB library can also be specified using
the ``"-DCUB_ROOT_DIR=<path-to-cub>"`` option of CMake.


## Troubleshooting

### Matlab mex headers not found

The Makefile tries to find the directories in which MATLAB was installed on 
your system. If this fails, you can manually insert the path to your MATLAB 
installation (ending with `/extern/include`) inside the Makefile. 

### CUDA headers not found

The Makefile also tries to automatically find the directories with headers 
and libraries needed to compile the CUDA codes. If this fails, these can as well be 
inserted at the top of the Makefile.

### <cub/cub.cuh> not found

The GPU code has only one external dependency, which is the CUB library. You 
can download it from: https://nvlabs.github.io/cub/index.html. The easiest 
way to install CUB is to add the top-level directory of where you've 
unpacked the CUB source codes to your ``$CPATH`` environment variable. For 
example, if you've unzipped the CUB sources into a directory called 
``/home/username/cub-version.number``, you can use 
``export CPATH=$CPATH:/home/username/cub-version.number/:`` to install CUB. In this way the 
nvcc compiler is able to find the CUB headers.

### Program tries to run GPU code when no GPU is present

Note that the mex files for the GPU code will be produced by `make` if your 
machine has `nvcc`. Once the mex files for the GPU code have been produced, 
the MATLAB code will prefer to use the GPU functions instead of the CPU 
functions. If you have no GPU available but did compile the mex files for 
the GPU code, you will get errors and MATLAB will exit. To disable the use 
of the GPU code type `make clean` and use `make cpu` instead of `make` or 
`make all`.

### Further questions

For further questions you can contact the authors
Hamidreza Heydarian <H.Heydarian@tudelft.nl> and
Ben van Werkhoven <b.vanwerkhoven@esciencecenter.nl>
Bernd Rieger <b.rieger@tudelft.nl>

Note that some files have been reused and adapted from the following sources:
GMM registration:
    https://github.com/bing-jian/gmmreg
	[1] Jian, B. & Vemuri, B. C. Robust point set registration using Gaussian 
    mixture models. IEEE PAMI 33, 16331645 (2011).

Lie-algebraic averaging:
    http://www.ee.iisc.ac.in/labs/cvl/research/rotaveraging/
    [2] Govindu, V. Lie-algebraic averaging for globally consistent motion estimation. 
    In Proc. IEEE Conf. on Computer Vision and Pattern Recognition (2004). 
    [3] Chatterjee, A. Geometric calibration and shape refinement for 3D reconstruction
    PhD thesis. Indian Institute of Science (2015).

l1-magic optimization toolbox:
    https://statweb.stanford.edu/~candes/l1magic/

Natural-Order Filename Sort
    https://nl.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort

## Developer instructions

The testing and tuning scripts for the GPU code have been written in Python, 
using [Kernel Tuner](https://github.com/benvanwerkhoven/kernel_tuner). This 
section provides information on how to setup a development environment. Note 
that these steps are only needed if you are interested in modifying the CUDA 
and C++ codes.

### Python 3

The tests for the GPU code and several of the C functions are written in 
Python, to run these a Python 3 installation is required. The easiest way to 
get this is using [Miniconda](https://conda.io/miniconda.html).

On Linux systems one could type the following commands to download and 
install Python 3 using Miniconda:
```
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```

All the required Python packages can be installed using the following command,
before you run it make sure that you have CUDA installed:
```
pip install -r requirements.txt
```

The tests can be run using ``nose``, for example by typing the following in 
the top-level or test directory:
```
nosetests -v
```
