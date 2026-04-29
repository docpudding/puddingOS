{pkgs ? import <nixpkgs> {}}: let
    home-manager = builtins.fetchGit {
        url = "https://github.com/nix-community/home-manager.git";
        rev = "0d02ec1d0a05f88ef9e74b516842900c41f0f2fe";
    };

    nixosEval = import "${pkgs.path}/nixos/lib/eval-config.nix" {
        inherit pkgs;
        system = builtins.currentSystem;
        modules = [../modules/nixos];
    };

    hmEval = import "${home-manager}/modules" {
        inherit pkgs;
        inherit (pkgs) lib;
        check = false;
        extraSpecialArgs = {};
        configuration = {
            imports = [../modules/home-manager];
            home.username = "user";
            home.homeDirectory = "/home/user";
            home.stateVersion = "25.11";
        };
    };

    nixosOptionsDoc = pkgs.nixosOptionsDoc {
        options = nixosEval.options;
        transformOptions = opt:
            opt
            // {
                visible = pkgs.lib.hasPrefix "pos" (builtins.concatStringsSep "." opt.loc);
            };
    };

    hmOptionsDoc = pkgs.nixosOptionsDoc {
        options = hmEval.options;
        transformOptions = opt:
            opt
            // {
                visible = pkgs.lib.hasPrefix "pos" (builtins.concatStringsSep "." opt.loc);
            };
    };

    catppuccinCss = pkgs.fetchurl {
        url = "https://github.com/catppuccin/mdBook/releases/latest/download/catppuccin.css";
        sha256 = "1zx7zwxcz190223xxrvn8ghkichvz5h89h53qyf24ffz1alyd2z0";
    };

    keymapsJson = pkgs.writeText "keymaps.json" (builtins.toJSON (
        map (k: {
            key = k.key;
            mode =
                if builtins.isList k.mode
                then k.mode
                else [k.mode];
            desc = k.options.desc or "";
        }) (import ../modules/home-manager/vi/keymaps.nix)
    ));
    python = pkgs.python3;
    generator = ./generate.py;
in
    pkgs.runCommand "pos-docs" {buildInputs = [pkgs.mdbook python];} ''
        mkdir -p $out

        # Copy hand-written docs structure.
        cp -r ${./src} src
        chmod -R +w src

        # Generate per-module pages, SUMMARY.md, and README.
        ${python}/bin/python3 ${generator} \
            ${nixosOptionsDoc.optionsJSON}/share/doc/nixos/options.json \
            ${hmOptionsDoc.optionsJSON}/share/doc/nixos/options.json \
            src \
            $out/README.md \
            ${keymapsJson}

        # Copy book config.
        cp ${./book.toml} book.toml

        # Install Catppuccin theme.
        mkdir -p theme
        cp ${catppuccinCss} theme/catppuccin.css
        cp ${./src/extra.css} theme/extra.css

        # Build the book.
        mdbook build --dest-dir $out/book
    ''
