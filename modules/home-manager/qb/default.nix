{
    config,
    lib,
    ...
}:
with lib; {
    options.pos.qb = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable vim-like web browser.";
        };
    };

    config = mkIf (config.pos.qb.enable
        && config.pos.enable) {
        programs.qutebrowser = {
            enable = true;

            keyBindings.normal = {
                "<Ctrl+r>" = "forward";
                "<u>" = "back";
                "<U>" = "undo";
                "<Ctrl-o>" = "cmd-set-text -s :open -p";
            };

            settings = {
                content = {
                    plugins = true;

                    # Allow copy on-click.
                    javascript.clipboard = "access-paste";
                };

                # Use custom download directory.
                downloads.location.directory = "~/stuff/downloads";

                # Apply style customizations.
                colors = {
                    webpage.darkmode.enabled = false;
                    webpage.preferred_color_scheme = "dark";
                };

                fonts = {
                    default_family = "OverpassM Nerd Font";
                    default_size = "12pt";
                };
            };
        };
        catppuccin.qutebrowser.enable = true;

        # Define a shell alias to launch the browser slightly faster.
        programs.fish.shellAliases.qb = "qutebrowser";
    };
}
