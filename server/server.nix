{
    pkgs,
    authentik-nix,
    ...
}: {
    imports = [./server];

    pos.server = {
        acmeEmail = "jackmj@proton.me";

        # cloudflare = {
        #     enable = true;
        #     token = "eyJhIjoiMDY4ZTE3ZjdiNGZlNjBmYWZhZTUwMjBkMjZiNTI2OTgiLCJ0IjoiMTU3NzBhMDYtYzlkNi00MWI0LTlkMmEtNzQzYjYyYjFjOWE1IiwicyI6IllqRTFNR1V3WWpNdFpEQTVPUzAwTWpFMExXSmxOV0V0Tm1VME1XVmpNRFk0WWpJNCJ9";
        # };

        # authentik = {
        #     enable = true;
        #     domain = "auth.drpudd.ing";
        #     packages = authentik-nix.packages.${pkgs.system};
        #     secretKey = "1gYQBrwX5qs_7HZs8IwteYGLviP7xS90rGQz3G356y0";
        # };
        #
        gitea = {
            enable = true;
            enableSSH = true;
            domain = "git.drpudd.ing";
        };

        #termix = {
        #enable = true;
        #enableBundlePatches = true;
        #domain = "drpudd.ing";
        #authentikHost = "192.168.1.116";
        #};
        # synapse = {
        #     enable = false;
        #     domain = "matrix.drpudd.ing";
        #     serverName = "drpudd.ing";
        #     secretsFile = ./synapse.age;
        # };
        #
        #  element = {
        #      enable = false;
        #      domain = "chat.drpudd.ing";
        #      homeserverUrl = "https://matrix.drpudd.ing";
        #      serverName = "drpudd.ing";
        #  };
    };

    networking = {
        usePredictableInterfaceNames = false;
        defaultGateway = "192.168.1.254";
        nameservers = ["1.1.1.1" "8.8.8.8"];

        interfaces.eth0.ipv4.addresses = [
            {
                address = "192.168.1.1";
                prefixLength = 24;
            }
        ];

        # firewall = {
        #     allowedUDPPorts = [53];
        #     allowedTCPPorts = [53 22];
        # };
        #
    };

    services.ddclient = {
        enable = true;
        protocol = "namecheap";
        server = "dynamicdns.drpudd.ing";
        username = "drpudd.ing";
        passwordFile = toString ./ddns-password;
        domains = ["git"];
        interval = "10min";
        ssl = true;
    };

    #services.unbound = {
    #    enable = false;
    #    settings = {
    #        server = {
    #            interface = ["0.0.0.0"];
    #            access-control = [
    #                "192.168.0.0/24 allow"
    #                "127.0.0.0/8 allow"
    #            ];

    #            local-zone = [''"drpudd.ing." static''];
    #            local-data = [
    #                ''"drpudd.ing. A 192.168.0.117"''
    #                ''"auth.drpudd.ing. A 192.168.0.117"''
    #                ''"git.drpudd.ing. A 192.168.0.117"''
    #                ''"chat.drpudd.ing. A 192.168.0.117"''
    #                ''"matrix.drpudd.ing. A 192.168.0.117"''
    #            ];
    #       };

    #        forward-zone = [
    #            {
    #                name = ".";
    #                forward-addr = ["8.8.8.8" "8.8.4.4"];
    #            }
    #        ];
    #    };
    #};
    #services.matrix-synapse.settings = {
    #    oidc_providers = [
    #        {
    #            idp_id = "authentik";
    #            idp_name = "Authentik";
    #            discover = true;
    #            issuer = "https://auth.drpudd.ing/application/o/synapse/";
    #            client_id = "gjVraGzjyQ7cGloul85JHyaP2YBV2pFPe3hrVSSr";
    #            client_secret = "Lb6sOdjP6fCe7cj2DGfumHtUi1AXVE23hE8sIYiRP1uoW0RMZqZ9tdHchWraoOZ3ILxU2im1aty2ah5tqzZvXcQWrdCWBJUFesDH5PQXOgsW8DK5tw0smXR8POOZjNcb";
    #            scopes = ["openid" "profile" "email"];
    #            user_mapping_provider.config = {
    #                localpart_template = "{{ user.preferred_username }}";
    #                display_name_template = "{{ user.name }}";
    #            };
    #        }
    #    ];
    #    password_config.enabled = false;
    #};
}
