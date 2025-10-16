# S01E09 – Challenge : E09 - Adressage IP 🔎

## Challenge
Au programme de ce challenge : installez et configurez un gestionnaire de mot de passe ! Nous vous recommandons Bitwarden, qui est gratuit pour un usage personnel et open-source (on reparlera de Au programme ce soir, un peu de maths 😱

Pour les adresses IP et masques de sous-réseau suivants, calculez :

l’adresse de réseau
l’adresse de broadcast
le nombre d’adresses utilisables par des machines
la plage d’adresses disponibles
Certains utilisent la notation « classique », d’autres la notation CIDR :

192.168.13.67/24
172.16.0.1 – 255.255.255.0
172.16.27.32/23
10.7.5.1 – 255.255.128.0
10.42.0.82/12

---
### Exercice 1
192.168.13.67/24

Masque CIDR /24 = 255.255.255.0

Calcul du nombre magique : 256-0 = 256

Multiple de 256 : 0.256

Première adresse : 192.168.13.0 (plus petit multiple)

Broadcast : 192.168.13.255 (plus grand multiple - 1)

---

### Exercice 2
172.16.0.1 – 255.255.255.0

Calcul du nombre magique : 256-0 = 256

Multiple de 256 : 0.256

Première adresse : 172.16.0.0

Broadcast : 172.16.0.255

---

### Exercice 3

Masque CIDR /23 = 255.255.254.0

Calcul du nombre magique : 256-254 = 2 

Multiple de 2 0.2.4.6.8.10.12.14.16.18.20.22.24.|26.28|.30.32.34

Première adresse : 172.16.26.0

Broadcast : 172.16.27.255

---

### Exercice 4

10.7.5.1 – 255.255.128.0

Calcul du nombre magique : 256-128 = 128 

Multiple de 128 : |0.128|.256

Première adresse : 10.7.0.0

Broadcast : 10.7.127.255

---

### Exercice 5

10.42.0.82/12

Masque CIDR /12 = 255.240.0.0

Calcul du nombre magique : 256-240 = 16

Multiple de 16 : 0.|16.32|.48

Première adresse : 10.32.0.0

Broadcast : 10.47.255.255

---
