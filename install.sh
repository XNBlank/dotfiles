#!/bin/bash

NC='\033[0m'; # No Color
GREEN='\033[0;32m'; # Green
RED='\033[0;31m'; # Red
export SPIN_PID='';

if [ $EUID != 0 ]; then
	echo -e "${RED}This script requires superuser permissions.${NC}";
	exit 1;
fi

echo -e "${GREEN}Checking for the following packages:${NC}";

function load_msg {
	if [ "$SPIN_PID" != "" ]; then
		kill -9 $SPIN_PID;
	fi
	spin $1 &
	export SPIN_PID=$!;
}

function spin() (
	spinner="/-\\|/-\\|";	
	msg=$*;
	echo -ne "${msg} ${spinner:1:1}"
	while :
	do
		for i in `seq 0 7`
		do 
			echo -ne "\r\e[0K";
			echo -ne "${msg} ${spinner:$i:1}";	
			sleep 0.1;
		done
	done
)

function install_bspwm {
	apt-get install -y -qq libxcb-xinerama0-dev libxcb-icccm4-dev libxcb-randr0-dev\
		libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev > /dev/null;

	mkdir ~/git && cd ~/git &&\
		git clone https://github.com/baskerville/bspwm.git > /dev/null &&\
		git clone https://github.com/baskerville/sxhkd.git > /dev/null &&\
		cd ~/git/bspwm && make && make install &&\
		cd ~/git/sxhkd && make && make install &&\
		cd ~/ && rm -rf ~/git/;
}

function install_termite {
	apt-get install -y -q g++ libgtk-3-dev gtk-doc-tools gnutls-bin \
		valac intltool libpcre2-dev libglib3.0-cil-dev libgnutls28-dev \
		libgirepository1.0-dev libxml2-utils gperf build-essential > /dev/null;

	mkdir ~/git && cd ~/git &&\
		git clone https://github.com/thestinger/vte-ng.git > /dev/null &&\
		git clone --recursive https://github.com/thestinger/termite.git > /dev/null &&\
		echo export LIBRARY_PATH="/usr/include/gtk-3.0:$LIBRARY_PATH" &&\
		cd ~/git/vte-ng && ./autogen.sh && make > /dev/null && make install > /dev/null &&\
		cd ~/git/termite && make > /dev/null && make install > /dev/null && ldconfig &&\
		cd ~/ && rm -rf ~/git/;
}

function check_package {
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1 2> /dev/null | grep "install ok installed" | cut -d" " -f3);
	echo -en "$1: ${GREEN}$PKG_OK${NC}";
	if [ "" == "$PKG_OK" ]; then
		echo -en "\en[1A\r\e[0K";
		echo -en "\r\033[2K$1 ${RED}not installed.${NC}";
		sleep 1;
		load_msg "Installing ${GREEN}$1${NC}..." &
		apt-get -y -q install $1 > /dev/null;
		echo -en "\r\e[0K";
		echo -e "\r$1 ${GREEN}installed${NC}";
	else
		echo -e "\r";
	fi
}

function install_powerlineshell {
	pip3 install powerline-shell > /dev/null;
}

function install_wal {
	pip3 install pywal > /dev/null;
}

function install_poddycast {
	load_msg "Installing electron-packager...";
	npm install electron-packager -g > /dev/null 2>&1;
	echo -en "\r\e[0K";
	load_msg "Fetching poddycast from git...";
	git clone https://github.com/MrChuckomo/poddycast > /dev/null 2>&1;
	echo -en "\r\e[0K";
	load_msg "Building poddycast...";
	electron-packager ./poddycast/app poddycast --platform=linux --arch=x64 --out=build --electron-version=3.1.4 --asar > /dev/null 2>&1 &&\
	mv ./build/poddycast-linux-x64 ./build/poddycast && cp -r ./build/poddycast /usr/local/bin/ &&\
	ln -s /usr/local/bin/poddycast/poddycast /usr/bin/poddycast &&\
	rm -rf ./poddycast && rm -rf ./build;
}

function check_expackage {
	PKG_OK=$(which $1);
	if [ "" == "$PKG_OK" ]; then
		echo -en "$1 ${RED}not installed.${NC}";
		sleep 1;
		if [ $1 == "poddycast" ]; then
			install_poddycast;
		else
			load_msg "Fetching and building ${GREEN}$1${NC}.";
			if [ $1 == "slack" ]; then
				snap install slack --classic > /dev/null;
			elif [ $1 == "bspwm" ]; then
				install_bspwm;
			elif [ $1 == "termite" ]; then
				install_termite;
			elif [ $1 == "powerline-shell" ]; then
				install_powerlineshell;
			elif [ $1 == "wal" ]; then
				install_wal;
			elif [ $1 == "spotify" ]; then
				snap install spotify > /dev/null;
			elif [ $1 == "discord" ]; then
				wget -O /tmp/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb" > /dev/null
				gdebi /tmp/discord.deb > /dev/null
			fi
		fi
		echo -en "\r\e[0K";
		echo -e "\r$1 ${GREEN}installed${NC}";
	else
		echo -e "$1: ${GREEN}installed${NC}";
	fi
}

check_package 'neovim';
check_package 'firefox';
check_package 'git';
check_package 'htop';
check_package 'subversion';
check_package 'mysql-client';
check_package 'python3.7';
check_package 'python3-pip';
check_package 'dunst';
check_package 'compton';
check_package 'rofi';
check_package 'libssl1.0-dev';
check_package 'nodejs-dev';
check_package 'node-gyp';
check_package 'npm';
check_package 'nodejs';
check_package 'lxappearance';
check_package 'thunderbird';
check_package 'wget';
check_package 'curl';
check_package 'gdebi-core';
check_package 'neofetch';
check_package 'mpv';
check_package 'mpd';
check_package 'ncmpcpp';
check_package 'sonata';
check_package 'nginx';
check_package 'imagemagick';
check_package 'perl';
check_package 'putty-tools';
check_package 'cpanminus';
check_expackage 'spotify';
check_expackage 'slack';
check_expackage 'bspwm';
check_expackage 'termite';
check_expackage 'powerline-shell';
check_expackage 'wal';
check_expackage 'poddycast';

echo -e "${RED}Removing nonessential packages.${NC}";

function remove_package {
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1 2> /dev/null | grep "install ok installed" | cut -d" " -f3);
	if [ "" != "$PKG_OK" ]; then
		echo -e "Removing ${RED}$1${NC}";
		apt-get -y -qq remove $1 > /dev/null;
	fi
}

remove_package "pidgen*" 
remove_package "simple-scan"
remove_package "ristretto"
remove_package "bubblewrap"
remove_package "sgt-puzzles"
remove_package "sgt-launcher"
remove_package "gnome-desktop*"
remove_package "gnome-font-viewer"
remove_package "gnome-icon-theme"
remove_package "gnome-menus"
remove_package "gnome-software-common"
remove_package "gnome-themes*"
remove_package "gnome-mines"
remove_package "gnome-sudoku"
remove_package "gigolo"
remove_package "catfish"
remove_package "xfburn"
remove_package "parole"
remove_package "transmission-*"
remove_package "atril*"
remove_package "xubuntu-*"
remove_package "xfwm4"
remove_package "whoopsie"
remove_package "shimmer-themes"
remove_package "orage"
remove_package "mate-*"
remove_package "greybird-gtk-theme"
remove_package "foomatic*"
remove_package "cups"
remove_package "cups-*"
remove_package "bluez*"
remove_package "apport"
remove_package "apport-*"
remove_package "cheese-common"

export SPIN_PID='';

echo -e "${GREEN}Done.${NC}";
