# Fiche de Cadrage : Projet "InfraCampus 2026"

**Objet :** Modernisation de l’infrastructure réseau et des services numériques.  
**Responsable de projet :** Responsable Informatique  
**Collaborateur :** A définir 

---

## 1. Objectifs du projet
L’objectif est de mettre à niveau l’infrastructure pour supporter la charge de 500 utilisateurs et garantir un environnement de travail sécurisé et performant.

* **Segmentation réseau :** Mise en place de VLANs pour isoler les flux (Administration, Formateurs, Apprenants, IoT).
* **Centralisation des données :** Déploiement d'un serveur de fichiers et d'un NAS pour le stockage et la sauvegarde.
* **Sécurisation périmétrique :** Installation d'un firewall (NGFW) pour filtrer les accès internet et protéger le réseau interne.
* **Connectivité Haute Densité :** Déploiement d'une infrastructure Wi-Fi sécurisée capable de gérer les connexions simultanées.

---

## 2. Périmètre et Exclusions

### **Périmètre (Inclus) :**
* Audit de l'infrastructure existante.
* Achat, installation et configuration du matériel (Firewall, Switchs managés, NAS, Bornes Wi-Fi).
* Configuration des services de fichiers et des droits d'accès.
* Mise en place de la stratégie de sauvegarde (3-2-1).
* Documentation technique pour l'exploitation.

### **Exclusions :**
* Renouvellement du parc de postes clients (Laptops/PC).
* Maintenance des terminaux personnels des apprenants (BYOD).
* Développement de logiciels ou d'applications métiers.

---

## 3. Parties prenantes

| Acteur | Rôle | Type |
| :--- | :--- | :--- |
| **Direction du Campus** | Commanditaire / Validation budgétaire | Interne |
| **Responsable IT** | Chef de projet / Superviseur | Interne |
| **Personnel & Formateurs** | Utilisateurs "Métier" (besoins fichiers/accès) | Interne |
| **Apprenants** | Utilisateurs finaux (Wi-Fi/Services) | Interne |
| **Fournisseur Hardware** | Livraison des équipements | Externe |

---

## 4. Livrables principaux

1.  **Schéma réseau cible :** Cartographie des VLANs et plan d'adressage IP.
2.  **Infrastructure active :** Firewall et switchs configurés.
3.  **Service de stockage :** NAS et serveur de fichiers opérationnels avec gestion des droits.
4.  **Réseau Wi-Fi :** Bornes déployées avec portail captif ou authentification Radius.
5.  **Cahier de Recette :** Document prouvant le bon fonctionnement de chaque service.
6.  **Procédure d'exploitation :** Guide pour la création de comptes et la gestion des sauvegardes.

---

## 5. Contraintes Qualité / Coût / Délai

* **Qualité :** Haute disponibilité du Wi-Fi (pas de zones blanches) et sécurité renforcée (isolation stricte des VLANs).
* **Coût :** Respect de l'enveloppe budgétaire allouée pour l'année 2026 (matériel + licences).
* **Délai :** Finalisation de l'infrastructure avant la prochaine rentrée majeure (sous 3 à 4 mois).
* **Disponibilité :** Les travaux lourds impactant le réseau doivent être réalisés hors heures de cours.

---