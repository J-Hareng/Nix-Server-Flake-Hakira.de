{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    fastfetch

    # terminal
    starship
    fish

    vim
    htop
    btop
    tmux

    nh
  ];
}
