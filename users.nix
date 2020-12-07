{ pkgs, ... }:
{
  users.extraGroups = {
    admin = { gid = 10000; };
  };

  users.extraUsers.admin = {
     description = "Administrator";
     home = "/home/admin";
     group = "admin";
     extraGroups = [
       "users"
       "wheel"
       "root"
       "adm"
       "cdrom"
       "docker"
       "fuse"
       "wireshark"
       "libvirtd"
       "networkmanager"
       "tty"
       "keys"
     ];
     uid = 10000;
     isNormalUser = true;
     createHome = true;
     useDefaultShell = false;
     shell = pkgs.fish;
     openssh.authorizedKeys.keys = [
     ];
  };
}
