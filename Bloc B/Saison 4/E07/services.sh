#!/bin/bash

# --- CONFIGURATION ---
# Liste des services à surveiller
# Vous pouvez remplacer "apache2" par "nginx" selon votre installation
SERVICES=("ssh" "cron" "apache2")

# Codes couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- VÉRIFICATION DES PERMISSIONS ---
# Le script vérifie s'il est lancé avec sudo/root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Erreur : Ce script doit être exécuté avec les privilèges root (sudo).${NC}"
   echo "Usage : sudo $0"
   exit 1
fi

# --- FONCTIONS ---

# Fonction pour afficher l'état des services
afficher_etat() {
    echo -e "\n${BLUE}--- État des Services Système ---${NC}"
    printf "%-15s %-20s %-20s\n" "SERVICE" "ÉTAT ACTUEL" "AU DÉMARRAGE"
    echo "--------------------------------------------------------"

    for service in "${SERVICES[@]}"; do
        # Vérifier si le service existe sur le système
        if systemctl list-unit-files | grep -q "^$service"; then
            
            # Vérifier l'état (Actif/Inactif)
            if systemctl is-active --quiet "$service"; then
                etat="${GREEN}Actif (Running)${NC}"
            else
                etat="${RED}Inactif (Stopped)${NC}"
            fi

            # Vérifier le démarrage (Enabled/Disabled)
            if systemctl is-enabled --quiet "$service"; then
                boot="Activé"
            else
                boot="Désactivé"
            fi
        else
            etat="${YELLOW}Non Installé${NC}"
            boot="N/A"
        fi

        # Affichage formaté (le %b permet d'interpréter les couleurs)
        printf "%-15s %-30b %-20s\n" "$service" "$etat" "$boot"
    done
    echo ""
}

# Fonction pour démarrer ou arrêter un service
action_service() {
    local action=$1 # "start" ou "stop"
    
    echo -e "Quel service voulez-vous $action ?"
    # Création d'un menu de sélection dynamique basé sur le tableau SERVICES
    select service in "${SERVICES[@]}" "Retour"; do
        case $service in
            "Retour")
                return
                ;;
            *)
                if [[ -n "$service" ]]; then
                    echo -e "${YELLOW}Tentative de $action pour $service...${NC}"
                    
                    # Exécution de la commande
                    systemctl "$action" "$service"
                    
                    # Vérification du code de retour (0 = succès)
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}Succès : Le service $service a été ${action}é.${NC}"
                    else
                        echo -e "${RED}Erreur : Impossible de $action le service $service.${NC}"
                    fi
                    
                    # Pause pour laisser l'utilisateur lire
                    read -p "Appuyez sur Entrée pour continuer..."
                    return
                else
                    echo "Option invalide."
                fi
                ;;
        esac
    done
}

# --- BOUCLE PRINCIPALE (MENU) ---
while true; do
    clear
    afficher_etat
    
    echo -e "${BLUE}--- Menu Principal ---${NC}"
    echo "1) Démarrer un service"
    echo "2) Arrêter un service"
    echo "3) Actualiser l'état"
    echo "4) Quitter"
    
    read -p "Votre choix [1-4] : " choix

    case $choix in
        1)
            action_service "start"
            ;;
        2)
            action_service "stop"
            ;;
        3)
            # Juste une actualisation de la boucle
            continue 
            ;;
        4)
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo -e "${RED}Choix invalide.${NC}"
            sleep 1
            ;;
    esac
done