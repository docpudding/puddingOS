{
    pkgs,
    config,
    lib,
    ...
}:
with lib; {
    imports = [./bindings.nix ./waybar.nix];

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

            configType = "lua";
            settings = {
                mod = {
                    _var = "SUPER";
                };

                # Autostart waybar on launch.
                on = {
                    _args = [
                        "hyprland.start"
                        (lib.generators.mkLuaInline ''
                            function()
                                hl.exec_cmd("waybar")
                            end
                        '')
                    ];
                };

                window_rule = [
                    {
                        match.class = "^(com.saivert.pwvucontrol)$";
                        fullscreen = true;
                    }
                    {
                        match.class = "^(com.saivert.pwvucontrol)$";
                        fullscreen_state = "3 3";
                    }
                    {
                        match.title = "^(Godot)$";
                        tile = true;
                    }
                ];

                config = {
                    general = {
                        layout = "dwindle";

                        # Style the window borders.
                        gaps_in = 2;
                        gaps_out = 2;
                        border_size = 2;
                        col = {
                            active_border = {
                                colors = [
                                    (lib.generators.mkLuaInline ''"rgba(" .. colors.mauveAlpha .. "ee)"'')
                                    (lib.generators.mkLuaInline ''"rgba(" .. colors.lavenderAlpha .. "ee)"'')
                                ];
                                angle = 45;
                            };
                            inactive_border = lib.generators.mkLuaInline ''"rgba(" .. colors.surface0Alpha .. "ee)"'';
                        };
                    };

                    # Define the primary tiling behaviour
                    dwindle = {
                        preserve_split = true;
                        split_width_multiplier = 1.25;
                    };

                    # Additional window styling.
                    decoration = {
                        rounding = 3;
                        blur.enabled = false;
                    };
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
                    splash = false;
                    wallpaper = [
                        {
                            monitor = "";
                            path = "~/stuff/wallpaper.png";
                        }
                    ];
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
