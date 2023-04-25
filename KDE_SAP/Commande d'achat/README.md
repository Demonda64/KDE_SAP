# Programme ABAP pour afficher des données de commande

## Description

Ce programme ABAP extrait des données des tables de base de données ekko, ekpo et ekes pour afficher les informations de commande dans une table ALV (ABAP List Viewer). Il utilise des options de sélection pour filtrer les données et permet à l'utilisateur de choisir entre deux modes d'affichage. 

Le programme utilise la classe cl_salv_table pour créer et afficher la table ALV, et utilise des requêtes SQL pour extraire les données de la base de données. Il utilise également des tables internes pour stocker les données extraites et les données de commande affichées.

## Utilisation

Le programme peut être exécuté en tant que programme autonome dans un système SAP. Pour l'exécuter, accédez à l'éditeur ABAP et copiez-collez le code dans un nouveau programme. Enregistrez le programme et exécutez-le en appuyant sur le bouton "Exécuter" dans l'éditeur.

Lorsque le programme s'exécute, une fenêtre de sélection d'options apparaît. L'utilisateur peut sélectionner les options pour filtrer les données en fonction des champs de la table de base de données ekko et ekpo. Il peut également choisir entre deux modes d'affichage en sélectionnant le bouton radio correspondant.

Une fois que l'utilisateur a sélectionné les options et le mode d'affichage, le programme extrait les données de la base de données en utilisant des requêtes SQL et les stocke dans une table interne. Il crée ensuite une table ALV en utilisant la classe cl_salv_table et affiche les données de la table interne.

## Personnalisation

Le programme peut être personnalisé pour répondre à des besoins spécifiques. Vous pouvez modifier les options de sélection pour filtrer les données de différentes manières ou ajouter des champs à la table de commande en modifiant le type de structure ty_commandes.

Vous pouvez également modifier le mode d'affichage pour afficher les données de manière différente ou ajouter des fonctionnalités supplémentaires en utilisant d'autres classes ou fonctions ABAP.

## Remarques

Ce programme a été testé et fonctionne correctement dans un système SAP. Toutefois, il peut nécessiter des modifications pour fonctionner dans d'autres environnements ou avec d'autres configurations de système SAP. Utilisez-le à vos propres risques et veillez à sauvegarder vos données avant de l'exécuter.
