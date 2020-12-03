{ pkgs, ... }:
{

  users.users.slurm.extraGroups = [ "keys" ];

  users.extraGroups = {
    jonas = { gid = 1000; };
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
       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKiAS30ZO+wgfAqDE9Y7VhRunn2QszPHA5voUwo+fGOf jonas-3"
       "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDULdlLC8ZLu9qBZUYsjhpr6kv5RH4yPkekXQdD7prkqapyoptUkO1nOTDwy7ZsKDxmp9Zc6OtdhgoJbowhGW3VIZPmooWO8twcaYDpkxEBLUehY/n8SlAwBtiHJ4mTLLcynJMVrjmTQLF3FeWVof0Aqy6UtZceFpLp1eNkiHTCM3anwtb9+gfr91dX1YsAOqxqv7ooRDu5rCRUvOi4OvRowepyuBcCjeWpTkJHkC9WGxuESvDV3CySWkGC2fF2LHkAu6SFsFE39UA5ZHo0b1TK+AFqRFiBAb7ULmtuno1yxhpBxbozf8+Yyc7yLfMNCyBpL1ci7WnjKkghQv7yM1xN2XMJLpF56v0slSKMoAs7ThoIlmkRm/6o3NCChgu0pkpNg/YP6A3HfYiEDgChvA6rAHX6+to50L9xF3ajqk4BUzWd/sCk7Q5Op2lzj31L53Ryg8vMP8hjDjYcgEcCCsGOcjUVgcsmfC9LupwRIEz3aF14AWg66+3zAxVho8ozjes= jonas.juselius@juselius.io"
     ];
  };

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
       "libvirtd"
       "networkmanager"
       "tty"
     ];
     uid = 1000;
     isNormalUser = true;
     createHome = true;
     useDefaultShell = false;
     shell = pkgs.fish;
     openssh.authorizedKeys.keys = [
       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKiAS30ZO+wgfAqDE9Y7VhRunn2QszPHA5voUwo+fGOf jonas-3"
       "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDULdlLC8ZLu9qBZUYsjhpr6kv5RH4yPkekXQdD7prkqapyoptUkO1nOTDwy7ZsKDxmp9Zc6OtdhgoJbowhGW3VIZPmooWO8twcaYDpkxEBLUehY/n8SlAwBtiHJ4mTLLcynJMVrjmTQLF3FeWVof0Aqy6UtZceFpLp1eNkiHTCM3anwtb9+gfr91dX1YsAOqxqv7ooRDu5rCRUvOi4OvRowepyuBcCjeWpTkJHkC9WGxuESvDV3CySWkGC2fF2LHkAu6SFsFE39UA5ZHo0b1TK+AFqRFiBAb7ULmtuno1yxhpBxbozf8+Yyc7yLfMNCyBpL1ci7WnjKkghQv7yM1xN2XMJLpF56v0slSKMoAs7ThoIlmkRm/6o3NCChgu0pkpNg/YP6A3HfYiEDgChvA6rAHX6+to50L9xF3ajqk4BUzWd/sCk7Q5Op2lzj31L53Ryg8vMP8hjDjYcgEcCCsGOcjUVgcsmfC9LupwRIEz3aF14AWg66+3zAxVho8ozjes= jonas.juselius@juselius.io"
     ];
  };
}
