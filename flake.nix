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
            graphviz
          ]
          ++ (with pkgs.python312Packages; [
            folium
            plotly
            scikit-learn
            geopandas
            shapely
            graphviz
            seaborn
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
            (
              buildPythonPackage rec {
                pname = "kagglehub";
                version = "0.3.13";
                src = fetchPypi {
                  inherit pname version;
                  sha256 = "sha256-08i2JQYn1mUJbNkalIdVm/XtYb5gfq9j0UURsg7qZG4=";
                };
                doCheck = false;
                format = "pyproject";
                nativeBuildInputs = with pkgs.python312Packages; [
                  hatchling
                ];
                propagatedBuildInputs = with pkgs.python312Packages; [
                  pyyaml
                  requests
                  tqdm
                ];
              }
            )
          ]);
        shellHook = ''
          echo "Python development environment with CUDA"
          export CUDA_PATH=${pkgs.cudaPackages.cudatoolkit}
          export LD_LIBRARY_PATH=${pkgs.cudaPackages.cudatoolkit}/lib64:$LD_LIBRARY_PATH
        '';
      };
    });
  };
}
