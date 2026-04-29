{
    pkgs,
    config,
    lib,
    ...
}:
with lib; let
    # Universal copy utility (currently supports wl-copy and osc52 over SSH).
    copy = pkgs.writers.writeBashBin "copy" ''
        # Get direct CLI input.
        if [ -t 0 ] && [ $# -gt 0 ]; then
            input="$*"
        elif [ -t 0 ]; then
            echo "No input provided." >&2
            exit 1

        # Get piped input
        else
            input=$(cat)
        fi

        # Handle input using appropriate clipboard backend.
        if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
            printf '\033]52;c;%s\007' "$(echo -n "$input" | base64)"
        elif [ -n "$WAYLAND_DISPLAY" ]; then
            echo -n "$input" | ${pkgs.wl-clipboard}/bin/wl-copy
        else
            echo "No supported clipboard method detected." >&2
            exit 1
        fi
    '';

    # Copy the contents of a file using the copy command.
    copycat = pkgs.writers.writeBashBin "copycat" ''
        if [ $# -eq 0 ]; then
          echo "No file specified." >&2
          exit 1
        fi

        if [ ! -f "$1" ]; then
          echo "Not a file." >&2
          exit 1
        fi

        cat "$1" | ${copy}/bin/copy
    '';
in {
    options.pos.shell.clipboard = {
        enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable clipboard management for multiple environments.";
        };
    };
    config = mkIf (config.pos.shell.enable
        && config.pos.enable) {
        home.packages = [
            copy
            copycat
            pkgs.wl-clipboard # Wayland clipboard manager (also required by pass).
        ];

        # Allows copy over SSH.
        programs.alacritty.settings.terminal.osc52 = "CopyPaste";

        # Clipboard history manager.
        services.cliphist = {
            enable = true;
            allowImages = true;
            systemdTargets = ["config.wayland.systemd.target"];

            extraOptions = [
                "-max-dedupe-search"
                "10"
                "-max-items"
                "500"
            ];
        };
    };
}
