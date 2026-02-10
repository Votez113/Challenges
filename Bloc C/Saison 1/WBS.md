# Organigramme du Projet (WBS)

```mermaid
graph TD
    %% Root
    Root[PROJET : MODERNISATION IT CAMPUS]

    %% Level 1: Lots
    L1[Lot 1 : Serveur & NAS]
    L2[Lot 2 : Sécurité & Firewall]
    L3[Lot 3 : Réseau & Wi-Fi]
    L4[Lot 4 : Finalisation & Recette]

    Root --> L1
    Root --> L2
    Root --> L3
    Root --> L4

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



