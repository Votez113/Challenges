#!/bin/bash

# --- CONFIGURATION ---
OUTPUT_FILE="rapport_systeme_$(date +%Y%m%d_%H%M%S).html"
TITLE="Rapport d'État du Système"

# --- RÉCUPÉRATION DES DONNÉES ---

# 1. Infos Système
HOSTNAME=$(hostname)
if [ -f /etc/os-release ]; then
    OS_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
else
    OS_NAME="Inconnu"
fi
KERNEL=$(uname -r)
UPTIME=$(uptime -p)
DATE=$(date "+%d/%m/%Y à %H:%M:%S")

# 2. CPU & Mémoire
# Récupération charge CPU (Load Average 1min)
CPU_LOAD=$(cat /proc/loadavg | awk '{print $1}')
# Récupération RAM (Total / Utilisée) - nécessite 'free'
MEM_TOTAL=$(free -h | grep Mem | awk '{print $2}')
MEM_USED=$(free -h | grep Mem | awk '{print $3}')
MEM_FREE=$(free -h | grep Mem | awk '{print $4}')

# --- GÉNÉRATION DU HTML ---

# Création de l'en-tête et du style CSS
cat <<EOF > "$OUTPUT_FILE"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>$TITLE</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f4f9; color: #333; margin: 0; padding: 20px; }
        .container { max-width: 1000px; margin: 0 auto; background: white; padding: 20px; box-shadow: 0 0 10px rgba(0,0,0,0.1); border-radius: 8px; }
        h1 { text-align: center; color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        h2 { color: #2980b9; margin-top: 30px; border-left: 5px solid #2980b9; padding-left: 10px; }
        .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 20px; }
        .card { background: #ecf0f1; padding: 15px; border-radius: 5px; text-align: center; }
        .card strong { display: block; font-size: 1.2em; color: #7f8c8d; }
        .card span { font-size: 1.5em; font-weight: bold; color: #2c3e50; }
        
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #3498db; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        
        .status-box { background: #333; color: #0f0; padding: 15px; border-radius: 5px; font-family: monospace; overflow-x: auto; max-height: 300px; }
        .footer { text-align: center; margin-top: 40px; font-size: 0.9em; color: #777; }
    </style>
</head>
<body>

<div class="container">
    <h1>$TITLE</h1>
    <p style="text-align: center;">Généré le : $DATE</p>

    <h2>1. Informations Système</h2>
    <div class="info-grid">
        <div class="card"><strong>Machine</strong><span>$HOSTNAME</span></div>
        <div class="card"><strong>OS</strong><span>$OS_NAME</span></div>
        <div class="card"><strong>Noyau</strong><span>$KERNEL</span></div>
        <div class="card"><strong>Uptime</strong><span>$UPTIME</span></div>
    </div>

    <h2>2. Utilisation Ressources</h2>
    <div class="info-grid">
        <div class="card"><strong>Charge CPU (1min)</strong><span>$CPU_LOAD</span></div>
        <div class="card"><strong>RAM Totale</strong><span>$MEM_TOTAL</span></div>
        <div class="card"><strong>RAM Utilisée</strong><span>$MEM_USED</span></div>
        <div class="card"><strong>RAM Libre</strong><span>$MEM_FREE</span></div>
    </div>

    <h2>3. Espace Disque</h2>
    <table>
        <thead>
            <tr>
                <th>Système de fichiers</th>
                <th>Taille</th>
                <th>Utilisé</th>
                <th>Dispo</th>
                <th>Utilisation %</th>
                <th>Montage</th>
            </tr>
        </thead>
        <tbody>
EOF

# Injection des données Disque (exclusion des tmpfs/loop pour la clarté)
df -hP | grep -vE '^Filesystem|tmpfs|cdrom|loop|udev' | while read -r fs size used avail usep mounted; do
    echo "<tr><td>$fs</td><td>$size</td><td>$used</td><td>$avail</td><td>$usep</td><td>$mounted</td></tr>" >> "$OUTPUT_FILE"
done

cat <<EOF >> "$OUTPUT_FILE"
        </tbody>
    </table>

    <h2>4. Services Actifs (Top 10)</h2>
    <div class="status-box">
EOF

# Injection des services (systemctl)
if command -v systemctl &> /dev/null; then
    systemctl list-units --type=service --state=running --no-pager | head -n 15 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' >> "$OUTPUT_FILE"
else
    echo "Commande systemctl non disponible." >> "$OUTPUT_FILE"
fi

cat <<EOF >> "$OUTPUT_FILE"
    </div>

    <h2>5. Dernières Connexions</h2>
    <table>
        <thead>
            <tr>
                <th>Utilisateur</th>
                <th>Terminal</th>
                <th>IP / Hôte</th>
                <th>Date / Heure</th>
            </tr>
        </thead>
        <tbody>
EOF

# Injection des logs (last)
# On prend les 5 dernières lignes, on ignore les lignes vides ou de reboot
last -n 5 | head -n 5 | grep -vE "^$|^wtmp" | while read -r line; do
    # Découpage basique des champs pour le tableau HTML
    user=$(echo $line | awk '{print $1}')
    term=$(echo $line | awk '{print $2}')
    ip=$(echo $line | awk '{print $3}')
    time=$(echo $line | awk '{print $4, $5, $6, $7}')
    
    echo "<tr><td>$user</td><td>$term</td><td>$ip</td><td>$time</td></tr>" >> "$OUTPUT_FILE"
done

cat <<EOF >> "$OUTPUT_FILE"
        </tbody>
    </table>

    <div class="footer">
        Rapport généré automatiquement par script Bash.
    </div>
</div>

</body>
</html>
EOF

echo "Rapport généré avec succès : $OUTPUT_FILE"

# --- OUVERTURE AUTOMATIQUE ---
# Détection de l'OS pour ouvrir le navigateur
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v xdg-open > /dev/null; then
        xdg-open "$OUTPUT_FILE" > /dev/null 2>&1
    elif command -v gnome-open > /dev/null; then
        gnome-open "$OUTPUT_FILE" > /dev/null 2>&1
    else
        echo "Impossible d'ouvrir le navigateur automatiquement (pas d'interface graphique détectée ?)."
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    open "$OUTPUT_FILE" # Mac OS
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
    cmd.exe /c start "$OUTPUT_FILE" 2>/dev/null # Windows / WSL
else
    echo "Ouvrez manuellement le fichier : $OUTPUT_FILE"
fi