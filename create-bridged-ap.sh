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

# Create hostapd configuration file
sudo touch /etc/hostapd/hostapd.conf

# Receive country code
read -p "Write your country code (US, GB, MX) and press enter:" country

# Receive operation mode
read -p "Choose operation mode (a=5GHz, b=2.4GHz, g=2.4GHz) and press enter:" mode

# Create network SSID
read -p "Write the name of your newtork and press enter:" ssid

# Create network password
read -p "Write the password of your network" pass

# Change channel according to operation mode
if [ "$mode" = "a" ]; then
	channel = "40"
else
	channel = "7"
fi

# Edit hostapd configuration file  with saved values
sudo tee -a /etc/hostapd/hostapd.conf > /dev/null <<EOT
country_code=${country:-US}
interface=wlan0
bridge=br0
ssid=${ssid:-PiNet}
hw_mode=${mode:-g}
channel=${channel:-7}
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=${pass:-qawsed78}
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOT
