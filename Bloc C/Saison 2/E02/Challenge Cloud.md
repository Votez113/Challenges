# Consulting Cloud pour PME — Énoncé simplifié

## Contexte

Vous êtes consultant chez **TechConseil**. Votre client **MediCare+** (PME de services de santé) veut moderniser son IT. L’infrastructure est 100% on‑premises et l’équipe est peu à l’aise avec le cloud.

Votre mission : **proposer une stratégie cloud simple, cohérente et réaliste**.

---

## Le client en bref

- 50 employés, siège à Lyon, agences à Marseille et Paris
- Application métier interne (PHP/MySQL), critique pour l’activité
- Site web vitrine WordPress
- Données sensibles mais **pas** de dossiers médicaux complets
- Un administrateur système à mi‑temps

---

## Infrastructure actuelle (résumé)

- Active Directory + DNS/DHCP sur un serveur Windows
- Application métier + base MySQL + fichiers sur un serveur Windows
- Site web sur un petit serveur Linux
- NAS + sauvegardes manuelles
- VPN inter‑sites

Coût annuel estimé : **~46 000 €**

---

## Problèmes constatés

- Coûts élevés et matériel à renouveler
- Disponibilité limitée, sauvegardes manuelles
- Accès distant difficile pour le télétravail
- Montée en charge compliquée
- RGPD pas assez cadré

---

## Objectifs du client

- Réduire les coûts et la maintenance
- Améliorer disponibilité et collaboration
- Sécuriser et cadrer la conformité RGPD
- Préparer la croissance

---

## Votre mission (livrable attendu)

Vous remettez **un document de recommandation**. Pas besoin d’un pavé : **2 à 3 pages suffisent** si c’est clair.

Le document contient :

### 1. Architecture cible (le cœur du travail)

Pour chaque composant, proposez une cible simple : On‑prem, IaaS, PaaS ou SaaS, avec le provider et la justification.

| Composant | Proposition | Modèle | Provider | Justification courte |
| :--- | :--- | :--- | :--- | :--- |
| **Identités** | SAAS | O365 | Microsoft | Utilisation d'Entra ID |
| **Messagerie + bureautique** | SAAS | O365 | Microsoft | Gestion simplifiée et application leader |
| **Fichiers partagés** | SAAS | O365 | Microsoft | SharePoint, intégré avec les licences O365. |
| **App métier** | PAAS | Compute | OVH | VM hébergée dans le cloud avec option PCA |
| **Base de données** | PAAS | Database | OVH | VM hébergée dans le cloud avec option PCA |
| **Sauvegardes** | On-prem + PCA OVH | | | Utilisation du NAS pour la sauvegarde des fichiers, base SQL et site Web, et souscription de l'offre PCA OVH |
| **Site web** | PAAS | Compute | OVH | VM hébergée dans le cloud avec option PCA |

Ajoutez un **schéma simple** (même à la main) : utilisateurs → services principaux → données.

### 2. Choix du provider

Comparez **2 ou 3 providers** (Azure, AWS, OVHcloud, etc.).

## 2. Choix du provider

| Critère | Azure | AWS | OVHcloud |
| :--- | :--- | :--- | :--- |
| **Localisation France** | Oui (Régions France Central / South) | Oui (Région Paris) | Oui (Plusieurs datacenters en France) |
| **Services managés (PaaS)** | **Très complet** : Idéal pour Windows, SQL et Web Apps. | **Exhaustif** : Le catalogue le plus large du marché. | **En croissance** : Managed DB et Web PaaS performants. |
| **Coût estimé** | Moyen (Optimisé via les licences M365 existantes). | Élevé (Tarification complexe à prévoir). | **Très Compétitif** : Environ 40-60% moins cher qu'Azure/AWS. |
| **Support / Simplicité** | **Élevée** : Interface familière pour les profils Windows. | **Faible** : Demande une expertise technique très pointue. | **Moyenne** : Interface simplifiée et souveraineté européenne. |

### Conclusion et recommandation
Pour MediCare+, nous préconisons une stratégie **hybride centrée sur Microsoft 365 et OVHcloud**. Ce choix permet de bénéficier du meilleur outil collaboratif du marché (M365) tout en hébergeant les applications critiques chez un acteur européen **souverain et économique**. C'est le compromis idéal pour garantir la conformité RGPD et la maîtrise budgétaire sans surcharger votre administrateur système.

### 3. Estimation budgétaire (ordre de grandeur)

Donnez une estimation mensuelle **globale** (pas besoin d’être exact) et expliquez vos hypothèses.

### 4. Points d’attention

Listez 3 à 5 risques majeurs et comment vous les réduisez (ex : migration, sécurité, dépendance fournisseur).

Migration : la migration des données doit être effectuée par lot, et vérifiée à chaque étape. Elle doit être validée après confirmation du transfert total des données, ainsi que l'application correcte des droits.

Sécurité : conserver les comptes administrateur dans un coffre numérique sécurisé, avec un accès restreint.

Dépendance fournisseur : Etablir un PCA qui permet la continuité d'activité (redondance géographique), établie un PRA qui permet la reprise d'activité chez un autre prestataire.

---

## Conseils

- Restez simples et cohérents.
- Mieux vaut une solution sobre et justifiée qu’un catalogue de services.
- Si vous manquez de temps, priorisez l’architecture et le choix du provider.

---

## Rendu

Un document unique par groupe. Le format est libre (PDF, Word, Google Docs).

Bonne chance, et posez des questions si besoin.