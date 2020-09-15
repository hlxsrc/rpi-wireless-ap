#!/bin/bash

# Update system
sudo apt update

# Install access point software
sudo apt install hostapd

# Enable wireless access point service
sudo systemctl unmask hostapd
# Set start on boot
sudo systemctl enable hostapd
