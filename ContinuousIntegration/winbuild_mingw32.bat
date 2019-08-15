choco install -y --no-progress diffutils
@call ContinuousIntegration\winbuild_set_msys2_path.bat
rem MinGW build
mingw32-make -f Makefile.win clean
mingw32-make -f Makefile.win -j3
dir /N sjasmplus.exe
rem sjasmplus install
mingw32-make -f Makefile.win PREFIX=c:/tools/sjasmplus/ install
mingw32-make -f Makefile.win clean
rem check
dir /N c:\tools\sjasmplus
sjasmplus --version
