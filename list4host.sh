#/bin/bash

# L'objectif du script est de récupérer sur la sortie standard la liste des noms et ip des containers pour pouvoir les mettre 
# facilement dans /etc/hosts.

# Le nom du serveur lxd est lxd à la suite d'une installation par snap.
# Un curl d'interrogation afin d'avoir la liste des instances
LIST_HOSTNAME=$(curl -s --unix-socket /var/snap/lxd/common/lxd/unix.socket -H "Content-Type: application/json" lxd/1.0/instances | jq '.metadata | .[] | .[15:]')
for I_HOSTNAME in $LIST_HOSTNAME
do
        # Supression des " de la variable I_HOSTNAME
        I_HOSTNAME=$(echo $I_HOSTNAME | sed -e "s/\"//g")
        # Récupération de l'ip avec le nom du container
        IP_HOSTNAME=$( curl -s --unix-socket /var/snap/lxd/common/lxd/unix.socket -H "Content-Type: application/json" "lxd/1.0/instances/${I_HOSTNAME}/state" | jq '.metadata.network.eth0.addresses[] | select(.family=="inet").address' )
        # Supression des " de la variable IP_HOSTNAME
        IP_HOSTNAME=$(echo $IP_HOSTNAME | sed -e "s/\"//g")
        # Affichage sur la sorti standard
        echo $I_HOSTNAME $IP_HOSTNAME
done