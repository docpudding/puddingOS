{
    pkgs,
    lib,
    config,
    ...
}: let
    python = pkgs.python3.withPackages (ps: [ps.click]);
    pos-cmd = pkgs.stdenv.mkDerivation {
        name = "pos";
        src = ./.;
        buildInputs = [python];
        installPhase = ''
            mkdir -p $out/lib/pos $out/bin
            cp pos.py $out/lib/pos/
            cp static.py $out/lib/pos/
            cat > $out/bin/pos <<EOF
            #!${python}/bin/python3
            import sys
            sys.path.insert(0, "$out/lib/pos")
            from pos import cmd
            cmd()
            EOF
            chmod +x $out/bin/pos
        '';
    };
    godot-rdb = pkgs.stdenv.mkDerivation {
        name = "godot-rdb";
        src = ./.;
        buildInputs = [python];
        installPhase = ''
            mkdir -p $out/lib/godot-rdb $out/bin
            cp godot_rdb.py $out/lib/godot-rdb/
            cp static.py $out/lib/godot-rdb/
            cat > $out/bin/godot-rdb <<EOF
            #!${python}/bin/python3
            import sys
            sys.path.insert(0, "$out/lib/godot-rdb")
            from godot_rdb import cmd
            cmd()
            EOF
            chmod +x $out/bin/godot-rdb
        '';
    };
in {
    config = lib.mkMerge [
        (lib.mkIf config.pos.enable {
            environment.systemPackages = [
                pos-cmd
            ];
        })

        (lib.mkIf config.pos.godot.enableRemoteDebug {
            environment.systemPackages = [
                godot-rdb
            ];
        })
    ];
}
