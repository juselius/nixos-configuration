sys=/dev/nvme0n1
root=${sys}p1
boot=${sys}p2

# data=/dev/sda1

parted $sys -- mklabel gpt

parted $sys -- mkpart primary 512MiB 100%
parted $sys -- set 1 lvm on
parted $sys -- mkpart ESP fat32 1MiB 512MiB
parted $sys -- set 2 esp on

cryptsetup luksFormat $root
cryptsetup open $root luks-root

pvcreate /dev/mapper/luks-root
vgcreate vg0 /dev/mapper/luks-root
lvcreate -L 8G -n swap vg0
lvcreate -l '100%FREE' -n root vg0

mkfs.fat -F 32 -n boot $boot
mkfs.ext4 -L root /dev/vg0/root
mkswap -L swap /dev/vg0/swap

mount /dev/vg0/root /mnt
mkdir -p /mnt/boot
mount $boot /mnt/boot

swapon /dev/vg0/swap

# /data
if [ -n "$data" ]; then
    wipefs -a $data
    cryptsetup luksFormat $data
    cryptsetup open $data luks-data

    pvcreate /dev/mapper/luks-data
    vgcreate vg1 /dev/mapper/luks-data
    lvcreate -l '100%FREE' -n data vg1

    mkfs.ext4 -L root /dev/vg1/data
fi

# install
which git
[ $? != 0 ] && nix-env -iA nixos.git
[ ! -d /mnt/etc/nixos ] && git clone https://github.com/juselius/nixos-configuration.git /mnt/etc/nixos
[ -f /mnt/etc/nixos/hardware-configuration.nix ] && cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration.nix.bak
nixos-generate-config --show-hardware-config > /mnt/etc/nixos/hardware-configuration.nix


