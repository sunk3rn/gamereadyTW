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
    if [ $ulang == "cs"]; then
        source ./langs/lang_cs
    else
        source ./langs/lang_en
    fi
}
get_os () {
    . /etc/os-release
    setting=
    for id in $ID_LIKE
    do
        case "$id" in
            suse)
                setting="suse"
                echo $suse
                ;;
            arch)
                setting="cachy"
                echo $cachy
                ;;
            fedora)
                setting="fedora"
                echo $rpm
                ;;
            ubuntu)
                setting="ubuntu"
                echo $deb
                ;;
        esac
    done
    if -z "$setting"
    then
         echo $incompat
         sleep 5
         exit 1
    fi
# old OS checking - deprecated but left in case of issues with new code
#    if command -v "pacman" &> /dev/null; then
#        setting="cachy"
#        echo $cachy
#    elif command -v "apt" &> /dev/null; then
#        setting="ubuntu"
#        echo $deb
#    elif command -v "dnf" &> /dev/null; then
#        setting="fedora"
#        echo $rpm
#    elif command -v "zypper" &> /dev/null; then
#        setting="suse"
#        echo $suse
#    else
#        echo $incompat
#        sleep 5
#        exit 1
#    fi
}
fedora_scr () {
    GPU=$(lspci | grep -i '.* vga .* nvidia .*')
	shopt -s nocasematch
	if [[ $GPU == *' nvidia '* ]]; then
		echo $yesnvidia
        sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-power xorg-x11-drv-nvidia-cuda-libs
        sudo dracut -f --regenerate-all
	else
		echo $nonvidia
	fi
    sudo dnf in -y wine-staging winetricks dxvk vkd3d lutris steam
    flatpak install -y --or-update --noninteractive --system com.vysp3r.ProtonPlus com.github.tchx84.Flatseal
    echo $finished
}
cachy_scr () {
    source ./bit
    if [ $bit == "0" ]; then
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
        sudo sed -i -f script.sed /etc/pacman.conf
        sudo pacman -Syu --noconfirm
        sudo pacman -S --needed --noconfirm yay octopi flatpak wine-staging winetricks vkd3d dxvk steam lutris
        sed -i '1 s/^.*$/bit="1"/' bit
        echo $reboot
    elif [ $bit == "1" ]; then
        flatpak install -y --or-update --noninteractive --system com.vysp3r.ProtonPlus com.github.tchx84.Flatseal
        sed -i '1 s/^.*$/bit="2"/' bit
        echo $finished
    elif [ $bit == "2" ]; then
        echo $again
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
        sudo apt install -y flatpak
        sudo apt install -y gnome-software gnome-software-plugin-flatpak gnome-software-plugin-snap ffmpegthumbnailer ubuntustudio-installer
        flatpak flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        flatpak install -y --or-update --noninteractive --system net.lutris.Lutris com.valvesoftware.Steam com.vysp3r.ProtonPlus com.github.tchx84.Flatseal 
        sed -i '1 s/^.*$/bit="1"/' bit
        echo $reboot
    elif [ $bit == "1" ]; then
        echo $again
        sed -i '1 s/^.*$/bit="0"/' bit
        echo $finished
    else
        echo $bitnotfound
        sleep 5
        exit 2
    fi
}
suse_scr () {
    GPU=$(lspci | grep -i '.* vga .* nvidia .*')
	shopt -s nocasematch
	if [[ $GPU == *' nvidia '* ]]; then
        echo $yesnvidia
        sudo zypper in -q nvidia-video-G06 nvidia-gl-G06 nvidia-compute-G06 nvidia-compute-utils-G06 nvidia-settings
        sudo dracut -f --regenerate-all
    else
        echo $nonvidia
    fi
    sudo zypper in -q opi
    sudo opi codecs
    sudo zypper addrepo https://download.opensuse.org/repositories/openSUSE:Factory:NonFree/standard/openSUSE:Factory:NonFree.repo
    sudo zypper refresh
    sudo zypper install steam discord
    flatpak install -y --or-update --noninteractive --system com.dec05eba.gpu_screen_recorder com.github.tchx84.Flatseal net.lutris.Lutris com.vysp3r.ProtonPlus com.heroicgameslauncher.hgl
    sudo setsebool -P selinuxuser_execmod 1
    echo $finished
}
# runtime
get_lang
get_os
if [ $setting == "fedora" ]; then
    fedora_scr
elif [ $setting == "cachy" ]; then
    cachy_scr
elif [ $setting == "ubuntu" ]; then
    ubuntu_scr
elif [ $setting == "suse" ]; then
    suse_scr
else
    echo $incompat
    sleep 5
    exit 1
fi
sleep 5
exit 0
