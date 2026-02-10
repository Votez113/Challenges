# WBS du Projet IT Campus

## Lot 1 : Serveur & NAS
1.1 Analyse
1.2 Installation Serveur
1.3 Config Sauvegarde NAS

## Lot 2 : Firewall
2.1 Règles de filtrage
2.2 Installation physique et logique
2.3 VPN

## Lot 3 : Réseau & Wi-Fi
3.1 Segmentation VLAN
3.2 Déploiement Wi-Fi (500 users)

<<<<<<< HEAD
## Lot 4 : Recette
4.1 Tests de charge
4.2 Documentation
4.3 Transfert vers l'alternant

=======
    %% Détails Lot 1
    L1 --> L1.1[1.1 Analyse & Conception]
    L1 --> L1.2[1.2 Mise en œuvre Serveur]
    L1 --> L1.3[1.3 Stratégie Sauvegarde]

    %% Détails Lot 2
    L2 --> L2.1[2.1 Préparation]
    L2 --> L2.2[2.2 Config Technique]
    L2 --> L2.3[2.3 Accès Distant]

    %% Détails Lot 3
    L3 --> L3.1[3.1 Segmentation VLAN]
    L3 --> L3.2[3.2 Wi-Fi Haute Densité]

    %% Détails Lot 4
    L4 --> L4.1[4.1 Tests & Recette]
    L4 --> L4.2[4.2 Documentation]
    L4 --> L4.3[4.3 Transfert Alternant]

    %% Couleurs
    style Root fill:#f96,stroke:#333,stroke-width:4px
    style L1 fill:#d1e7ff,stroke:#000
    style L2 fill:#d1e7ff,stroke:#000
    style L3 fill:#d1e7ff,stroke:#000
    style L4 fill:#d1e7ff,stroke:#000
```
>>>>>>> bf6bd3ffb642144a488c0f2fb3360b23d346955f
---

# Diagramme de Gantt
```mermaid
gantt
    title Planning de déploiement
    dateFormat  YYYY-MM-DD
    section Serveur/NAS
    Audit           :2026-03-02, 7d
    Config          :10d
    section Réseau/Wi-Fi
    VLANs           :2026-03-16, 7d
    Wi-Fi           :14d
    section Sécurité
    Firewall        :2026-03-09, 10



