# nixos-configuration

1. Download the NixOS [minimal installation CD](https://nixos.org/nixos/download.html)
2. Install NixOS by following the [installation instructions](https://nixos.org/nixos/manual/index.html#sec-installation)

Configure the base OS:

    # nix-env -i git vim
    # cd /tmp
    # git clone https://github.com/juselius/nixos-configuration
    # cp nixos-configuration/*.nix /etc/nixos/
    # vim /etc/nixos/configuration.nix
    # nixos-rebuild switch
    # reboot

Configure the user account:

    # su - username
    $ git clone https://github.com/juselius/dotfiles .dotfiles
    $ git clone https://github.com/juselius/xmonad .xmonad
    $ ln -s .dotfiles/default.nix .
    $ vim default.nix
    $ nix-home


