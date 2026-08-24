{
    pkgs,
    config,
    lib,
    ...
}:
with lib; let
    # Fetches a prebuilt Godot editor zip and patches it to run on NixOS.
    mkGodotBinary = {
        pname,
        version,
        url,
        sha256,
        binaryName,
        mainProgram,
        desktopName,
        desktopComment,
        subdir ? null,
    }: let
        runtimeLibs = with pkgs; [
            alsa-lib
            dbus
            fontconfig.lib
            libGL
            libglvnd
            libpulseaudio
            libxkbcommon
            systemd
            vulkan-loader
            wayland
            xorg.libX11
            xorg.libXcursor
            xorg.libXext
            xorg.libXfixes
            xorg.libXi
            xorg.libXinerama
            xorg.libXrandr
            zlib
        ];

        desktopItem = pkgs.makeDesktopItem {
            name = mainProgram;
            exec = mainProgram;
            desktopName = desktopName;
            comment = desktopComment;
            categories = ["Development" "IDE" "Game"];
            startupNotify = true;
        };
    in
        pkgs.stdenv.mkDerivation {
            inherit pname version;

            src = pkgs.fetchzip {
                inherit url sha256;
                stripRoot = false;
            };

            dontConfigure = true;
            dontBuild = true;

            nativeBuildInputs = [
                pkgs.autoPatchelfHook
                pkgs.makeWrapper
            ];

            buildInputs = runtimeLibs;

            installPhase =
                if subdir == null
                then ''
                    runHook preInstall
                    install -Dm755 ${binaryName} $out/bin/${mainProgram}
                    install -Dm444 ${desktopItem}/share/applications/${mainProgram}.desktop $out/share/applications/${mainProgram}.desktop
                    runHook postInstall
                ''
                else ''
                    runHook preInstall
                    mkdir -p $out/share/${mainProgram}
                    cp -r ${subdir}/. $out/share/${mainProgram}/
                    chmod +x $out/share/${mainProgram}/${binaryName}
                    install -Dm444 ${desktopItem}/share/applications/${mainProgram}.desktop $out/share/applications/${mainProgram}.desktop
                    runHook postInstall
                '';

            postFixup =
                if subdir == null
                then ''
                    wrapProgram $out/bin/${mainProgram} \
                        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
                ''
                else ''
                    makeWrapper $out/share/${mainProgram}/${binaryName} $out/bin/${mainProgram} \
                        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
                '';

            meta = {
                platforms = ["x86_64-linux"];
                mainProgram = mainProgram;
            };
        };

    # Official vanilla Godot 4.7.2 editor.
    godot472 = mkGodotBinary {
        pname = "godot";
        version = "4.7.2";
        url = "https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip";
        sha256 = "sha256-+FmJl4dfXUMUBjII7stmYRCfDR/G3SJpgi2/EeFuNek=";
        binaryName = "Godot_v4.7.2-stable_linux.x86_64";
        mainProgram = "godot";
        desktopName = "Godot 4.7";
        desktopComment = "Godot Engine 4.7.2 game editor";
    };

    # Official vanilla Godot 4.7.2 Mono (C#) editor.
    godot472Mono = mkGodotBinary {
        pname = "godot-mono";
        version = "4.7.2";
        url = "https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_mono_linux_x86_64.zip";
        sha256 = "sha256-GrH1mz2WoMi1LvKLg1+93wMBkrdvb93+mHCq0fAienU=";
        binaryName = "Godot_v4.7.2-stable_mono_linux.x86_64";
        subdir = "Godot_v4.7.2-stable_mono_linux_x86_64";
        mainProgram = "godot-mono";
        desktopName = "Godot Mono 4.7";
        desktopComment = "Godot Engine 4.7.2 game editor with C# support";
    };

    # Zylann's "Godot + Voxel Tools" module-edition build.
    godotVoxel = mkGodotBinary {
        pname = "godot-voxel";
        version = "1.7";
        url = "https://github.com/Zylann/godot_voxel/releases/download/v1.7/godot.linuxbsd.editor.x86_64.zip";
        sha256 = "sha256-1mF0L+dpRaPZjOzKomSq6sOUCBL+w8/x1WyBN31u7vk=";
        binaryName = "godot.linuxbsd.editor.x86_64";
        mainProgram = "godot-voxel";
        desktopName = "Godot Voxel 4.7";
        desktopComment = "Godot Engine 4.7.2 with the Voxel Tools module built in";
    };
in {
    options.pos.godot = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Install Godot Engine 4.7.2.";
        };

        enableMono = mkOption {
            type = types.bool;
            default = false;
            description = "Install the Mono (C#) version of Godot Engine 4.7.2.";
        };

        enableRemoteDebug = mkOption {
            type = types.bool;
            default = false;
            description = "Open ports and add `godot-rdb` command for remote debugging.";
        };

        enableVoxelBuild = mkOption {
            type = types.bool;
            default = false;
            description = "Install a modified Godot Engine 4.7.2 build with Voxel Tools.";
        };
    };
    config = mkIf config.pos.enable (mkMerge [
        (mkIf config.pos.godot.enable {
            environment.systemPackages = [godot472];
        })

        (mkIf config.pos.godot.enableMono {
            environment.systemPackages = [
                godot472Mono
                pkgs.dotnet-sdk
            ];
        })

        (mkIf config.pos.godot.enableVoxelBuild {
            environment.systemPackages = [godotVoxel];
        })

        (mkIf config.pos.godot.enableRemoteDebug {
            networking.firewall = mkIf config.pos.godot.enableRemoteDebug {
                allowedTCPPorts = [6007 6008];
                allowedUDPPorts = [6007 6008];
            };
        })
    ]);
}
