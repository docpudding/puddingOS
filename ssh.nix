{config, ...}: {
    home-manager.users.jack.programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        matchBlocks = {
            "*" = {
                identityFile = "~/.ssh/${config.networking.hostName}";
                extraOptions = {
                    PreferredAuthentications = "publickey,password";
                    AddKeysToAgent = "yes";
                };
            };

            "server" = {
                hostname = "192.168.1.116";
                user = "jack";
            };

            "console" = {
                hostname = "192.168.1.118";
                user = "jack";
            };

            "github.com" = {
                hostname = "github.com";
                user = "git";
            };
        };
    };

    users.users.jack.openssh.authorizedKeys.keyFiles = [
        ../termix.pub
        ../thonkpad/thonkpad.pub
        ../server/server.pub
        ../console/console.pub
    ];
}
