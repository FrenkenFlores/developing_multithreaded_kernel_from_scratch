#!/bin/bash
# This script will download and setup a GCC Cross Compiler.
# For more information read the documents from:
# https://wiki.osdev.org/GCC_Cross-Compiler

CURRENT_PATH="$(realpath $(dirname ${BASH_SOURCE[0]}))"

export PREFIX="${CURRENT_PATH}/cross"
export TARGET=i686-elf
export PATH="${PREFIX}/bin:${PATH}"

# Check if the GCC-Cross compiler already installed. Exit if it is.
if ! ${TARGET}-gcc --version || ! ${TARGET}-ld --version ; then
    # Update packages list.
    sudo apt update
    # Installing Dependencies.
    sudo apt install -y build-essential 2> /dev/null
    sudo apt install -y bison 2> /dev/null
    sudo apt install -y flex 2> /dev/null
    sudo apt install -y libgmp3-dev 2> /dev/null
    sudo apt install -y libmpc-dev 2> /dev/null
    sudo apt install -y texinfo 2> /dev/null
    sudo apt install -y libcloog-isl-dev 2> /dev/null
    sudo apt install -y libisl-dev 2> /dev/null
    # Clean.
    sudo apt autoremove -y 2> /dev/null

    DOWNLOADS="${CURRENT_PATH}/downloads"
    SRC="${CURRENT_PATH}/src"
    mkdir -p "${DOWNLOADS}"
    mkdir -p "${SRC}"


    BINUTILS_VER="2.39"
    # Download the source code of GNU Binutils.
    if [ ! -f "${DOWNLOADS}/binutils-${BINUTILS_VER}.tar.gz" ]; then
        wget https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.gz --directory-prefix=${DOWNLOADS}/
    fi

    # Unarchive Binutils.
    if [ ! -d "${SRC}/binutils-${BINUTILS_VER}" ]; then
        tar -xzvf ${DOWNLOADS}/binutils-${BINUTILS_VER}.tar.gz -C ${SRC}
    fi

    # Install Binutils.
    if [ ! -d "${SRC}/build-binutils" ]; then
        mkdir -p ${SRC}/build-binutils
        cd ${SRC}/build-binutils
        ${SRC}/binutils-${BINUTILS_VER}/configure --target=${TARGET} --prefix="${PREFIX}" --with-sysroot --disable-nls --disable-werror
        make
        make install
    fi
    cd ${CURRENT_PATH}

    GCC_VER="10.2.0"
    # Download GCC.
    if [ ! -f "${DOWNLOADS}/gcc-${GCC_VER}.tar.gz" ]; then
        wget http://ftp.ntua.gr/mirror/gnu/gcc/releases/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.gz --directory-prefix=${DOWNLOADS}/
    fi

    # Unarchive GCC.
    if [ ! -d "${SRC}/gcc-${GCC_VER}" ]; then
        tar -xzvf ${DOWNLOADS}/gcc-${GCC_VER}.tar.gz -C ${SRC}
    fi

    # Install Binutils.
    if [ ! -d "${SRC}/build-gcc" ]; then
        # The $PREFIX/bin dir _must_ be in the PATH. We did that above.
        which -- ${TARGET}-as || echo ${TARGET}-as is not in the PATH
        
        mkdir -p ${SRC}/build-gcc
        cd ${SRC}/build-gcc
        ${SRC}/gcc-${GCC_VER}/configure --target=${TARGET} --prefix="${PREFIX}" --disable-nls --enable-languages=c,c++ --without-headers
        make all-gcc
        make all-target-libgcc
        make install-gcc
        make install-target-libgcc
    fi
    cd ${CURRENT_PATH}
fi
