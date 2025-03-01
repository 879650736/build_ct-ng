SHELL := /bin/bash

# Define the version number
VERSION := 1.27.0

# Define the URL for the tarball
TARBALL_URL := http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$(VERSION).tar.bz2

# Define the PGP key fingerprint
PGP_FINGERPRINT := 721B0FB1CDC8318AEBB888B809F6DD5F1F30EF2E

# Define the installation directory
TOOLDIR := $(HOME)/ct-ng-tool
WORKDIR := $(HOME)/ct-ng-work

test: apt download build install export_path local

all: download verify build install export_path

apt: sudo apt-get install -y gcc g++ \
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
