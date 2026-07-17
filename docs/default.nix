{pkgs ? import <nixpkgs> {}}: let
    home-manager = builtins.fetchGit {
        url = "https://github.com/nix-community/home-manager.git";
        rev = "0d02ec1d0a05f88ef9e74b516842900c41f0f2fe";
    };
    nixosEval = import "${pkgs.path}/nixos/lib/eval-config.nix" {
        inherit pkgs;
        system = pkgs.system;
        specialArgs = {inputs = {};};
        modules = [../modules/nixos];
    };
    hmEval = import "${home-manager}/modules" {
        inherit pkgs;
        inherit (pkgs) lib;
        check = false;
        extraSpecialArgs = {inputs = {};};
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
    generatedDocs = pkgs.runCommand "pos-docs-generated" {buildInputs = [pkgs.python3];} ''
        mkdir -p $out
        python3 ${./generate.py} \
          ${nixosOptionsDoc.optionsJSON}/share/doc/nixos/options.json \
          ${hmOptionsDoc.optionsJSON}/share/doc/nixos/options.json \
          ${./src/content} \
          $out \
          ${keymapsJson}
    '';
    src = pkgs.lib.cleanSourceWith {
        src = ./.;
        filter = path: type: let
            basename = builtins.baseNameOf path;
        in
            basename != "node_modules" && basename != "dist" && basename != ".astro";
    };
in
    pkgs.stdenv.mkDerivation {
        pname = "puddingos-docs";
        version = "0.0.1";
        inherit src;
        nativeBuildInputs = [pkgs.nodejs pkgs.pnpm.configHook];
        pnpmDeps = pkgs.pnpm.fetchDeps {
            pname = "puddingos-docs";
            version = "0.0.1";
            inherit src;
            fetcherVersion = 2;
            hash = "sha256-Z8CSP7IbOjeURZUBZDHOYEnXIRBha5oHzIDyzZMNIBQ=";
        };
        buildPhase = ''
            runHook preBuild
            mkdir -p src/content/docs/configuration
            cp -r ${generatedDocs}/. src/content/docs/configuration/
            pnpm run build
            runHook postBuild
        '';
        installPhase = ''
            runHook preInstall
            cp -r dist $out
            runHook postInstall
        '';
    }
