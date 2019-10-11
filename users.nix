{ pkgs, ... }:
{
  users.extraGroups = [
    { name = "jonas"; gid = 1000; }
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.jonas = {
     description = "Jonas Juselius";
     home = "/home/jonas";
     group = "jonas";
     extraGroups = [
       "users"
       "wheel"
       "root"
       "adm"
       "cdrom"
       "docker"
       "fuse"
       "wireshark"
       "sway"
       "libvirtd"
     ];
     uid = 1000;
     isNormalUser = true;
     createHome = true;
     useDefaultShell = false;
     shell = pkgs.fish;
     openssh.authorizedKeys.keys = [
       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKiAS30ZO+wgfAqDE9Y7VhRunn2QszPHA5voUwo+fGOf jonas"
     ];
  };
}
