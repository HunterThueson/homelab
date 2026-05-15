# lib/presets/monitors.nix

#------------#
#  Monitors  #
#------------#

# Monitor presets define individual monitors.
# Layout presets define complete multi-monitor arrangements including xorg config.

{ lib, ... }:

{
  #---------------------#
  #  Individual Monitors #
  #---------------------#

  gigabyte = {
    m28u = {
      name = "Gigabyte M28U";
      resolution  = lib.mkDefault "3840x2160@144";
      orientation = lib.mkDefault "landscape";
      placement   = lib.mkDefault "primary";
    };
  };

  dell = {
    s2417dg = {
      name = "Dell S2417DG";
      resolution = lib.mkDefault "2560x1440@144";
      orientation = lib.mkDefault "landscape";
      placement = lib.mkDefault "primary";
    };
  };

  lenovoThinkPad = {
    "built-in" = {
      name = "Lenovo ThinkPad X1 Carbon Gen 12 built-in screen";
      resolution = lib.mkDefault "2880x1800@120";
      orientation = lib.mkDefault "landscape";
      placement = lib.mkDefault "primary";
    };
  };

  #-------------------#
  #  Layout Presets   #
  #-------------------#

  # Complete monitor arrangements — portable across hosts.
  # Each layout includes the monitors list and xorg-specific configuration.

  layouts = {

    # Gigabyte M28U (4K primary, landscape) + Dell S2417DG (1440p, portrait, right)
    # DPI matched to 4K panel; Dell scaled via ViewPort to compensate.
    #
    # DPI calculation:
    #   Target DPI: 153.9 (native DPI of the Gigabyte M28U)
    #   Dell scaling factor: 153.9 / 123.42 = 1.24696
    #   Dell virtual resolution: 2560 * 1.247 = 3192, 1440 * 1.247 = 1796
    #   Virtual screen: x = 3840 + 3192 = 7032, y = 2160
    #   Dell vertical offset: (2160 - 1796) / 2 = 182

    "m28u-landscape--s2417dg-portrait-right" = {
      alignment = "center";
      monitors = [
        {
          name = "Gigabyte M28U";
          resolution = "3840x2160@144";
          orientation = "landscape";
          placement = "primary";
        }
        {
          name = "Dell S2417DG";
          resolution = "2560x1440@144";
          orientation = "portrait";
          placement = {
            position = "right-of";
            relativeTo = "primary";
          };
        }
      ];
      xorg = {
        dpi = 154;
        virtualScreen = { x = 7032; y = 2160; };
        screenSection = ''
          Option    "MetaModes" "DP-4: 3840x2160_144 +0+0 { ForceCompositionPipeline=On, AllowGSYNCCompatible=On }, HDMI-0: 2560x1440_60 +3840+182 { ViewPortIn=3192x1796, ViewPortOut=2560x1440, ForceCompositionPipeline=On }"
        '';
        xrandrHeads = [
          {
            output = "DP-4";
            primary = true;
            monitorConfig = ''
              Modeline "3840x2160_144.00"  1833.14  3840 4200 4632 5424  2160 2161 2164 2347  -HSync +Vsync
              Option "DPMS" "true"
              Option "PreferredMode" "3840x2160_144.00"
              Option "Position" "0 0"
            '';
          }
          {
            output = "HDMI-0";
            primary = false;
            monitorConfig = ''
              Option "DPMS" "true"
              Option "PreferredMode" "2560x1440_60.00"
              Option "Position" "3840 182"
            '';
          }
        ];
      };
    };

  };
}
