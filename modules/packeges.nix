{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    btop
    tmux
  ];
}
