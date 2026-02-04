#!/bin/bash

# ==============================================================================
# Script de gestion d'utilisateurs en masse depuis CSV
# Usage: ./create-users.sh [-d] <fichier.csv>
# -d : Active le mode suppression
# ==============================================================================

# --- Configuration ---
LOG_FILE="/var/log/user-creation.log"
OUTPUT_FILE="users_created.txt"
MODE="CREATE" # Par défaut

# --- Fonctions ---

log_message() {
    local TYPE=$1
    local MESSAGE=$2
    local TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] [$TYPE] $MESSAGE" >> "$LOG_FILE"
    
    # Retour visuel coloré
    case $TYPE in
        "SUCCESS") echo -e "\033[0;32m✅ $MESSAGE\033[0m" ;;
        "ERROR")   echo -e "\033[0;31m❌ $MESSAGE\033[0m" >&2 ;;
        "INFO")    echo -e "\033[0;34mℹ️  $MESSAGE\033[0m" ;;
        "WARN")    echo -e "\033[1;33m⚠️  $MESSAGE\033[0m" ;;
    esac
}

generate_password() {
    # Génère un mdp de 12 caractères alphanumériques
    openssl rand -base64 12
}

format_username() {
    local PRE=$1
    local NOM=$2
    # Première lettre prénom + nom, le tout en minuscule
    # On nettoie aussi les accents et espaces potentiels
    local USR="${PRE:0:1}${NOM}"
    echo "$USR" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g'
}

# --- Vérifications initiales ---

if [ "$EUID" -ne 0 ]; then
    echo "❌ Ce script doit être exécuté avec sudo."
    exit 1
fi

# Gestion des options (Mode suppression)
while getopts "d" opt; do
    case $opt in
        d) MODE="DELETE" ;;
        *) echo "Usage: $0 [-d] <fichier.csv>"; exit 1 ;;
    esac
done
shift $((OPTIND-1))

INPUT_CSV=$1

if [ -z "$INPUT_CSV" ] || [ ! -f "$INPUT_CSV" ]; then
    echo "❌ Erreur : Fichier CSV manquant ou invalide."
    echo "Usage: $0 [-d] <fichier.csv>"
    exit 1
fi

# Initialisation du fichier de sortie si en mode création
if [ "$MODE" == "CREATE" ]; then
    echo "--- Rapport de création du $(date) ---" > "$OUTPUT_FILE"
    log_message "INFO" "Démarrage du traitement du fichier $INPUT_CSV (Mode: $MODE)"
else
    log_message "INFO" "Démarrage du traitement du fichier $INPUT_CSV (Mode: $MODE)"
fi

# --- Traitement du CSV ---

# On lit le fichier ligne par ligne
# IFS=, définit le séparateur
# tr -d '\r' supprime les retours chariot Windows si présents
# tail -n +2 saute la ligne d'en-tête
tail -n +2 "$INPUT_CSV" | tr -d '\r' | while IFS=, read -r PRENOM NOM DEPARTEMENT FONCTION; do
    
    # Ignorer les lignes vides
    if [ -z "$PRENOM" ]; then continue; fi

    USERNAME=$(format_username "$PRENOM" "$NOM")
    GROUPname=$(echo "$DEPARTEMENT" | tr '[:upper:]' '[:lower:]') # Nom de groupe normalisé

    # === MODE SUPPRESSION ===
    if [ "$MODE" == "DELETE" ]; then
        if id "$USERNAME" &>/dev/null; then
            read -p "❓ Voulez-vous vraiment supprimer l'utilisateur $USERNAME ? (o/n) " -n 1 -r
            echo # saut de ligne
            if [[ $REPLY =~ ^[Oo]$ ]]; then
                userdel -r "$USERNAME" 2>/dev/null
                if [ $? -eq 0 ]; then
                    log_message "SUCCESS" "Utilisateur $USERNAME supprimé."
                else
                    log_message "ERROR" "Erreur lors de la suppression de $USERNAME."
                fi
            else
                log_message "INFO" "Suppression annulée pour $USERNAME."
            fi
        else
            log_message "WARN" "Utilisateur $USERNAME introuvable, suppression impossible."
        fi

    # === MODE CRÉATION ===
    else
        # 1. Gestion du Groupe (Département)
        if ! getent group "$GROUPname" > /dev/null; then
            groupadd "$GROUPname"
            log_message "INFO" "Groupe '$GROUPname' créé."
        fi

        # 2. Vérification utilisateur
        if id "$USERNAME" &>/dev/null; then
            log_message "WARN" "L'utilisateur $USERNAME existe déjà. Ignoré."
            continue
        fi

        # 3. Création utilisateur
        # -m : home directory, -g : groupe principal, -c : commentaire, -s : shell
        useradd -m -g "$GROUPname" -c "$PRENOM $NOM - $FONCTION" -s /bin/bash "$USERNAME"

        if [ $? -eq 0 ]; then
            # 4. Mot de passe
            PASSWORD=$(generate_password)
            echo "$USERNAME:$PASSWORD" | chpasswd
            
            # 5. Sortie et Logs
            log_message "SUCCESS" "Utilisateur $USERNAME créé (Groupe: $GROUPname)"
            echo "Login: $USERNAME | Pass: $PASSWORD | Dept: $DEPARTEMENT" >> "$OUTPUT_FILE"
            echo "   👉 Créé: $USERNAME ($PASSWORD)"
        else
            log_message "ERROR" "Échec de la création pour $USERNAME"
        fi
    fi

done

echo "------------------------------------------------"
if [ "$MODE" == "CREATE" ]; then
    echo "Terminé. Les mots de passe sont sauvegardés dans $OUTPUT_FILE"
else
    echo "Terminé."
fi