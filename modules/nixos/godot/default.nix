{
    pkgs,
    config,
    lib,
    ...
}:
with lib; {
    options.pos.godot = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Install the latest version of Godot Engine.";
        };

        enableMono = mkOption {
            type = types.bool;
            default = false;
            description = "Enable the latest Mono version of Godot Engine.";
        };

        enableRemoteDebug = mkOption {
            type = types.bool;
            default = false;
            description = "Open ports and add `godot-rdb` command for remote debugging.";
        };
    };

    config = mkIf config.pos.enable (mkMerge [
        (mkIf config.pos.godot.enable {
            environment.systemPackages = with pkgs; [godot];
        })

        (mkIf config.pos.godot.enableMono {
            environment.systemPackages = with pkgs; [
                godot-mono
                dotnet-sdk
            ];
        })

        (mkIf config.pos.godot.enableRemoteDebug {
            networking.firewall = mkIf config.pos.godot.enableRemoteDebug {
                allowedTCPPorts = [6007 6008];
                allowedUDPPorts = [6007 6008];
            };
        })
    ]);
}
