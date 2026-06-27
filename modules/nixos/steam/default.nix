{
    pkgs,
    config,
    lib,
    ...
}:
with lib; {
    options.pos.steam = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Steam with Gamescope session.";
        };

        enableOverlayPatches = mkOption {
            type = types.bool;
            default = true;
            description = "Patch Gamescope to clear HDR connector state on VT switch.";
        };
    };

    config = mkIf (config.pos.steam.enable
        && config.pos.enable) {
        nixpkgs.overlays = optionals config.pos.steam.enableOverlayPatches [
            (final: prev: {
                gamescope = prev.gamescope.overrideAttrs (old: {
                    patches =
                        (old.patches or [])
                        ++ [
                            ./overlay.patch
                        ];
                });
            })
        ];

        programs = {
            # Main desktop gaming platform.
            steam = {
                enable = true;
                gamescopeSession.enable = true;
                remotePlay.openFirewall = true;
                dedicatedServer.openFirewall = true;
                localNetworkGameTransfers.openFirewall = true;

                # Overriding Steam's environment to allow evdev for input.
                extraCompatPackages = [];
            };

            # Isolated graphical environment for gaming.
            gamescope = {
                enable = true;
                capSysNice = true;
            };
        };

        # Disable HIDAPI, use evdev instead. Required for Xbox Controllers over Bluetooth.
        environment.sessionVariables = {
            SDL_JOYSTICK_HIDAPI = "0";
        };

        # Modern drivers for xinput.
        boot = {
            extraModulePackages = with config.boot.kernelPackages; [xpadneo];
            kernelModules = ["hid-xpadneo"];
        };

        environment.systemPackages = with pkgs; [
            gamescope-wsi # Required for extended Windows features like HDR.

            # Create a script to launch gamescope session via TTY.
            (pkgs.writeScriptBin "startgs" ''
                #!/usr/bin/env bash
                set -euo pipefail

                for arg in "$@"; do
                    case "$arg" in
                        # Display usage information and exit.
                        --help)
                            echo "Usage: startgs [OPTIONS]"
                            echo ""
                            echo "Launch a console-like Steam session via TTY."
                            echo ""
                            echo "Options:"
                            echo "  --no-hdr    Disable HDR output for this session."
                            echo "  --help      Show this message and exit."
                            exit 0
                            ;;
                    esac
                done

                set -x
                hdr=1

                for arg in "$@"; do
                    case "$arg" in
                        # Disable HDR output for this session.
                        --no-hdr) hdr=0 ;;
                    esac
                done

                gamescopeArgs=(
                    --adaptive-sync
                    --rt
                    --steam

                )
                if [[ "$hdr" == "1" ]]; then
                    gamescopeArgs+=(--hdr-enabled)
                fi

                steamArgs=(
                    -pipewire-dmabuf
                    -tenfoot
                )

                exec gamescope "''${gamescopeArgs[@]}" -- steam "''${steamArgs[@]}"
            '')
        ];
    };
}
