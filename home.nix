{osConfig, ...}: {
    home = {
        username = "jack";
        homeDirectory = "/home/jack";
        stateVersion = "25.11";
    };

    # Core Home Manager configurations.
    programs = {
        git = {
            enable = true;
            userName = "Jackson Jones";
            userEmail = "jackmj@proton.me";
            settings.init.defaultBranch = "main";
        };

        fish = {
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

        qutebrowser = {
            settings.url.start_pages = ["https://bb.tulsacc.edu/ultra/course"];
            settings.url.default_page = "https://bb.tulsacc.edu/ultra/course";
            quickmarks = {
                "Blackboard" = "https://bb.tulsacc.edu/ultra/course";
                "Find Hub" = "https://www.google.com/android/find";
            };
        };
    };

    wayland.windowManager.hyprland.settings.bind = [
        "SUPER, P, exec, alacritty -e fish -c \"rcd ~/.pos; exec fish\""
    ];
}
