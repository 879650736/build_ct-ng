SHELL := /bin/bash

# Define the version number
VERSION := 1.27.0

# Define the URL for the tarball
TARBALL_URL := http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$(VERSION).tar.bz2

# Define the PGP key fingerprint
PGP_FINGERPRINT := 721B0FB1CDC8318AEBB888B809F6DD5F1F30EF2E

# Define the installation directory
TARGET := arm-unknown-linux-gnueabi
TOOLDIR := $(HOME)/ct-ng-tool
WORKDIR := $(HOME)/ct-ng-work
BUILDDIR := $(HOME)/x-tools
LOG_DIR := $(HOME)/build_toolchain/build_ct-ng/log

test: apt download build install export_path local

all: download verify build install export_path

apt: sudo apt update && sudo apt upgrade -y
	sudo apt-get install -y gcc g++ \
	build-essential gperf bison flex texinfo  \
	help2man make libncurses5-dev  \
	python3-dev autoconf automake libtool \
	libtool-bin gawk wget bzip2 xz-utils unzip 

# Target to download the tarball
download:
	if [ ! -f crosstool-ng-$(VERSION).tar.bz2 ]; then \
		wget -P . $(TARBALL_URL); \
	fi;

# Target to verify the PGP signature
verify:
	gpg --keyserver pgp.surfnet.nl --recv-keys $(PGP_FINGERPRINT); \
	wget -P . $(TARBALL_URL).sig; \
	if gpg --verify crosstool-ng-$(VERSION).tar.bz2.sig; then \
		echo "Signature verified successfully."; \
		rm crosstool-ng-$(VERSION).tar.bz2.sig; \
	else \
		echo "Signature verification failed."; \
		rm crosstool-ng-$(VERSION).tar.bz2.sig; \
		exit 1; \
	fi

# Target to build the project
build:
	if [ ! -d $(TOOLDIR) ]; then \
		mkdir -p $(TOOLDIR); \
	fi; \
	if [ ! -d crosstool-ng-$(VERSION) ]; then \
		tar -xjf crosstool-ng-$(VERSION).tar.bz2; \
	fi; \
	cd crosstool-ng-$(VERSION) && ./configure --prefix=$(TOOLDIR) && make

# Target to install the project
install:
	cd crosstool-ng-$(VERSION) && make install

# Target to export the PATH
export_path:
	@if ! grep -q "$(TOOLDIR)/bin" ~/.env_vars; then \
		echo "export PATH=$(TOOLDIR)/bin:\$$PATH" >> ~/.env_vars; \
	fi
	@echo "请执行以下命令完成配置:"
	@echo "source ~/.zshrc"

run: 
	mkdir -p $(WORKDIR)
	cd $(WORKDIR) && ct-ng menuconfig

help:
	mkdir -p $(WORKDIR)
	cd $(WORKDIR) && ct-ng help

local:
	cd crosstool-ng-$(VERSION);\
	./configure --enable-local;\
	make
#./ct-ng help
ctbuild:

	unset CFLAGS CXXFLAGS LDFLAGS LD_LIBRARY_PATH; \
	ct-ng build

ctinstall_env:
	echo "安装完成，配置环境变量..."
	@if ! grep -q "$(BUILDDIR)/$(TARGET)/bin" ~/.zshrc; then \
		echo "export PATH=$(BUILDDIR)/$(TARGET)/bin:\$$PATH" >> ~/.zshrc; \
	fi
	@if ! grep -q "$(BUILDDIR)/$(TARGET)/bin" ~/.bashrc; then \
		echo "export PATH=$(BUILDDIR)/$(TARGET)/bin:\$$PATH" >> ~/.bashrc; \
	fi
	echo "环境变量配置完成! 请手动执行: source ~/.zshrc"

compile_test:
	mkdir -p log
	@echo "Compiling test code with arm-unknown-linux-gnueabi-gcc..." | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/compile_test-$(DATE).log
	arm-unknown-linux-gnueabi-gccgo -o test_code/arm_test test_code/arm_test.go | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/compile_test-$(DATE).log
	arm-unknown-linux-gnueabi-gccgo -static -o test_code/arm_test_static test_code/arm_test.go | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/compile_test-$(DATE).log
	@echo "Compilation completed."

file:
	mkdir -p log
	@echo "display file type" | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/file-target-$(DATE).log
	file test_code/arm_test | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/file-target-$(DATE).log
	file test_code/arm_test_static | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/file-target-$(DATE).log

ldd:
	mkdir -p log
	@echo "display ldd" | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/ldd-target-$(DATE).log
	ldd test_code/arm_test | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/ldd-target-$(DATE).log
#ldd test_code/arm_test_static > static_ldd.log 2>&1 | tee -a $(LOG_DIR)/ldd-target.log

run_test:
	mkdir -p log
	@echo "Running compiled binary with qemu-arm..." | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/run_test-target-$(DATE).log
	@echo "begin first test" | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/run_test-target-$(DATE).log
	qemu-arm -L $(BUILDDIR)/$(TARGET) test_code/arm_test | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/run_test-target-$(DATE).log
	@echo "=========================================" | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/run_test-target-$(DATE).log
	@echo "begin static test" | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/run_test-target-$(DATE).log
	qemu-arm -L $(BUILDDIR)/$(TARGET) test_code/arm_test_static | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/run_test-target-$(DATE).log
	@echo "Test execution completed." | ts '[%Y-%m-%d %H:%M:%S]' | tee -a $(LOG_DIR)/run_test-target-$(DATE).log

clean:
	echo "删除无用文件..."
	@cd $(BUILDDIR); \
	rm -rf $(TARGET)
	echo "删除无用文件完成"