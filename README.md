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







## Miscellaneous Notes

```
finish complete windows installation instructions to get the opengl nodejs to work
install cygwin 17
  comes with mintty
  install console 2 Console-2.00b148-Beta_32bit.zip
  install all the wget, build-essential stuff
  install zsh
    zsh theme = "gnzh"
    customize zsh config with my settings
      autoload -U compinit
      compinit -C
    apply the blue color config for mintty 
      http://superuser.com/questions/444558/how-do-i-change-the-unreadable-dark-blue-color-cygwin-uses-for-directories
    fix startup errors on cygwin; just append `restart` to `.zshrc`
  install tmux
    follow guide http://java.ociweb.com/mark/programming/tmuxInCygwin.html
      libevent-2.0.21-stable.tar.gz
      ncurses-5.9.tar.gz
    checkout 1.8 branch? maybe head will work too
    apply patch https://gist.github.com/10sr/5794078
    include CFLAGS -lcurses -static
  install gvim
    alias gvim="/cygdrive/c/Program\ Files\ \(x86\)/Vim/vim74/gvim.exe"
    alias ll="ls -l -a"
    mv /home/mike/.* ~/ && rm -rf /home/mike && ln -s ~ /home/mike
    chgrp -R Users ~/.ssh
    http://superuser.com/questions/397288/using-cygwin-in-windows-8-chmod-600-does-not-work-as-expected
    
    https://gist.github.com/epegzz/1634235
    
    http://stackoverflow.com/questions/235671/how-do-i-add-a-font-in-gvim-on-windows-system
    https://github.com/eugeneching/consolas-powerline-vim
    
    guifont=Consolas_for_Powerline_FixedD:h9:cANSI
    set encoding=utf-8
    set directory=.,$TEMP

package up my installer
  visual studio express edition for C++
  strongloop node or node 64-bit .msi
  cmake-2.6.4-win32-x86.exe
  glew-1.10.0-win32.zip
  glfw-3.0.3.bin.WIN64.zip
  FreeImage3154Win32.zip

see if i can find a way to get node compiled into single .exe stand-alone distributable

```
