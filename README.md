# nixos-configuration

1. Download the NixOS [minimal installation CD](https://nixos.org/nixos/download.html)
2. Install NixOS by following the [installation instructions](https://nixos.org/nixos/manual/index.html#sec-installation)
3. For full disk encryption with LUKS and [encrypted root](https://gist.github.com/martijnvermaat/76f2e24d0239470dd71050358b4d5134)

## Configure the base OS

After partitioning, before running ``nixos-genrate-config``:

    # mkdir /mnt/etc
    # nix-env -i git vim
    # cd /mnt/etc
    # git clone https://github.com/juselius/nixos-configuration nixos
    # cd /mnt/etc/nixos
    # nixos-generate-config --show-hardware-config >>hardware-configuration.nix

    # vim configuration.nix
    # vim users.nix

    # nixos-install
    # reboot

## Configure the user account:

    # su - username
    $ git clone https://github.com/juselius/dotfiles .dotfiles
    $ git clone https://github.com/juselius/xmonad .xmonad
    $ ln -s .dotfiles/default.nix .
    $ vim default.nix
    $ nix-home


