#!/bin/bash

# --- CONFIGURAZIONE DEFAULT ---
DEFAULT_BACKUP_DIR="$HOME/vm_backups"
LIBVIRT_IMAGES="/var/lib/libvirt/images"

# Funzione per mostrare le VM presenti nel sistema
show_vms() {
    echo -e "\n\e[34m--- MACCHINE VIRTUALI ATTUALI ---\e[0m"
    virsh list --all
    echo "------------------------------------------"
}

# Funzione per validare e creare la directory se non esiste
get_directory() {
    local prompt_msg=$1
    read -p "$prompt_msg [$DEFAULT_BACKUP_DIR]: " USER_DIR
    USER_DIR=${USER_DIR:-$DEFAULT_BACKUP_DIR}
    
    if [ ! -d "$USER_DIR" ]; then
        echo "La directory non esiste. Tento di crearla..."
        mkdir -p "$USER_DIR" || { echo "Errore: Impossibile creare la directory."; exit 1; }
    fi
    echo "$USER_DIR"
}

# --- LOGICA DI ESPORTAZIONE ---
export_vm() {
    show_vms
    read -p "Inserisci il nome della VM da esportare: " VM_NAME
    
    if ! virsh dominfo "$VM_NAME" >/dev/null 2>&1; then
        echo -e "\e[31mErrore: VM '$VM_NAME' non trovata.\e[0m"
        return
    fi

    TARGET_DIR=$(get_directory "Dove vuoi salvare i file di backup?")

    echo "Analisi dischi in corso..."
    DISK_PATH=$(virsh domblklist "$VM_NAME" --details | grep 'disk' | awk '{print $4}' | head -n 1)

    echo -e "\e[32mEsportazione XML...\e[0m"
    virsh dumpxml "$VM_NAME" > "$TARGET_DIR/$VM_NAME.xml"
    
    echo -e "\e[32mCopia disco QCOW2 (sparse mode)... Questo richiederà tempo.\e[0m"
    sudo cp --sparse=always -v "$DISK_PATH" "$TARGET_DIR/$VM_NAME.qcow2"
    
    sudo chown $USER:$USER "$TARGET_DIR/$VM_NAME.xml" "$TARGET_DIR/$VM_NAME.qcow2"
    echo -e "\n\e[32m[BACKUP COMPLETATO]\e[0m File salvati in: $TARGET_DIR"
}

# --- LOGICA DI IMPORTAZIONE ---
import_vm() {
    SOURCE_DIR=$(get_directory "Da quale directory devo prelevare i file?")
    
    echo -e "\nFile trovati in $SOURCE_DIR:"
    ls -lh "$SOURCE_DIR" | grep -E ".xml|.qcow2"
    
    read -p "Inserisci il nome base del file (es. se hai 'webserver.xml', scrivi 'webserver'): " FILE_BASE
    
    XML_FILE="$SOURCE_DIR/$FILE_BASE.xml"
    QCOW_FILE="$SOURCE_DIR/$FILE_BASE.qcow2"

    if [[ ! -f "$XML_FILE" || ! -f "$QCOW_FILE" ]]; then
        echo -e "\e[31mErrore: File $FILE_BASE.xml o .qcow2 non trovati.\e[0m"
        return
    fi

    echo "Copia del disco nel volume storage di sistema ($LIBVIRT_IMAGES)..."
    sudo cp -v "$QCOW_FILE" "$LIBVIRT_IMAGES/$FILE_BASE.qcow2"
    sudo chown libvirt-qemu:libvirt-qemu "$LIBVIRT_IMAGES/$FILE_BASE.qcow2"

    # Piccola correzione dinamica del percorso disco nell'XML prima dell'import
    # Questo serve se il percorso originale era diverso da /var/lib/libvirt/images
    sed -i "s|<source file='.*'/>|<source file='$LIBVIRT_IMAGES/$FILE_BASE.qcow2'/>|g" "$XML_FILE"

    echo "Definizione della nuova VM..."
    virsh define "$XML_FILE"
    
    echo -e "\n\e[32m[IMPORTAZIONE COMPLETATA]\e[0m"
    show_vms
}

# --- MENU PRINCIPALE ---
clear
echo "==========================================="
echo "   KVM MIGRATION TOOL (Zorin/Ubuntu)       "
echo "==========================================="
echo "1) ESPORTA (Macchina Origine)"
echo "2) IMPORTA (Macchina Destinazione)"
echo "3) ESCI"
echo "-------------------------------------------"
read -p "Scegli opzione: " OPT

case $OPT in
    1) export_vm ;;
    2) import_vm ;;
    3) exit 0 ;;
    *) echo "Opzione non valida." ;;
esac

