# S01E06 – Challenge : Administration Windows 🔎

## Challenge
En priorité, terminez l’atelier d’hier ! (y compris les bonus, si possible)
C’est à dire : installez Ubuntu et les logiciels demandés dessus !
Activez le copier/coller entre vos VMs et votre système hôte (petit indice : il faudra regarder du coté des « Additions Invité » de Virtual Box 😉 une petite recherche sur Internet (ou avoir écouté votre super formateur) devrait vous permettre de trouver comment faire !)
Bonus: Installer une 3ème ou 4ème VM avec le système d’exploitation Debian 13 !

---

## 📸 Partie 1 : Installation des Add-ins VirtualBox

Dans notre VM Ubuntu, je clique sur Périphériques / Insérer l'image des Additions invités

L'ISO s'ajoute automatiquement dans Ubuntu

![Image ADDin](/Images/E06/ubuntu_addin2.jpg)

![Image ADDin](/Images/E06/ubuntu_addin.jpg)

Avant de la lancer, il faut préparer notre OS en lançant les commandes suivantes : 

```sudo apt update```

```sudo apt upgrade```

```sudo apt install build-essential linux-headers-$(uname -r)```

Une fois les commandes terminées, je fais un clic droit dans l'espace vide → Ouvrir dans un terminal.
J'exécute : sudo ./VBoxLinuxAdditions.run, et l'installation se fait.

![Image ADDin](/Images/E06/ubuntu_addin2.jpg)

Puis redémarrage de la machine.

J'active ensuite les options de copier/coller, puis test, tout fonctionnne

---

## 🔌 Partie 2 : Installation de Debian

Création d'une nouvelle VM Debian

1. Installation en mode graphique

2. Choix des options de partition

3. Ouverture de session

4. Installation des logiciels en lignes de commande

(image.png)

