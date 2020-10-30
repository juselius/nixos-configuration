{ pkgs, config, ...}:
{

  # networking = {
  #   hostName = "nixos";
  #   domain = "local";
  #   search = [ "local" ];
  # };

  # users.extraUsers.root.openssh.authorizedKeys.keys = [];

  # customize = {
  #   desktop.enable = false;

  #   boot = {
  #     bios = false;
  #     device = "/dev/sda";
  #   };

  #   kernelExtras = false;

  #   externalInterface = "eth0";

  #   virtualisation = {
  #     docker = true;
  #     libvirt = false;
  #   };

  #   lan = {
  #     enable = false;

  #     samba.extraConfig = ''
  #       netbios name = ${config.networking.hostName}
  #       workgroup = WORKGROUP
  #       # add machine script = /run/current-system/sw/bin/useradd -d /var/empty -g 65534 -s /run/current-system/sw/bin/false -M %u
  #     '';

  #     dnsmasq.extraConfig = ''
  #       address=/.test.local/10.0.0.1
  #     '';

  #     krb5.default_realm = "LOCAL";

  #     krb5.domain_realm = {
  #       "local" = "LOCAL";
  #       ".local" = "LOCAL";
  #     };

  #     krb5.realms = {
  #       "LOCAL" = {
  #         admin_server = "dc.local";
  #         kdc = "dc.local";
  #       };
  #     };
  #   };
  # };
}

