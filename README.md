## update && upgrade
sudo apt update
sudo apt upgrade -y

## git
sudo apt update
sudo apt install git -y

## exfat
sudo apt update
sudo apt install exfat-fuse exfatprogs -y

## virt
sudo apt update
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients virt-manager bridge-utils ovmf -y
sudo systemctl enable --now libvirtd
sudo adduser $USER libvirt
sudo adduser $USER kvm
sudo adduser $USER libvirt-qemu
### necessario riavvio per utilizzare kvm

## cockpit (ubuntu)
sudo apt update
sudo apt install cockpit cockpit-machines -y
sudo systemctl enable --now cockpit.socket

## Firefox
sudo apt update
sudo apt install firefox -y

## FreeCAD
sudo add-apt-repository universe -y
sudo apt update
sudo apt install freecad -y

## Visual studio code
sudo apt update
sudo apt install code -y

## Steam
sudo apt update
sudo apt install steam -y

## riavvio per finire di configurare tutto
sudo reboot
