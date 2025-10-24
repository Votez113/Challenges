## 🛠️ Challenge : Tester la Stabilité de la RAM avec MemTest86

Le diagnostic des problèmes de stabilité d'un ordinateur passe souvent par le test de sa **mémoire vive (RAM)**. L'outil **MemTest86** est la référence pour cette tâche, car il exécute des tests approfondis directement au démarrage du système, avant le chargement de l'OS.


| **1. Téléchargement de l'ISO** | 

**Je télécharge l'image disque (.ISO) de MemTest86** depuis le site officiel. | Le format **ISO** est un fichier image de disque optique universel. Il est idéal pour la virtualisation car il simule le support de démarrage le plus couramment utilisé dans les machines virtuelles, agissant comme si vous insériez un CD-ROM physique dans la machine virtuelle. |

![ISO1](/Images/E03/Telechargement_ISO.jpg)

| **2. Montage ISO dans une VM VirtualBox** |

Dans les paramètres de la VM, j'accède à la section **Stockage** et je monte le fichier ISO comme un **Disque Optique Virtuel** (lecteur CD/DVD). Ensuite, je me rends dans la section **Système** et modifie l'**ordre de boot** pour que le "Lecteur Optique" soit le premier périphérique d'amorçage. | Pour que la VM démarre sur MemTest86, nous devons simuler le processus de démarrage sur un CD. En plaçant le lecteur optique en tête de la séquence de boot (avant le disque dur virtuel), nous garantissons que le BIOS/UEFI virtuel chargera l'outil de diagnostic en priorité.  |

![ISO2](/Images/E03/Montage_ISO.jpg)

| **3. Lancement MemTest** | 

**Au démarrage de la VM**, le système d'exploitation interne ne se charge pas. À la place, **MemTest86 se lance automatiquement** et exécute ses routines. | La VM va "booter" sur l'ISO monté. L'outil prend le contrôle total de l'environnement virtuel pour effectuer ses tests en profondeur, vérifiant l'intégrité de la **quantité exacte de RAM spécifiquement allouée** à cette instance de machine virtuelle (par exemple, 4 Go ou 8 Go, selon votre configuration). Ce test confirmera si la mémoire virtuelle est corrompue ou instable. |

![ISO3](/Images/E03/Lancement_Memtest.jpg)
