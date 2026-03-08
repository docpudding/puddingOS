{
    # Core home-manager configuration.
    home = {
        username = "jack";
        homeDirectory = "/home/jack";
        stateVersion = "25.11";
    };

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
            set pmod /home/jack/.pos/modules
            set ploc /home/jack/.pos/local
        '';
    };
}
