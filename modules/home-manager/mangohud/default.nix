{
    lib,
    config,
    ...
}:
with lib; {
    options.pos.mangohud = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable performance profiler. Toggle with F3.";
        };
    };

    config = mkIf (config.pos.mangohud.enable
        && config.pos.enable) {
        programs.mangohud = {
            enable = true;
            enableSessionWide = true;

            settings = {
                table_columns = 3;

                # Background
                background_color = "24273A";
                background_alpha = 0.8;
                round_corners = 10;

                # Text
                font_size = 24;
                text_color = "CAD3F5";
                text_outline_color = "363A4F";

                # GPU
                gpu_stats = true;
                gpu_temp = true;

                gpu_text = "GPU";
                gpu_color = "A6DA95";

                gpu_load_change = true;
                gpu_load_color = "CAD3F5,F5A97F,ED8796";

                # CPU
                cpu_stats = true;
                cpu_temp = true;

                cpu_text = "CPU";
                cpu_color = "8AADF4";

                cpu_load_change = true;
                cpu_load_color = "CAD3F5,F5A97F,ED8796";

                # RAM
                ram = true;
                ram_color = "F5BDE6";

                # Other
                arch = true;
                wine = true;
                winesync = true;
                wine_color = "ED8796";
                engine_color = "ED8796";

                # Minecraft-adjacent keybind.
                toggle_hud = "F3";
                no_display = true;
            };
        };
    };
}
