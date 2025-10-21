# ⌨️ Le Challenge

Actuellement, sur Windows 10 et Windows 11, il est impossible de "pinguer" vos machines virtuelles (VM) depuis votre ordinateur hôte (votre PC personnel) sous VirtualBox.

## 🎯 L'Objectif

Votre tâche consiste à permettre à votre machine hôte d’effectuer un ping vers vos VM Windows.
En d’autres termes, vous devez configurer votre environnement de manière à rendre vos VM accessibles en réseau depuis votre poste principal.

---

## 🛠️ 1. Mise en Pratique

Nous allons faire communiquer l'hôte (mon PC), avec les VM Windows 10 et Windows 11 et effectuer des pings croisés.

## 🌐 2. Modifier la carte réseau des VM

Dans VirtualBox, je passe les cartes réseau de chaque VM en **réseau par pont** (choix de la VM / Configuration / Réseau / Mode d'accès réseau : Accès par pont).

![Carte reseau](/Images/E02/reseau_par_pont.jpg)

## 🔍 3. Vérification des Adresses IP

Chaque machine reçoit une IP distribuée par le DHCP de ma box, et figure dans le même réseau que ma machine.

![DHCP](/Images/E02/IP_DHCP_VM.jpg)

## 🛡️ 4. Problème : Ping inter-VM (Le Pare-feu)

Le Ping ne fonctionne pas de suite entre les VM. La faute à la version Famille de Windows qui bloque le réseau en "partage public" (tout est bloqué par défaut).

**Solution :** Pour contourner ce problème, je crée une règle dans le pare-feu Windows pour autoriser le ping (principe du moindre droit) à toutes les machines.

![Pare-feu](/Images/E02/regle_1.jpg)

![Pare-feu](/Images/E02/regle_2.jpg)

![Pare-feu](/Images/E02/regle_3.jpg)

![Pare-feu](/Images/E02/regle_4.jpg)

![Pare-feu](/Images/E02/regle_5.jpg)


## ✅ 5. Résolution : Ping inter-VM fonctionnel

Après la création et l'activation de la règle sur chaque machine, le ping (via la commande `ping` dans un CMD) entre les différentes VM fonctionne.

![Ping](/Images/E02/ping_interVm.jpg)

![Ping](/Images/E02/ping_vers_hote.jpg)

![Ping](/Images/E02/ping_depuis_hote.jpg)

Le ping via les noms DNS fonctionne également.

![Ping](/Images/E02/ping_DNS.jpg)

---

## 🎉 Résultat Final

Toutes les machines peuvent se voir et communiquer ensemble.