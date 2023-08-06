#!/bin/bash

THREADS=36
DATE=$(date +"%Y%m%d")

mkdir -p /pkg
rm -rf /pkg/$DATE
mkdir -p /pkg/$DATE
mkdir -p /pkg/$DATE/gnu
mkdir -p /pkg/$DATE/gnu/mpich
mkdir -p /pkg/$DATE/gnu/openmpi
rm -rf /pkg/gnu
ln -sf /pkg/$DATE/gnu /pkg/gnu
cp -r ./gnu/* /pkg/$DATE/gnu

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

ask "https://www.mpich.org/static/downloads/4.1.2/mpich-4.1.2.tar.gz" "/pkg/$DATE/gnu/mpich-4.1.2" "" "gcc" "" "mpich-4.1.2"

ask "https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.5.tar.gz" "/pkg/$DATE/gnu/openmpi-4.1.5" "" "gcc" "" "openmpi-4.1.5"

module load mpich/4.1.2

ask "https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_14_1-2.tar.gz" "/pkg/$DATE/gnu/mpich/hdf5-1_14_1-2" "--enable-unsupported=yes --enable-fortran=yes --enable-fortran2003=yes --enable-hl=yes --enable-hltools=yes --enable-tools=yes --enable-shared=yes --enable-static=yes --enable-fast-install=yes --enable-parallel=yes --enable-build-all=yes" "mpicc" "mpifort" "hdf5-hdf5-1_14_1-2"

module load hdf5-mpich/1.14.1-2

ask "https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.2.tar.gz" "/pkg/$DATE/gnu/mpich/netcdf-c-4_9_2" "" "mpicc" "mpifort" "netcdf-c-4.9.2"

module load netcdf-c-mpich/4.9.2

ask "https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.1.tar.gz" "/pkg/$DATE/gnu/mpich/netcdf-fortran-4_6_1" "" "mpicc" "mpifort" "netcdf-fortran-4.6.1"

module load netcdf-fortran-mpich/4.6.1

ask "http://www.gfd-dennou.org/library/gtool/gtool5/gtool5_current.tgz" "/pkg/$DATE/gnu/mpich/gtool5-20160613" "--with-netcdf=/pkg/$DATE/gnu/mpich/netcdf-c-4_9_2/lib/libnetcdf.a --with-netcdf=/pkg/$DATE/gnu/mpich/netcdf-fortran-4_6_1/lib/libnetcdff.a --with-netcdf-include=/pkg/$DATE/gnu/mpich/netcdf-fortran-4_6_1/include FC=mpifort" "mpicc" "mpifort" "gtool5-20160613"

module unload netcdf-c-mpich/4.9.2

ask "https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.2.tar.gz" "/pkg/$DATE/gnu/mpich/netcdf" "" "mpicc" "mpifort" "netcdf-c-4.9.2"

module load netcdf-mpich/current

ask "https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.1.tar.gz" "/pkg/$DATE/gnu/mpich/netcdf" "" "mpicc" "mpifort" "netcdf-fortran-4.6.1"


module purge
module load openmpi/4.1.5

ask "https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_14_1-2.tar.gz" "/pkg/$DATE/gnu/openmpi/hdf5-1_14_1-2" "--enable-unsupported=yes --enable-fortran=yes --enable-fortran2003=yes --enable-hl=yes --enable-hltools=yes --enable-tools=yes --enable-shared=yes --enable-static=yes --enable-fast-install=yes --enable-parallel=yes --enable-build-all=yes" "mpicc" "mpifort" "hdf5-hdf5-1_14_1-2"

module load hdf5-openmpi/1.14.1-2

ask "https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.2.tar.gz" "/pkg/$DATE/gnu/openmpi/netcdf-c-4_9_2" "" "mpicc" "mpifort" "netcdf-c-4.9.2"

module load netcdf-c-openmpi/4.9.2

ask "https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.1.tar.gz" "/pkg/$DATE/gnu/openmpi/netcdf-fortran-4_6_1" "" "mpicc" "mpifort" "netcdf-fortran-4.6.1"

module load netcdf-fortran-openmpi/4.6.1

ask "http://www.gfd-dennou.org/library/gtool/gtool5/gtool5_current.tgz" "/pkg/$DATE/gnu/openmpi/gtool5-20160613" "--with-netcdf=/pkg/$DATE/gnu/openmpi/netcdf-c-4_9_2/lib/libnetcdf.a --with-netcdf=/pkg/$DATE/gnu/openmpi/netcdf-fortran-4_6_1/lib/libnetcdff.a --with-netcdf-include=/pkg/$DATE/gnu/openmpi/netcdf-fortran-4_6_1/include FC=mpifort" "mpicc" "mpifort" "gtool5-20160613"

module unload netcdf-c-openmpi/4.9.2

ask "https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.2.tar.gz" "/pkg/$DATE/gnu/openmpi/netcdf" "" "mpicc" "mpifort" "netcdf-c-4.9.2"

module load netcdf-openmpi/current

ask "https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.1.tar.gz" "/pkg/$DATE/gnu/openmpi/netcdf" "" "mpicc" "mpifort" "netcdf-fortran-4.6.1"

