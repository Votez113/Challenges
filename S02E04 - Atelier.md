SA2 : Atelier Mme Michu

Aujourd’hui, tu vas devoir diagnostiquer et résoudre plusieurs pannes sur l’ordinateur de Madame Michu, une utilisatrice âgée sympathique qui adore les Yorkshires.

Voici le message qu’elle t’as envoyé :

Bonjour, Mon ordinateur ne veut plus démarrer correctement, et quand j’arrive enfin sur le Bureau, mon processeur et ma RAM sont utilisés à 100% (elle est balaise, Mme Michu, pour le pré-diagnostic). En plus, j’ai remarqué que des fichiers dans mon dossier « Images » ont disparu ! Je suis inquiète pour l’état de mes disques durs aussi, il parait qu’ils sont défectueux, pourrais-tu les vérifier aussi ? Merci beaucoup de ton aide !

Ta mission est de diagnostiquer et corriger les différentes pannes présentes sur la machine de Madame Michu en suivant ces quatre étapes :

Réparer le démarrage de Windows,
Restaurer les performances normales de la machine,
Vérifier l’état des disques durs,
Retrouver les fichiers disparus dans le dossier « Images ».

Voici le développement des points de votre compte-rendu en phrases courtes.

## 1. Réparation du BootMGR

Le PC ne démarrait plus et affichait l'erreur "BootMGR is missing". 

![BootMGR](/Challenges/Images/E04_atelier/2025-10-23_10h56_32.jpg)


J'ai démarré l'ordinateur à l'aide d'une image ISO de Windows 10, la tentative de réparation automatique n'a pas fonctionné. 

![BootMGR](/Challenges/Images/E04_atelier/S04_Demarrage.jpg)

J'ai donc redémarré pour accéder à l'invite de commandes. 

![BootMGR](/Challenges/Images/E04_atelier/S04_Demarrage.jpg)

![BootMGR](/Challenges/Images/E04_atelier/S04_depannage.jpg)

J'ai ensuite exécuté les commandes spécifiques pour réparer le BootMGR. 

bootrec /fixmbr
bcdboot E:\Windows
bootrec /rebuildbcd

Après un dernier redémarrage, la machine a fonctionné.

---

## 2. Problème Winload

Au démarrage suivant, un écran bleu (BSOD) lié à "Winload" est apparu. 

![BootMGR](/Challenges/Images/E04_atelier/2025-10-23_12h08_33.jpg)

L'outil de réparation automatique s'est lancé à plusieurs reprises. 

![BootMGR](/Challenges/Images/E04_atelier/2025-10-23_12h15_50.jpg)

Finalement, après ces tentatives, la session Windows a réussi à s'ouvrir.

---

## 3. Ralentissement du poste

Le poste était très lent. Le gestionnaire des tâches montrait de nombreuses fenêtres "CMD" et "Ping" actives. 

![BootMGR](/Challenges/Images/E04_atelier/2025-10-23_14h32_32.jpg)

En vérifiant les programmes au démarrage, j'ai identifié un script PowerShell suspect.

![BootMGR](/Challenges/Images/E04_atelier/2025-10-23_14h33_14.jpg)

J'ai désactivé ce script et redémarré.

Le problème persistant, j'ai vérifié le dossier "Démarrage" (shell:startup). 

![BootMGR](/Challenges/Images/E04_atelier/2025-10-23_14h52_58.jpg)

J'y ai trouvé un raccourci "Ping". 

Les propriétés de ce raccourci pointaient vers un script Windows. La suppression de ce script a définitivement résolu le problème de ralentissement.

![BootMGR](/Challenges/Images/E04_atelier/2025-10-23_14h53_45.jpg)

---

## 4. Disparition du 2ème disque

Le second disque dur (E:) n'était plus visible. 


Je me suis rendu dans le "Gestionnaire de disques", j'ai constaté que le second disque était "hors-ligne". 

![BootMGR](/Challenges/Images/E04_atelier/2025-10-23_14h45_24.jpg)

Je l'ai remis "en ligne" via le menu contextuel, et le disque E: est immédiatement réapparu.

![BootMGR](/Challenges/Images/E04_atelier/2025-10-23_14h43_31.jpg)

---

## 5. Disparition du dossier York

Un dossier nommé "York" avait disparu du répertoire "Images". 

J'ai fait un clic droit sur le dossier "Images" pour accéder à ses "Propriétés". Dans l'onglet "Versions précédentes", j'ai vu deux fichiers disponibles à la restauration. 

![BootMGR](/Challenges/Images/E04_atelier/2025-10-23_14h41_59.jpg)

J'ai restauré ces deux éléments, le dossier "York" est alors réapparu correctement dans le dossier "Images".

![BootMGR](/Challenges/Images/E04_atelier/2025-10-23_14h44_32.jpg)
