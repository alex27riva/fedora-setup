#!/bin/bash
HEIGHT=15
WIDTH=90
CHOICE_HEIGHT=4
BACKTITLE="Fedora quick setup"
TITLE="Make a selection"
MENU="Please Choose one of the following options:"

OH_MY_ZSH_URL="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"


which dialog 1>/dev/null && echo "Dialog not installed, installing it" && sudo dnf -y install dialog

OPTIONS=(1 "Enable RPM Fusion - Enables the RPM Fusion Repos"
         2 "Enable Better Fonts - Better font rendering by Dawid"
         3 "Speed up DNF - This enables fastestmirror, max downloads and deltarpms"
         4 "Enable Flatpak - Flatpak is installed by default but not enabled"
         5 "Install Software - Installs a bunch of my most used software"
         6 "Setup Flat Look - Installs and Enables the Flat GTK and Icon themes"
         7 "Install ZSH and Oh My ZSH"
         10 "Quit")

while [ "$CHOICE -ne 4" ]; do
    CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --nocancel \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

    clear
    case $CHOICE in
        1)  echo "Enabling RPM Fusion"
            sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
            notify-send "RPM Fusion Enabled" --expire-time=10
           ;;
        2)  echo "Enabling Better Fonts by Dawid"
            sudo -s dnf -y copr enable dawid/better_fonts
            sudo -s dnf install -y fontconfig-font-replacements
            sudo -s dnf install -y fontconfig-enhanced-defaults
            notify-send "Fonts prettified - enjoy!" --expire-time=10
           ;;
        3)  echo "Speeding Up DNF"
            echo 'fastestmirror=1' | sudo tee -a /etc/dnf/dnf.conf
            echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
            echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
            notify-send "Your DNF config has now been amended" --expire-time=10
           ;;
        4)  echo "Enabling Flatpak"
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            flatpak update
            notify-send "Flatpak has now been enabled" --expire-time=10
           ;;
        5)  echo "Installing Software"
            sudo dnf install -y gnome-extensions-app gnome-tweaks gnome-shell-extension-appindicator gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel lame\* --exclude=lame-devel \
                arc-theme dropbox nautilus-dropbox papirus-icon-theme neofetch
            notify-send "Software has been installed" --expire-time=10
           ;;
        6)  echo "Enabling Flat GTK and Icon Theme"
            sudo dnf install -y gnome-shell-extensions-user-theme
            gnome-extensions install user-theme@gnome-shell-extensions.gcampax.github.com
            gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
            gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark-solid"
            # gsettings set org.gnome.desktop.wm.preferences theme "Flat-Remix-Blue"
            gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
            notify-send "There you go, that's better" --expire-time=10
           ;;
        7)  echo "Installing ZSH and Oh My ZSH"
            sudo dnf -y install zsh util-linux-user
            sh -c "$(curl -fsSL $OH_MY_ZSH_URL)"
            if [ ! -f "$ZSHRC_FILE" ]; then
		        cp -v zshrc_template $HOME
		        echo ".zshrc file copied"
	        fi
            echo "Installing zsh_autosuggestions"
            git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
            echo "change shell to ZSH"
            ;;

        10)
          exit 0
          ;;
    esac
done
