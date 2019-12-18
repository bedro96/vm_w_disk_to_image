#!/bin/bash

sudo apt update
sudo apt dist-upgrade -y

# fdisk /dev/sdc
sudo sh -c 'echo "n\np\n\n\n\nw\n" | fdisk /dev/sdc'

# mkfs
sudo mkfs -t ext4 /dev/sdc1
# create a mount point 
sudo mkdir -p /logs
sudo sh -c 'chown nobody:nogroup /logs'
sudo sh -c 'chmod 777 /logs'
# mount 
sudo mount /dev/sdc1 /logs
# Get UUID for /dev/sdc and place in fstab
# sudo -i blkid
# /dev/sdc1: UUID=33333333-3b3b-3c3c-3d3d-3e3e3e3e3e3e TYPE=ext4
sdc_uuid=$(sudo -i blkid | grep ^/dev/sdc1 | awk -F '"' '{print $2}')
# sdc_uuid=`sudo -i blkid | grep ^/dev/sdc1 | awk -F '' '{print $2}'`
# UUID=33333333-3b3b-3c3c-3d3d-3e3e3e3e3e3e   /logs   ext4   defaults   1   2
inputstring="UUID=$sdc_uuid /logs ext4 defaults 1 2"
echo $inputstring | sudo tee -a /etc/fstab
sudo umount /logs
sudo mount /logs

# Disabling cloud-init
echo disable cloud-init
sudo touch /etc/cloud/cloud-init.disabled
sudo sed -i '/azure_resource/d' /etc/fstab
echo comment out source VM config
sudo sed -i -e 's/match:/#match:/g' /etc/netplan/50-cloud-init.yaml
sudo sed -i -e 's/macaddress:/#macaddress:/g' /etc/netplan/50-cloud-init.yaml
sudo sed -i -e 's/set-name:/#set-name:/g' /etc/netplan/50-cloud-init.yaml
echo update the netplan config
echo note you would need to restart the systemd.networkd.service to apply it
echo this relies on a new VM starting the network with this config
sudo netplan generate
sudo netplan apply