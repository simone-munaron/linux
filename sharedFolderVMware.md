# Aggiorna i repository e installa i tool necessari nella VM linux (debian)
sudo apt update
sudo apt install open-vm-tools open-vm-tools-desktop -y

# Questo comando deve restituire il nome della cartella scelto al punto 1.4
vmware-hgfsclient

# Mount definitivo sostituisci shared_data con il nome della cartella condivisa restituita da "vmware-hgfsclient"
sudo nano /etc/fstab
.host:/shared_data /mnt/hgfs fuse.vmhgfs-fuse allow_other,uid=1000,gid=1000,auto_unmount 0 0