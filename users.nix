{ pkgs, ... }:
{
  users.extraGroups = {
    admin = { gid = 1000; };
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
     ];
     uid = 1000;
     isNormalUser = true;
     createHome = true;
     useDefaultShell = false;
     shell = pkgs.fish;
     openssh.authorizedKeys.keys = [];
  };
}
