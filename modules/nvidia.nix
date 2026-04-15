# NVIDIA driver config — import this in any host that has an nvidia gpu
# works for both the desktop and whatever the second machine ends up being
{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;

  hardware.nvidia = {
    # modesetting is basically required for wayland to not be a disaster
    modesetting.enable = true;
    # open kernel modules are still kinda rough, stick with proprietary
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
