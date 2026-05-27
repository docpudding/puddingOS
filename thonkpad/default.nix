{
    pkgs,
    pos,
    lib,
    ...
}: {
    imports = [
        ./hardware.nix

        # Extended local configurations.
        ./connections.nix
    ];

    # Configure puddingOS modules.
    pos = {
        enable = true;
        grub.enable = true;
        hyprland.enable = true;
        steam.enable = true;
        sessions = {
            autologinUser = "jack";
            autostart.tty1 = "hyprland";
        };
        godot = {
            enable = true;
            enableRemoteDebug = true;
        };
    };

    # Configure ThinkPad nipple.
    hardware.trackpoint = {
        enable = true;
        sensitivity = 64;
        speed = 97;
        emulateWheel = true;
    };

    # Configure main NixOS user.
    users.users.jack = {
        isNormalUser = true;
        home = "/home/jack";
        extraGroups = ["wheel" "input" "docker"];
    };

    # Network configuration.
    networking.hostName = "thonkpad";
    services.openssh.enable = true;

    # System configuration.
    time.timeZone = "America/Chicago";
    system.stateVersion = "25.11";

    # Allow certain proprietary software sources.
    nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
            "Oracle_VirtualBox_Extension_Pack"
            "steam"
            "steam-unwrapped"
            "mongodb"
        ];

    environment.systemPackages = with pkgs; [cloudflared libreoffice-still];

    home-manager.users.jack = {
        imports = [
            pos.homeManagerModules.default
            ./home.nix
        ];
    };
}
