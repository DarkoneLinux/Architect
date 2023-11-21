source src/cmd.sh

declare -A software_list

function populate_software_list() {
    lang=$(echo $LANG | cut -d_ -f1)
    
    software_list=(
    ["1"]=" OBS Studio (flatpak)|com.obsproject.Studio"
    ["2"]=" OBS Studio (from Arch repository)|obs-studio"
    ["3"]=" Firefox|firefox firefox-i18n-${lang}"
    ["4"]=" Brave|brave-bin"
    ["5"]=" Chromium|chromium"
    ["6"]=" Vivaldi|vivaldi"
    ["7"]=" Google Chrome|google-chrome"
    ["8"]=" Microsoft Edge|microsoft-edge-stable-bin"
    ["9"]=" Discord|discord"
    ["10"]="Steam|steam"
    ["11"]="Lastest proton GE for Steam|proton-ge-custom-bin"
    ["12"]="Lutris|lutris wine-staging"
    ["13"]="Heroic Games Launcher|heroic-games-launcher-bin"
    ["14"]="protonup-qt|protonup-qt-bin"
    ["15"]="Spotify|spotify"
    ["16"]="Kdenlive|kdenlive"
    ["17"]="Davinci Resolve|davinci-resolve"
    ["18"]="Davinci Resolve Studio (paid version)|davinci-resolve-studio"
    ["19"]="LibreOffice|libreoffice-fresh libreoffice-fresh-${lang}"
    ["20"]="OnlyOffice|onlyoffice-bin"
    ["21"]="Gimp|gimp"
    ["22"]="Krita|krita"
    ["23"]="Inkscape|inkscape"
    ["24"]="VLC|vlc"
    ["25"]="Visual Studio Code|visual-studio-code-bin"
    ["26"]="Virtualbox|virtualbox-host-dkms virtualbox-guest-iso"
    ["27"]="Open RGB|openrgb-bin"
    ["28"]="Arch Update|arch-update"
)
}

function display_software_list() {
    echo -e "\n${GREEN}Software list${RESET}"
    local sorted_keys=($(echo "${!software_list[@]}" | tr ' ' '\n' | sort -n))
    for key in "${sorted_keys[@]}"; do
        IFS='|' read -ra software <<< "${software_list[$key]}"
        echo -e "${GREEN}${key})${RESET} ${software[0]}"
    done
}

function install_software() {
    populate_software_list
    display_software_list
    local choices
    read -rp ":: Packages to be installed (e.g. 1 2 3, 1-3, all) : " choices
    
    local lang=$(echo $LANG | cut -d_ -f1)
    local packages=""
    local flatpak=""

    if [[ $choices == "all" ]]; then
        for key in "${!software_list[@]}"; do
            IFS='|' read -ra software <<<"${software_list[$key]}"
            [[ $key == "1" ]] && flatpak="${software[1]}" || packages+="${software[1]} "
        done
    else
        for choice in $choices; do
            if [[ $choice =~ ^[0-9]+-[0-9]+$ ]]; then
                IFS='-' read -ra range <<<"$choice"
                for ((i = ${range[0]}; i <= ${range[1]}; i++)); do
                    if [[ -n ${software_list[$i]} ]]; then
                        IFS='|' read -ra software <<<"${software_list[$i]}"
                        [[ $i == "1" ]] && flatpak="${software[1]}" || packages+="${software[1]} "
                    fi
                done
            elif [[ -n ${software_list[$choice]} ]]; then
                IFS='|' read -ra software <<<"${software_list[$choice]}"
                [[ $choice == "1" ]] && flatpak="${software[1]}" || packages+="${software[1]} "
            fi
        done
    fi

    if [[ -n ${flatpak} ]]; then
        install_lst "${flatpak}" "flatpak"
    fi
    if [[ -n ${packages} ]]; then
        install_lst "${packages}"
    fi
}
