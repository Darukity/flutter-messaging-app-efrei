## Messaging App Project Backend

[![fr](https://img.shields.io/badge/lang-fr-blue)](README.fr.md)

This is the backend repository for the Full Stack Messaging App Project built for the [Odin Project Curriculum](https://www.theodinproject.com/lessons/nodejs-messaging-app).

The goal of the project was to build a messaging web app that allows users to send and receive real-time messages.

A restful API was built using ExpressJS and serves as the project's backend.

The Socket.IO library was used for the real-time communication functionality utilized by the project's backend API.

- Project's Live Preview url https://messaging-app-project.onrender.com
- Project's Parent Repository - https://github.com/skynter/Messaging-App
- Project's Frontend Repository - https://github.com/skynter/Messaging-App-Frontend

## Technologies Used

- NodeJS
- ExpressJS
- MongoDB
- Cloudinary NodeJS
- Socket.IO

## Key features

- Real-time transmission of messages between users
- Integration with RESTful backend API
- Persistent Authentication using JWTs
- Customizing users profiles
- CRUD operations (Adding and Deleting Messages / Updating Profiles)

## Installation

To run the project locally :

- Run the following command to spin up a local development server :

```
npm run dev
```

- Access the frontend repository of the project and spin up a local development server to interact with the API

- The API endpoints listed in the backend folder can be accessed through the hosted API on https://odin-messaging-app-api.onrender.com

- The two main API endpoints are the GET https://odin-messaging-app-api.onrender.com/conversation endpoint and the POST https://odin-messaging-app-api.onrender.com/conversation/add_message
