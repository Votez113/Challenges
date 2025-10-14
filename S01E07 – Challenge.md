# S01E07 – Challenge : Installer et utiliser un gestionnaire de mot de passe 🔎

## Challenge
Au programme de ce challenge : installez et configurez un gestionnaire de mot de passe ! Nous vous recommandons Bitwarden, qui est gratuit pour un usage personnel et open-source (on reparlera de ce que ça implique plus tard mais vous avez de toute évidence déjà été un peu spoil).

---
### 💾 Installation de Keepass
Pour commencer, je me suis rendu sur le site officiel de KeePass pour télécharger la dernière version recommandée pour mon ordinateur. J'ai ensuite installer rapidement Keepass sur mon poste.

---

### 🔑 Création d'une base avec un mot de passe Maître très sécurisé et unique
Une fois KeePass installé, je l'ai ouvert pour créer ma nouvelle base de données. J'ai alors défini mon "mot de passe Maître", en m'assurant qu'il soit très long et complexe (plus de 12 caractères, avec des majuscules, des minuscules, des chiffres et des symboles 🔢🔣🔡). C'est le seul mot de passe que j'aurai à retenir, et je ne l'utilise nulle part ailleurs.

---

### ☁️ Choix de la déposer sur mon Drive Google, pour un accès sur n'importe quel périphérique connecté à internet
Au moment d'enregistrer ma base de données, j'ai choisi de la placer directement dans mon dossier Google Drive synchronisé sur mon PC. De cette façon, mon fichier de mots de passe est automatiquement sauvegardé en ligne, ce qui me permet d'y accéder depuis n'importe lequel de mes appareils.

---

### 📤 Extraction de mes mots de passe Google
Je suis allé dans les paramètres de mon compte Google, puis dans la section "Sécurité" pour trouver le "Gestionnaire de mots de passe". Là, j'ai utilisé l'option "Exporter" pour télécharger tous mes mots de passe enregistrés dans un seul fichier au format CSV.

---

### 📥 Importation du CSV dans Keepass
De retour dans KeePass, je suis allé dans le menu "Fichier", puis "Importer". J'ai sélectionné le format "Generic CSV Importer", j'ai choisi le fichier CSV de Google, et j'ai suivi les étapes pour que tous mes anciens mots de passe soient correctement ajoutés à ma nouvelle base de données.

---

### 📂 Réorganisation des mots de passe avec dossier
Pour y voir plus clair, j'ai créé plusieurs dossiers (ou "groupes") pour classer mes identifiants par catégories : "Réseaux Sociaux" 📱, "Travail" 💼, "Achats en ligne" 🛒, etc. J'ai simplement glissé-déposé chaque entrée dans le dossier correspondant.

---

### 🤖 Installation de Keepass2Android
Sur mon téléphone Android, j'ai ouvert le Google Play Store et j'ai installé l'application gratuite "KeePass2Android".

---

### 🔄 Configuration de l'accès à la base sur Drive
J'ai ensuite ouvert KeePass2Android et j'ai choisi "Ouvrir un fichier..." via "Google Drive". Après m'être connecté à mon compte Google, j'ai simplement sélectionné mon fichier de base de données (.kdbx) pour l'ouvrir sur mon téléphone.

---

### 📲 Configuration de la saisie Automatique dans le téléphone
Dans les paramètres de KeePass2Android, j'ai activé la saisie automatique. Puis, dans les réglages de mon téléphone, sous "Langue et saisie", j'ai défini "KeePass2Android" comme service de remplissage par défaut. Maintenant, l'application me propose de remplir mes identifiants automatiquement.

---

### 💻 Configuration de la saisie Automatique dans le PC via extension Chrome
Enfin, sur mon ordinateur, j'ai installé l'extension "ChromeKeepass" depuis le Chrome Web Store. Je l'ai connectée à ma base de données KeePass qui était ouverte. Grâce à cela, une petite icône apparaît dans les champs de connexion des sites web, me permettant de remplir mes identifiants en un seul clic.
