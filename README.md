# Notepad: Web App

## General Info

Notepad Web App is a prototype notepad designed for practice purposes.

**Programming Language:** Dart

**Framework:** Flutter

**Arquetype:** Maven

**Support:** Browser

## Features

- Add, edit, read and delete text notes.
- Communication with Notepad API.
- Responsive design.
- All data is stored in a MySQL database.

## Execution Instructions

1. Fork and run the [Notepad API](https://github.com/AlexitoSnow/notepad_api) project.

2. Fork this project and run it.

If you want to run it on other devices:

3. Run from the command console, inside the main folder:
    
    `flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0`
    
    **NOTE:** Must be connected to the same network.

4. Enter the following link in your browser: `http://<Dirección IP de tu PC>:8080`

**NOTE:**
- If you want to modify the API URL, you must modify the `requestUri` variable in the `lib/main.dart` file.
- The [Notepad API](https://github.com/AlexitoSnow/notepad_api) project does not support connection with version [0.0.1](https://github.com/AlexitoSnow/notepad_web_app/releases/tag/v0.0.1) of this project.