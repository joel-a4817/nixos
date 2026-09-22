{ config, lib, pkgs, ... }:
{
  services.resolved.enable = true;
  services.usbmuxd.enable = true;

  networking.networkmanager = {
    enable = true;

    ensureProfiles = {
      environmentFiles = [
        "/home/joel/Documents/prefs/audio/airplay-hotspot.env"
      ];

      profiles."airplay-direct" = {
        connection = {
          id = "AirPlay Direct";
          type = "wifi";
          autoconnect = false;
          permissions = "";
        };

        wifi = {
          mode = "ap";
          ssid = "Joel AirPlay";
        };

        wifi-security = {
          # WPA2-Personal only.
          key-mgmt = "wpa-psk";
          proto = "rsn";

          # AES-CCMP only. Do not permit TKIP.
          pairwise = "ccmp";
          group = "ccmp";

          psk = "$AIRPLAY_HOTSPOT_PASSWORD";
        };

        ipv4 = {
          # NetworkManager provides local addressing, DHCP and NAT.
          method = "shared";
        };

        ipv6 = {
          method = "disabled";
        };
      };
    };
  };

  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      3689
      5000
      7000 #airplay
      8384 #syncthing
      22000
    ];

    allowedTCPPortRanges = [
      {
        from = 32768;
        to = 60999;
      }
    ];

    allowedUDPPorts = [
      319 #nqptp
      320 #nqptp
      5353
      22000
      21027
    ];

    allowedUDPPortRanges = [
      {
        from = 6000;
        to = 6009;
      }
      {
        from = 32768;
        to = 60999;
      }
    ];
  };

  services.tailscale.enable = true;
}
