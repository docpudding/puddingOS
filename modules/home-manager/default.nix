{
    lib,
    config,
    ...
}: let
    catppuccin = builtins.fetchTarball {
        url = "https://github.com/catppuccin/nix/archive/release-25.11.tar.gz";
        sha256 = "0p9v37l8fvm15ziig45ragqfk581584mgl425v1nkqrnkafzl8i3";
    };
in {
    # Import dependencies and submodules.
    imports = [
        (catppuccin + "/modules/home-manager")
        ./hyprland
        ./mangohud
        ./qb

        ./shell
        ./vi
    ];

    # Configuration for toggling puddingOS and other submodules.
    options.pos = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable puddingOS core module for Home Manager.";
        };
    };

    config = lib.mkMerge [
        # Core module (base configuration).
        (lib.mkIf config.pos.enable {
            catppuccin = {
                flavor = "macchiato";
                accent = "lavender";
            };
        })
    ];
}
