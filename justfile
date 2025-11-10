set shell := ["nu", "-c"]

build:
    mkdir build
    cd build; ../configure --prefix=$env.RISCV --with-boost-libdir=($env.BOOST_ROOT)/lib
    cd build; make