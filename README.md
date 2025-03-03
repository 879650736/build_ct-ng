# Crosstool-NG 交叉工具链构建项目

## 项目概述

本项目用于自动化构建基于crosstool-ng的ARM交叉编译工具链，支持以下主要功能：

- 自动下载和验证crosstool-ng源码
- 构建定制化的交叉编译工具链
- 自动化测试工具链功能
- 环境变量自动配置

## 系统要求

- Ubuntu/Debian系Linux发行版(在ubuntu 24.04测试通过)

## 依赖安装

```bash
sudo apt update && sudo apt upgrade -y
sudo apt-get install -y gcc g++ \
	build-essential gperf bison flex texinfo  \
	help2man make libncurses5-dev  \
	python3-dev autoconf automake libtool \
	libtool-bin gawk wget bzip2 xz-utils\
	unzip dejagnu libcrypt-dev

```

## 安装步骤

### 1. 构建安装crosstool-ng

```bash
make install_ct-ng
```

### 2. 配置工具链

```bash
make run  
# 配置完成后保存退出
```

### 3. 构建交叉工具链

```bash
make build_cross_toolchain
```

## 关键配置参数


| 变量名        | 默认值                                     | 说明                 |
| ------------- | ------------------------------------------ | -------------------- |
| VERSION       | 1.27.0                                     | crosstool-ng版本号   |
| TARGET        | arm-unknown-linux-gnueabi                  | 目标架构             |
| TOOLDIR       | $(HOME)/ct-ng-tool                         | 工具安装目录         |
| CROSSTOOL_DIR | $(HOME)/x-tools                            | 生成的工具链存放目录 |
| BUILD_DIR     | $(HOME)/build_toolchain/build_ct-ng/.build | 构建临时目录         |
| LOG_DIR       | $(HOME)/build_toolchain/build_ct-ng/log    | 日志目录             |

## 常用命令

```makefile
make install_ct-ng      # 完整安装流程
make build_cross_toolchain  # 构建交叉工具链
make test               # 运行完整测试套件
make clean              # 清理构建产物
make help               # 查看ct-ng帮助信息
make local              # 编译本地模式ct-ng
```

## 测试验证

项目包含三级测试验证：

1. 编译测试：构建ARM架构测试程序
   ```bash
   make compile_test
   ```
2. 二进制文件验证：
   ```bash
   make file  # 验证文件类型
   make ldd   # 验证动态链接
   ```
3. QEMU模拟测试：
   ```bash
   make run_test  # 在模拟环境中运行测试程序
   ```

## 环境配置

构建完成后需要配置环境变量：

```bash
source ~/.zshrc  # 或 source ~/.bashrc
```

## 目录结构

```
build_ct-ng/
├── makefile                  # 主构建脚本
├── .config_arm               # arm配置文件
├── .config_arm_static        # 使用静态库的arm配置文件
├── test_code/                # 测试用例目录
│   ├── $(TEST_CODE).go           # Go语言测试用例
│   └── arm_test              # 编译后的测试程序
└── log/                      # 构建日志目录
```

## 注意事项

1. 构建过程中请保持网络连接稳定
