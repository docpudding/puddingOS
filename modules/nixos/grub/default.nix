{
    config,
    lib,
    ...
}:
with lib; {
    options.pos.grub = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable bootloader for EFI and BIOS";
        };

        device = mkOption {
            type = types.str;
            default = "nodev";
            example = "/dev/sda";
            description = ''
                Boot device for GRUB installation.
                - `nodev`: EFI mode (default)
                - `/dev/xxx`: BIOS mode, install GRUB to specified device.
            '';
        };
    };

    config = mkIf (config.pos.grub.enable && config.pos.enable) {
        # Configure boot options and menu.
        boot.loader = {
            grub = {
                enable = true;
                useOSProber = true;
                efiInstallAsRemovable = false;
                gfxmodeEfi = "1920x1080";
                configurationName = "puddingOS";

                # EFI/BIOS configuration based on device option
                device = config.pos.grub.device;
                efiSupport = config.pos.grub.device == "nodev" || config.pos.grub.device == "";
            };
            efi.canTouchEfiVariables =
                config.pos.grub.device == "nodev" || config.pos.grub.device == "";
        };

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

        # Enable style configuration for the boot menu.
        catppuccin.grub.enable = true;
    };
}
