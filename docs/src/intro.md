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

## How do I override?

If you intend on using a significant portion of the puddingOS modules, you will probably eventually want to make some changes to the defaults set by puddingOS. If you try to set a configuration value which is already defined by a module you have enabled, then the system rebuild will fail due to conflicting definitions. Most of the values set by puddingOS use the standard priority level, so you can override them like so:

```nix
pos.grub.enable = true;

# Will NOT work because the value is already defined when pos.grub is enabled.
grub.useOSProber = false;

# Use a higher priority level for your definition:
grub.useOSProber = lib.mkForce false;
```

If you aren't a fan of the Catppuccin styling, you can disable it this way as well. See the [Catppuccin Nix Documentation](https://nix.catppuccin.com) for more information.
