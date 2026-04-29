{
    lib,
    config,
    ...
}:
with lib; {
    config = mkIf (config.pos.hyprland.enable
        && config.pos.enable) {
        # Top status bar.
        programs.waybar = {
            enable = true;
            settings.main = {
                modules-left = ["custom/run" "hyprland/workspaces"];
                modules-center = ["clock"];
                modules-right = ["battery" "wireplumber" "custom/exit"];

                # Application launcher button.
                "custom/run" = {
                    format = "󰌽";
                    return-type = "json";
                    exec = "${./fuzzel-run-daemon.fish}";
                    on-click = "${./fuzzel-run.fish}";
                    tooltip = false;
                };

                # Current workspace tracker.
                "hyprland/workspaces" = {
                    "persistent-workspaces" = {
                        "eDP-1" = [1 2 3];
                        "DP-1" = [1 2 3];
                        "DP-2" = [2 4 6];
                        "HDMI-A-1" = [2 4 6];
                    };
                };

                # Time and date display.
                "clock" = {
                    format = "<span size='15900'>󰥔</span> {:%I:%M %p}";
                    format-alt = "<span size='15900'></span> {:%Y-%m-%d}";
                    tooltip = false;
                };

                "tray" = {
                    spacing = 8;
                };

                # Battery display for laptops/etc.
                "battery" = {
                    format = "<span size='12000'>{icon}</span> {capacity}%";
                    format-charging = "󰂄 {capacity}%";
                    format-plugged = "󰂄 {capacity}%";
                    format-discharging = "<span size='12000'>{icon}</span> {capacity}%";
                    tooltip = false;

                    # Notification warnings (I think...? test this at some point).
                    states = {
                        warning = 15;
                        critical = 5;
                    };

                    format-icons.default = [
                        "󰁺" # 0%
                        "󰁻" # 10%
                        "󰁼" # 20%
                        "󰁽" # 30%
                        "󰁾" # 40%
                        "󰁿" # 50%
                        "󰂀" # 60%
                        "󰂁" # 70%
                        "󰂁" # 80%
                        "󰂂" # 90%
                        "󰁹" # 100%
                    ];
                };

                # Volume display.
                "wireplumber" = {
                    format = "<span size='12000'>󰓃</span> {volume}%";
                    format-muted = "<span size='15900'>󰖁</span> {volume}%";
                    exec = "pwvucontrol";
                    on-click = "pwvucontrol";
                    tooltip = false;
                };

                "custom/exit" = {
                    format = "";
                    return-type = "json";
                    exec = "${./fuzzel-exit-daemon.fish}";
                    on-click = "${./fuzzel-exit.fish}";
                    tooltip = false;
                };

                # Additional style settings.
                height = 48;
                spacing = 4;
                margin-top = 2;
                margin-left = 2;
                margin-right = 2;
                margin-bottom = 2;
            };
        };

        # Styling for the top status bar.
        catppuccin.waybar = {
            enable = true;
            mode = "createLink";
        };
        xdg.configFile."waybar/style.css".source = ./waybar_style.css;

        # Main application launcher.
        programs.fuzzel = {
            enable = true;

            # Override the default Catppuccin styling.
            settings = {
                main = {
                    font = "OverpassM Nerd Font:size=7";
                    icons-enabled = false;
                    width = 24;
                    height = 24;
                    x-margin = 2;
                    y-margin = 2;
                };

                colors = {
                    background = "24273aff";
                    border = "c6a0f6ff";
                    prompt = "c6a0f6ff";

                    text = "cad3f5ff";
                    input = "cad3f5ff";
                    match = "c6a0f6ff";

                    selection = "5b6078ff";
                    selection-text = "#b7bdf8ff";
                    selection-input = "cad3f5ff";
                    selection-match = "c6a0f6ff";

                    # Not sure what these correspond to yet.
                    placeholder = "ff0000ff";
                    counter = "ff0000ff";
                };

                border = {
                    width = 2;
                    radius = 3;
                    selection-radius = 3;
                };
            };
        };
    };
}
