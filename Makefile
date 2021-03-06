# there are several steps that need to occur in this build system
# build/1_webpack webpack packs files into a compiled index.js
# build/2_packer nodegui-packer creates a standalone package directory
# build/3_dist stub.c is compiled and executable files are patched with icons
a     := fs_date_archivist
build := deploy/win32/build/$(name)
self  := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PATH  := $(self)\node_modules\.bin;$(PATH)

usage:
	@echo make
	@echo cli   : runs the cli
	@echo gui   : build and run the gui
	@echo build : build everything

cli:
	node src/cli

clean:
	-rd /s /q build

build: clean build~3
	-

build_1 := build/1_webpack/index.js
build_2 := build/2_packer/deploy/win32/build/fs_date_archivist
build_3 := build/3_dist
build~1: $(build_1)
	-
build~2: $(build_2)
	-
build~3: $(build_3)
	-

$(build_1): webpack.config.js $(wildcard src/*.js) $(wildcard res/*)
	webpack

$(build_2): $(build_1)
	-mkdir build\2_packer
	cd build\2_packer && nodegui-packer --init $a
	cd build\2_packer && nodegui-packer --pack ..\1_webpack

define set_icon =
	vendor/rcedit/rcedit-x64.exe $1 --set-icon res/icon.ico
endef

build/3_dist: $(build_2) src/stub.c
	-move $< $@
	clang $(word 2,$^) -Ofast -fuse-ld=lld -o $@/$a.exe
	$(call set_icon,$@/$a.exe)
	$(call set_icon,$@/qode.exe)

.PHONY: cli gui clean build
