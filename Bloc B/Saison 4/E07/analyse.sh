#!/bin/bash

# --- CONFIGURATION ---
# Fichier temporaire pour stocker les résultats bruts (pour l'export)
REPORT_FILE="/tmp/disk_report_$(date +%Y%m%d_%H%M%S).txt"

# Codes couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# --- VÉRIFICATION ROOT ---
# Nécessaire pour lire tous les dossiers de /home avec 'du'
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Attention :${NC} Ce script doit être lancé avec sudo pour analyser correctement /home."
   echo "Usage : sudo $0"
   exit 1
fi

# Fonction pour ajouter du texte à la fois à l'écran et dans le fichier de rapport
# Usage : print_dual "Texte sans couleur" "Texte avec couleur pour l'écran"
print_dual() {
    local clean_text="$1"
    local colored_text="$2"
    
    # Si le texte coloré n'est pas fourni, on utilise le texte propre
    if [[ -z "$colored_text" ]]; then
        colored_text="$clean_text"
    fi
    
    echo -e "$colored_text"
    echo -e "$clean_text" >> "$REPORT_FILE"
}

# --- DÉBUT DU SCRIPT ---
# On vide/crée le fichier de rapport
> "$REPORT_FILE"

print_dual "--- RAPPORT D'UTILISATION DISQUE ---" "${BLUE}--- RAPPORT D'UTILISATION DISQUE ---${NC}"
print_dual "Date : $(date)" ""
print_dual "------------------------------------" ""

# 1. ANALYSE DES PARTITIONS
print_dual "\n[1] UTILISATION DES PARTITIONS :" "${YELLOW}\n[1] UTILISATION DES PARTITIONS :${NC}"
printf "%-20s %-10s %-10s %-10s %-20s\n" "Système" "Taille" "Utilisé" "Dispo" "Montage" >> "$REPORT_FILE"
printf "${BOLD}%-20s %-10s %-10s %-10s %-20s${NC}\n" "Système" "Taille" "Utilisé" "Dispo" "Montage"

# On boucle sur la sortie de df. 
# grep -vE exclut les systèmes de fichiers temporaires (tmpfs, udev, loop, cdrom)
df -hP | grep -vE '^Filesystem|tmpfs|cdrom|loop|udev' | while read -r fs size used avail usep mounted; do
    
    # On retire le '%' pour la comparaison numérique
    usage_int=${usep%\%}
    
    # Formatage de la ligne pour le fichier texte (clean)
    line_clean=$(printf "%-20s %-10s %-10s %-10s %-20s" "$fs" "$size" "$used" "$avail" "$mounted")
    echo "$line_clean" >> "$REPORT_FILE"

    # Gestion de la couleur (Rouge si >= 80%, sinon Vert)
    if [ $usage_int -ge 80 ]; then
        color=$RED
    else
        color=$GREEN
    fi
    
    # Affichage écran
    printf "%-20s %-10s ${color}%-10s${NC} %-10s %-20s\n" "$fs" "$size" "$usep" "$avail" "$mounted"
done

# 2. ANALYSE DE /HOME
print_dual "\n[2] TOP 10 CONSOMMATEURS DANS /HOME :" "${YELLOW}\n[2] TOP 10 CONSOMMATEURS DANS /HOME :${NC}"
print_dual "(Analyse en cours, veuillez patienter...)" "${BLUE}(Analyse en cours, veuillez patienter...)${NC}"

# Explication de la commande :
# du -h : taille lisible
# --max-depth=2 : On regarde les users (/home/user) et leurs sous-dossiers immédiats (/home/user/Downloads)
# 2>/dev/null : On cache les erreurs de permission si on n'est pas root (même si on a vérifié au début)
# sort -rh : trier par taille humaine (reverse)
# head -n 10 : les 10 premiers
top_dirs=$(du -h /home --max-depth=2 2>/dev/null | sort -rh | head -n 10)

print_dual "$top_dirs"

# --- PROPOSITION D'EXPORT ---
echo ""
echo -e "${BLUE}------------------------------------${NC}"
read -p "Voulez-vous enregistrer ce rapport dans un fichier ? (o/N) : " response

if [[ "$response" =~ ^[oO](ui)?$ ]]; then
    read -p "Entrez le nom du fichier (défaut: rapport_disque.txt) : " filename
    filename=${filename:-rapport_disque.txt}
    
    # On déplace le fichier temporaire vers la destination finale
    mv "$REPORT_FILE" "$filename"
    echo -e "${GREEN}Rapport sauvegardé sous : $filename${NC}"
else
    rm "$REPORT_FILE"
    echo "Rapport non sauvegardé."
fi