{
    description = "puddingOS - A high-level configuration layer for NixOS and Home Manager.";

    outputs = {self}: {
        nixosModules.default = import ./modules/nixos;
        homeManagerModules.default = import ./modules/home-manager;
    };
}
