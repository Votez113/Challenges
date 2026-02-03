#!/bin/bash

# --- CONFIGURATION ---
INPUT_FILE="${1:-paquets.txt}" # Prend le fichier en argument ou utilise paquets.txt par défaut
LOG_FILE="installation_$(date +%Y%m%d_%H%M%S).log"

# Codes couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Tableaux pour le rapport final
INSTALLED_OK=()
INSTALLED_FAIL=()
ALREADY_PRESENT=()
SKIPPED_USER=()

# --- VÉRIFICATIONS ---

# 1. Vérifier root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Erreur : Ce script doit être exécuté avec sudo.${NC}"
   exit 1
fi

# 2. Vérifier fichier d'entrée
if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${RED}Erreur : Le fichier '$INPUT_FILE' est introuvable.${NC}"
    echo "Usage : sudo $0 <nom_fichier_liste>"
    exit 1
fi

# 3. Mise à jour des dépôts (optionnel mais recommandé)
echo -e "${BLUE}--- Mise à jour des dépôts (apt update) ---${NC}"
apt-get update -qq

# --- FONCTIONS ---

# Fonction barre de progression
# Usage : progress_bar <actuel> <total> <nom_paquet>
draw_progress_bar() {
    local current=$1
    local total=$2
    local task=$3
    
    # Calcul pourcentage
    local percent=$(( 100 * current / total ))
    local completed=$(( percent / 2 )) # Pour une barre de 50 chars
    local remaining=$(( 50 - completed ))
    
    # Construction de la barre
    printf "\r["
    printf "%${completed}s" | tr ' ' '='
    printf ">"
    printf "%${remaining}s" | tr ' ' '.'
    printf "] %d%% - Traitement de : %-15s" "$percent" "$task"
}

# --- TRAITEMENT ---

# Lire le fichier dans un tableau (ignorer lignes vides et commentaires)
mapfile -t PACKAGES < <(grep -vE "^\s*#|^\s*$" "$INPUT_FILE")
TOTAL_PKG=${#PACKAGES[@]}
CURRENT_COUNT=0

echo -e "\n\n${BLUE}--- Démarrage de l'analyse ($TOTAL_PKG paquets) ---${NC}"
echo "Les logs détaillés sont dans : $LOG_FILE"

for pkg in "${PACKAGES[@]}"; do
    ((CURRENT_COUNT++))
    
    # Afficher la barre de progression (on nettoie la ligne précédente)
    draw_progress_bar "$CURRENT_COUNT" "$TOTAL_PKG" "$pkg"
    
    # 1. Vérifier si installé (dpkg -s renvoie 0 si trouvé)
    if dpkg -s "$pkg" &> /dev/null; then
        ALREADY_PRESENT+=("$pkg")
        # On loggue dans le fichier mais pas à l'écran pour ne pas casser la barre
        echo "[$pkg] Déjà installé." >> "$LOG_FILE"
    else
        # Effacer la barre temporairement pour poser la question
        printf "\r\033[K" 
        
        # 2. Demander confirmation
        echo -e "${YELLOW}Le paquet '$pkg' n'est pas installé.${NC}"
        read -p "Voulez-vous l'installer ? (o/N) : " reponse
        
        if [[ "$reponse" =~ ^[oO](ui)?$ ]]; then
            echo "Installation de $pkg en cours..." >> "$LOG_FILE"
            
            # 3. Tentative d'installation (mode silencieux, erreurs redirigées vers log)
            # DEBIAN_FRONTEND=noninteractive évite les popups de configuration
            DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg" >> "$LOG_FILE" 2>&1
            
            if [ $? -eq 0 ]; then
                INSTALLED_OK+=("$pkg")
            else
                INSTALLED_FAIL+=("$pkg")
            fi
        else
            SKIPPED_USER+=("$pkg")
            echo "[$pkg] Ignoré par l'utilisateur." >> "$LOG_FILE"
        fi
    fi
done

# Fin de la barre de progression
draw_progress_bar "$TOTAL_PKG" "$TOTAL_PKG" "Terminé"
echo "" # Retour à la ligne

# --- RAPPORT FINAL ---

echo -e "\n${BLUE}==============================${NC}"
echo -e "${BLUE}       RÉSUMÉ FINAL       ${NC}"
echo -e "${BLUE}==============================${NC}"

# Succès
if [ ${#INSTALLED_OK[@]} -gt 0 ]; then
    echo -e "\n${GREEN}[SUCCESS] Installés (${#INSTALLED_OK[@]}) :${NC}"
    printf "  - %s\n" "${INSTALLED_OK[@]}"
fi

# Déjà présents
if [ ${#ALREADY_PRESENT[@]} -gt 0 ]; then
    echo -e "\n${BLUE}[INFO] Déjà présents (${#ALREADY_PRESENT[@]}) :${NC}"
    printf "  - %s\n" "${ALREADY_PRESENT[@]}"
fi

# Ignorés
if [ ${#SKIPPED_USER[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}[SKIP] Ignorés par l'utilisateur (${#SKIPPED_USER[@]}) :${NC}"
    printf "  - %s\n" "${SKIPPED_USER[@]}"
fi

# Erreurs
if [ ${#INSTALLED_FAIL[@]} -gt 0 ]; then
    echo -e "\n${RED}[ERROR] Échecs d'installation (${#INSTALLED_FAIL[@]}) :${NC}"
    printf "  - %s\n" "${INSTALLED_FAIL[@]}"
    echo -e "${RED}Consultez $LOG_FILE pour voir les détails des erreurs.${NC}"
fi

echo ""