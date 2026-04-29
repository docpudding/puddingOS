{
    pkgs,
    config,
    lib,
    ...
}:
with lib; let
    cfg = config.pos.sessions;

    # Creates a session for a specific user with no login needed.
    mkAutoSession = tty: cmd: {
        name = "autovt@${tty}";
        value = {
            overrideStrategy = "asDropin";
            serviceConfig = {
                ExecStart = [
                    ""
                    "@${pkgs.util-linux}/sbin/agetty agetty --login-program ${pkgs.shadow}/bin/login --autologin ${cfg.autologinUser} --noclear - $TERM"
                ];
            };
        };
    };
    mkProfileEntry = tty: cmd: ''
        if [[ "$(tty)" == "/dev/${tty}" ]]; then
            exec ${cmd}
        fi
    '';
in {
    options.pos.sessions = {
        autologinUser = mkOption {
            type = types.str;
            default = "";
            example = "tux";
            description = "Skip password login to set a default user for all TTYs.";
        };
        autostart = mkOption {
            type = types.attrsOf types.str;
            default = {};
            example = {
                tty1 = "hyprland";
                tty2 = "startgs";
            };
            description = "Map of TTY names to commands to autostart on login.";
        };
    };

    config = mkIf config.pos.enable {
        # Setup autologin configuration if a user is defined.
        services.getty.autologinUser = mkIf (cfg.autologinUser != "") cfg.autologinUser;
        systemd.services =
            mkIf (cfg.autologinUser != "" && cfg.autostart != {})
            (mapAttrs' mkAutoSession cfg.autostart);

        # Create an autostart script for configured TTYs.
        environment.loginShellInit =
            concatStringsSep "\n" (mapAttrsToList mkProfileEntry cfg.autostart);

        # Warn if TTY1 is overridden while sddm is enabled.
        warnings = mkIf (config.pos.sddm.enable && cfg.autostart ? "tty1") [
            "An autostart command has been configured on TTY1 while the SDDM module is enabled. SDDM typically runs on TTY1 and may conflict."
        ];
    };
}
