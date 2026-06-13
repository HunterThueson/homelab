# system/networking/wifi.nix

#--------#
#  Wifi  #
#--------#

{ config, lib, ... }: 

let
  secrets = config.sops.secrets;
in

{
  config = lib.mkIf config.networking.networkmanager.enable {
    networking.networkmanager.ensureProfiles = {
      environmentFiles = [ secrets."wifi-auth".path ];
      profiles = {
        home = {
          connection = { id = "home"; type = "wifi"; };
          wifi = {
            ssid = "$WIFI_HOME_SSID";
            mode = "infrastructure";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$WIFI_HOME_PASS";
          };
        };
        mobile = {
          connection = { id = "mobile"; type = "wifi"; };
          wifi = {
            ssid = "$WIFI_MOBILE_SSID";
            mode = "infrastructure";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$WIFI_MOBILE_PASS";
          };
        };
      };
    };
  };
}
