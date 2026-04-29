{
    pkgs,
    config,
    lib,
    ...
}:
with lib; {
    options.pos.shell.rgr = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable vim-like file explorer.";
        };
    };
    config = mkIf (config.pos.shell.rgr.enable
    && config.pos.shell.enable
    && config.pos.enable) {
        programs.ranger = {
            enable = true;
            plugins = [
                {
                    name = "devicons";
                    src = builtins.fetchGit {
                        url = "https://github.com/alexanderjeurissen/ranger_devicons.git";
                        rev = "1bcaff0366a9d345313dc5af14002cfdcddabb82";
                    };
                }
            ];
            settings = {
                preview_images = true;
                preview_images_method = "ueberzug";
            };
            extraConfig = "default_linemode devicons";
        };

        home.packages = with pkgs; [ueberzugpp];

        programs.fish = {
            shellAliases.rgr = "ranger";
            functions.rcd = ''
                set start_dir (test -n "$argv[1]" && echo $argv[1] || echo $PWD)

                if not test -d "$start_dir"
                    echo "rcd: not a directory: $start_dir" >&2
                    return 1
                end

                set tmpfile (mktemp)
                ranger --choosedir=$tmpfile $start_dir

                if test -s $tmpfile
                    set dest (cat $tmpfile)
                    if test -d "$dest"
                        cd "$dest"
                    end
                end

                rm -f $tmpfile
            '';
        };
    };
}
