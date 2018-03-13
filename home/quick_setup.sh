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

# Install xorg and non-aur packages
sudo pacman -S xorg-server xorg-xclock xorg-xinit xorg-xrandr xterm thunar sddm networkmanager \
    pulseaudio pulseaudio-alsa imagemagick maim zenity feh --noconfirm --needed


# Install WM and stuff
pacaur -S i3-gaps-next-git i3status-git i3lock-git otf-font-awesome-4 ttf-monaco ttf-fira-mono ttf-fira-sans polybar-git rofi-git dunst-git termite-git compton-git --noconfirm --noedit --needed

# Firefox PGP key seems to break often so..
gpg --recv-key 0x61B7B526D98F0353

# Also need the PGP keys from libc++
gpg --recv-key 0x8F0871F202119294

# Install personal apps
pacaur -S discord-canary firefox-nightly neovim-git spotify ffmpeg-git mpv-git youtube-dl-git playerctl-git neofetch-git  --noconfirm --noedit --needed

# We're done! To make sure, set login to use graphical by default, then enable and start the display manager.
sudo systemctl set-default graphical.target 
sudo systemctl enable sddm.service
sudo systemctl start sddm.service 
