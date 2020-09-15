#!/bin/bash

# Update system
sudo apt update

# Install access point software
sudo apt install hostapd

# Enable wireless access point service
sudo systemctl unmask hostapd
# Set start on boot
sudo systemctl enable hostapd

# Create a bridge device
sudo touch /etc/systemd/network/bridge-br0.netdev
sudo tee -a /etc/systemd/network/bridge-br0.netdev > /dev/null <<EOT
[NetDev]
Name=br0
Kind=bridge
EOT

# Add Ethernet interface as a bridge member 
sudo touch /etc/systemd/network/br0-member-eth0.network
sudo tee -a /etc/systemd/network/br0-member-eth0.network > /dev/null <<EOT
[Match]
Name=eth0

[Network]
Bridge=br0
EOT

# Enable systemd-networkd service to create the bridge at boot
sudo systemctl enable systemd-networkd

# Define bridge device IP configuration
sudo sed -i '1s/^/denyinterfaces wlan0 eth0\n/' /etc/dhcpcd.conf
sudo tee -a /etc/systemd/network/br0-member-eth0.network > /dev/null <<EOT

interface br0
EOT

# Ensure wireless operation
sudo rfkill unblock wlan
