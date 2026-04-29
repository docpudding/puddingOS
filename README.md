# puddingOS: a high-level configuration layer for NixOS and Home Manager

## What even is this?

This project started as simply a repository to store my own Nix configurations which I made public in order to make cloning easier, and that is still one of its primary purposes. However, I eventually realized that I needed the system to be more modular/decoupled due to the fact that I was using it on several different types of machines with very different needs and purposes.

Also, I had spent a lot of time writing simple scripts and CLI tools for my own use that were genuinely helpful, such as a unified clipboard manager that works across both Wayland and X11 sesssions, as well as over SSH/Telnet connections. I wanted a way of bundling these tools with my Nix configurations so that they would be installed alongside them, without actually needing to apply the entire configuration setup just to use them.

The current iteration of puddingOS is structured as a set of mostly independent submodules. The syntax is designed to be consistent with common Nix module syntax:

```nix
pos.enable = true;
pos.grub.enable = true;
pos.grub.device = "/dev/sda";
```

The configurations above would fully install and enable the Grub bootloader on a NixOS system with puddingOS-specific customization options. Since `pos.grub.device` is set, it will use legacy BIOS boot mode instead of EFI.

## Should I use this?

The short answer is no, probably not. But certain parts of it might be useful to you if you are looking for something specific that happens to be covered by this project's scope. You might be interested in puddingOS if you care about any of these things:

- A complete starter Neovim environment for development.
- An option to log in to an isolated Gamescope session, i.e. "Boot to Steam Deck" behaviour that allows hot-swapping between Console Mode and Desktop Mode on the same machine.
- Several custom shell utilities for system maintenance, clipboard management, data synchronization, and more.
- Quick installation and fleshed-out starter configurations for any of the specific programs that are configurable through other puddingOS submodules.

Ultimately, my primary goal is to formalize my own configurations more so than it is to provide a public Nix module. So any features and support this project gets will be heavily biased towards my exact needs. But if any of those needs happen to overlap with your own, then you might benefit from puddingOS.

## Installation

There are several routes to installing puddingOS on your system depending on what you need. The first thing to understand is that it is composed of two independent parts: a NixOS module and a Home Manager module. The Home Manager module is treated as the default for most configurations, with the NixOS module only being used whenever system-level configuration is absolutely necessary (such as with the Grub and Limine submodules).

The Home Manager module can be installed on any Linux system that supports the Nix package manager, provided you are able to use it to install the standalone version of Home Manager. In theory it should work with nix-darwin as well, but this has not been tested. If you want to use the system-level NixOS module, you will need a machine that is actively running NixOS.

### Stable Nix Installation

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

### Flakes Installation

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

### Local Clone Import

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

## Usage

Extensive guides for configuring and using the various features of puddingOS can be found in the [full documentation](https://dr-pudding.github.io/pos).
