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
|---|---|---|---|---|
| Identités |  |  |  |  |
| Messagerie + bureautique |  |  |  |  |
| Fichiers partagés |  |  |  |  |
| App métier |  |  |  |  |
| Base de données |  |  |  |  |
| Sauvegardes |  |  |  |  |
| Site web |  |  |  |  |

Ajoutez un **schéma simple** (même à la main) : utilisateurs → services principaux → données.

### 2. Choix du provider

Comparez **2 ou 3 providers** (Azure, AWS, OVHcloud, etc.).

| Critère | Azure | AWS | OVHcloud |
|---|---|---|---|
| Localisation France |  |  |  |
| Services managés (PaaS) |  |  |  |
| Coût estimé |  |  |  |
| Support / simplicité |  |  |  |

Concluez en 4 ou 5 lignes : **le provider retenu et pourquoi**.

### 3. Estimation budgétaire (ordre de grandeur)

Donnez une estimation mensuelle **globale** (pas besoin d’être exact) et expliquez vos hypothèses.

### 4. Points d’attention

Listez 3 à 5 risques majeurs et comment vous les réduisez (ex : migration, sécurité, dépendance fournisseur).

---

## Conseils

- Restez simples et cohérents.
- Mieux vaut une solution sobre et justifiée qu’un catalogue de services.
- Si vous manquez de temps, priorisez l’architecture et le choix du provider.

---

## Rendu

Un document unique par groupe. Le format est libre (PDF, Word, Google Docs).

Bonne chance, et posez des questions si besoin.