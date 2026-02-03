#!/bin/bash

# --- CONFIGURATION ---
# Liste des serveurs à tester (DNS et IP)
SERVEURS=(
    "google.com"
    "github.com"
    "cloudflare.com"
    "wikipedia.org"
    "1.1.1.1" # Cloudflare DNS
    "8.8.8.8" # Google DNS
)

# Fichier de rapport
LOG_FILE="resultat_connexion_$(date +%Y%m%d).txt"

# Seuils de qualité (en millisecondes)
SEUIL_BON=50
SEUIL_MOYEN=150

# Codes couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- FONCTIONS ---

# Fonction pour écrire à l'écran et dans le fichier
# Usage: log_message "Message avec couleurs" "Message brut pour fichier"
log_message() {
    local screen_msg="$1"
    local file_msg="$2"

    # Si le 2ème argument est vide, on nettoie les codes couleurs du 1er pour le fichier
    if [[ -z "$file_msg" ]]; then
        file_msg=$(echo -e "$screen_msg" | sed 's/\x1b\[[0-9;]*m//g')
    fi

    echo -e "$screen_msg"
    echo "$file_msg" >> "$LOG_FILE"
}

# --- DÉBUT DU SCRIPT ---

# Initialisation du fichier log
> "$LOG_FILE"

# En-tête
HEADER_SCREEN="${BLUE}--- TEST DE CONNECTIVITÉ RÉSEAU ---${NC}"
HEADER_FILE="--- TEST DE CONNECTIVITÉ RÉSEAU ---"
log_message "$HEADER_SCREEN" "$HEADER_FILE"
log_message "Date : $(date)" ""
log_message "---------------------------------------------------------------" ""
# Format d'affichage : Nom (20 car), IP (15 car), Statut (10 car), Temps, Qualité
printf "%-20s %-15s %-10s %-10s %-15s\n" "CIBLE" "IP" "STATUT" "LATENCE" "QUALITÉ" >> "$LOG_FILE"
printf "${BLUE}%-20s %-15s %-10s %-10s %-15s${NC}\n" "CIBLE" "IP" "STATUT" "LATENCE" "QUALITÉ"

# Compteurs
TOTAL=${#SERVEURS[@]}
UP_COUNT=0

# --- BOUCLE DE TEST ---

for serveur in "${SERVEURS[@]}"; do
    # Ping : 1 paquet (-c 1), délai max 2 sec (-W 2), silencieux (-q)
    # On récupère l'IP résolue et le résultat
    ping_output=$(ping -c 1 -W 2 "$serveur" 2>&1)
    ping_exit_code=$?

    # Extraction de l'IP (entre parenthèses dans la sortie ping)
    ip_address=$(echo "$ping_output" | grep -oP '\(\K[^)]+')
    # Fallback si grep -P n'est pas dispo ou si c'est déjà une IP
    if [[ -z "$ip_address" ]]; then ip_address="$serveur"; fi

    if [ $ping_exit_code -eq 0 ]; then
        ((UP_COUNT++))
        status="${GREEN}EN LIGNE${NC}"
        status_clean="EN LIGNE"
        
        # Extraction du temps (time=XX.X ms)
        time_ms=$(echo "$ping_output" | grep -o "time=[0-9.]*" | cut -d= -f2)
        # Convertir en entier pour comparaison (suppression des décimales)
        time_int=${time_ms%.*}

        # Détermination de la qualité
        if [ "$time_int" -lt "$SEUIL_BON" ]; then
            quality="${GREEN}EXCELLENTE${NC}"
            quality_clean="EXCELLENTE"
        elif [ "$time_int" -lt "$SEUIL_MOYEN" ]; then
            quality="${YELLOW}MOYENNE${NC}"
            quality_clean="MOYENNE"
        else
            quality="${RED}LENTE${NC}"
            quality_clean="LENTE"
        fi
        
        # Affichage LIGNE SUCCÈS
        printf "%-20s %-15s %b %-10s %b\n" "$serveur" "$ip_address" "$status" "${time_ms} ms" "$quality"
        printf "%-20s %-15s %-10s %-10s %-15s\n" "$serveur" "$ip_address" "$status_clean" "${time_ms} ms" "$quality_clean" >> "$LOG_FILE"

    else
        status="${RED}HORS LIGNE${NC}"
        status_clean="HORS LIGNE"
        
        # Affichage LIGNE ÉCHEC
        printf "%-20s %-15s %b %-10s %s\n" "$serveur" "Inconnue" "$status" "-" "-"
        printf "%-20s %-15s %-10s %-10s %-15s\n" "$serveur" "Inconnue" "$status_clean" "-" "-" >> "$LOG_FILE"
    fi
done

# --- RÉSUMÉ FINAL ---

log_message "---------------------------------------------------------------" ""
summary_msg="RÉSULTATS : ${UP_COUNT}/${TOTAL} serveurs accessibles."
log_message "${BLUE}$summary_msg${NC}" "$summary_msg"

if [ $UP_COUNT -eq $TOTAL ]; then
    log_message "${GREEN}Le réseau est pleinement opérationnel.${NC}" "Le réseau est pleinement opérationnel."
elif [ $UP_COUNT -eq 0 ]; then
    log_message "${RED}ALERTE CRITIQUE : Aucune connexion internet.${NC}" "ALERTE CRITIQUE : Aucune connexion internet."
else
    log_message "${YELLOW}ATTENTION : Certains services sont inaccessibles.${NC}" "ATTENTION : Certains services sont inaccessibles."
fi

echo -e "\nRapport sauvegardé dans : ${YELLOW}$LOG_FILE${NC}"