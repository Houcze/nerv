#!/bin/bash

THREADS=36
DATE=$(date +"%Y%m%d")

mkdir -p /pkg
mkdir -p /pkg/$DATE
mkdir -p /pkg/$DATE/cintel
rm -rf /pkg/cintel
ln -sf /pkg/$DATE/cintel /pkg/cintel
cp -r ./cintel/* /pkg/$DATE/cintel

cd /src

ask() {
    local url=$1
    local prefix=$2
    local configure_options=$3
    local compiler=$4
    local fortran_compiler=$5
    local name=$(basename $url)
    local dir_name=$6

    if [ ! -f $name ]; then
        wget $url
    fi

    tar xvf $name
    cd $dir_name
    if [ -n "$compiler" ]; then
        export CC=$compiler
    fi
    if [ -n "$fortran_compiler" ]; then
        export FC=$fortran_compiler
    fi
    chmod 755 ./configure
    ./configure --prefix=$prefix $configure_options

    if [ "$dir_name" == "gtool5-20160613" ]; then
        includedir=$(nf-config --includedir)
        sed -i "s|SYSFFLAGS=.*|SYSFFLAGS=-I$includedir|g" Config.mk
    fi

    make -j$THREADS
    make install

    cd ..
    rm -rf $dir_name
}

module purge

module load icc mpi

CC=mpiicc
CXX=mpiicc
FC=mpiifort

ask "https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_14_1-2.tar.gz" "/pkg/$DATE/cintel/hdf5-1_14_1-2" "--enable-unsupported=yes --enable-fortran=yes --enable-fortran2003=yes --enable-hl=yes --enable-hltools=yes --enable-tools=yes --enable-shared=yes --enable-static=yes --enable-fast-install=yes --enable-parallel=yes --enable-build-all=yes" "mpiicc" "mpiifort" "hdf5-hdf5-1_14_1-2"

module load hdf5-cintel

ask "https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.2.tar.gz" "/pkg/$DATE/cintel/netcdf-c-4_9_2" "" "mpiicc" "mpiifort" "netcdf-c-4.9.2"

module load netcdf-c-cintel

ask "https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.1.tar.gz" "/pkg/$DATE/cintel/netcdf-fortran-4_6_1" "" "mpiicc" "mpiifort" "netcdf-fortran-4.6.1"

module load netcdf-fortran-cintel

ask "http://www.gfd-dennou.org/library/gtool/gtool5/gtool5_current.tgz" "/pkg/$DATE/cintel/gtool5-20160613" "--with-netcdf=/pkg/$DATE/cintel/netcdf-c-4_9_2/lib/libnetcdf.a --with-netcdf=/pkg/$DATE/cintel/netcdf-fortran-4_6_1/lib/libnetcdff.a --with-netcdf-include=/pkg/$DATE/cintel/netcdf-fortran-4_6_1/include FC=mpiifort" "mpiicc" "mpiifort" "gtool5-20160613"

module unload netcdf-c-cintel

ask "https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.2.tar.gz" "/pkg/$DATE/cintel/netcdf" "" "mpiicc" "mpiifort" "netcdf-c-4.9.2"

module load netcdf-cintel

ask "https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.1.tar.gz" "/pkg/$DATE/cintel/netcdf" "" "mpiicc" "mpiifort" "netcdf-fortran-4.6.1"
