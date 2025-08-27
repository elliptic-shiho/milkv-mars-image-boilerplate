{
  description = "CrinoidOS Building environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
      pkg = nixpkgs.legacyPackages.${system};
      pkg_riscv64 =
        (import nixpkgs {
          inherit system;
          crossSystem.config = "riscv64-linux";
        })
        .buildPackages;
      in
      {
        devShells = {
          default = pkg.mkShell {
            buildInputs = [
              pkg.mtools
              pkg.dosfstools
              pkg.openssl
              pkg.gcc
              pkg.autoconf
              pkg.automake
              pkg.libconfuse
              pkg_riscv64.gcc
            ];

          shellHook = ''
            rustup update
            rustup target add riscv64gc-unknown-none-elf
            export PS1='\e[37m`LANG=C date`\e[0m \e[1;4m\w\e[0m\n(Milk-V Building Shell) > '
            echo " === Building shell ==="
          '';
          };
        };
      }
    );
}
