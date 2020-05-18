# Zephyr Crosstool-NG

## Introduction

The `zephyr-crosstool-ng` repository contains the build system and tools to simplify the process of generating cross toolchains (binutils, gcc, newlib, ...) targeting the Zephyr RTOS.

`zephyr-crosstool-ng` is a fork of the [`crosstool-ng` project](https://github.com/crosstool-ng/crosstool-ng/).

The primary goal of this project is to provide a comprehensive toolchain support for the Zephyr RTOS developers:

- Multi-host platform support (Linux, macOS and Windows)
- Multi-target architecture support (ARC, ARM, NIOS2, RISC-V, x86, ...)
- Package-based distribution for simple installation and maintenance

## zephyr-crosstool-ng vs. crosstool-ng

The main differences between `zephyr-crosstool-ng` and `crosstool-ng` are as follows:

- [nano.specs support ("nano" variant of `newlib` and `libstdc++`)](https://github.com/stephanosio/zephyr-crosstool-ng/pull/9)
- [Zephyr RTOS targets (provided in the form of "samples")](https://github.com/stephanosio/zephyr-crosstool-ng/pull/16)
- [Zephyr RTOS-specific patches (used by the Zephyr RTOS targets)](https://github.com/stephanosio/zephyr-crosstool-ng/pull/16)

## zephyr-crosstool-ng vs. sdk-ng

The Zephyr [`sdk-ng`](https://github.com/zephyrproject-rtos/sdk-ng) (aka. Zephyr SDK) is a legacy software development kit for the Zephyr RTOS that is only available on the Linux hosts.

`sdk-ng` is similar to `zephyr-crosstool-ng` in that it uses `crosstool-ng` to build its toolchains (e.g. assembler, compiler, linker); however, it also includes a set of development tools such as QEMU and OpenOCD.

The plan is to eventually phase out the `sdk-ng` and replace it with the "SDK packages" that are available through various package distribution channels (e.g. snap, apt, brew, choco).

In the meantime, `zephyr-crosstool-ng` and `sdk-ng` will co-exist and be kept updated with each other.
