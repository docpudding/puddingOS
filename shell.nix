# This is the development shell for puddingOS.
{pkgs ? import <nixpkgs> {}}: let
    agenix = builtins.fetchGit {
        url = "https://github.com/ryantm/agenix.git";
        rev = "96e078c646b711aee04b82ba01aefbff87004ded";
    };
in
    pkgs.mkShell {
        packages = with pkgs; [
            # Testing environment for the custom CLI utilities.
            python3
            python3Packages.click
            (pkgs.callPackage "${agenix}/pkgs/agenix.nix" {})

            # For generating documentation.
            mdbook
        ];
    }
