{
    config,
    lib,
    inputs ? {},
    ...
}:
with lib; {
    imports = optional (inputs ? authentik-nix) inputs.authentik-nix.nixosModules.default;

    options.pos.servers.authentik = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Authentik identity and access management server.";
        };
        domain = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Public domain to serve Authentik on. Enables nginx and ACME when set.";
        };
        host = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = "Host Authentik listens on.";
        };
        port = mkOption {
            type = types.port;
            default = 9000;
            description = "Port Authentik listens on.";
        };
        secretKey = mkOption {
            type = types.str;
            description = "Authentik secret key used for signing cookies and tokens.";
        };
        packages = mkOption {
            type = types.nullOr (types.attrsOf types.package);
            default = null;
            description = ''
                The authentik packages provided by authentik-nix.
                Add authentik-nix as a flake input and set:
                pos.servers.authentik.packages = authentik-nix.packages.''${system};
            '';
        };
    };
    config = mkMerge [
        (mkIf (config.pos.servers.authentik.domain != null) {
            pos.servers._nginx = true;
        })
        (mkIf (config.pos.enable && config.pos.servers.authentik.enable) {
            assertions = [
                {
                    assertion = (inputs ? authentik-nix) && config.pos.servers.authentik.packages != null;
                    message = ''
                        pos.servers.authentik requires packages to be set.
                        On flakes, add authentik-nix as a flake input and set:
                        pos.servers.authentik.packages = authentik-nix.packages.''${pkgs.system};
                        On non-flakes, import authentik-nix's NixOS module yourself and set
                        pos.servers.authentik.packages manually.
                    '';
                }
            ];
        })
        (optionalAttrs (inputs ? authentik-nix) (mkIf (config.pos.enable && config.pos.servers.authentik.enable && config.pos.servers.authentik.packages != null) {
            services.authentik = {
                enable = true;
                authentikComponents = config.pos.servers.authentik.packages;
                settings = {
                    secret_key = config.pos.servers.authentik.secretKey;
                    disable_startup_analytics = true;
                    avatars = "initials";
                    listen.listen_http = "${config.pos.servers.authentik.host}:${toString config.pos.servers.authentik.port}";
                };
            };
        }))
        (mkIf (config.pos.enable && config.pos.servers.authentik.enable && config.pos.servers.authentik.domain != null) {
            services.nginx.virtualHosts.${config.pos.servers.authentik.domain} = {
                enableACME = true;
                forceSSL = true;
                extraConfig = ''
                    proxy_set_header Host "${config.pos.servers.authentik.domain}";
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
                    proxy_set_header X-Forwarded-Host $host;
                    proxy_buffer_size 128k;
                    proxy_buffers 4 256k;
                    proxy_busy_buffers_size 256k;
                '';
                locations."/" = {
                    proxyPass = "http://${config.pos.servers.authentik.host}:${toString config.pos.servers.authentik.port}";
                    proxyWebsockets = true;
                };
            };
        })
    ];
}
