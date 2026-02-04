#!/bin/bash

# ==============================================================================
# Suite d'Outils d'Administration Système (Master Script)
# Version: 1.0
# Auteur: SysAdmin
# ==============================================================================

# --- Configuration ---
# Récupère le dossier où se trouve ce script pour trouver les autres
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
LOG_FILE="/var/log/sysadmin-tools.log"
VERSION="1.0.0"

# Noms des scripts dépendants
SCRIPT_BACKUP="backup.sh"
SCRIPT_MONITOR="monitor.sh"
SCRIPT_USERS="create-users.sh"
SCRIPT_CLEAN="cleanup.sh"
SCRIPT_CHECK="check-services.sh"

# Couleurs
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Fonctions Utilitaires ---

# Journalisation centralisée (6.3)
log_usage() {
    local TOOL=$1
    local USER_NAME=${SUDO_USER:-$USER}
    local DATE=$(date "+%Y-%m-%d %H:%M:%S")
    # Crée le fichier log si nécessaire
    if [ ! -f "$LOG_FILE" ]; then touch "$LOG_FILE"; chmod 600 "$LOG_FILE"; fi
    echo "[$DATE] User: $USER_NAME | Tool: $TOOL" >> "$LOG_FILE"
}

# Pause avant de revenir au menu
pause() {
    echo ""
    read -p "Appuyez sur [Entrée] pour revenir au menu..."
}

# Vérification des dépendances (6.3)
check_scripts() {
    local MISSING=false
    for script in "$SCRIPT_BACKUP" "$SCRIPT_MONITOR" "$SCRIPT_USERS" "$SCRIPT_CLEAN" "$SCRIPT_CHECK"; do
        if [ ! -f "$SCRIPT_DIR/$script" ]; then
            echo -e "${RED}❌ Erreur critique : Le script '$script' est introuvable dans $SCRIPT_DIR${NC}"
            MISSING=true
        elif [ ! -x "$SCRIPT_DIR/$script" ]; then
            echo -e "${YELLOW}⚠️  Avertissement : '$script' n'est pas exécutable. Correction...${NC}"
            chmod +x "$SCRIPT_DIR/$script"
        fi
    done

    if [ "$MISSING" = true ]; then
        echo "Veuillez placer tous les scripts dans le même dossier."
        exit 1
    fi
}

# Affichage de l'en-tête (6.3)
show_header() {
    clear
    echo -e "${CYAN}=================================${NC}"
    echo -e "${CYAN}    OUTILS D'ADMINISTRATION      ${NC}"
    echo -e "${CYAN}=================================${NC}"
    echo -e "Version : $VERSION"
    echo -e "Auteur  : SysAdmin"
    echo -e "Dossier : $SCRIPT_DIR"
    echo -e "${CYAN}=================================${NC}"
}

# Documentation (6.3 - Option Aide)
show_help() {
    echo -e "${GREEN}=== Documentation ===${NC}"
    echo "1. Sauvegarde : Archive un dossier en .tar.gz avec rotation (garde les 7 derniers)."
    echo "2. Monitoring : Affiche CPU, RAM, Disque et processus (Option rapport disponible)."
    echo "3. Utilisateurs : Crée ou supprime des comptes en masse depuis un fichier CSV."
    echo "4. Nettoyage : Vide /tmp, cache APT, logs anciens et corbeilles (Mode sécurisé par défaut)."
    echo "5. Services : Vérifie les services critiques (ssh, apache...) et redémarre si nécessaire."
    pause
}

# --- Fonctions Wrappers (Lancement des scripts) ---

wrapper_backup() {
    echo -e "\n${YELLOW}--- Sauvegarde de répertoire ---${NC}"
    # read -e permet l'autocomplétion des chemins avec tabulation
    read -e -p "Entrez le chemin du dossier à sauvegarder : " TARGET_DIR
    
    if [ -z "$TARGET_DIR" ]; then
        echo -e "${RED}Annulé : Aucun dossier spécifié.${NC}"
        return
    fi

    log_usage "Backup ($TARGET_DIR)"
    "$SCRIPT_DIR/$SCRIPT_BACKUP" "$TARGET_DIR"
    pause
}

wrapper_monitor() {
    echo -e "\n${YELLOW}--- Monitoring Système ---${NC}"
    read -p "Voulez-vous générer un rapport dans /var/log ? (o/n) : " REP
    
    ARGS=""
    if [[ "$REP" =~ ^[Oo]$ ]]; then ARGS="-r"; fi
    
    log_usage "Monitoring $ARGS"
    "$SCRIPT_DIR/$SCRIPT_MONITOR" $ARGS
    pause
}

wrapper_users() {
    echo -e "\n${YELLOW}--- Gestion Utilisateurs ---${NC}"
    echo "1. Créer des utilisateurs"
    echo "2. Supprimer des utilisateurs"
    read -p "Votre choix (1/2) : " ACTION
    
    if [ "$ACTION" != "1" ] && [ "$ACTION" != "2" ]; then
        echo "Choix invalide."
        return
    fi

    read -e -p "Chemin du fichier CSV : " CSV_FILE
    if [ ! -f "$CSV_FILE" ]; then
        echo -e "${RED}Fichier introuvable.${NC}"
        return
    fi

    ARGS="$CSV_FILE"
    MODE="Creation"
    if [ "$ACTION" == "2" ]; then 
        ARGS="-d $CSV_FILE"
        MODE="Suppression"
    fi

    log_usage "Users ($MODE)"
    "$SCRIPT_DIR/$SCRIPT_USERS" $ARGS
    pause
}

wrapper_cleanup() {
    echo -e "\n${YELLOW}--- Nettoyage Système ---${NC}"
    echo "Par défaut, le nettoyage est lancé en mode SIMULATION."
    read -p "Voulez-vous lancer le nettoyage RÉEL ? (o/n) : " CONFIRM
    
    ARGS=""
    if [[ "$CONFIRM" =~ ^[Oo]$ ]]; then 
        ARGS="-f"
        log_usage "Cleanup (FORCE)"
    else
        log_usage "Cleanup (DryRun)"
    fi
    
    "$SCRIPT_DIR/$SCRIPT_CLEAN" $ARGS
    pause
}

wrapper_services() {
    echo -e "\n${YELLOW}--- Vérification Services ---${NC}"
    echo "1. Vérification simple"
    echo "2. Monitoring en direct (Ctrl+C pour quitter)"
    echo "3. Vérification avec tentative de redémarrage"
    read -p "Choix : " S_CHOICE

    case $S_CHOICE in
        1) ARGS=""; log_usage "Services (Check)" ;;
        2) ARGS="-w"; log_usage "Services (Watch)" ;;
        3) ARGS="-r"; log_usage "Services (Restart)" ;;
        *) echo "Choix invalide."; return ;;
    esac

    "$SCRIPT_DIR/$SCRIPT_CHECK" $ARGS
    
    # Pas de pause si on revient du mode monitoring (Watch)
    if [ "$S_CHOICE" != "2" ]; then pause; fi
}

# --- Boucle Principale ---

# Vérification root (la plupart des sous-scripts en ont besoin)
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Veuillez lancer ce menu avec sudo.${NC}"
    exit 1
fi

check_scripts

while true; do
    show_header
    echo "1. Sauvegarde de répertoire"
    echo "2. Monitoring système"
    echo "3. Gestion des utilisateurs (CSV)"
    echo "4. Nettoyage système"
    echo "5. Vérifier les services"
    echo "6. Aide / Documentation"
    echo "7. Quitter"
    echo -e "${CYAN}=================================${NC}"
    read -p "Votre choix : " CHOIX

    case $CHOIX in
        1) wrapper_backup ;;
        2) wrapper_monitor ;;
        3) wrapper_users ;;
        4) wrapper_cleanup ;;
        5) wrapper_services ;;
        6) show_help ;;
        7) 
            echo "Au revoir !"
            log_usage "Exit"
            exit 0 
            ;;
        *) 
            echo -e "${RED}Choix invalide.${NC}"
            sleep 1
            ;;
    esac
done