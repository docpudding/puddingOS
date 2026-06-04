{
    pkgs,
    pos,
    ...
}: {
    # Only keep the most recent five generations.
    system.activationScripts.gc-old-generations = {
        text = ''
            ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations +5
            ${pkgs.nix}/bin/nix-collect-garbage
        '';
        deps = [];
    };

    # Network configurations.
    networking = {
        useDHCP = false;
        dhcpcd.enable = false;

        networkmanager = {
            enable = true;
            #wifi.powersave = true;
            #dns = "none";
        };
    };

    # Import home configurations.
    home-manager.users.jack.imports = [
        pos.homeManagerModules.default
        ./home.nix
    ];
}
