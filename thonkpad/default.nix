{
    pos,
    lib,
    ...
}: {
    imports = [
        ./hardware.nix

        # Extended local configurations.
        ./connections.nix
        ./msoe.nix
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
    };

    # Configure main NixOS user.
    users.users.jack = {
        isNormalUser = true;
        home = "/home/jack";
        extraGroups = ["wheel" "input" "docker"];
    };

    home-manager.users.jack = {
        imports = [
            pos.homeManagerModules.default
            ./home.nix
        ];
    };

    # Allow certain proprietary software sources.
    nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
            "Oracle_VirtualBox_Extension_Pack"
            "steam"
            "steam-unwrapped"
            "mongodb"
        ];

    # Network configuration.
    networking.hostName = "thonkpad";
    services.openssh.enable = true;

    # System configuration.
    time.timeZone = "America/Chicago";
    system.stateVersion = "25.11";
}
