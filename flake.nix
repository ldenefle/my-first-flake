{
  inputs = {
    msb.url = github:rrbutani/nix-mk-shell-bin;
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { flake-utils, msb, nixpkgs, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      shell = pkgs.mkShell {
        nativeBuildInputs = [
          pkgs.hello
          pkgs.coreutils
        ];
      };
      entrypoint = msb.lib.mkShellBin {
        nixpkgs = pkgs;
        drv = shell;
        bashPrompt = "[my-env]$ ";
      };
    in
    {
      devShells.default = shell;
      packages.container-image = pkgs.dockerTools.buildLayeredImage {
        name = "my-env-msb";
        tag = "latest";
        extraCommands = ''
          mkdir -m 1777 tmp
        '';
        config.Cmd = [ "${entrypoint}/bin/${entrypoint.name}" ];
      };
      packages.from-nix-image = pkgs.dockerTools.buildNixShellImage {
        name = "ldenefle/my-env-nix";
        tag = "latest";
        drv = shell;
      };
    }
  );
}
