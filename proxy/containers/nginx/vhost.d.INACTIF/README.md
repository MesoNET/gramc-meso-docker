Bidouille very quick and dirty
====

Ce répertoire est un VOLUME de docker-gen
docker-gen génère un fichier default alors que nginx a besoin d'un fichier default_location
Le fichier généré ne sert pas, mais il est recopié avec le nom default_location
dans le VRAI volume de nginx

