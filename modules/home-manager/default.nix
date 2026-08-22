{
    lib,
    config,
    ...
}: let
    # Install styling library for various applications, pinned to a specific commit.
    catppuccin = builtins.fetchGit {
        url = "https://github.com/catppuccin/nix.git";
        rev = "096f4670cf078d810a931fae59b57db4cc3fb4d3";
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
