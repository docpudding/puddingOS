{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.pos;

    agenix = builtins.fetchGit {
        url = "https://github.com/ryantm/agenix.git";
        rev = "96e078c646b711aee04b82ba01aefbff87004ded";
    };

    # Install styling library for various applications.
    catppuccin = builtins.fetchTarball {
        url = "https://github.com/catppuccin/nix/archive/release-25.11.tar.gz";
        sha256 = "0p9v37l8fvm15ziig45ragqfk581584mgl425v1nkqrnkafzl8i3";
    };
in {
    # Configuration for toggling puddingOS and other submodules.
    options.pos = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable puddingOS core module with basic drivers and more.";
        };

        sddm.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable display manager and login greeter.";
        };

        hyprland.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable window manager and desktop environment.";
        };
    };

    # Import dependencies and submodules.
    imports = [
        "${catppuccin}/modules/nixos"
        "${agenix}/modules/age.nix"
        ./sessions.nix
        ./grub
        ./limine
        ./godot
        ./steam
        ./cmd
    ];

    config = lib.mkMerge [
        # Core module (base configuration).
        (lib.mkIf cfg.enable {
            nix.settings.experimental-features = ["nix-command" "flakes"];

            # OpenGL drivers with legacy support.
            hardware.graphics = {
                enable = true;
                enable32Bit = lib.mkIf (pkgs.system == "x86_64-linux") true;
            };

            # Pipewire audio drivers with PulseAudio support.
            services.pipewire = {
                enable = true;
                pulse.enable = true;
            };

            # Unified color and styling for system applications.
            catppuccin = {
                flavor = "macchiato";
                accent = "lavender";
                tty.enable = true;
            };

            # Main font set for system applications.
            fonts.packages = [pkgs.nerd-fonts.overpass];

            environment.systemPackages = [
                (pkgs.callPackage "${agenix}/pkgs/agenix.nix" {})
            ];
        })

        # SDDM module (display manager).
        (lib.mkIf (cfg.sddm.enable && cfg.enable) {
            services.displayManager.sddm = {
                enable = true;
                wayland.enable = true;
                package = pkgs.kdePackages.sddm;
            };

            catppuccin.sddm = {
                enable = true;
                font = "OverpassMNerdFont";
                fontSize = "12";
            };
        })

        # Hyprland module (desktop environment).
        (lib.mkIf (cfg.hyprland.enable && cfg.enable) {
            programs.hyprland = {
                enable = true;
                xwayland.enable = true;
            };
        })
    ];
}
