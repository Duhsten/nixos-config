# home-manager config for duhsten
# user-level stuff: shell config, git, cli tools etc
{ pkgs, inputs, ... }:

{
  home.username = "duhsten";
  home.homeDirectory = "/home/duhsten";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    # cli tools i actually use
    ripgrep
    fd
    bat
    eza
    fzf
    jq
    htop
    tree
    unzip
  ];

  # --- git ---
  programs.git = {
    enable = true;
    settings.user.name  = "duhsten";
    settings.user.email = "duhsten@nixos.local";
  };

  # --- zsh ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # nixos shortcuts
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#osborne-home";
      update   = "nix flake update --flake ~/nixos-config";
      search   = "nix search nixpkgs";
      # nicer defaults
      ls  = "eza";
      ll  = "eza -l";
      la  = "eza -la";
      cat = "bat -p";
    };

    history = {
      size = 10000;
      save = 10000;
    };
  };

  programs.starship.enable = true;
  programs.fzf.enable = true;

  programs.home-manager.enable = true;
}
