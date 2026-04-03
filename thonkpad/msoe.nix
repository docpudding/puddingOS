{pkgs, ...}: let
    # Threat modelling tool for DevSecOps.
    threat-dragon = pkgs.appimageTools.wrapType2 {
        pname = "threat-dragon";
        version = "2.5.0";
        src = pkgs.fetchurl {
            url = "https://github.com/OWASP/threat-dragon/releases/download/v2.5.0/Threat-Dragon-ng-2.5.0.AppImage";
            sha256 = "0bg2mglay6gzy6avfp8v3qmz4c1nq62568vxlj0a8fl75rfi4yi2";
        };
    };
in {
    # Docker containers for several CS classes.
    virtualisation.docker.enable = true;

    # Virtual machines for DevSecOps.
    virtualisation.virtualbox.host.enable = true;
    virtualisation.virtualbox.host.enableExtensionPack = true;

    # Packet capture tool.
    programs.wireshark = {
        enable = true;
        dumpcap.enable = true;
    };

    environment.systemPackages = with pkgs; [
        wireshark # Wireshark desktop application.
        threat-dragon # Threat Dragon desktop application.
        libreoffice-still # Office document editor.
        remmina # RDP client for Windows.

        # For Microservices class.
        kubectl
        kind
    ];
}
