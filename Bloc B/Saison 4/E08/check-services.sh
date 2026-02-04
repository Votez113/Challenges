#!/bin/bash

# ==============================================================================
# Script de surveillance de services (Status, Restart, JSON, Monitoring)
# Usage: ./check-services.sh [-r] [-w]
# -r : Tente de redémarrer les services en échec
# -w : Mode Watch (boucle infinie toutes les 30s)
# ==============================================================================

# --- Configuration ---
CONFIG_FILE="services.conf"
JSON_OUTPUT="services_report.json"
REFRESH_RATE=30

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Options par défaut
AUTO_RESTART=false
WATCH_MODE=false

# --- Gestion des arguments (5.3 & 5.4) ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -r|--restart) AUTO_RESTART=true ;;
        -w|--watch)   WATCH_MODE=true ;;
        *) echo "Usage: $0 [-r|--restart] [-w|--watch]"; exit 1 ;;
    esac
    shift
done

# --- Fonctions ---

check_root_for_restart() {
    if [ "$AUTO_RESTART" = true ] && [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}⚠️  Attention : Le redémarrage automatique (-r) nécessite sudo.${NC}"
        exit 1
    fi
}

generate_report() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}❌ Erreur : Fichier $CONFIG_FILE introuvable.${NC}"
        exit 1
    fi

    # Variables pour le rapport
    local COUNT_ACTIVE=0
    local COUNT_INACTIVE=0
    local JSON_CONTENT=""
    local FIRST_JSON=true

    echo -e "${BLUE}=== ÉTAT DES SERVICES CRITIQUES ($(date '+%H:%M:%S')) ===${NC}"
    printf "%-20s %-15s %-15s %-20s\n" "SERVICE" "ÉTAT" "BOOT (Enabled)" "ACTION"
    echo "-------------------------------------------------------------------------"

    # Lecture du fichier de configuration ligne par ligne
    # "|| [ -n ... ]" permet de lire la dernière ligne même sans saut de ligne final
    while IFS= read -r SERVICE || [ -n "$SERVICE" ]; do
        
        # Ignorer les lignes vides ou les commentaires
        [[ -z "$SERVICE" || "$SERVICE" =~ ^# ]] && continue

        # 1. Vérification de l'état (Active)
        # systemctl is-active retourne "active" ou "inactive" (ou "unknown")
        STATUS=$(systemctl is-active "$SERVICE")
        
        # 2. Vérification du démarrage (Enabled - 5.3)
        ENABLED=$(systemctl is-enabled "$SERVICE" 2>/dev/null || echo "unknown")

        MSG_ACTION=""
        
        if [ "$STATUS" == "active" ]; then
            COLOR=$GREEN
            ((COUNT_ACTIVE++))
        else
            COLOR=$RED
            ((COUNT_INACTIVE++))
            
            # Alerte simple (5.3)
            echo "🚨 ALERTE : Le service $SERVICE est DOWN !" >&2

            # Redémarrage automatique (5.3)
            if [ "$AUTO_RESTART" = true ]; then
                echo -n " Tentative de redémarrage... "
                systemctl start "$SERVICE" 2>/dev/null
                
                # Vérification après redémarrage
                if systemctl is-active --quiet "$SERVICE"; then
                    MSG_ACTION="${GREEN}Redémarré avec succès${NC}"
                    STATUS="restarted"
                    # On corrige le compteur car il est redevenu actif
                    ((COUNT_INACTIVE--))
                    ((COUNT_ACTIVE++))
                    COLOR=$GREEN
                else
                    MSG_ACTION="${RED}Échec redémarrage${NC}"
                fi
            else
                MSG_ACTION="${YELLOW}Aucune action${NC}"
            fi
        fi

        # Affichage formaté
        printf "%-20s ${COLOR}%-15s${NC} %-15s %b\n" "$SERVICE" "$STATUS" "$ENABLED" "$MSG_ACTION"

        # Construction du JSON (5.3)
        # On ajoute une virgule sauf pour le premier élément
        if [ "$FIRST_JSON" = true ]; then
            FIRST_JSON=false
        else
            JSON_CONTENT="${JSON_CONTENT},"
        fi
        JSON_CONTENT="${JSON_CONTENT}{\"service\":\"$SERVICE\",\"status\":\"$STATUS\",\"enabled\":\"$ENABLED\"}"

    done < "$CONFIG_FILE"

    echo "-------------------------------------------------------------------------"
    echo -e "Résumé : ${GREEN}$COUNT_ACTIVE Actifs${NC} | ${RED}$COUNT_INACTIVE Inactifs${NC}"

    # Sauvegarde JSON
    echo "[$JSON_CONTENT]" > "$JSON_OUTPUT"
    # echo "Rapport JSON exporté dans $JSON_OUTPUT"
}

# --- Exécution ---

check_root_for_restart

# Gestion du mode Monitoring (5.4)
if [ "$WATCH_MODE" = true ]; then
    # Trap pour gérer l'arrêt propre avec Ctrl+C
    trap "echo -e '\n\nArrêt du monitoring.'; exit 0" SIGINT
    
    while true; do
        clear # Efface l'écran à chaque itération
        generate_report
        echo ""
        echo -e "${BLUE}Mode Monitoring activé. Ctrl+C pour arrêter.${NC}"
        echo "Prochaine vérification dans ${REFRESH_RATE}s..."
        sleep $REFRESH_RATE
    done
else
    # Exécution unique
    generate_report
    echo "Rapport JSON exporté dans $JSON_OUTPUT"
fi