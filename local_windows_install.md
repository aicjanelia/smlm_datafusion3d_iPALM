# Building smlm_datafusion_3d_iPALM on Windows

These instructions are intended for a local installation of this repository on a Windows machine with a CUDA compatible GPU.  If you are comfortable with CMake and the underlying dependencies, you could also follow the more general instructions in the README.


## Intial Set Up

1. Clone or download this repository. The file location of the folder containing this repository will be referred to as `repoPATH` throughout these instructions.
2. Create a subfolder called dependences inside the repository to store the various files we will download or build: `repoPATH\dependencies`.
3. Download the [CUB library](https://nvlabs.github.io/cub/index.html), unzip the folder, and place it in your dependencies folder.
4. Download the [GLFW binaries](http://www.glfw.org/download.html). Choose the 64-bit Windows pre-compiled binaries, unzip the folder, and place it in your dependencies folder.
5. Download the Bio-Formats library from [OME](https://www.openmicroscopy.org/bio-formats/downloads) by choosing the Bio-Formats Package option.  Place the bioformats_package.jar file in your dependencies folder.


## Guided Installations

6. You will need MATLAB installed on your machine with the Parallel Computing Toolbox and the Statistics Toolbox.  To check your installed toolboxes, open MATALB on your system and type `ver` in the command window; the resulting display needs to include `distrib_computing_toolbox` and `statistics_toolbox`.
7. If you do not already have a version of Visual Studio, download and install it from [https://visualstudio.microsoft.com/](https://visualstudio.microsoft.com/). Follow the guided installation instructions, making sure to install the workload for _Desktop development with C++_.
8. If you do not already have a version of JAVA SDK, download the [Java SE Development Kit](https://www.oracle.com/java/technologies/downloads/#jdk18-windows) x64 Installer for Windows.
9. Install the [CUDA toolkit](https://developer.nvidia.com/cuda-downloads). Note this step requires Visual Studio, so please complete step 8 first.  Follow the prompts to choose your operating system and the version number. This installation has been tested with v11, but the required version may depend on your graphics card.
10. Install [CMake](https://cmake.org/download/). Under Latest Release, choose the Windows x64 Installer (not the Windows Source), which should be a .msi file. Follow the guided installation instructions.



## Building DIPimage
DIPimage is a required dependency for building this repository which itself requires its own build. These steps will walk you thorugh the basics of the [DIPlib Windows Installation Instructions](https://github.com/DIPlib/diplib/blob/master/INSTALL_Windows.md).

11. First download the source code for [The DIPImage toolbox](https://github.com/DIPlib/diplib/releases). Under the latest release (e.g., DIPlib version 3.3.0), download the source code (e.g., the zip file). Unzip the folder and place it in `repoPATH\dependencies`.
12. Open the CMake GUI. Click _Browse Source..._, navigate to `repoPATH\dependencies`, and choose the DIPlib folder you created in step 11. Click _Browse Build_, navigate to the same folder, create a new subfolder called `build` and choose this build folder.
13. Click on _Configure_. A popup window will ask you which generator to use.  You should select the version of Visual Studio you installed in step 7. Under the optional platform for generator, type `x64` and click ok.
14. There should be a list of name/value pairs, likely in red, in the middle of your CMake window.  You will fill in the appropriate values that are missing to move forward with the installation:
    - `CMAKE_INSTALL_PREFIX` should be set to the directory where DIPlib is to be installed.  For ease of later steps, set this to `repoPATH\dependences\DIPlib`.
    - `GLFW_INCLUDE_DIR` should point to the subfolder called `include` inside the GLFW folder you placed in `dependencies`.
    - `GLFW_LIBRARY` should point to the file `lib-vc2015\glfw3.lib` inside the GLFW folder you placed in `dependencies`.
    - `BIOFORMATS_JAR` should point to the bioformats_package.jar file you placed in `dependencies`. 
15. If any of these options are missing, first make sure that the option `DIP_BUILD_DIPVIEWER` is checked. Then click on _Configure_; the list of name/value pairs will update based on the new paths you have selected. If the only two options that remain red at this point are `OpenCV_DIR` and `Vigra_DIR`, click _Configure_ a second time to update the requirements.  If no red name/value pairs remain, move on to the next step.  If red pairs remain, make sure all paths are correctly specified; if options are still missing check the full [DIPlib Windows Installation Instructions](https://github.com/DIPlib/diplib/blob/master/INSTALL_Windows.md) to see what steps may have been missed. For example, if `BIOFORMATS_JAR` is not available as an option, the Java SDK could not be found, possibly because you skipped step 8 above.
16. Once all name/value pairs are no longer red, click _Generate_, which will create a Visual Studio solution file (.sln).
    - You may recieve a message about dox++ not being found. This is only necessary to generate documentation, and as such moving past this warning without fixing it will not cause issues with further steps.
17. Click on _Open Project_ in CMake (or open the .sln file from the build subfolder of DIPlib in `repoPATH\dependencies\`). This will open Visual Studio. Make sure the dropdown menus at the top of the screen are set to "Release" (not Debug) and x64, respectively.
18. There is a _Solution Explorer_ on the right hand side of the main Visual Studio screen. Right click on the _Install_ target and chose build. If you set your paths correctly in CMake, this will build and install everything to `repoPATH\dependences\DIPlib\`.
19. To check whether DIPlib built correctly, type the following commands in the MATLAB command window. If multiple windows and a DIPimage menu open, you can move on to building the repository. (You can close all the DIPlib generated windows).
```
p = `repoPATH\dependences\DIPlib`
addpath([p 'share\DIPimage'])
setenv('PATH',[p '\bin',';',getenv('PATH')]);
dipimage
```


## Building this repository (finally!)
20. Open CMake. Set _Browse Source..._ to `repoPATH`. Create a new subfolder to set _Browse Build..._ to `repoPATH\build`.
21. Make an install subfolder in `repoPATH\build`. Set `CMAKE_INSTALL_PREFIX` to this new folder: `repoPATH\build\install`.
22. You will need to set the `CUB_ROOT_DIR` to the CUB library you downloaded in step 2.
23. Click _Configure_. If MATLAB remains red, click _Configure_ a second time. If name/value pairs are still red, make sure all paths are set correctly.
24. Once no name/value pairs are red, click _Generate_.
25. Click _Open Project_ to open your .sln file in Visual Studio. Make sure the dropdown menus at the top of the screen are set to "Release" (not Debug) and x64, respectively.
26. In the _Solutions Explorer_, right click on `expdist` and build.
27. In the _Solutions Explorer_, right click on `guasstransform` and build.
28. Select all items under _Solutions Explorer_, right click and build.


## Next Steps
Now that this repository has been built, you can move on to using it to fuse together particles! Make sure that any code using this repository is correctly pointed to `repoPATH` and `repoPATH\build` as appropriate.
