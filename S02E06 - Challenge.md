⌨️ Challenge
Accédez au BIOS de votre ordinateur, et explorez les différentes pages, sections et réglages proposés !
⚠️ Ne modifiez rien, vous risqueriez d’empêcher votre ordinateur de démarrer.
Prenez des photos des pages ou des réglages que vous ne comprenez/connaissez pas.
Pour ceux qui sont sur Mac, pas de BIOS dispo ! Vous pouvez explorer ce simulateur en ligne . ou celui-ci ou encore lui
Sauvegardez les données d’une clé USB, puis tentez de :
convertir sa table de partitions de MBR à GPT (ou l’inverse) à l’aide de l’utilitaire DiskPart (depuis une VM Windows, si vous êtes sous MacOS)
créer plusieurs partitions sur cette clé et tester de les formater avec différents systèmes de fichiers : NTFS, FAT32 et ExFAT
testez la compatibilité avec les différents systèmes d’exploitation (en connectant la clé USB sur des VMs VirtualBox)

## 1. Utilisation d'une clé USB de 64 Go

Pour ce premier test j'utilise une clé d'une capacité totale de 64 Go

![Clé 64Go](Images/E06/E06_Connexion_USB.jpg)

Les propriétés indiquent un Formatage en ExFAT

![Clé 64Go](Images/E06/E06_FormatNTFS1.jpg)

Je formate la clé en NTFS via l'interface graphique :

![Clé 64Go](Images/E06/E06_FormatNTFS2.jpg)

![Clé 64Go](Images/E06/E06_FormatNTFS3.jpg)

![Clé 64Go](Images/E06/E06_FormatNTFS4.jpg)

## 2. Conversion d'un volume NTFS en FAT32 via Diskpart

![NTFS FAT32](Images/E06/E06ConvertNTFStoFAT32.jpg)

![NTFS FAT32](Images/E06/E06ConvertNTFStoFAT32_2.jpg)

Diskpart m'affiche un message d'erreur : le volume est trop grand

![NTFS FAT32](Images/E06/E06ConvertNTFStoFAT32_3.jpg)

## 3. Utilisation d'une clé USB de 4Go

Pour contourner les limations dû aux formats 16 bits, j'utilise une clé USB de 4 Go

![Multi parts](Images/E06/E06_Cle4Go.jpg)

Via Diskpart, je transforme la partition MBR en GPT

![Multi parts](Images/E06/E06_Convertion_MBR_GPT.jpg) 

Puis je créé différents volumes via l'interface graphique

![Multi parts](Images/E06/E06Cle_RAW.jpg)

Et pour terminer, je créé un volume logique en FAT

![Multi parts](Images/E06/E06_Creation_Volume1.jpg) 

![Multi parts](Images/E06/E06_Creation_Volume2.jpg) 

![Multi parts](Images/E06/E06_Creation_Volume3.jpg) 

![Multi parts](Images/E06/E06_Creation_Volume4.jpg) 

![Multi parts](Images/E06/E06_Formatage_FAT32.jpg) 

Résultat final :

![Multi parts](Images/E06/E06_resultat_partition.jpg)
