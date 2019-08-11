# sjasmplus
[![Build Status](https://api.cirrus-ci.com/github/ped7g/sjasmplus.svg)](https://cirrus-ci.com/github/ped7g/sjasmplus)
[![GitHub repo size in bytes](https://img.shields.io/github/repo-size/ped7g/sjasmplus.svg)](https://github.com/ped7g/sjasmplus/)
[![BSD 3-Clause License](https://img.shields.io/github/license/ped7g/sjasmplus.svg)](https://github.com/ped7g/sjasmplus/blob/master/LICENSE.md)
[![Coverage Status](https://coveralls.io/repos/github/ped7g/sjasmplus/badge.svg?branch=ped-master)](https://coveralls.io/github/ped7g/sjasmplus?branch=ped-master)

Command-line cross-compiler of assembly language for Z80 CPU. 

Supports many ZX-Spectrum specific directives, has built-in Lua scripting engine and 3-pass design.

For Linux/BSD/Windows/Dos. Make/Make Install or CMake installation methods for your convenience.

Main Features
=============

- Z80/R800/Z80N documented and undocumented opcodes support
- Very fast compilation: 1 million lines by 2-3 seconds on modern computer
- Code inlining through colon (`LD A,C:INC A:PUSH AF:IFDEF FX:LD A,D:ENDIF`…)
- Structures to define data structures in memory more easily (`STRUCT` pseudo-op)
- Conditional assembly
- Macro definitions
- Local labels
- User's messages
- Temporary labels
- Virtual device mode for common machines: ZX 128, ZX Next, ... (pseudo op `DEVICE`)
- Defines and array of defines
- Fake instructions as `LD HL,DE` (`LD H,D:LD L,E`) and more
- Source and binary file inclusion
- Multiline block comments
- Multi file output and file updating
- ZX Spectrum specific directives and pseudo ops (SAVESNA, SAVETAP, SAVEHOB, INCHOB, INCTRD...)
- ZX Spectrum Next specific features and directives (Z80N, 8ki memory paging, SAVENEX)
- Correctness is assured by Cirrus-CI with 140+ automated tests

This repository was created by import from original Aprisobal's repository @ https://sourceforge.net/projects/sjasmplus/.
