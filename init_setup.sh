#!/bin/bash

# Function to handle errors and log them
log_error() {
    echo "[ERROR] $1"
    exit 1
}

log_success() {
    echo "[SUCCESS] $1"
}

# Step 1: Install linux-headers, dkms, and nvidia-dkms
echo "Installing linux-headers, dkms, and nvidia-dkms..."
sudo pacman -Syu --noconfirm || log_error "Failed to update the system."
sudo pacman -S --noconfirm linux-headers dkms nvidia-dkms || log_error "Failed to install linux-headers, dkms, or nvidia-dkms."
log_success "linux-headers, dkms, and nvidia-dkms installed successfully."

# Step 2: Install yay (AUR helper)
echo "Installing yay..."
git clone https://aur.archlinux.org/yay.git || log_error "Failed to clone yay repository."
cd yay || log_error "Failed to enter yay directory."
makepkg -si --noconfirm || log_error "Failed to install yay."
cd .. || log_error "Failed to go back to the previous directory."
rm -rf yay || log_error "Failed to remove the yay folder."
log_success "yay installed and the folder removed."

# Step 3: Install additional packages using yay
echo "Installing packages using yay..."
yay -S --noconfirm asusctl supergfxctl rog-control-center thunar stow kitty mako cliphist \
    brightnessctl blueman ttf-jetbrains-mono-nerd lxqt-policykit hyprland hyprpaper hyprlock \
    hypridle rofi xorg-xwayland xdg-desktop-portal-hyprland pavucontrol power-profiles-daemon \
    spotify-launcher google-chrome visual-studio-code-bin github-cli btop waybar zsh || log_error "Failed to install one or more packages using yay."
log_success "All packages installed successfully."

# Step 4: Set zsh as the default shell
echo "Setting zsh as the default shell..."
chsh -s /bin/zsh || log_error "Failed to set zsh as the default shell."
log_success "zsh set as the default shell."

# Step 5: Check for existing Hyprland config and delete it
if [ -d "$HOME/.config/hypr" ]; then
    echo "Deleting existing ~/.config/hypr directory..."
    rm -rf "$HOME/.config/hypr" || log_error "Failed to remove existing Hyprland config."
    log_success "Existing Hyprland config removed."
else
    echo "No existing ~/.config/hypr directory found."
fi

# Step 6: Clone DotFiles repository and run stow
echo "Cloning DotFiles repository..."
git clone https://github.com/dlsathvik04/DotFiles.git "$HOME/DotFiles" || log_error "Failed to clone DotFiles repository."
cd "$HOME/DotFiles" || log_error "Failed to enter DotFiles directory."
stow . || log_error "Failed to run stow in DotFiles directory."
log_success "DotFiles repository cloned and stow applied."

# Step 7: Notify user and prompt for system reboot
echo "System setup completed successfully!"
read -p "Do you want to reboot your system now? (y/n): " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Rebooting the system..."
    sudo reboot
else
    echo "Please remember to reboot your system later."
fi
