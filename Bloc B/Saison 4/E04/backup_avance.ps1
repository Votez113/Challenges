<#
.SYNOPSIS
    Script de sauvegarde avancé avec logs, barre de progression et statistiques.
.DESCRIPTION
    Ce script copie le contenu d'un dossier source vers une destination,
    gère les erreurs, journalise les actions et affiche un résumé.
#>

# --- 1. CONFIGURATION ---
$SourceDir = "C:\DossierSource"        # À MODIFIER : Chemin du dossier source
$DestDir   = "D:\DossierBackup"        # À MODIFIER : Chemin du dossier de destination
$LogDir    = "$PSScriptRoot\Logs"      # Dossier des logs (au même endroit que le script)

# Création du nom de fichier log avec horodatage (ex: backup_20231027_143000.log)
$DateStr   = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile   = Join-Path -Path $LogDir -ChildPath "backup_$DateStr.log"

# --- 2. FONCTION DE LOG ---
function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogLine   = "[$TimeStamp] [$Level] $Message"

    # Écriture dans le fichier (Append)
    Add-Content -Path $LogFile -Value $LogLine -ErrorAction SilentlyContinue

    # Affichage console avec couleurs
    switch ($Level) {
        "INFO"    { Write-Host $LogLine -ForegroundColor Cyan }
        "SUCCESS" { Write-Host $LogLine -ForegroundColor Green }
        "WARNING" { Write-Host $LogLine -ForegroundColor Yellow }
        "ERROR"   { Write-Host $LogLine -ForegroundColor Red }
    }
}

# --- 3. DÉBUT DU TRAITEMENT ---
Clear-Host
# Création du dossier de logs si inexistant
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

Write-Log "Démarrage du script de sauvegarde." "INFO"
Write-Log "Source : $SourceDir" "INFO"
Write-Log "Destination : $DestDir" "INFO"

# Variables pour les statistiques
$FilesCopied = 0
$TotalSize   = 0
$ErrorsCount = 0

try {
    # --- 4. VÉRIFICATION SOURCE ---
    if (-not (Test-Path -Path $SourceDir)) {
        throw "Le dossier source n'existe pas : $SourceDir"
    }

    # --- 5. CRÉATION DESTINATION ---
    if (-not (Test-Path -Path $DestDir)) {
        Write-Log "Le dossier de destination n'existe pas. Création en cours..." "INFO"
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
        Write-Log "Dossier destination créé avec succès." "SUCCESS"
    }

    # Récupération de la liste des fichiers (pour la barre de progression)
    Write-Log "Analyse des fichiers à copier..." "INFO"
    $Files = Get-ChildItem -Path $SourceDir -Recurse -File -ErrorAction Stop
    $TotalCount = $Files.Count

    if ($TotalCount -eq 0) {
        Write-Log "Aucun fichier trouvé dans le dossier source." "WARNING"
    }
    else {
        # --- 6. COPIE AVEC PROGRESSION ---
        $Counter = 0
        
        foreach ($File in $Files) {
            $Counter++
            
            # Calcul du pourcentage pour la barre
            $Percent = [math]::Round(($Counter / $TotalCount) * 100)
            
            # Construction du chemin de destination (préservation de l'arborescence)
            $RelativePath = $File.FullName.Substring($SourceDir.Length)
            $TargetFile   = Join-Path -Path $DestDir -ChildPath $RelativePath
            $TargetFolder = Split-Path -Path $TargetFile -Parent

            # Affichage de la barre de progression
            Write-Progress -Activity "Sauvegarde en cours..." `
                           -Status "$Percent% Complet ($Counter / $TotalCount fichiers)" `
                           -CurrentOperation "Copie de : $($File.Name)" `
                           -PercentComplete $Percent

            try {
                # Création du sous-dossier si nécessaire
                if (-not (Test-Path $TargetFolder)) {
                    New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
                }

                # Copie du fichier
                Copy-Item -Path $File.FullName -Destination $TargetFile -Force -ErrorAction Stop
                
                # Mise à jour des stats
                $FilesCopied++
                $TotalSize += $File.Length
            }
            catch {
                # Gestion d'erreur locale (pour un fichier spécifique)
                Write-Log "Erreur lors de la copie de $($File.Name) : $_" "ERROR"
                $ErrorsCount++
            }
        }
    }

    # Conversion de la taille totale en MB
    $TotalSizeMB = [math]::Round($TotalSize / 1MB, 2)

    # --- 7. RÉSUMÉ FINAL ---
    Write-Log "--- RÉSUMÉ DE LA SAUVEGARDE ---" "INFO"
    Write-Log "Fichiers copiés : $FilesCopied / $TotalCount" "SUCCESS"
    Write-Log "Taille totale   : $TotalSizeMB MB" "SUCCESS"
    
    if ($ErrorsCount -gt 0) {
        Write-Log "Nombre d'erreurs : $ErrorsCount" "WARNING"
    } else {
        Write-Log "Aucune erreur détectée." "SUCCESS"
    }

}
catch {
    # --- 8. GESTION D'ERREUR GLOBALE ---
    # Capture les erreurs critiques (ex: disque plein, source introuvable, droits d'accès script)
    Write-Log "Une erreur critique est survenue : $($_.Exception.Message)" "ERROR"
}
finally {
    # Nettoyage de la barre de progression
    Write-Progress -Activity "Sauvegarde en cours..." -Completed
    
    # --- 9. AFFICHAGE CHEMIN LOG ---
    Write-Host "`n--------------------------------------------------" -ForegroundColor Gray
    Write-Host "Fichier de log disponible ici :" -ForegroundColor White
    Write-Host $LogFile -ForegroundColor Cyan
    Write-Host "--------------------------------------------------" -ForegroundColor Gray
}