#!/bin/bash

# ==============================================================================
# Script de monitoring système avec alertes et rapports
# Usage: ./monitor.sh [-r]
# -r : Génère un rapport dans /var/log/
# ==============================================================================

# --- Configuration des couleurs ---
# Codes ANSI pour l'affichage terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Fichier de log
LOG_FILE="/var/log/monitor_$(date +%Y%m%d).txt"
GENERATE_REPORT=false

# Gestion des options (2.3)
while getopts "r" opt; do
  case $opt in
    r) GENERATE_REPORT=true ;;
    *) echo "Usage: $0 [-r]" >&2; exit 1 ;;
  esac
done

# --- Fonctions ---

# Fonction pour déterminer la couleur en fonction du seuil (2.2)
# Usage: get_color_code <valeur_pourcentage>
get_color_code() {
    local val=${1%.*} # Supprime les décimales pour la comparaison
    if [ "$val" -ge 85 ]; then
        echo "$RED"
    elif [ "$val" -ge 70 ]; then
        echo "$YELLOW"
    else
        echo "$GREEN"
    fi
}

# Fonction principale de collecte et d'affichage
collect_and_display() {
    # Entête
    echo -e "${BLUE}${BOLD}=== RAPPORT MONITORING SYSTÈME ===${NC}"
    echo -e "Serveur : ${BOLD}$(hostname)${NC}"
    echo -e "Date    : $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "Uptime  : $(uptime -p)"
    echo -e "${BLUE}----------------------------------${NC}"

    # --- CPU (2.1 & 2.2) ---
    # Astuce: top -bn2 pour avoir l'instantané (la 1ère itération est souvent la moyenne depuis le boot)
    CPU_USAGE=$(top -bn2 | grep "Cpu(s)" | tail -1 | awk '{print $2 + $4}')
    CPU_COLOR=$(get_color_code "$CPU_USAGE")
    echo -e "Utilisation CPU    : ${CPU_COLOR}${CPU_USAGE}%${NC}"

    # --- Mémoire (2.1 & 2.2) ---
    # Récupération des valeurs en Mo
    MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
    
    # Calculs
    MEM_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($MEM_USED/$MEM_TOTAL)*100}")
    MEM_USED_GB=$(awk "BEGIN {printf \"%.2f\", $MEM_USED/1024}")
    MEM_TOTAL_GB=$(awk "BEGIN {printf \"%.2f\", $MEM_TOTAL/1024}")
    
    MEM_COLOR=$(get_color_code "$MEM_PERCENT")
    echo -e "Utilisation RAM    : ${MEM_COLOR}${MEM_USED_GB}Go / ${MEM_TOTAL_GB}Go (${MEM_PERCENT}%)${NC}"

    # --- Processus (2.1) ---
    PROCESS_COUNT=$(ps aux | wc -l)
    echo -e "Processus actifs   : ${PROCESS_COUNT}"
    echo ""

    # --- Disques (2.1 & 2.2) ---
    echo -e "${BOLD}--- Utilisation Disques ---${NC}"
    printf "%-20s %-10s %-10s %-10s\n" "Montage" "Taille" "Utilisé" "Statut"
    
    # On boucle sur df, on ignore les tmpfs et udev pour la clarté
    df -hP | grep -vE '^Filesystem|tmpfs|cdrom|udev' | while read -r line; do
        MOUNT=$(echo "$line" | awk '{print $6}')
        SIZE=$(echo "$line" | awk '{print $2}')
        USE_PCT_STR=$(echo "$line" | awk '{print $5}') # ex: 45%
        USE_PCT_VAL=${USE_PCT_STR%\%} # ex: 45
        
        DISK_COLOR=$(get_color_code "$USE_PCT_VAL")
        printf "%-20s %-10s %-10s ${DISK_COLOR}%-10s${NC}\n" "$MOUNT" "$SIZE" "$USE_PCT_STR" "Check"
    done
    echo ""

    # --- Top Processus (2.4) ---
    echo -e "${BOLD}--- Top 5 CPU ---${NC}"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 | awk 'NR==1 {print $0} NR>1 {printf "%-8s %-8s %-40s %-6s %-6s\n", $1, $2, substr($3,1,40), $4, $5}'

    echo ""
    echo -e "${BOLD}--- Top 5 Mémoire ---${NC}"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6 | awk 'NR==1 {print $0} NR>1 {printf "%-8s %-8s %-40s %-6s %-6s\n", $1, $2, substr($3,1,40), $4, $5}'
    echo -e "${BLUE}==================================${NC}"
}

# --- Exécution ---

# On capture la sortie de la fonction dans une variable pour pouvoir la traiter
OUTPUT=$(collect_and_display)

# Affichage à l'écran (avec couleurs)
echo -e "$OUTPUT"

# Gestion du rapport (2.3)
if [ "$GENERATE_REPORT" = true ]; then
    # Vérification des droits root si on écrit dans /var/log
    if [ ! -w "$(dirname "$LOG_FILE")" ]; then
         echo "❌ Erreur : Impossible d'écrire dans /var/log. Relancez avec sudo." >&2
         exit 1
    fi
    
    # Nettoyage des codes couleurs pour le fichier texte
    # La regex sed retire les séquences d'échappement ANSI
    echo -e "$OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' > "$LOG_FILE"
    
    echo ""
    echo "✅ Rapport sauvegardé dans : $LOG_FILE"
fi