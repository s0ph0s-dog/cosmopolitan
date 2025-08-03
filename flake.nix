{
  description = "Your build-once run-anywhere c library";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-25.05";

  outputs = {
    self,
    nixpkgs,
  }: let
    # System types to support.
    supportedSystems = ["x86_64-linux" "x86_64-darwin"]; #"aarch64-linux" "aarch64-darwin" ];

    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Nixpkgs instantiated for supported system types.
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      });
  in {
    formatter = forAllSystems (
      system: nixpkgs.legacyPackages.${system}.alejandra
    );

    overlays.default = final: prev: {
      cosmocc = final.callPackage ./package-cosmocc.nix {};
      s0ph0s-cosmopolitan = final.callPackage ./package.nix {
        cosmocc = final.cosmocc;
      };
    };

    packages = forAllSystems (system: {
      inherit (nixpkgsFor.${system}) s0ph0s-cosmopolitan;
      default = self.packages.${system}.s0ph0s-cosmopolitan;
    });

    nixosModules = let
      module = {
        lib,
        pkgs,
        config,
        ...
      }: let
        cfg = config.programs.ape;
      in {
        options.programs.ape.binfmt = lib.mkEnableOption ''
          Add binfmt-misc registration for the Actually Portable Executable
          loader (optional, reduces executable launch time by ~400ms).
        '';
        config = lib.mkIf cfg.binfmt {
          boot.binfmt.registrations.APE = {
            interpreter = "${pkgs.cosmopolitan.${pkgs.stdenv.hostPlatform.system}.default}/bin/ape";
            recognitionType = "magic";
            magicOrExtension = "MZqFpD";
            fixBinary = true;
            preserveArgvZero = true;
            wrapInterpreterInShell = false;
          };
        };
      };
    in {
      cosmopolitan = module;
      default = module;
    };
  };
}
