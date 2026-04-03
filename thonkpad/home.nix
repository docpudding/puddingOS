{...}: {
    imports = [../home.nix];
    wayland.windowManager.hyprland.settings.monitor = [
        "eDP-1, 1920x1200@60, 0x0, 1"
    ];

    # Configure puddingOS modules.
    pos = {
        enable = true;

        # Terminal modules.
        shell = {
            enable = true;
            rgr.enable = true;
        };
        vi.enable = true;

        # Desktop modules.
        hyprland.enable = true;
        mangohud.enable = true;
        qb.enable = true;
    };
}
