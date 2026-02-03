#!/bin/bash

# --- CONFIGURATION ---
LOG_DIR="/var/log"
HISTORY_FILE="/var/log/clean_logs_history.log"
TEMP_LIST=$(mktemp) # Fichier temporaire pour stocker la liste des candidats

# Codes couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- VÉRIFICATIONS PRÉLIMINAIRES ---

# 1. Vérifier les droits root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Erreur : Ce script doit être exécuté avec sudo.${NC}"
   exit 1
fi

# 2. Vérifier l'argument (nombre de jours)
DAYS=$1
if [[ -z "$DAYS" ]] || ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
    echo -e "${YELLOW}Usage : sudo $0 <nombre_de_jours>${NC}"
    echo "Exemple : sudo $0 7 (pour supprimer les logs de plus de 7 jours)"
    rm -f "$TEMP_LIST"
    exit 1
fi

echo -e "${BLUE}--- Recherche des fichiers (.log et .gz) de plus de $DAYS jours dans $LOG_DIR ---${NC}"

# --- RECHERCHE DES FICHIERS ---

# On cherche :
# - Dans /var/log
# - Type fichier (-type f)
# - Nom finissant par .log OU .gz
# - Modifié il y a plus de X jours (-mtime +X)
# - On exclut le fichier d'historique de ce script pour ne pas le supprimer
find "$LOG_DIR" -type f \( -name "*.log" -o -name "*.gz" \) -mtime +$DAYS ! -name "$(basename $HISTORY_FILE)" -print0 > "$TEMP_LIST"

# Vérifier si des fichiers ont été trouvés
if [[ ! -s "$TEMP_LIST" ]]; then
    echo -e "${GREEN}Aucun fichier ancien trouvé à nettoyer.${NC}"
    rm -f "$TEMP_LIST"
    exit 0
fi

# --- AFFICHAGE ET CALCUL ---

echo -e "\n${YELLOW}Les fichiers suivants sont candidats à la suppression :${NC}"
echo "---------------------------------------------------"

# Afficher la liste et la taille avec du (disk usage)
# --files0-from lit la liste générée par find (qui gère les espaces dans les noms)
du -ah --files0-from="$TEMP_LIST"

echo "---------------------------------------------------"

# Récupérer la taille totale (la dernière ligne de du -ch contient "total")
TOTAL_SIZE=$(du -ch --files0-from="$TEMP_LIST" | tail -n1 | cut -f1)
FILE_COUNT=$(tr -cd '\0' < "$TEMP_LIST" | wc -c) # Compte les null bytes

echo -e "Nombre de fichiers : ${BLUE}$FILE_COUNT${NC}"
echo -e "Espace disque récupérable : ${RED}$TOTAL_SIZE${NC}"

# --- CONFIRMATION ---

echo ""
read -p "Confirmez-vous la suppression DÉFINITIVE de ces fichiers ? (o/N) : " response

if [[ "$response" =~ ^[oO](ui)?$ ]]; then
    
    # --- SUPPRESSION ---
    # xargs -0 récupère les noms de fichiers depuis temp_list et exécute rm
    xargs -0 rm -f < "$TEMP_LIST"
    
    echo -e "\n${GREEN}Nettoyage terminé.${NC}"
    echo -e "Espace libéré : $TOTAL_SIZE"
    
    # --- JOURNALISATION ---
    DATE_NOW=$(date "+%Y-%m-%d %H:%M:%S")
    LOG_ENTRY="[$DATE_NOW] Nettoyage exécuté. Critère: >$DAYS jours. Fichiers supprimés: $FILE_COUNT. Espace libéré: $TOTAL_SIZE."
    
    echo "$LOG_ENTRY" >> "$HISTORY_FILE"
    echo "Opération enregistrée dans $HISTORY_FILE"

else
    echo -e "\n${BLUE}Opération annulée. Aucun fichier n'a été touché.${NC}"
fi

# --- NETTOYAGE FINAL ---
rm -f "$TEMP_LIST"