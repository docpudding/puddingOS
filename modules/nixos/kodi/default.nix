{
    pkgs,
    config,
    lib,
    ...
}:
with lib; {
    options.pos.kodi.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Kodi with a standalone X11 session.";
    };

    config = mkIf (config.pos.kodi.enable && config.pos.enable) (let
        # Bundle Kodi with the joystick peripheral addon so gamepads work.
        kodiWithAddons = pkgs.kodi.withPackages (p: with p; [joystick]);

        # Build a standalone X session and run Kodi as the sole client.
        kodiSession = pkgs.writeShellScript "kodi-xsession" ''
            exec ${kodiWithAddons}/bin/kodi-standalone --windowing=x11
        '';
    in {
        # Enable Xorg without a display manager, since sessions are launched per TTY.
        services.xserver.enable = true;
        services.xserver.displayManager.startx.enable = true;

        environment.systemPackages = [
            kodiWithAddons

            # Start a Kodi session on the current TTY.
            (pkgs.writeShellScriptBin "startkodi" ''
                exec startx ${kodiSession} -- vt''${XDG_VTNR:-3}
            '')
        ];
    });
}
