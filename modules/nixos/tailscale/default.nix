{
    pkgs,
    config,
    lib,
    ...
}:
with lib; {
    options.pos.tailscale = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable zero confiuration VPN using modern nftables.";
        };
    };

    config = mkIf (config.pos.tailscale.enable && config.pos.enable) {
        # Enable the service and the firewall.
        services.tailscale.enable = true;
        networking.nftables.enable = true;
        networking.firewall = {
            enable = true;
            trustedInterfaces = [config.services.tailscale.interfaceName];
            allowedUDPPorts = [config.services.tailscale.port];
        };

        # Force tailscaled to use nftables.
        systemd.services.tailscaled.serviceConfig.Environment = [
            "TS_DEBUG_FIREWALL_MODE=nftables"
        ];

        # Prevent systemd from waiting for network online.
        systemd.network.wait-online.enable = false;
        boot.initrd.systemd.network.wait-online.enable = false;
    };
}
