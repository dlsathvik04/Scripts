#!/bin/bash

# Update and upgrade the system
echo "Updating and upgrading the system..."
sudo pacman -Syu --noconfirm

# Install basic dependencies
echo "Installing basic dependencies..."
sudo pacman -S --noconfirm git base-devel

# Install yay (AUR helper)
echo "Installing yay..."
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm

# After installation, delete the cloned yay folder
cd ..
rm -rf yay
echo "yay installed and the folder has been removed."

# Install NVIDIA drivers and related packages
echo "Installing NVIDIA drivers and related packages..."
sudo pacman -S --noconfirm nvidia-dkms nvidia-dkms lib32-nvidia-utils egl-wayland libva-nvidia-driver

# Detect NVIDIA GPU and modify bootloader if detected
nvidia_detect() {
    readarray -t dGPU < <(lspci -k | grep -E "(VGA|3D)" | awk -F ': ' '{print $NF}')
    if [ "${1}" == "--verbose" ]; then
        for indx in "${!dGPU[@]}"; do
            echo -e "\033[0;32m[gpu$indx]\033[0m detected // ${dGPU[indx]}"
        done
        return 0
    fi
    if [ "${1}" == "--drivers" ]; then
        while read -r -d ' ' nvcode ; do
            awk -F '|' -v nvc="${nvcode}" 'substr(nvc,1,length($3)) == $3 {split(FILENAME,driver,"/"); print driver[length(driver)],"\nnvidia-utils"}' "${scrDir}"/.nvidia/nvidia*dkms
        done <<< "${dGPU[@]}"
        return 0
    fi
    if grep -iq nvidia <<< "${dGPU[@]}"; then
        return 0
    else
        return 1
    fi
}

# Check if NVIDIA GPU is detected
if nvidia_detect; then
    echo -e "\033[0;32m[BOOTLOADER]\033[0m NVIDIA detected, adding nvidia_drm.modeset=1 to boot option..."

    # Modify GRUB to include nvidia_drm.modeset=1
    sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=\"\).*\"\$/\1nvidia_drm.modeset=1\"/' /etc/default/grub

    # Regenerate GRUB configuration
    sudo grub2-mkconfig -o /boot/grub/grub.cfg
else
    echo -e "\033[0;31m[BOOTLOADER]\033[0m NVIDIA not detected."
fi

# Install additional packages for Hyprland and system setup
echo "Installing additional packages..."
sudo pacman -S --noconfirm dolphin hyprland stow kitty mako nwg-bar cliphist \
    brightnessctl waybar power-profiles-daemon asusctl supergfxctl rog-control-center \
    spotify-launcher blueman network-manager-applet xorg-xwayland xdg-desktop-portal-hyprland \
    ttf-jetbrains-mono-nerd lxqt-policykit pavucontrol

# Enable services for power management and hybrid graphics
echo "Enabling supergfxd and power-profiles-daemon services..."
sudo systemctl enable supergfxd
sudo systemctl enable power-profiles-daemon

echo "Script completed successfully!"
