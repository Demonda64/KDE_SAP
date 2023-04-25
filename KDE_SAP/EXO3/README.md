# Programme ZKDE_CORR_EXO3

Ce programme est écrit en ABAP et a pour but de récupérer des données depuis la table ZDRIVER_CAR_KDE et de les afficher ainsi que de réaliser certaines opérations de manipulation de données. Il est destiné à être exécuté dans l'environnement SAP.

## Utilisation

1. Ouvrir SAP et se connecter au système souhaité
2. Aller dans l'éditeur de programmes et créer un nouveau programme avec le nom ZKDE_CORR_EXO3
3. Copier le contenu des fichiers ZKDE_CORR_EXO3_TOP.abap, ZKDE_CORR_EXO3_SCR.abap et ZKDE_CORR_EXO3_F01.abap dans les fichiers correspondants du programme nouvellement créé
4. Enregistrer et activer le programme
5. Exécuter le programme à l'aide de la transaction SE38 ou en double-cliquant sur le nom du programme dans l'éditeur de programmes

## Fonctionnalités

Le programme effectue les opérations suivantes :

- Affiche le nombre de lignes actuellement dans la table ZDRIVER_CAR_KDE
- Affiche le nombre de voitures de couleur "NOIR" dans la table
- Sélectionne l'année de fabrication de la voiture la plus récente et affiche le prénom du propriétaire de cette voiture
- Vérifie à l'aide d'une lecture directe s'il existe une voiture de la marque "AUDI" dans la table
- Crée une nouvelle table interne avec seulement les lignes de la table ZDRIVER_CAR_KDE pour lesquelles le propriétaire vit à "Toulouse" et l'affiche
- Crée une nouvelle ligne dans la nouvelle table interne et l'ajoute à la table ZDRIVER_CAR_KDE
- Supprime de la nouvelle table interne toutes les lignes qui sont également présentes dans la table ZDRIVER_CAR_KDE
- Modifie une ligne dans la nouvelle table interne en changeant la valeur d'un champ de cette ligne
- Ajoute une nouvelle ligne dans la nouvelle table interne, vérifie si elle est en double avec une ligne existante, puis l'ajoute à la table ZDRIVER_CAR_KDE

## Auteur

Ce programme a été écrit par [Nom de l'auteur].
