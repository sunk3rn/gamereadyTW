#!/bin/sh
# vars
setting=""
# func
get_lang() {
    local lang="${LANG:0:2}"
    local available=("pt")
    if [[ " ${available[*]} " == *"$lang"* ]]; then
        ulang="$lang"
    else
        ulang="en"
    fi
    if [ $ulang == "pt" ]; then
        source ./langs/lang_pt
    else
        source ./langs/lang_en
    fi
}
get_os () {
    if command -v "pacman" &> /dev/null; then
        setting="cachy"
        echo $cachy
    elif command -v "apt" &> /dev/null; then
        setting="ubuntu"
        echo $deb
    elif command -v "dnf" &> /dev/null; then
        setting="fedora"
        echo $rpm
    else
        echo $incompat
        sleep 5
        exit 1
    fi
}
fedora_scr () {
    GPU=$(lspci | grep -i '.* vga .* nvidia .*')
	shopt -s nocasematch
	if [[ $GPU == *' nvidia '* ]]; then
		echo $yesnvidia
        sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-power xorg-x11-drv-nvidia-cuda-libs
	else
		echo $nonvidia
	fi
    sudo dnf in -y wine-staging winetricks dxvk vkd3d lutris steam
    flatpak install -y --or-update --noninteractive com.vysp3r.ProtonPlus com.github.tchx84.Flatseal
}
cachy_scr () {
    source ./bit
    if [ $bit == "0" ]; then
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
        # append chaotic append
        sudo pacman -Syu --noconfirm
        sudo pacman -S --needed --noconfirm yay octopi flatpak wine-staging winetricks vkd3d dxvk steam lutris
        sed -i '1 s/^.*$/bit="1"/' bit
        echo $reboot
    elif [ $bit == "1" ]; then
        flatpak install -y --or-update --noninteractive com.vysp3r.ProtonPlus com.github.tchx84.Flatseal
        sed -i '1 s/^.*$/bit="0"/' bit
        echo $finished
    else
        echo $bitnotfound
        sleep 5
        exit 2
    fi
}
ubuntu_scr () {
    source ./bit
    if [ $bit == "0" ]; then
        sudo apt install -y flatpak wine-staging dxvk vkd3d lutris steam winetricks
        sed -i '1 s/^.*$/bit="1"/' bit
        echo $reboot
    elif [ $bit == "1" ]; then
        flatpak install -y --or-update --noninteractive com.vysp3r.ProtonPlus com.github.tchx84.Flatseal
        sed -i '1 s/^.*$/bit="0"/' bit
        echo $finished
    else
        echo $bitnotfound
        sleep 5
        exit 2
    fi
}
# runtime
get_lang
get_os
if [ $setting == "fedora" ]; then
    fedora_scr
    echo $finished
elif [ $setting == "cachy" ]; then
    cachy_scr
elif [ $setting == "ubuntu" ]; then
    ubuntu_scr
else
    echo $incompat
    exit 1
fi
sleep 5
exit 0
