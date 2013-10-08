# Node.JS OpenGL

The point of this is to make cross-platform 3d game development easy with:

* CoffeeScript (minimal syntax assists with continuation passing, enumeration, and parallel programming flow control)
* Node.JS (performant libuv async i/o, libev event loop, v8 javascript interpreter)
* OpenGL (free cross-platform video acceleration)

## Installation on Windows 8 64-bit 

Install StrongLoop or regular node .msi. I'm using 64-bit so its important to grab the correct installer which is kind of hidden sometimes.
 
Install Visual Studio 2012 Express for Windows Desktop - English (with C++)
I also installed Update 3 when it prompted it, but its probably unnecessary
http://www.microsoft.com/visualstudio/eng/downloads

Install node-gyp binary
```bashrc
npm install node-gyp -g # make sure its in path
```

also need to install python 2.7x! and add it to PATH
http://www.python.org/ftp/python/2.7.5/python-2.7.5.amd64.msi

Download all the .dll and .lib from here:
https://github.com/mikeseven/node-native-graphics-deps/tree/master/win32

Move the .DLL files (they are for GLEW, GLFW, FreeImage, AntTweakBar) to:

`C:\Windows\System32\`

Then copy the 32-bit .LIB files to: 

`C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\lib\`

Then copy the 64-bit .LIB files to: 

`C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\lib\amd64\`

Then run:

```bash
git clone # ...
npm install
```

## Usage

```bash
npm start
```









## TODO:

* see if i can find a way to get node compiled into single .exe stand-alone distributable


## Miscellaneous Notes:

When developing in Visual Studio 2012:

If there are any .H files, copy to:

`C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\include\`

Notice that the GLEW.h goes under:

`C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\include\GL\`


latest vers (unused)
http://softlayer-dal.dl.sourceforge.net/project/glfw/glfw/3.0.3/glfw-3.0.3.bin.WIN32.zip
http://hivelocity.dl.sourceforge.net/project/glfw/glfw/3.0.3/glfw-3.0.3.bin.WIN64.zip
http://softlayer-dal.dl.sourceforge.net/project/freeimage/Binary%20Distribution/3.15.4/FreeImage3154Win32.zip
http://downloads.sourceforge.net/project/anttweakbar/AntTweakBar_116.zip?r=http%3A%2F%2Fanttweakbar.sourceforge.net%2Fdoc%2Ftools%3Aanttweakbar%3Adownload&ts=1381188645&use_mirror=softlayer-dal