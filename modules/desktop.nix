# everything wayland/display related
# niri is the main compositor, hyprland is there too if needed
{ pkgs, ... }:

{
  # keyboard layout — nothing fancy just us
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # niri — scroll-based wayland compositor, the main one we're using
  programs.niri.enable = true;

  # niri doesn't manage xwayland itself so we use xwayland-satellite
  # it's a standalone xwayland server that bridges x11 apps (like steam) to wayland
  programs.xwayland.enable = true;
  environment.sessionVariables.DISPLAY = ":0";

  systemd.user.services.xwayland-satellite = {
    description = "xwayland-satellite — x11 bridge for niri";
    wantedBy = [ "graphical-session.target" ];
    partOf  = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite :0";
      Restart = "on-failure";
    };
  };

  # hyprland is here as an option too, pick it from the greeter
  programs.hyprland = {
    enable = true;
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

  # tuigreet — tui login screen, lightweight and gets the job done
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --sessions /run/current-system/sw/share/wayland-sessions --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # portals let apps do stuff like file pickers and screen share on wayland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
