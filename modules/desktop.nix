# everything wayland/display related
# the enabled compositor list drives which real sessions DMS can show
{ config, pkgs, lib, ... }:

let
  cfg = config.my.desktop;
  niriEnabled = lib.elem "niri" cfg.compositors;
  hyprlandEnabled = lib.elem "hyprland" cfg.compositors;
in
{
  options.my.desktop = {
    compositors = lib.mkOption {
      type = with lib.types; listOf (enum [ "niri" "hyprland" ]);
      default = [ "niri" "hyprland" ];
      example = [ "niri" ];
      description = ''
        Wayland compositor sessions to install and expose in the display manager.
      '';
    };

    greeterCompositor = lib.mkOption {
      type = lib.types.enum [ "niri" "hyprland" ];
      default = "niri";
      description = ''
        Compositor DMS uses for the greetd greeter itself.
        Keep this in `my.desktop.compositors` so the greeter and session list stay aligned.
      '';
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.compositors != [ ];
        message = "my.desktop.compositors must contain at least one compositor.";
      }
      {
        assertion = lib.elem cfg.greeterCompositor cfg.compositors;
        message = "my.desktop.greeterCompositor must also be present in my.desktop.compositors.";
      }
    ];

  # keyboard layout — nothing fancy just us
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # niri — scroll-based wayland compositor, the main one we're using
  programs.niri.enable = niriEnabled;

  # niri doesn't manage xwayland itself, so keep the Xwayland bits available.
  # the actual xwayland-satellite user service is managed in home-manager and
  # tied specifically to the niri session.
  programs.xwayland.enable = lib.mkIf niriEnabled true;

  # hyprland is an alternate session in the display manager.
  # use the upstream NixOS module so session files, portals and other integration
  # are wired correctly.
  programs.hyprland = {
    enable = hyprlandEnabled;
    withUWSM = true;
    xwayland.enable = true;
  };

  # dms-shell — material design shell thing
  programs.dms-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  # dms-greeter — greetd greeter matching the dms lock screen aesthetic
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = cfg.greeterCompositor;
    configHome = "/home/duhsten";
    configFiles = [ "/home/duhsten/.config/DankMaterialShell/settings.json" ];
  };

  # niri dlopens X11 libs at runtime via winit — greetd's service env doesn't have them
  systemd.services.greetd.environment.LD_LIBRARY_PATH = lib.mkIf (cfg.greeterCompositor == "niri") (with pkgs; lib.makeLibraryPath [
    libxcursor libx11 libxrender libxi libxrandr libxinerama libxext libxkbcommon
  ]);
  systemd.services.greetd.path = lib.mkIf (cfg.greeterCompositor == "niri") [ pkgs.niri ];

  # portals let apps do stuff like file pickers and screen share on wayland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # hint chromium/electron apps to prefer native wayland when available
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
