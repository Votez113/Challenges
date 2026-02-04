#!/bin/bash

# ==============================================================================
# Script de sauvegarde automatisé avec rotation et journalisation
# Usage: ./backup.sh <dossier_a_sauvegarder>
# ==============================================================================

# --- Configuration ---
BACKUP_DIR="/backup"
LOG_FILE="/var/log/backup.log"
RETENTION_COUNT=7
DATE_FORMAT=$(date +%Y%m%d_%H%M%S)

# Fonction de journalisation (1.2)
log_message() {
    local TYPE=$1
    local MESSAGE=$2
    local TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] [$TYPE] $MESSAGE" >> "$LOG_FILE"
    # On affiche aussi les erreurs dans la console pour l'utilisateur
    if [ "$TYPE" == "ERROR" ]; then
        echo "❌ $MESSAGE" >&2
    elif [ "$TYPE" == "INFO" ]; then
        echo "ℹ️  $MESSAGE"
    else
        echo "✅ $MESSAGE"
    fi
}

# --- 1.2 Vérification des privilèges (nécessaire pour /backup et /var/log) ---
if [ "$EUID" -ne 0 ]; then 
  echo "❌ Ce script doit être exécuté en tant que root (sudo)."
  exit 1
fi

# --- 1.1 & 1.2 Validation de l'argument et du dossier source ---
if [ -z "$1" ]; then
    echo "Usage: $0 <dossier_source>"
    exit 1
fi

SOURCE_DIR="${1%/}" # Retire le slash final si présent pour éviter les erreurs
DIR_NAME=$(basename "$SOURCE_DIR") # Nom du dossier pour l'info

if [ ! -d "$SOURCE_DIR" ]; then
    log_message "ERROR" "Le répertoire source '$SOURCE_DIR' n'existe pas."
    exit 1
fi

# Création du dossier de backup s'il n'existe pas (1.1)
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    log_message "INFO" "Dossier $BACKUP_DIR créé."
fi

# --- 1.2 Vérification de l'espace disque ---
# Estimation de la taille source (en Ko)
SOURCE_SIZE=$(du -sk "$SOURCE_DIR" | cut -f1)
# Espace disponible dans le dossier backup (en Ko)
AVAILABLE_SPACE=$(df -k "$BACKUP_DIR" | awk 'NR==2 {print $4}')

# On ajoute une marge de sécurité (ex: on veut que l'espace libre soit > taille source)
if [ "$SOURCE_SIZE" -gt "$AVAILABLE_SPACE" ]; then
    log_message "ERROR" "Espace disque insuffisant. Requis: ${SOURCE_SIZE}Ko, Dispo: ${AVAILABLE_SPACE}Ko"
    exit 1
fi

# --- 1.1 Création de l'archive ---
ARCHIVE_NAME="backup_${DATE_FORMAT}.tar.gz"
DEST_FILE="${BACKUP_DIR}/${ARCHIVE_NAME}"

log_message "INFO" "Début de la sauvegarde de $SOURCE_DIR vers $DEST_FILE"

tar -czf "$DEST_FILE" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" 2>/dev/null

if [ $? -eq 0 ]; then
    # Récupération de la taille lisible par l'humain
    ARCHIVE_SIZE=$(du -h "$DEST_FILE" | cut -f1)
    log_message "SUCCESS" "Sauvegarde réussie. Archive: $ARCHIVE_NAME (Taille: $ARCHIVE_SIZE)"
else
    log_message "ERROR" "Échec de la commande tar lors de la création de l'archive."
    exit 1
fi

# --- 1.3 Rotation des sauvegardes ---
# Liste les archives triées par date (plus récent en premier), garde les N premiers, sélectionne le reste
BACKUPS_TO_DELETE=$(ls -tp "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | grep -v '/$' | tail -n +$(($RETENTION_COUNT + 1)))

COUNT_DELETED=0
if [ -n "$BACKUPS_TO_DELETE" ]; then
    log_message "INFO" "Rotation des logs : suppression des anciennes archives..."
    
    # Boucle pour supprimer les fichiers (gère les espaces dans les noms si besoin)
    while IFS= read -r FILE; do
        rm "$FILE"
        if [ $? -eq 0 ]; then
            ((COUNT_DELETED++))
        fi
    done <<< "$BACKUPS_TO_DELETE"
    
    log_message "INFO" "Rotation terminée : $COUNT_DELETED sauvegarde(s) supprimée(s)."
else
    log_message "INFO" "Rotation non nécessaire (moins de $RETENTION_COUNT sauvegardes)."
fi

exit 0