#!/bin/sh

# Make sure our shiny new arch is up-to-date
echo "Checking for system updates..."
sudo pacman -Syu

### Installing Pacaur
# Create a tmp-working-dir and navigate into it
mkdir -p /tmp/pacaur_install
cd /tmp/pacaur_install

# Install pacaur dependencies from arch repos
sudo pacman -S expac yajl git --noconfirm --needed

# Install cower from AUR
if [ ! -n "$(pacman -Qs cower)" ]; then
    curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower
    makepkg PKGBUILD --skippgpcheck --install --needed
fi

# Install pacaur from AUR
if [ ! -n "$(pacman -Qs pacaur)" ]; then
    curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
    makepkg PKGBUILD --install --needed
fi

# Clean up
cd ~
rm -r /tmp/pacaur_install

### Installing my stuff

# Install xorg
if [ ! -n "$(pacman -Qs xorg-server)" ]; then
    sudo pacman -S xorg-server xorg-xclock xorg-xinit xterm thunar sddm feh --noconfirm --needed
fi

# Install WM and stuff
pacaur -S i3-gaps-next-git i3status-git i3lock-git otf-font-awesome-4 ttf-monaco ttf-fira-mono ttf-fira-sans polybar-git rofi-git dunst-git termite-git compton-git --noconfirm --noedit --needed

# Install personal apps
pacaur -S discord-canary firefox-nightly neovim-git spotify mpv-git youtube-dl-git --noconfirm --noedit --needed

sudo systemctl set-default graphical.target 
sudo systemctl enable sddm.service
sudo systemctl start sddm.service 
