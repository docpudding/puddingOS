{
    pkgs,
    lib,
    ...
}: {
    imports = [./hardware.nix];

    # Configure puddingOS modules.
    pos = {
        enable = true;

        session.tty1 = {
            autologinUser = "jack";
            autostart = "hyprland";
        };

        session.tty2 = {
            autologinUser = "jack";
            autostart = "startkodi";
        };

        limine.enable = true;
        tailscale.enable = true;

        hyprland.enable = true;
        steam.enable = true;
        kodi.enable = true;

        godot = {
            enable = true;
            enableRemoteDebug = true;
        };
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

    environment.systemPackages = with pkgs; [libreoffice-still moonlight-qt];
    home-manager.users.jack.imports = [./home.nix];

    hardware.graphics = {
        enable = true;
        extraPackages = [pkgs.intel-media-driver];
    };
}
