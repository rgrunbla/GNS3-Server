{
  inputs = {
    nixpkgs.url = "nixpkgs/master";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-generators, ... }:
    with import nixpkgs { system = "x86_64-linux"; }; {
      # Development Shell
      devShell.x86_64-linux = mkShell {
        buildInputs = [
        ];
      };

      packages.x86_64-linux = {
        vm = callPackage ./serveur-gns3/base.nix {
          inherit nixos-generators nixpkgs;
          lib = nixpkgs.lib;
          pkgs = pkgs;
        };
        default = self.packages.x86_64-linux.vm;
      };
    };
}