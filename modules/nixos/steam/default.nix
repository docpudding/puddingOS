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
    };

    config = mkIf (config.pos.steam.enable
        && config.pos.enable) {
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

        # Create a script to launch gamescope session via TTY.
        environment.systemPackages = with pkgs; [
            gamescope-wsi # Required for extended Windows features like HDR.
            (pkgs.writeScriptBin "startgs" ''
                #!/usr/bin/env bash
                set -xeuo pipefail

                gamescopeArgs=(
                    --adaptive-sync
                    --hdr-enabled
                    --rt
                    --steam
                )

                steamArgs=(
                    -pipewire-dmabuf
                    -tenfoot
                )

                exec gamescope "''${gamescopeArgs[@]}" -- steam "''${steamArgs[@]}"
            '')
        ];
    };
}
