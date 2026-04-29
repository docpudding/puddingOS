{
    config,
    lib,
    ...
}:
with lib; let
    cfg = config.pos.limine;
in {
    options.pos.limine = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Limine bootloader for EFI devices only.";
        };
    };

    config = mkIf (cfg.enable && config.pos.enable) {
        # Configure Limine for EFI.
        boot.loader = {
            efi.canTouchEfiVariables = true;
            limine = {
                enable = true;
                maxGenerations = 1;
            };
        };
        catppuccin.limine.enable = true;

        # Enable silent boot.
        boot.consoleLogLevel = 3;
        boot.initrd.verbose = false;
        boot.kernelParams = [
            "quiet"
            "splash"
            "boot.shell_on_fail"
            "udev.log_priority=3"
            "rd.systemd.show_status=auto"
        ];
    };
}
