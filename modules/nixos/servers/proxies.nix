{
    config,
    lib,
    ...
}:
with lib; let
    proxyOpts = {
        options = {
            domain = mkOption {
                type = types.str;
                description = "Public domain to serve this proxy on. Enables nginx and ACME.";
            };

            host = mkOption {
                type = types.str;
                default = "127.0.0.1";
                description = "Backend host address.";
            };

            port = mkOption {
                type = types.port;
                description = "Backend port.";
            };

            proxyWebsockets = mkOption {
                type = types.bool;
                default = true;
                description = "Whether to proxy WebSocket connections.";
            };

            requireAuthentik = mkOption {
                type = types.bool;
                default = false;
                description = "Gate this proxy behind Authentik forward auth.";
            };
        };
    };

    authentikLocations = {
        "/outpost.goauthentik.io" = {
            proxyPass = "http://${config.pos.servers.authentik.host}:${toString config.pos.servers.authentik.port}/outpost.goauthentik.io";
            extraConfig = ''
                proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
                add_header Set-Cookie $auth_cookie;
                auth_request_set $auth_cookie $upstream_http_set_cookie;
                proxy_pass_request_body off;
                proxy_set_header Content-Length "";
            '';
        };

        "@goauthentik_proxy_signin".extraConfig = ''
            internal;
            add_header Set-Cookie $auth_cookie;
            return 302 /outpost.goauthentik.io/start?rd=$scheme://$http_host$request_uri;
        '';
    };
in {
    options.pos.servers.proxies = mkOption {
        type = types.attrsOf (types.submodule proxyOpts);
        default = {};
        description = "Arbitrary reverse-proxy entries forwarded through nginx with ACME TLS.";
    };

    config = mkMerge [
        (mkIf (config.pos.servers.proxies != {}) {
            pos.servers._nginx = true;
        })

        (mkIf (config.pos.enable && config.pos.servers.proxies != {}) {
            services.nginx.virtualHosts = mapAttrs' (
                name: proxy:
                    nameValuePair proxy.domain {
                        enableACME = true;
                        forceSSL = true;
                        extraConfig = ''
                            proxy_set_header Host "${proxy.domain}";
                            proxy_set_header X-Real-IP $remote_addr;
                            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                            proxy_set_header X-Forwarded-Proto $scheme;
                            proxy_set_header X-Forwarded-Host $host;
                        '';
                        locations =
                            {
                                "/" = {
                                    proxyPass = "http://${proxy.host}:${toString proxy.port}";
                                    proxyWebsockets = proxy.proxyWebsockets;
                                    extraConfig = optionalString proxy.requireAuthentik ''
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
                                };
                            }
                            // optionalAttrs proxy.requireAuthentik authentikLocations;
                    }
            )
            config.pos.servers.proxies;
        })
    ];
}
