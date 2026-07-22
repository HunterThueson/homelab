# system/login-manager/sddm.nix

#--------#
#  SDDM  #
#--------#

# Enables SDDM when hostSettings.loginManager = "sddm".

{ config, lib, ... }:

let
  cfg = config.hostSettings;
in {
  config = lib.mkIf (cfg.loginManager == "sddm") {
    services.displayManager.sddm = {
      enable = true;
      enableHidpi = true;
      autoNumlock = true;
      wayland.enable = true;                                                    # Wayland greeter; X11 didn't help and renders tiny [1]
      settings.General.GreeterEnvironment = lib.concatStringsSep "," [          # comma-separated, NOT space [1]
        "QT_WAYLAND_SHELL_INTEGRATION=layer-shell"                              # restate the module default this setting replaces [1]
        "QV4_GC_TIMELIMIT=0"                                                    # Qt ≥6.8 QML GC bug breaks the user list [1]
        "QT_QUICK_BACKEND=software"                                             # CPU-render the greeter; stops NVIDIA GL-loss spam [1]
      ];
    };
  };
}


#-------------#
#  Footnotes  #
#-------------#

# 1: The greeter's user list is broken on this machine: selecting a user doesn't
#    commit (breeze `UserList.qml: Cannot read property 'userName' of null`), so
#    the greeter submits the *remembered* user's name with whatever password is
#    typed — logging in as anyone else "fails" even with the correct password.
#    Two theories were tested and falsified (July 2026):
#      - X11 vs Wayland greeter: the breakage occurs on both (journal, Jul 5
#        22:45 on X11), and the X11 greeter additionally renders tiny on the 4K
#        display, so X11 buys nothing.
#      - NVIDIA GL context loss (`QRhiGles2: Graphics device lost`): real, but
#        cosmetic. QT_QUICK_BACKEND=software eliminates the GL spam (kept for
#        that) yet the user list stayed broken with it active (gen 174, Jul 5
#        23:34–23:37).
#    Best current match is KDE bug 494804: Qt ≥6.8's incremental QML garbage
#    collector prematurely collects live theme objects, breaking greeter/lock
#    controls on multi-monitor setups (this host drives two). QV4_GC_TIMELIMIT=0
#    disables the incremental GC — the workaround from that bug. Nominally fixed
#    in Qt 6.8.2 but still reproduced upstream on Qt 6.11 (this stack), so a
#    nixpkgs channel bump won't help. If it recurs anyway: the greeter's
#    "Other…" button types a username directly (bypasses the list), and
#    `sudo sed -i 's/^User=.*/User=hunter/' /var/lib/sddm/state.conf` flips the
#    remembered user. GreeterEnvironment must restate
#    QT_WAYLAND_SHELL_INTEGRATION=layer-shell because settings.General.*
#    replaces the module's computed defaults (lib.recursiveUpdate), rather than
#    merging with them. Its entries are comma-separated (sddm parses the value
#    as a QStringList, splitting on ","; see sddm.conf(5)) — joining with
#    spaces collapses everything into ONE variable whose value is the rest of
#    the string. With that, the greeter can't load its Wayland shell
#    integration and aborts on startup; sddm keeps running with no greeter, so
#    the boot appears to hang at a blank screen right after the last logged
#    service (Jul 8: presented as a freeze after "Starting LACT GPU Control
#    Daemon"). The generated sddm.conf looks plausible either way — verify the
#    greeter env took effect via journalctl, not by reading the config.
