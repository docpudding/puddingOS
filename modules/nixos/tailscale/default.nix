{
    config,
    lib,
    ...
}:
with lib; {
    options.pos.tailscale = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable zero configuration VPN using modern nftables.";
        };
        enableLegacyTables = mkOption {
            type = types.bool;
            default = false;
            description = "Use legacy iptables instead of modern nftables.";
        };
    };
    config = mkIf (config.pos.tailscale.enable && config.pos.enable) (mkMerge [
        # Enable the Tailscale service.
        {
            services.tailscale.enable = true;
        }

        # Enable the firewall and force nftables when not using legacy tables.
        (mkIf (!config.pos.tailscale.enableLegacyTables) {
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
        })
    ]);
}
