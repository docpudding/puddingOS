{
    pkgs,
    pos,
    ...
}: {
    system.activationScripts.gc-old-generations = {
        text = ''
            ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations +5
            ${pkgs.nix}/bin/nix-collect-garbage
        '';
        deps = [];
    };
    home-manager.users.jack.imports = [
        pos.homeManagerModules.default
        ./home.nix
    ];
}
