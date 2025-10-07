{
  description = "A Nix-flake-based Python development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              cudaSupport = true;
            };
          };
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs;
          [
            python312
            cudaPackages.cudatoolkit
          ]
          ++ (with pkgs.python312Packages; [
            arviz
            ipywidgets
            pillow
            jupyterlab
            matplotlib
            pandas
            pip
            playwright
            pymc
            # tensorflow
            (
              buildPythonPackage rec {
                pname = "ucimlrepo";
                version = "0.0.7";
                src = fetchPypi {
                  inherit pname version;
                  sha256 = "sha256-TP8/noFDZ91glW2pmazkcxlyN7n85MB+mmied7T/tZo=";
                };
                doCheck = false;
              }
            )
          ]);
        shellHook = ''
          echo "Python development environment with NumPy, Pandas, and PyTorch (CUDA)"
          export CUDA_PATH=${pkgs.cudaPackages.cudatoolkit}
          export LD_LIBRARY_PATH=${pkgs.cudaPackages.cudatoolkit}/lib64:$LD_LIBRARY_PATH
          echo "Run 'nvidia-offload python' to execute Python with NVIDIA GPU support"
        '';
      };
    });
  };
}
