## Backend du Projet Messaging App

[![en](https://img.shields.io/badge/lang-en-red)](README.md)

Ce dépôt comprend la partie backend du Messaging App projet créé pour [Odin Project](https://www.theodinproject.com/lessons/nodejs-messaging-app).

L'objectif de ce projet est de créer une application Web de messagerie permettant aux utilisateurs d'envoyer et de recevoir des messages en temps réel.

Une API RESTful a été créé à l'aide d'ExpressJS et sert de backend au projet.

La bibliothèque Socket.IO a été utilisée pour la fonctionnalité de communication en temps réel utilisée par l'API du projet.

- Lien du projet - https://messaging-app-project.onrender.com
- Dépôt principal du projet - https://github.com/skynter/Messaging-App
- Dépôt frontend du projet - https://github.com/skynter/Messaging-App-Frontend

## Technologies Utilisées

- NodeJS
- ExpressJS
- MongoDB
- Cloudinary NodeJS
- Socket.IO

## Principales Fonctionnalités

- Transmission en temps réel de messages entre utilisateurs
- Intégration avec une RESTful backend API
- Authentification à travers les JWTs
- Personnalisation des profils d'utilisateurs
- Opérations CRUD (Ajout et suppression de messages / Personnalisation de profils)

## Installation

Pour exécuter le projet localement sur votre machine :

- Exécutez la commande suivante pour générer un serveur local de développement :

```
npm run dev
```

- Accédez au dépôt frontend du projet et générez un serveur local de développement pour interagir avec l'API

- Les points de terminaison de l'API figurant au niveau de ce dépôt sont accessibles à travers l'API hébergé sur https://odin-messaging-app-api.onrender.com

- Les deux points de terminaisons principaux de l'API sont le GET https://odin-messaging-app-api.onrender.com/conversation et le POST https://odin-messaging-app-api.onrender.com/conversation/add_message
