{
    config,
    lib,
    ...
}:
with lib; {
    options.pos.servers = {
        acmeEmail = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Email address for Let's Encrypt ACME certificates.";
        };

        _nginx = mkOption {
            type = types.bool;
            default = false;
            internal = true;
            description = "True if a domain is set for any service.";
        };
    };

    imports = [
        ./authentik.nix
        ./gitea.nix
    ];

    config = mkIf config.pos.enable {
        services.nginx = mkIf config.pos.servers._nginx {
            enable = true;
            recommendedProxySettings = true;
            recommendedTlsSettings = true;
            commonHttpConfig = ''
                proxy_headers_hash_max_size 1024;
                proxy_headers_hash_bucket_size 128;
                log_format upstream '$remote_addr - [$time_local] "$request" $status upstream=$upstream_addr upstream_status=$upstream_status';
                access_log syslog:server=unix:/dev/log upstream;
            '';
        };

        security.acme = mkIf (config.pos.servers._nginx && config.pos.servers.acmeEmail != null) {
            acceptTerms = true;
            defaults.email = config.pos.servers.acmeEmail;
        };

        networking.firewall.allowedTCPPorts = [80 443];
    };
}
