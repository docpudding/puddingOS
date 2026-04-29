{
    pkgs,
    config,
    lib,
    ...
}:
with lib; let
    # Simple randomizer utility.
    rng = pkgs.writers.writePython3Bin "rng" {
        libraries = [pkgs.python3Packages.click];
    } (builtins.readFile ./rng.py);
in {
    imports = [
        ./rgr
        ./clipboard
    ];

    options.pos.shell = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable shell configurations and terminal emulator.";
        };
    };

    config = mkIf (config.pos.shell.enable
        && config.pos.enable) {
        programs.fish = {
            enable = true;

            shellAliases = {
                # Use fish for nix-shell.
                nix-shell = "nix-shell --run fish";

                # I am aware that this could shadow the actual shell program called nsh,
                # but if you enabled this shell module then you probably aren't using it.
                # If you need both anyway, you can override this by using mkForce.
                nsh = "nix-shell";

                # Open another terminal window in the current directory.
                dupe = "alacritty & disown";
            };

            interactiveShellInit = ''
                set fish_greeting;
            '';
        };

        # Apply Catppuccin colors to shell theme.
        # You can tell it's working if the username text is teal instead of light green.
        catppuccin.fish.enable = true;
        home.activation.fishCatppuccinTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
            ${pkgs.fish}/bin/fish --no-config -c 'fish_config theme choose "Catppuccin Macchiato"'
        '';

        # Default shell behaviour for fish (see https://nixos.wiki/wiki/Fish).
        programs.bash = {
            enable = true;
            initExtra = ''
                if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
                then
                  shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
                  exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
                fi
            '';
        };

        # Improved ls command
        programs.lsd = {
            enable = true;
            enableFishIntegration = true;
            icons.filetype = {
                "dir" = "󰉋";
            };
        };
        catppuccin.lsd.enable = true;

        # Version control
        programs.git = {
            enable = true;
            settings = {
                init.defaultBranch = "main";
                core.askpass = "";
            };
        };

        # Password management
        programs.password-store = {
            enable = true;
            settings.PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.pass";
        };

        # GPG key management for password decryption.
        programs.gpg.enable = true;
        services.gpg-agent = {
            enable = true;
            pinentry.package = pkgs.pinentry-tty;
        };

        # Improved cat command and pager.
        programs.bat.enable = true;
        programs.fish.shellAliases.cat = "bat -pp";
        catppuccin.bat.enable = true;

        # Improved command history system.
        programs.atuin.enable = true;
        catppuccin.atuin.enable = true;

        # System monitor.
        programs.bottom.enable = true;
        catppuccin.bottom.enable = true;

        # Graphical terminal emulator.
        programs.alacritty = {
            enable = true;
            settings = {
                window.opacity = 0.9;
                font = {
                    size = 12;
                    normal.family = "OverpassM Nerd Font";
                };
                terminal.osc52 = "CopyPaste"; # Allows copy over SSH.
            };
        };
        catppuccin.alacritty.enable = true;

        home.packages = [rng pkgs.unzip];
    };
}
