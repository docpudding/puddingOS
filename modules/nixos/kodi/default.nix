{
    pkgs,
    config,
    lib,
    ...
}:
with lib; {
    options.pos.kodi = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Kodi with a standalone X11 session.";
        };

        enableThirdPartyRepositories = mkOption {
            type = types.bool;
            default = false;
            description = "Enable third-party Kodi addon repositories.";
        };
    };
    config = mkIf (config.pos.kodi.enable && config.pos.enable) (let
        # Smirgol's repository hosts the actively maintained Crunchyroll addon.
        smirgolRepository = pkgs.kodiPackages.buildKodiAddon {
            pname = "repository-smirgol";
            namespace = "repository.smirgol";
            version = "1.0.1";
            src = pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/smirgol/crunchyroll_repo/refs/heads/main/repository.smirgol/repository.smirgol-1.0.1.zip";
                hash = "sha256-20xCc8i3eWS4asN2cXnwBnX3Qh+7Z373Z5eGcjya7Yw=";
            };
            nativeBuildInputs = [pkgs.unzip];
        };

        # Bundle Kodi with the additional addons and repositories.
        kodiWithAddons = pkgs.kodi.withPackages (p:
            with p;
                [joystick inputstream-adaptive]
                ++ optionals config.pos.kodi.enableThirdPartyRepositories [
                    smirgolRepository
                ]);

        # Build a standalone X session and run Kodi as the sole client.
        kodiSession = pkgs.writeShellScript "kodi-xsession" ''
            ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-1 --set "Colorspace" "Default" 2>/dev/null || true
            exec ${kodiWithAddons}/bin/kodi-standalone --windowing=x11
        '';
    in {
        # Enable Xorg without a display manager, since sessions are launched per TTY.
        services.xserver.enable = true;
        services.xserver.displayManager.startx.enable = true;

        environment.systemPackages = [
            kodiWithAddons

            # Start a Kodi session on the current TTY when ready.
            (pkgs.writeShellScriptBin "startkodi" ''
                for arg in "$@"; do
                    case "$arg" in
                        # Display usage information and exit.
                        --help)
                            echo "Usage: startkodi [OPTIONS]"
                            echo ""
                            echo "Launch a Kodi session via TTY."
                            echo ""
                            echo "Options:"
                            echo "  --help    Show this message and exit."
                            exit 0
                            ;;
                    esac
                done
                ${pkgs.systemd}/bin/systemctl --user start pipewire.service wireplumber.service pipewire-pulse.service
                exec startx ${kodiSession} -- vt''${XDG_VTNR:-3}
            '')
        ];
    });
}
