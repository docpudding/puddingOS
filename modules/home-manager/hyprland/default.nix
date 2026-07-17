{
    pkgs,
    config,
    lib,
    ...
}:
with lib; {
    imports = [./waybar.nix];

    options.pos.hyprland = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable window manager and other DE features. Requires the corresponding NixOS module to be enabled.";
        };
    };

    config = mkIf (config.pos.hyprland.enable
        && config.pos.enable) {
        wayland.windowManager.hyprland = {
            enable = true;
            package = null;
            portalPackage = null;
            settings = {
                "$mod" = "SUPER";
                exec-once = ["waybar"];

                windowrulev2 = [
                    "fullscreen, class:^(com.saivert.pwvucontrol)$"
                    "fullscreenstate 3 3, class:^(com.saivert.pwvucontrol)$"
                    "tile, title:^(Godot)$"
                ];

                bind = [
                    # Quick-launch applications.
                    "$mod, T, exec, alacritty" # Terminal emulator shortcut.
                    "$mod, E, exec, alacritty -e fish -c \"rcd; exec fish\"" # File explorer shortcut.
                    "$mod, B, exec, qutebrowser" # Browser shortcut.

                    # Quick-launch utilities.
                    "$$mod, Z, exec, ${./fuzzel-run.fish}" # Application launcher shortcut.
                    "$mod, Q, exec, ${./fuzzel-exit.fish}" # Session management shortcut.
                    "$mod, L, exec, hyprlock" # Session locker shortcut.
                    ", Print, exec, hyprshot --mode region --output-folder $HOME/stuff/screenshots" # Screenshot shortcut.

                    # Manage windows.
                    "$mod, W, killactive"
                    "$mod, X, togglesplit"
                    "$mod, C, pseudo"
                    "$mod, V, togglefloating"

                    # Select active window.
                    "$mod, left, movefocus, l"
                    "$mod, right, movefocus, r"
                    "$mod, up, movefocus, u"
                    "$mod, down, movefocus, d"

                    # Move active window.
                    "$mod SHIFT, left, movewindow, l"
                    "$mod SHIFT, right, movewindow, r"
                    "$mod SHIFT, up, movewindow, u"
                    "$mod SHIFT, down, movewindow, d"

                    # Resize active window.
                    "$mod ALT, left, resizeactive, -64 0"
                    "$mod ALT, right, resizeactive, 64 0"
                    "$mod ALT, up, resizeactive, 0 -64"
                    "$mod ALT, down, resizeactive, 0 64"

                    # Swap workspaces.
                    "$mod, 1, workspace, 1"
                    "$mod, 2, workspace, 2"
                    "$mod, 3, workspace, 3"
                    "$mod, 4, workspace, 4"
                    "$mod, 5, workspace, 5"
                    "$mod, 6, workspace, 6"
                    "$mod, 7, workspace, 7"
                    "$mod, 8, workspace, 8"
                    "$mod, 9, workspace, 9"
                    "$mod, 0, workspace, 10"

                    # Move windows between workspaces.
                    "$mod SHIFT, 1, movetoworkspace, 1"
                    "$mod SHIFT, 2, movetoworkspace, 2"
                    "$mod SHIFT, 3, movetoworkspace, 3"
                    "$mod SHIFT, 4, movetoworkspace, 4"
                    "$mod SHIFT, 5, movetoworkspace, 5"
                    "$mod SHIFT, 6, movetoworkspace, 6"
                    "$mod SHIFT, 7, movetoworkspace, 7"
                    "$mod SHIFT, 8, movetoworkspace, 8"
                    "$mod SHIFT, 9, movetoworkspace, 9"
                    "$mod SHIFT, 0, movetoworkspace, 10"
                ];

                bindm = [
                    # Move/resize windows using the mouse.
                    "$mod, mouse:272, movewindow"
                    "$mod, mouse:273, resizewindow"
                ];

                bindle = [
                    ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"
                    ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"
                    ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
                    ", XF86AudioPlay, exec, playerctl play-pause"
                    ", XF86AudioNext, exec, playerctl next"
                    ", XF86AudioPrev, exec, playerctl previous"
                    ", XF86MonBrightnessUp, exec, brightnessctl set 10%+"
                    ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
                ];

                general = {
                    layout = "dwindle";

                    # Style the window borders.
                    gaps_in = 2;
                    gaps_out = 2;
                    border_size = 2;
                    "col.active_border" = "rgba($mauveAlphaee) rgba($lavenderAlphaee) 45deg";
                    "col.inactive_border" = "rgba($surface0Alphaee)";
                };

                # Define the primary tiling behaviour
                dwindle = {
                    pseudotile = "yes";
                    preserve_split = "yes";
                    split_width_multiplier = 1.25;
                };

                # Additional window styling.
                decoration = {
                    rounding = 3;
                    blur.enabled = false;
                };
            };
        };
        catppuccin = {
            hyprland.enable = true;
            cursors.enable = true;
        };

        services = {
            # Use custom desktop wallpaper.
            hyprpaper = {
                enable = true;
                settings = {
                    preload = ["~/stuff/wallpaper.png"];
                    wallpaper = [",~/stuff/wallpaper.png"];
                };
            };

            # Notification daemon (not well configured, waiting for a necessary use case)
            dunst.enable = true;
        };
        catppuccin.dunst.enable = true;

        # Copy over the default wallpaper if one has not been assigned.
        home.activation.copyWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
            if [ ! -f ${config.home.homeDirectory}/stuff/wallpaper.png ]; then
              mkdir -p ${config.home.homeDirectory}/stuff
              cp ${./cat-waves.png} ${config.home.homeDirectory}/stuff/wallpaper.png
            fi
        '';

        # Session locker utility.
        programs.hyprlock = {
            enable = true;
            settings = {
                source = "${./hyprlock_style.conf}";

                animations = {
                    fade_in.duration = 300;
                    fade_out.duration = 300;
                };

                background = {
                    path = "~/stuff/wallpaper.png";
                    blur_passes = 3;
                };
            };
        };
        catppuccin.hyprlock.enable = false;

        home.packages = with pkgs; [
            hyprshot # Screenshot utility.
            playerctl # Media control (play, pause, etc.)
            pwvucontrol # Graphical audio control utility.
            brightnessctl # Laptop backlight control
            libnotify # Notification tools
            inotify-tools # Waybar wants this for some reason
        ];
    };
}
