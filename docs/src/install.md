# Installation

There are several routes to installing puddingOS on your system depending on what you need. The first thing to understand is that it is composed of two independent parts: a NixOS module and a Home Manager module. The Home Manager module is treated as the default for most configurations, with the NixOS module only being used whenever system-level configuration is absolutely necessary (such as with the Grub and Limine submodules).

The Home Manager module can be installed on any Linux system that supports the Nix package manager, provided you are able to use it to install the standalone version of Home Manager. In theory it should work with nix-darwin as well, but this has not been tested. If you want to use the system-level NixOS module, you will need a machine that is actively running NixOS.

## Stable Nix Installation

You can install and import one or both modules into your existing Nix configurations:

```nix
{ ... }: let
    pos = builtins.fetchTarball {
        url = "https://github.com/dr-pudding/pos/archive/release-25.11.tar.gz";
    };

    # Optional: required for puddingOS home-manager module.
    home-manager = builtins.fetchTarball {
        url = "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";
    };
in {
    imports = [ "${pos}/modules/nixos" ];
    pos.enable = true;

    home-manager.users.USERNAME = {
        imports = [ "${pos}/modules/home-manager" ];
        pos.enable = true;
    };
}
```

## Flakes Installation

Add puddingOS as a flake input alongside nixpkgs and home-manager:

```nix
{
    inputs = {
        pos.url = "github:dr-pudding/pos/release-25.11";
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

        # Optional: required for puddingOS home-manager module.
        home-manager = {
            url = "github:nix-community/home-manager/release-25.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { nixpkgs, home-manager, pos, ... }: {
        nixosConfigurations.HOSTNAME = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            # Optional: required for imported modules to access pos options.
            specialArgs = { inherit pos; };

            modules = [
                home-manager.nixosModules.home-manager
                pos.nixosModules.default

                ({ pos, ... }: {
                    pos.enable = true;

                    home-manager.users.USERNAME = {
                        imports = [ pos.homeManagerModules.default ];
                        pos.enable = true;
                    };
                })
            ];
        };
    };
}
```

## Local Clone Import

The examples above are written with the assumption that you are are purely a user and are not making any changes to the puddingOS configuration directly. If you want to develop/modify puddingOS (beyond just overriding it from your own configurations), you will need to clone the repository manually:

```sh
git clone https://github.com/dr-pudding/pos /path/to/pos
```

Import the modules directly from their local paths rather than URLs:

```nix
imports = [ /modules/nixos ];
home-manager.users.USERNAME.imports = [ /path/to/pos/modules/home-manager ];
```

For a flakes-based system, you would just need to change the input url:

```nix
inputs.pos.url = "path:/path/to/pos";
```

Keep in mind that if you are using flakes and want to continue rebuilding without `--impure` then you must clone within the same root directory as your flake file. For most NixOS users, this is probably somewhere in `/etc/nixos`. If are like me and do not like accessing your configurations directly from that path, you could create a symbolic link. My own setup looks something like this:

```sh
git clone https://github.com/dr-pudding/pos /etc/nixos
chown USERNAME /etc/nixos/pos
ln -s /etc/nixos/pos /home/USERNAME/.pos
```

If you don't like that approach, you could also just define a shortcut via an environmental variable or simply rebuild with `--impure`.
