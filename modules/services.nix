{...}:
{
 imports = [
# ./services/test.nix
  ./firewall.nix
  ./packeges.nix
];
	
  services.dbus.implementation = "dbus";
	


  services.openssh.enable = true;
  users.users."admin".openssh.authorizedKeys.keys = [
	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA3iIaNQMBWiNth4PgpQxw1MTvmwZvw4+Rb8JzqzUuwv ju@juga"
  ];

}
