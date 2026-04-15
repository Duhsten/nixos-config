# everything wayland/display related
# niri is the main compositor, hyprland is there too if needed
{ pkgs, lib, ... }:

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

  # dms-greeter — greetd greeter matching the dms lock screen aesthetic
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/duhsten";
    configFiles = [ "/home/duhsten/.config/DankMaterialShell/settings.json" ];
  };

  # niri dlopens X11 libs at runtime via winit — greetd's service env doesn't have them
  systemd.services.greetd.environment.LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
    libxcursor libx11 libxrender libxi libxrandr libxinerama libxext libxkbcommon
  ];
systemd.services.greetd.path = [ pkgs.niri ];

  # portals let apps do stuff like file pickers and screen share on wayland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
