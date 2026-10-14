{ ... }:
{
  services.openssh = {
    enable = true;

    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.users."admin".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA3iIaNQMBWiNth4PgpQxw1MTvmwZvw4+Rb8JzqzUuwv ju@juga"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP0kRbTAAN6dLby3ts89Y78vM7W1axJuESQw6gcZvUX8 ju@juga"
  ];
}
