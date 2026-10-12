{ ... }:
{
  services.openssh = {
    enable = true;

    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.users."admin".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA3iIaNQMBWiNth4PgpQxw1MTvmwZvw4+Rb8JzqzUuwv ju@juga"
  ];
}
