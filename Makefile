# Makefile for sjasmplus created by Tygrys' hands.
# install/uninstall features added, CFLAGS and LDFLAGS modification by z00m's hands. [05.05.2016]
# overall optimization and beautification by mborik's hands. [05.05.2016]
# overall rewrite by Ped7g [2019-03-21]
# added code coverage targets and variables by Ped7g [2019-07-22]

## Some examples of my usage of this Makefile:
# make DEBUG=1					- to get DEBUG build
# make tests 					- to run the CI test+example script runner
# make memcheck TEST=misc DEBUG=1		- to use valgrind on assembling sub-directory "misc" in tests
# make PREFIX=~/.local install			- to install release version into ~/.local/bin/
# make clean && make CC=gcc-8 CXX=g++-8		- to compile binary with gcc-8
# make DEBUG=1 LUA_COVERAGE=1 coverage		- to produce build/debug/coverage/* files by running the tests
# make COVERALLS_SERVICE=1 DEBUG=1 coverage	- to produce coverage data and upload them to https://coveralls.io/

# set up CC+CXX explicitly, because windows MinGW/MSYS environment don't have it set up
CC=gcc
CXX=g++
BASH=/usr/bin/env bash

PREFIX=/usr/local
INSTALL=install -c
UNINSTALL=rm -vf
REMOVEDIR=rm -vdf
DOCBOOKGEN=xsltproc
MEMCHECK=valgrind --leak-check=yes

EXE := sjasmplus
BUILD_DIR := build

SUBDIR_BASE=sjasm
SUBDIR_LUA=lua5.1
SUBDIR_TOLUA=tolua++
SUBDIR_DOCS=docs
SUBDIR_COV=coverage

CFLAGS := -Wall -pedantic -DUSE_LUA -DLUA_USE_LINUX -DMAX_PATH=PATH_MAX -I$(SUBDIR_LUA) -I$(SUBDIR_TOLUA) $(CFLAGS_EXTRA)
LDFLAGS := -ldl

ifdef DEBUG
BUILD_DIR := $(BUILD_DIR)/debug
CFLAGS += -g -O0
else
BUILD_DIR := $(BUILD_DIR)/release
CFLAGS += -DNDEBUG -O2
# for Linux (added strip flag)
LDFLAGS += -s
endif

# C++ flags (the CPPFLAGS are for preprocessor BTW, if you always wonder, like me...)
CXXFLAGS = -std=gnu++14 $(CFLAGS)
#full path to executable
EXE_FP := "$(CURDIR)/$(BUILD_DIR)/$(EXE)"

# UnitTest++ related values (slightly modified defaults)
# Unit Test exe (checks for "--unittest" and runs unit tests then)
EXE_UT := sjasm+ut
BUILD_DIR_UT := $(BUILD_DIR)+ut
SUBDIR_UT := unittest-cpp
SUBDIR_TESTS := cpp-src-tests
EXE_UT_FP := "$(CURDIR)/$(BUILD_DIR_UT)/$(EXE_UT)"

# turns list of %.c/%.cpp files into $BUILD_DIR/%.o list
define object_files
	$(addprefix $(BUILD_DIR)/, $(patsubst %.c,%.o, $(patsubst %.cpp,%.o, $(1))))
endef
define object_files_ut
	$(addprefix $(BUILD_DIR_UT)/, $(patsubst %.c,%.o, $(patsubst %.cpp,%.o, $(1))))
endef

# sjasmplus files
SRCS := $(wildcard $(SUBDIR_BASE)/*.c) $(wildcard $(SUBDIR_BASE)/*.cpp)
OBJS := $(call object_files,$(SRCS))
OBJS_UT := $(call object_files_ut,$(SRCS))

# liblua files
LUASRCS := $(wildcard $(SUBDIR_LUA)/*.c)
LUAOBJS := $(call object_files,$(LUASRCS))
LUAOBJS_UT := $(call object_files_ut,$(LUASRCS))

# tolua files
TOLUASRCS := $(wildcard $(SUBDIR_TOLUA)/*.c)
TOLUAOBJS := $(call object_files,$(TOLUASRCS))
TOLUAOBJS_UT := $(call object_files_ut,$(TOLUASRCS))

# UnitTest++ files
UTPPSRCS := $(wildcard $(SUBDIR_UT)/UnitTest++/*.cpp) $(wildcard $(SUBDIR_UT)/UnitTest++/Posix/*.cpp)
UTPPOBJS := $(call object_files,$(UTPPSRCS))
TESTSSRCS := $(wildcard $(SUBDIR_TESTS)/*.cpp)
TESTSOBJS := $(call object_files_ut,$(TESTSSRCS))

ALL_OBJS := $(OBJS) $(LUAOBJS) $(TOLUAOBJS)
ALL_OBJS_UT := $(OBJS_UT) $(LUAOBJS_UT) $(TOLUAOBJS_UT) $(UTPPOBJS) $(TESTSOBJS)
ALL_COVERAGE_RAW := $(patsubst %.o,%.gcno,$(ALL_OBJS_UT)) $(patsubst %.o,%.gcda,$(ALL_OBJS_UT))

# GCOV options to generate coverage files
ifdef COVERALLS_SERVICE
GCOV_OPT := -rlp
else
GCOV_OPT := -rlpmab
endif

#implicit rules to compile C/CPP files into $(BUILD_DIR)
$(BUILD_DIR)/%.o : %.c
	@mkdir -p $(@D)
	$(COMPILE.c) $(OUTPUT_OPTION) $<

$(BUILD_DIR)/%.o : %.cpp
	@mkdir -p $(@D)
	$(COMPILE.cc) $(OUTPUT_OPTION) $<

#implicit rules to compile C/CPP files into $(BUILD_DIR_UT) (with unit tests enabled)
$(BUILD_DIR_UT)/%.o : %.c
	@mkdir -p $(@D)
	$(COMPILE.c) -DADD_UNIT_TESTS -I$(SUBDIR_UT) $(OUTPUT_OPTION) $<

$(BUILD_DIR_UT)/%.o : %.cpp
	@mkdir -p $(@D)
	$(COMPILE.cc) -DADD_UNIT_TESTS -I$(SUBDIR_UT) $(OUTPUT_OPTION) $<

.PHONY: all install uninstall clean docs tests memcheck coverage

# "all" will also copy the produced binary into project root directory (to mimick old makefile)
all: $(EXE_FP)
	cp $(EXE_FP) "$(EXE)"

$(EXE_FP): $(ALL_OBJS)
	$(CXX) -o $(EXE_FP) $(CXXFLAGS) $(ALL_OBJS) $(LDFLAGS)

$(EXE_UT_FP): $(ALL_OBJS_UT)
	$(CXX) -o $(EXE_UT_FP) $(CXXFLAGS) $(ALL_OBJS_UT) $(LDFLAGS)

install: $(EXE_FP)
	$(INSTALL) $(EXE_FP) "$(PREFIX)/bin"

uninstall:
	$(UNINSTALL) "$(PREFIX)/bin/$(EXE)"

tests: $(EXE_UT_FP)
ifdef TEST
	EXE=$(EXE_UT_FP) $(BASH) "$(CURDIR)/ContinuousIntegration/test_folder_tests.sh" "$(TEST)"
else
	$(EXE_UT_FP) --unittest
	EXE=$(EXE_UT_FP) $(BASH) "$(CURDIR)/ContinuousIntegration/test_folder_tests.sh"
	@EXE=$(EXE_UT_FP) $(BASH) "$(CURDIR)/ContinuousIntegration/test_folder_examples.sh"
endif

memcheck: $(EXE_FP)
ifdef TEST
	MEMCHECK="$(MEMCHECK)" EXE=$(EXE_FP) $(BASH) "$(CURDIR)/ContinuousIntegration/test_folder_tests.sh" $(TEST)
else
	MEMCHECK="$(MEMCHECK)" EXE=$(EXE_FP) $(BASH) "$(CURDIR)/ContinuousIntegration/test_folder_tests.sh"
	MEMCHECK="$(MEMCHECK)" EXE=$(EXE_FP) $(BASH) "$(CURDIR)/ContinuousIntegration/test_folder_examples.sh"
endif

coverage:
	$(MAKE) CFLAGS_EXTRA=--coverage tests
	gcov $(GCOV_OPT) --object-directory $(BUILD_DIR_UT)/$(SUBDIR_BASE) $(SRCS)
ifdef LUA_COVERAGE
# by default the "external" lua sources are excluded from coverage report, sjasmplus is not focusing to cover+fix lua itself
# to get full coverage report, including the lua sources, use `make DEBUG=1 LUA_COVERAGE=1 coverage`
	gcov $(GCOV_OPT) --object-directory $(BUILD_DIR_UT)/$(SUBDIR_LUA) $(LUASRCS)
	gcov $(GCOV_OPT) --object-directory $(BUILD_DIR_UT)/$(SUBDIR_TOLUA) $(TOLUASRCS)
endif
ifndef COVERALLS_SERVICE
# coversall.io is serviced by 3rd party plugin: https://github.com/eddyxu/cpp-coveralls
# (from *.gcov files stored in project root directory, so not moving them here)
# local coverage is just moved from project_root to build_dir/coverage/
	@mkdir -p $(BUILD_DIR_UT)/$(SUBDIR_COV)
	mv *#*.gcov $(BUILD_DIR_UT)/$(SUBDIR_COV)/
endif

docs: $(SUBDIR_DOCS)/documentation.html ;

$(SUBDIR_DOCS)/documentation.html: Makefile $(wildcard $(SUBDIR_DOCS)/*.xml) $(wildcard $(SUBDIR_DOCS)/*.xsl)
	$(DOCBOOKGEN) \
		--stringparam html.stylesheet docbook.css \
		--stringparam generate.toc "book toc" \
		-o $(SUBDIR_DOCS)/documentation.html \
		$(SUBDIR_DOCS)/docbook-xsl-ns-html-customization-linux.xsl \
		$(SUBDIR_DOCS)/documentation.xml

clean:
	$(UNINSTALL) \
		"$(EXE)" \
		"$(EXE_UT)" \
		"$(BUILD_DIR)/$(EXE)" \
		"$(BUILD_DIR_UT)/$(EXE_UT)" \
		$(ALL_OBJS) \
		$(ALL_COVERAGE_RAW) \
		$(ALL_OBJS_UT) \
		$(BUILD_DIR_UT)/$(SUBDIR_COV)/*.gcov
	$(REMOVEDIR) \
		$(BUILD_DIR)/$(SUBDIR_BASE) \
		$(BUILD_DIR)/$(SUBDIR_LUA) \
		$(BUILD_DIR)/$(SUBDIR_TOLUA) \
		$(BUILD_DIR)/$(SUBDIR_UT)/UnitTest++/Posix \
		$(BUILD_DIR)/$(SUBDIR_UT)/UnitTest++ \
		$(BUILD_DIR)/$(SUBDIR_UT) \
		$(BUILD_DIR) \
		$(BUILD_DIR_UT)/$(SUBDIR_BASE) \
		$(BUILD_DIR_UT)/$(SUBDIR_LUA) \
		$(BUILD_DIR_UT)/$(SUBDIR_TOLUA) \
		$(BUILD_DIR_UT)/$(SUBDIR_TESTS) \
		$(BUILD_DIR_UT)/$(SUBDIR_COV) \
		$(BUILD_DIR_UT)/
