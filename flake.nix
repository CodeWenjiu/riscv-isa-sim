{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      utils,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              gnumake
              gcc
              autoconf
              automake
              libtool
              pkg-config
              dtc
              bison
              flex
              python3
              zlib
              # Boost: provide headers and libs (we'll expose include/lib paths to configure)
              boost
            ];

            # helpful hint when entering the dev shell and help configure find Boost
            shellHook = ''
              echo "Entered dev shell for riscv-isa-sim. To build: mkdir build && cd build && ../configure --prefix=\$RISCV --with-boost-libdir=(\$env.BOOST_ROOT)/lib/ && make"
              echo "If you haven't set RISCV to your riscv tools install path, do so now (nushell: let-env RISCV = \"~/riscv\")"
              # export BOOST_ROOT so autotools/AX_BOOST macros can find boost in the nix store
              export BOOST_ROOT=${pkgs.boost}
              # make sure configure can find headers/libs provided by the nix boost package
              export CPPFLAGS="-I${pkgs.boost}/include $CPPFLAGS"
              export LDFLAGS="-L${pkgs.boost}/lib $LDFLAGS"
              export LD_LIBRARY_PATH="${pkgs.boost}/lib:$LD_LIBRARY_PATH"
              # help the linker pick up boost regex/system when configure checks for -lboost_regex etc
              export LIBS="-lboost_regex -lboost_system $LIBS"
              echo "BOOST_ROOT set to: $BOOST_ROOT"
              echo "CPPFLAGS and LDFLAGS updated to include Nix boost paths"
              echo "If configure still can't find Boost, try: ../configure --with-boost=$BOOST_ROOT --prefix=\$RISCV"
            '';
        };
      }
    );
}
