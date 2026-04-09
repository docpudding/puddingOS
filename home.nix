{osConfig, ...}: {
    home = {
        username = "jack";
        homeDirectory = "/home/jack";
        stateVersion = "25.11";
    };

    # Core home-manager configuration.
    programs.fish = {
        functions = {
            # Configure current git repository to use personal account.
            git-config-personal = ''
                git config user.name "dr-pudding"
                git config user.email "jackmj@proton.me"
            '';

            # Configure current git repository to use professional account.
            git-config-professional = ''
                git config user.name "jackmj1024"
                git config user.email "jackmj@protonmail.com"
            '';
        };

        # Shortcut to puddingOS configurations.
        shellInit = ''
            set pmod /etc/nixos/pos/modules
            set ploc /etc/nixos/pos/local/${osConfig.networking.hostName}
            set downloads /home/jack/stuff/downloads
        '';

        shellAliases = {
            pgr = "rgr ~/.pos";
            pcd = "rcd ~/.pos";
        };
    };

    wayland.windowManager.hyprland.settings.bind = [
        "SUPER, P, exec, alacritty -e fish -c \"rcd ~/.pos; exec fish\""
    ];

    programs.qutebrowser = {
        settings.url.start_pages = ["https://msoe.instructure.com/calendar"];
        settings.url.default_page = "https://msoe.instructure.com/calendar";
        quickmarks = {
            "Canvas LMS" = "https://msoe.instructure.com/calendar";
            "Find Hub" = "https://www.google.com/android/find";
        };
    };
}
