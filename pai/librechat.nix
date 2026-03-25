{
    pkgs,
    lib,
    ...
}: let
    unstable = import (fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
    }) {};
in {
    imports = [
        "${unstable.path}/nixos/modules/services/web-apps/librechat.nix"
    ];

    services.librechat = {
        enable = true;
        enableLocalDB = true;
        credentialsFile = "/etc/librechat/credentials.env";

        settings = {
            version = "1.0.8";
            cache = true;
            endpoints = {
                custom = [
                    {
                        name = "Ollama";
                        apiKey = "ollama";
                        baseURL = "http://localhost:11434/v1/";
                        models = {
                            default = ["llama3"];
                            fetch = true;
                        };
                        titleConvo = true;
                        titleModel = "current_model";
                        modelDisplayLabel = "Ollama";
                    }
                ];
            };
        };
    };

    services.ollama.enable = true;

    system.activationScripts.librechatCredentials = {
        deps = [];
        text = ''
                  mkdir -p /etc/librechat
                  chmod 700 /etc/librechat

                  if [ ! -f /etc/librechat/credentials.env ]; then
                    ${pkgs.openssl}/bin/openssl rand -hex 32 | tr -d '\n' > /tmp/creds_key
                    ${pkgs.openssl}/bin/openssl rand -hex 16 | tr -d '\n' > /tmp/creds_iv
                    ${pkgs.openssl}/bin/openssl rand -hex 32 | tr -d '\n' > /tmp/jwt_secret
                    ${pkgs.openssl}/bin/openssl rand -hex 32 | tr -d '\n' > /tmp/jwt_refresh_secret

                    cat > /etc/librechat/credentials.env << EOF
            CREDS_KEY=$(cat /tmp/creds_key)
            CREDS_IV=$(cat /tmp/creds_iv)
            JWT_SECRET=$(cat /tmp/jwt_secret)
            JWT_REFRESH_SECRET=$(cat /tmp/jwt_refresh_secret)
            EOF

                    rm /tmp/creds_key /tmp/creds_iv /tmp/jwt_secret /tmp/jwt_refresh_secret
                    chmod 600 /etc/librechat/credentials.env
                  fi
        '';
    };
}
