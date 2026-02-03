#!/bin/bash

# --- CONFIGURATION ---
LOG_FILE="/tmp/sync_operation.log"

# Codes couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- VÉRIFICATION DES ARGUMENTS ---

if [ "$#" -ne 2 ]; then
    echo -e "${RED}Erreur : Nombre d'arguments incorrect.${NC}"
    echo "Usage : $0 <source_directory> <destination_directory>"
    exit 1
fi

SOURCE_DIR="${1%/}" # On retire le slash final s'il existe pour la cohérence
DEST_DIR="${2%/}"

# Vérification existence source
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Erreur : Le répertoire source '$SOURCE_DIR' n'existe pas.${NC}"
    exit 1
fi

# Vérification existence destination (création si absent)
if [ ! -d "$DEST_DIR" ]; then
    echo -e "${YELLOW}Le répertoire destination n'existe pas. Création en cours...${NC}"
    mkdir -p "$DEST_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Erreur : Impossible de créer le répertoire destination (Permissions ?).${NC}"
        exit 1
    fi
fi

# --- MENU DU BONUS (SUPPRESSION) ---

DELETE_FLAG=""
MODE_TEXT="Synchronisation Standard (Ajout/Mise à jour uniquement)"

echo -e "${BLUE}--- Options de Synchronisation ---${NC}"
echo "1) Standard : Copier les nouveaux et modifiés (ne supprime rien)"
echo "2) Miroir   : Copier les nouveaux ET supprimer ce qui n'existe plus dans la source"
read -p "Votre choix [1/2] : " choice

if [ "$choice" == "2" ]; then
    DELETE_FLAG="--delete"
    MODE_TEXT="Synchronisation Miroir (Attention : Suppression des fichiers obsolètes)"
    echo -e "${RED}Attention : Les fichiers présents dans la destination mais absents de la source seront supprimés.${NC}"
    read -p "Confirmez-vous ? (o/N) : " confirm
    if [[ ! "$confirm" =~ ^[oO](ui)?$ ]]; then
        echo "Annulation."
        exit 0
    fi
fi

# --- EXÉCUTION ---

echo -e "\n${BLUE}--- Démarrage : $MODE_TEXT ---${NC}"
echo "Source : $SOURCE_DIR"
echo "Dest   : $DEST_DIR"
echo "---------------------------------------------------"

# Explication de la commande rsync :
# -a : archive (garde les permissions, dates, liens, etc.)
# -v : verbeux (liste les fichiers)
# -h : nombres lisibles (Ko, Mo)
# --stats : affiche les statistiques à la fin
# --ignore-errors : continue même si erreurs I/O (pour le rapport)
rsync -avh --stats --ignore-errors $DELETE_FLAG "$SOURCE_DIR/" "$DEST_DIR/" > "$LOG_FILE" 2>&1

RSYNC_EXIT_CODE=$?

# --- AFFICHAGE DE LA LISTE DES FICHIERS ---

# On affiche les lignes du log, mais on filtre les infos techniques de rsync pour ne montrer que les fichiers
# On exclut les lignes vides, et les blocs de stats de fin
echo -e "${YELLOW}Fichiers traités :${NC}"
grep -vE "^$|Number of files|Total file size|Literal data|Matched data|File list|sent [0-9]|total size is" "$LOG_FILE" | sed 's/^/  - /'

# Si grep ne trouve rien, c'est qu'aucun fichier n'a été copié
if [ ${PIPESTATUS[1]} -ne 0 ]; then
    echo "  (Aucun fichier transféré)"
fi

# --- ANALYSE DES STATISTIQUES ---

echo -e "\n${BLUE}--- Résumé Statistique ---${NC}"

# Extraction des données depuis le log rsync
# Note: rsync --stats fournit ces labels précis
COUNT_FILES=$(grep "Number of regular files transferred" "$LOG_FILE" | awk -F: '{print $2}' | tr -d ' ,')
TOTAL_SIZE=$(grep "Total transferred file size" "$LOG_FILE" | awk -F: '{print $2}')

# Si les variables sont vides (cas où rsync échoue tôt), on met 0
COUNT_FILES=${COUNT_FILES:-0}
TOTAL_SIZE=${TOTAL_SIZE:-0}

echo -e "Fichiers copiés/mis à jour : ${GREEN}$COUNT_FILES${NC}"
echo -e "Volume total transféré     : ${GREEN}$TOTAL_SIZE${NC}"

# --- GESTION DES ERREURS ---

echo "---------------------------------------------------"
if [ $RSYNC_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}Succès : Synchronisation terminée sans erreur.${NC}"
elif [ $RSYNC_EXIT_CODE -eq 23 ] || [ $RSYNC_EXIT_CODE -eq 13 ]; then
     echo -e "${YELLOW}Avertissement : Certains fichiers n'ont pas pu être copiés (Permissions ?).${NC}"
     echo "Vérifiez les logs."
elif [ $RSYNC_EXIT_CODE -eq 10 ] || [ $RSYNC_EXIT_CODE -eq 11 ]; then
    echo -e "${RED}Erreur Critique : Erreur d'entrée/sortie (Disque plein ou déconnecté ?).${NC}"
else
    echo -e "${RED}Erreur : rsync s'est terminé avec le code $RSYNC_EXIT_CODE.${NC}"
fi

# Nettoyage
rm -f "$LOG_FILE"