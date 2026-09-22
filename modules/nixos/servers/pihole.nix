{
    config,
    lib,
    ...
}:
with lib; {
    options.pos.servers.pihole = {
        enable = mkEnableOption "Pi-hole DNS filtering and web dashboard.";

        domain = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Public domain to serve the Pi-hole dashboard on. Enables nginx and ACME when set.";
        };

        host = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = "Address nginx proxies to for the Pi-hole dashboard.";
        };

        port = mkOption {
            type = types.port;
            default = 8443;
            description = "Port Pi-hole's own TLS webserver listens on. Must not be 443.";
        };

        upstreamDNS = mkOption {
            type = types.listOf types.str;
            default = ["1.1.1.1" "9.9.9.9"];
            description = "Upstream DNS servers Pi-hole forwards non-blocked queries to.";
        };

        theme = mkOption {
            type = types.nullOr types.str;
            default = "catppuccin-macchiato";
            description = "Name of a theme from theme.park to inject into the dashboard.";
        };

        requireAuthentik = mkOption {
            type = types.bool;
            default = false;
            description = "Gate the dashboard behind Authentik forward auth.";
        };

        settings = mkOption {
            type = types.attrs;
            default = {};
            description = "Extra settings merged into services.pihole-ftl.settings, passed through directly.";
        };
    };

    config = mkMerge [
        (mkIf (config.pos.servers.pihole.domain != null) {
            pos.servers._nginx = true;
        })

        (mkIf (config.pos.enable && config.pos.servers.pihole.enable) {
            services.pihole-ftl = {
                enable = true;
                settings = recursiveUpdate {
                    dns.upstreams = config.pos.servers.pihole.upstreamDNS;
                }
                config.pos.servers.pihole.settings;
            };

            services.pihole-web = {
                enable = true;
                ports = ["${toString config.pos.servers.pihole.port}s"];
            };
        })

        (mkIf (config.pos.enable && config.pos.servers.pihole.enable && config.pos.servers.pihole.domain != null) {
            services.nginx.virtualHosts.${config.pos.servers.pihole.domain} = {
                enableACME = true;
                forceSSL = true;
                extraConfig = ''
                    proxy_set_header Host "${config.pos.servers.pihole.domain}";
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
                    proxy_set_header X-Forwarded-Host $host;
                    proxy_ssl_verify off;
                '';
                locations."/" = {
                    proxyPass = "https://${config.pos.servers.pihole.host}:${toString config.pos.servers.pihole.port}";
                    proxyWebsockets = true;
                };
            };
        })

        (mkIf (config.pos.enable && config.pos.servers.pihole.enable && config.pos.servers.pihole.domain != null && config.pos.servers.pihole.theme != null) {
            services.nginx.virtualHosts.${config.pos.servers.pihole.domain}.locations."/".extraConfig = ''
                proxy_set_header Accept-Encoding "";
                sub_filter '</head>' '<link rel="stylesheet" type="text/css" href="https://theme-park.dev/css/base/pihole/${config.pos.servers.pihole.theme}.css"></head>';
                sub_filter_once on;
                proxy_hide_header Content-Security-Policy;
                add_header Content-Security-Policy "default-src 'none'; base-uri 'none'; child-src 'self'; form-action 'self'; frame-src 'self'; font-src 'self'; connect-src 'self'; img-src 'self' https://raw.githubusercontent.com; manifest-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' https://raw.githubusercontent.com https://theme-park.dev 'unsafe-inline'";
            '';
        })

        (mkIf (config.pos.enable && config.pos.servers.pihole.enable && config.pos.servers.pihole.domain != null && config.pos.servers.pihole.requireAuthentik) {
            services.nginx.virtualHosts.${config.pos.servers.pihole.domain} = {
                locations."/".extraConfig = ''
                    auth_request /outpost.goauthentik.io/auth/nginx;
                    error_page 401 = @goauthentik_proxy_signin;
                    auth_request_set $auth_cookie $upstream_http_set_cookie;
                    add_header Set-Cookie $auth_cookie;
                    auth_request_set $authentik_username $upstream_http_x_authentik_username;
                    auth_request_set $authentik_groups $upstream_http_x_authentik_groups;
                    auth_request_set $authentik_entitlements $upstream_http_x_authentik_entitlements;
                    auth_request_set $authentik_email $upstream_http_x_authentik_email;
                    auth_request_set $authentik_name $upstream_http_x_authentik_name;
                    auth_request_set $authentik_uid $upstream_http_x_authentik_uid;
                    proxy_set_header X-authentik-username $authentik_username;
                    proxy_set_header X-authentik-groups $authentik_groups;
                    proxy_set_header X-authentik-entitlements $authentik_entitlements;
                    proxy_set_header X-authentik-email $authentik_email;
                    proxy_set_header X-authentik-name $authentik_name;
                    proxy_set_header X-authentik-uid $authentik_uid;
                '';

                locations."/outpost.goauthentik.io" = {
                    proxyPass = "http://${config.pos.servers.authentik.host}:${toString config.pos.servers.authentik.port}/outpost.goauthentik.io";
                    extraConfig = ''
                        proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
                        add_header Set-Cookie $auth_cookie;
                        auth_request_set $auth_cookie $upstream_http_set_cookie;
                        proxy_pass_request_body off;
                        proxy_set_header Content-Length "";
                    '';
                };

                locations."@goauthentik_proxy_signin".extraConfig = ''
                    internal;
                    add_header Set-Cookie $auth_cookie;
                    return 302 /outpost.goauthentik.io/start?rd=$scheme://$http_host$request_uri;
                '';
            };
        })
    ];
}
