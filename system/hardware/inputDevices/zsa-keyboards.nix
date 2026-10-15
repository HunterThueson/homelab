# system/hardware/inputDevices/zsa-keyboards.nix

#-----------------------------#
#  ZSA Keyboard Configuration #
#-----------------------------#

# Enables udev rules and tools for ZSA keyboards (Moonlander, Voyager, etc.)
# when hostSettings.hardware.keyboard.model.manufacturer = "zsa".

{ config, pkgs, lib, ... }:

let
  cfg = config.hostSettings.hardware.keyboard;
in {
  config = lib.mkIf (cfg.model.manufacturer == "zsa") {

    hardware.keyboard.zsa.enable = true;                      # Oryx and Wally udev rules
    hardware.keyboard.qmk.enable = true;                      # QMK bootloader udev rules [1]

    environment.systemPackages = with pkgs; [
      jq                                                      # Layout detection for the Ækeynox generator [2]
      keymapp                                                 # Configure ZSA keyboards
      kontroll                                                # CLI for the Keymapp API
      qmk                                                     # Build and flash QMK firmware [3]
    ];
  };
}


#-------------#
#  Footnotes  #
#-------------#

# 1: `hardware.keyboard.zsa.enable` and `hardware.keyboard.qmk.enable` do not
#    conflict. Each only appends a rules package to `services.udev.packages`,
#    which merges additively, and every matching rule still runs — `TAG+=`
#    accumulates rather than overwriting. The two overlap on the Moonlander's
#    STM32 DFU bootloader (0483:df11), tagged `uaccess` by both ZSA's
#    `50-wally.rules` and `50-qmk.rules`, which is redundant rather than
#    contradictory. The QMK rules are what cover the bootloaders ZSA's rules
#    omit, so they earn their place once firmware is built locally instead of
#    through Oryx. Note that `50-qmk.rules` also relaxes *every* hidraw device
#    to 0660 root:plugdev, not just keyboards; `plugdev` is created empty, so
#    access still comes from the `uaccess` seat ACL.
#
#    `pkgs.via` is deliberately absent. Its `92-viia.rules` sets `MODE="0666"`
#    on all hidraw devices and sorts after `50-qmk.rules`, so it would override
#    that 0660 and leave raw HID — keystrokes included — world-readable and
#    writable to any local process. It also buys nothing here: ZSA's stock
#    firmware speaks Oryx/Keymapp, and the Ækeynox `rules.mk` never sets
#    `VIA_ENABLE`, so neither firmware answers the VIA protocol.
#
# 2: The Ækeynox generator (`generator.sh`) shells out to `jq` to read a board's
#    `layouts` field out of its `keyboard.json` and intersect it with the
#    `LAYOUT_*` macros the keymap supports. It is a hard prerequisite of the QMK
#    workflow rather than of the ZSA tools, and is not installed anywhere else
#    in this config.
#
# 3: `hardware.keyboard.qmk.enable` installs udev rules and creates the
#    `plugdev` group; it does not install the CLI, so the package is still
#    required. The nixpkgs wrapper already carries the whole toolchain on its
#    PATH — gcc-arm-embedded for the Moonlander's STM32F303, the avr-gcc chain,
#    dfu-util, dfu-programmer, teensy-loader-cli and gnumake — so no separate
#    toolchain packages are needed.
