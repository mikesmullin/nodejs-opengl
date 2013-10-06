You have to carefully follow the installation instructions in the README of the node_modules/ included.
Then you can run the tests on each node_module, which are pretty impressive by themselves.

Basically install Visual Studio Express Edition 2012 with C++.

Then copy the .DLL files you need for GLEW, GLFW, FreeImage, etc. to:

C:\Windows\System32\

Then copy the 32-bit .LIB files to: 

C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\lib\

Then copy the 64-bit .LIB files to: 

C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\lib\amd64\

Then copy the .H files to:

C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\include\

Notice that the GLEW.h goes under:

C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\include\GL\