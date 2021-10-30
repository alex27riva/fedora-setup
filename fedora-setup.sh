#!/bin/bash
HEIGHT=18
WIDTH=90
CHOICE_HEIGHT=4
BACKTITLE="Fedora quick setup"
TITLE="Make a selection"
MENU="Please Choose one of the following options:"
n_time=5

OH_MY_ZSH_URL="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
FLATPAK_LIST="flatpak.list"
debug=True

function pause(){
    read -s -n 1 -p "Press any key to return to the menu"
    echo ""
}

# catch Ctrl+c, clear the screen and exit
function cleanup()
{
    clear
}

trap cleanup EXIT

which dialog 2>/dev/null
ret=$?
[[ $ret -eq 1 ]] && echo "Dialog not installed, installing it..." && sudo dnf -y install dialog

OPTIONS=(1 "Enable RPM Fusion - Enables the RPM Fusion Repos"
    2 "Enable Better Fonts - Better font rendering by Dawid"
    3 "Speed up DNF - This enables fastestmirror, max downloads and deltarpms"
    4 "Enable Flatpak - Flatpak is installed by default but not enabled"
    5 "Install Software - Installs a bunch of my most used software"
    6 "Setup ARC Theme - Installs and enables Arc Theme and Papirus Icons"
    7 "Install ZSH and Oh My ZSH"
    8 "DNF tweaks - add default to yes"
    9 "Dump installed flatpaks - Save list of installed flatpaks to file"
    10 "Install flatpaks - Install flatpaks from file"
99 "Quit")

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
            notify-send "Fonts prettified - enjoy!" --expire-time=$n_time
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
            notify-send "Flatpak has now been enabled" --expire-time=$n_time
        ;;
        5)  echo "Installing Software"
            sudo dnf install -y gnome-extensions-app gnome-tweaks gnome-shell-extension-appindicator\
            arc-theme papirus-icon-theme neofetch vim
            [[ $debug = True ]] && pause
            notify-send "Software has been installed" --expire-time=$n_time
        ;;
        6)  echo "Enabling Flat GTK and Icon Theme"
            sudo dnf install -y gnome-shell-extension-user-theme
            # gnome-extensions install user-theme@gnome-shell-extension.gcampax.github.com
            # gnome-extensions enable user-theme@gnome-shell-extension.gcampax.github.com
            gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark-solid"
            gsettings set org.gnome.desktop.wm.preferences theme "Arc-Dark-solid"
            gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
            [[ $debug = True ]] && pause
            notify-send "There you go, that's better" --expire-time=$n_time
        ;;
        7)  echo "Installing ZSH and Oh My ZSH"
            sudo dnf -y install zsh util-linux-user
            sh -c "$(curl -fsSL $OH_MY_ZSH_URL --unattended)"
            if [ ! -f "$ZSHRC_FILE" ]; then
                cp -v zshrc_template ~/.zshrc
                echo ".zshrc file copied"
            fi
            echo "Installing zsh_autosuggestions"
            git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
            echo "change shell to ZSH"
            chsh -s "$(which zsh)"
            [[ $debug = True ]] && pause
        ;;
        8)  echo "Tweak DNF configuration"
            grep defaultyes /etc/dnf/dnf.conf > /dev/null
            ret=$?
            if [[ $ret -eq 1 ]]; then
                echo 'defaultyes=True' | sudo tee -a /etc/dnf/dnf.conf
            else
                echo "Tweak already applied"
            fi
            [[ $debug = True ]] && pause
        ;;
        9)  echo "Creating a list of installed flatpak"
            if [[ -f $FLATPAK_LIST ]]; then
                while true; do
                    read -p "File already exists, overwrite? (yn)" yn
                    case $yn in
                        [Yy]* ) flatpak list --app --columns=application | grep -v "Application ID" > $FLATPAK_LIST; echo "File successfully saved"; break;;
                        [Nn]* ) echo "file not saved"; break;;
                        * ) echo "Please answer yes or no.";;
                    esac
                done
            else
                flatpak list --app --columns=application | grep -v "Application ID" > $FLATPAK_LIST; echo "File successfully saved";
            fi
            [[ $debug = True ]] && pause
        ;;
        10)
            echo "Installing flatpaks from list:"
            input="$FLATPAK_LIST"
            while IFS= read -r line
            do
                echo " Installling $line"
                flatpak -y install "$line"
            done < "$input"
            [[ $debug = True ]] && pause
        ;;
        
        
        99)
            echo "exit"
            exit 0
        ;;
    esac
done
