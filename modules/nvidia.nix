# NVIDIA driver config — import this in any host that has an nvidia gpu
# works for both the desktop and whatever the second machine ends up being
{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;

  # run ollama against CUDA on NVIDIA hosts and keep the CLI available in PATH
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };
  environment.systemPackages = with pkgs; [
    ollama-cuda
  ];

  hardware.nvidia = {
    # modesetting is basically required for wayland to not be a disaster
    modesetting.enable = true;
    # open kernel modules are still kinda rough, stick with proprietary
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # force nvidia_drm to load early so the render node exists before greetd starts
  boot.kernelModules = [ "nvidia_drm" ];
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
}
