#!/bin/bash

# ==============================================================================
# Script de nettoyage système sécurisé (Logs, Tmp, Trash, Apt)
# Usage: ./cleanup.sh [-f] [-d jours]
# Par défaut : Mode Simulation (ne supprime rien)
# ==============================================================================

# --- Configuration ---
LOG_FILE="/var/log/cleanup.log"
TMP_DIR="/tmp"
LOG_DIR="/var/log"
TRASH_PATTERN="/home/*/.local/share/Trash/*" # Corbeilles utilisateurs
APT_CACHE="/var/cache/apt/archives"

# Valeurs par défaut
DAYS_TMP=7
DAYS_LOGS=30
DRY_RUN=true
FORCE_EXEC=false

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Fonctions Utilitaires ---

log_message() {
    local TYPE=$1
    local MSG=$2
    local TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    # Écriture dans le fichier log
    echo "[$TIMESTAMP] [$TYPE] $MSG" >> "$LOG_FILE"
    
    # Affichage écran
    case $TYPE in
        "INFO") echo -e "${BLUE}ℹ️  $MSG${NC}" ;;
        "WARN") echo -e "${YELLOW}⚠️  $MSG${NC}" ;;
        "DEL")  echo -e "${RED}🗑️  $MSG${NC}" ;;
        "OK")   echo -e "${GREEN}✅ $MSG${NC}" ;;
    esac
}

get_size() {
    # Retourne la taille en octets d'un dossier/fichier ou liste de fichiers
    # $1: Commande find ou chemin
    local SIZE=$(du -sc $1 2>/dev/null | tail -1 | awk '{print $1}')
    # Si vide, retourne 0
    echo "${SIZE:-0}"
}

format_size() {
    # Convertit les Ko (sortie de du) en Mo
    awk "BEGIN {printf \"%.2f Mo\", $1/1024}"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}❌ Ce script doit être exécuté en tant que root.${NC}"
        exit 1
    fi
}

# --- Traitement des Arguments (4.2 & 4.3) ---

while getopts "fd:" opt; do
  case $opt in
    f) DRY_RUN=false ;;
    d) DAYS_TMP=$OPTARG; DAYS_LOGS=$OPTARG ;; # On applique l'âge aux deux pour simplifier, ou on pourrait séparer
    *) echo "Usage: $0 [-f (force)] [-d jours (âge fichiers)]"; exit 1 ;;
  esac
done

check_root

# --- Démarrage ---

clear
echo -e "${BLUE}=== OUTIL DE NETTOYAGE SYSTÈME ===${NC}"
echo "Mode actuel : $( [ "$DRY_RUN" = true ] && echo "${YELLOW}SIMULATION (Dry-Run)${NC}" || echo "${RED}ACTIF (Suppression réelle)${NC}" )"
echo "Critère d'âge : Fichiers plus vieux que $DAYS_TMP jours"
echo "----------------------------------------"

# 4.1 Espace disque avant
DISK_BEFORE=$(df / | awk 'NR==2 {print $4}') # En Ko
echo "Espace libre actuel : $(format_size $DISK_BEFORE)"
echo ""

# Confirmation de sécurité (4.2)
if [ "$DRY_RUN" = false ]; then
    echo -e "${RED}ATTENTION : Vous êtes sur le point de supprimer des fichiers définitivement.${NC}"
    read -p "Êtes-vous sûr de vouloir continuer ? (o/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        log_message "INFO" "Annulation par l'utilisateur."
        exit 0
    fi
fi

# Initialisation du log
if [ ! -f "$LOG_FILE" ]; then touch "$LOG_FILE"; fi
log_message "INFO" "Démarrage du script de nettoyage (DryRun=$DRY_RUN)"

TOTAL_CLEANED_KB=0

# --- 1. Nettoyage /tmp (4.1) ---
echo -e "\n${BLUE}--- Analyse de $TMP_DIR (> $DAYS_TMP jours) ---${NC}"

# On cherche les fichiers temporaires
FIND_TMP="find $TMP_DIR -type f -atime +$DAYS_TMP"
SIZE_TMP_KB=$( $FIND_TMP -exec du -k {} + 2>/dev/null | awk '{sum+=$1} END {print sum}' )
SIZE_TMP_KB=${SIZE_TMP_KB:-0} # 0 si vide

if [ "$SIZE_TMP_KB" -gt 0 ]; then
    if [ "$DRY_RUN" = true ]; then
        log_message "INFO" "Simulé : Suppression fichiers temp ($DAYS_TMP j+). Gain : $(format_size $SIZE_TMP_KB)"
        $FIND_TMP -print | head -n 5 | sed 's/^/  - /' # Affiche 5 exemples
    else
        $FIND_TMP -delete
        log_message "DEL" "Supprimé : Fichiers temp. Gain : $(format_size $SIZE_TMP_KB)"
        TOTAL_CLEANED_KB=$((TOTAL_CLEANED_KB + SIZE_TMP_KB))
    fi
else
    log_message "OK" "Rien à nettoyer dans $TMP_DIR"
fi

# --- 2. Nettoyage Logs compressés (4.1) ---
echo -e "\n${BLUE}--- Analyse des logs compressés (> $DAYS_LOGS jours) ---${NC}"

FIND_LOGS="find $LOG_DIR -name '*.gz' -mtime +$DAYS_LOGS"
SIZE_LOGS_KB=$( $FIND_LOGS -exec du -k {} + 2>/dev/null | awk '{sum+=$1} END {print sum}' )
SIZE_LOGS_KB=${SIZE_LOGS_KB:-0}

if [ "$SIZE_LOGS_KB" -gt 0 ]; then
    if [ "$DRY_RUN" = true ]; then
        log_message "INFO" "Simulé : Suppression vieux logs. Gain : $(format_size $SIZE_LOGS_KB)"
        $FIND_LOGS -print | head -n 5 | sed 's/^/  - /'
    else
        $FIND_LOGS -delete
        log_message "DEL" "Supprimé : Vieux logs. Gain : $(format_size $SIZE_LOGS_KB)"
        TOTAL_CLEANED_KB=$((TOTAL_CLEANED_KB + SIZE_LOGS_KB))
    fi
else
    log_message "OK" "Aucun vieux log (.gz) trouvé."
fi

# --- 3. Cache APT (4.1) ---
echo -e "\n${BLUE}--- Analyse du cache APT ---${NC}"
# APT clean ne retourne pas la taille, il faut mesurer le dossier archive avant
SIZE_APT_KB=$(du -sk "$APT_CACHE" 2>/dev/null | cut -f1)
SIZE_APT_KB=${SIZE_APT_KB:-0}

# On considère qu'on nettoie si > 40Ko (taille dossier vide approx)
if [ "$SIZE_APT_KB" -gt 100 ]; then
    if [ "$DRY_RUN" = true ]; then
         log_message "INFO" "Simulé : 'apt-get clean'. Gain estimé : $(format_size $SIZE_APT_KB)"
    else
         apt-get clean
         log_message "DEL" "Exécuté : 'apt-get clean'. Gain : $(format_size $SIZE_APT_KB)"
         TOTAL_CLEANED_KB=$((TOTAL_CLEANED_KB + SIZE_APT_KB))
    fi
else
    log_message "OK" "Cache APT déjà propre."
fi

# --- 4. Corbeilles Utilisateurs (4.1) ---
echo -e "\n${BLUE}--- Analyse des corbeilles utilisateurs ---${NC}"
# C'est délicat, on va mesurer sans supprimer les dossiers parents Trash, juste le contenu
SIZE_TRASH_KB=$(du -skc /home/*/.local/share/Trash/* 2>/dev/null | tail -1 | cut -f1)
SIZE_TRASH_KB=${SIZE_TRASH_KB:-0}

if [ "$SIZE_TRASH_KB" -gt 0 ]; then
    if [ "$DRY_RUN" = true ]; then
        log_message "INFO" "Simulé : Vidage corbeilles. Gain : $(format_size $SIZE_TRASH_KB)"
    else
        # On supprime le contenu des dossiers files et info dans Trash
        rm -rf /home/*/.local/share/Trash/files/* 2>/dev/null
        rm -rf /home/*/.local/share/Trash/info/* 2>/dev/null
        log_message "DEL" "Supprimé : Contenu des corbeilles. Gain : $(format_size $SIZE_TRASH_KB)"
        TOTAL_CLEANED_KB=$((TOTAL_CLEANED_KB + SIZE_TRASH_KB))
    fi
else
    log_message "OK" "Corbeilles utilisateurs vides."
fi

# --- Résumé (4.3) ---
echo -e "\n----------------------------------------"
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}TOTAL ESTIMÉ RÉCUPÉRABLE : $(format_size $TOTAL_CLEANED_KB)${NC}"
    echo "Pour exécuter le nettoyage : sudo $0 -f"
else
    DISK_AFTER=$(df / | awk 'NR==2 {print $4}')
    GAIN_REAL=$((DISK_AFTER - DISK_BEFORE))
    echo -e "${GREEN}TOTAL NETTOYÉ : $(format_size $TOTAL_CLEANED_KB)${NC}"
    echo "Espace libre final : $(format_size $DISK_AFTER)"
    
    # Écriture finale log
    log_message "INFO" "Fin du nettoyage. Total libéré : $(format_size $TOTAL_CLEANED_KB)"
fi

exit 0