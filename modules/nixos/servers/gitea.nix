{
    config,
    lib,
    pkgs,
    ...
}:
with lib; let
    catppuccinTheme = pkgs.fetchzip {
        url = "https://github.com/catppuccin/gitea/releases/download/v1.0.2/catppuccin-gitea.tar.gz";
        sha256 = "sha256-rZHLORwLUfIFcB6K9yhrzr+UwdPNQVSadsw6rg8Q7gs=";
        stripRoot = false;
    };
in {
    options.pos.servers.gitea = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Gitea git hosting server.";
        };

        domain = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Public domain to serve Gitea on. Enables nginx and ACME when set.";
        };

        host = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = "Address Gitea's HTTP server binds to.";
        };

        port = mkOption {
            type = types.port;
            default = 3000;
            description = "Port Gitea's HTTP server listens on.";
        };

        enableSSH = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Gitea's built-in SSH server. Uses sshPort to avoid conflicting with the system SSH daemon.";
        };

        sshPort = mkOption {
            type = types.port;
            default = 2222;
            description = "Port for Gitea's built-in SSH server. Only used when enableSSH = true.";
        };

        allowRegistration = mkOption {
            type = types.bool;
            default = false;
            description = "Allow public user registration. Disabled by default.";
        };
    };
    config = mkMerge [
        (mkIf (config.pos.servers.gitea.domain != null) {
            pos.servers._nginx = true;
        })

        (mkIf (config.pos.enable && config.pos.servers.gitea.enable) {
            services.gitea = {
                enable = true;
                settings =
                    {
                        server =
                            {
                                HTTP_ADDR = config.pos.servers.gitea.host;
                                HTTP_PORT = config.pos.servers.gitea.port;
                                DISABLE_SSH = !config.pos.servers.gitea.enableSSH;
                                START_SSH_SERVER = config.pos.servers.gitea.enableSSH;
                            }
                            // optionalAttrs (config.pos.servers.gitea.domain != null) {
                                DOMAIN = config.pos.servers.gitea.domain;
                                ROOT_URL = "https://${config.pos.servers.gitea.domain}/";
                            }
                            // optionalAttrs config.pos.servers.gitea.enableSSH {
                                SSH_PORT = config.pos.servers.gitea.sshPort;
                            };
                        service = {
                            DISABLE_REGISTRATION = !config.pos.servers.gitea.allowRegistration;
                        };
                        ui = {
                            DEFAULT_THEME = "dark";
                            THEMES = "dark,light";
                        };
                    }
                    // optionalAttrs (config.pos.servers.gitea.domain != null) {
                        session = {
                            COOKIE_SECURE = true;
                        };
                    };
            };

            systemd.services.gitea = {
                preStart = lib.mkAfter ''
                    rm -rf ${config.services.gitea.stateDir}/custom/public/assets/css
                    mkdir -p ${config.services.gitea.stateDir}/custom/public/assets/css
                    cp ${catppuccinTheme}/theme-catppuccin-macchiato-lavender.css \
                        ${config.services.gitea.stateDir}/custom/public/assets/css/theme-dark.css
                    cp ${catppuccinTheme}/theme-catppuccin-latte-lavender.css \
                        ${config.services.gitea.stateDir}/custom/public/assets/css/theme-light.css
                '';
            };

            networking.firewall.allowedTCPPorts = mkIf config.pos.servers.gitea.enableSSH [config.pos.servers.gitea.sshPort];
        })

        (mkIf (config.pos.enable && config.pos.servers.gitea.enable && config.pos.servers.gitea.domain != null) {
            services.nginx.virtualHosts.${config.pos.servers.gitea.domain} = {
                enableACME = true;
                forceSSL = true;
                extraConfig = ''
                    proxy_set_header Host "${config.pos.servers.gitea.domain}";
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
                    proxy_set_header X-Forwarded-Host $host;
                '';
                locations."/" = {
                    proxyPass = "http://${config.pos.servers.gitea.host}:${toString config.pos.servers.gitea.port}";
                    proxyWebsockets = true;
                };
            };
        })
    ];
}
