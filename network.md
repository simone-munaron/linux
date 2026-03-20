# Gestione Rete Linux - Comandi Utili

## Visualizza Configurazione
- `ip addr show` o `ip a`: Lista IP tutte interfacce.[web:52]
- `ip link show`: Lista interfacce rete (nomi enp*, wlp*).
- `hostname -I`: Solo IP attivi rapidi.
- `ip route show`: Tabella routing/gateway.

## Cambia IP Temporaneo
1. `sudo ip addr flush dev enp2s0` (pulisci IP).
2. `sudo ip addr add 192.168.1.100/24 dev enp2s0`.
3. `sudo ip route add default via 192.168.1.1`.
4. DNS: `echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf`.[web:76]

## NMCLI Persistente
- `nmcli con show`: Lista connessioni.
- DHCP: `nmcli con mod 'Wired connection 1' ipv4.method auto && nmcli con up 'Wired connection 1'`.
- Statico: `nmcli con mod 'Wired connection 1' ipv4.method manual ipv4.addresses 192.168.1.100/24 ipv4.gateway 192.168.1.1 ipv4.dns '8.8.8.8 8.8.4.4' && nmcli con up 'Wired connection 1'`.[web:98]

## Netplan Persistente
- `ls /etc/netplan/`: Lista file.
- `sudo netplan status`: Config attive.
- Edita YAML, `sudo netplan generate && sudo netplan apply`.[web:72]

## Altri Comandi Utili
- `ping 8.8.8.8`: Test connettività.
- `nmcli device wifi list`: WiFi disponibili.
- `sudo systemctl restart NetworkManager`: Riavvia servizio.
- `ss -tuln`: Porte TCP/UDP aperte.
- `sudo iptables -L`: Regole firewall.
- `curl ifconfig.me`: IP pubblico.
- `traceroute 8.8.8.8`: Percorso pacchetti.[code_file:1]

