# remove the desktop packages
sudo apt remove --purge xserver-xorg x11-xserver-utils xinit openbox chromium-browser

# Remove any leftover dependencies
sudo apt autoremove --purge

# Clean up config files
rm -rf ~/.config/openbox
