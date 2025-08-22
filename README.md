# uwifiapp

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Prompt Incial de generacion del proyecto

Quiero que me apoyes en aplicar arquitectura clean en este proyecto que tiene las siguientes funcionalidades o features. Pantalla de Login que contendra un campo tipo mail y un campo password para entrar al sistema. Tendra un menu flotante con 4 opciones. Primera opcion tendra un texto Ver Videos, La segunda opcion en el menu tendra un texto que diga Home, la tercera opcion tendra un texto que diga Invite y la cuarta tendra en un texto que diga Profile. Este proyecto es un proyecto para dispositivos moviles y el backend que va utilizar para realizar la validacion del Login y recuperar y guardar los datos para hacerlos persistentes sera en una base de datos de supabase.

### Credecenciales de supabase

https://u-supabase.virtalus.cbluna-dev.com/

user: supabase
password: uwifi202405091721

### Administrador de contenido

https://u-wifi.virtalus.cbluna-dev.com/uwifi%20web/loqin

user: admin@uwifi.com
password: default

### Credenciales de usuario

user: freeuwifitest@gmail.com
password: Password

user2: peteuwifitest@gmail.com
password: Petepassword2!

### Ruta de documentacion de API y tablas de Supabase

https://docs.google.com/presentation/d/1om9ScIUfZXX6tCHlqEV3GTZcnKNP7ZrLkltewrU2Fks/edit?slide=id.g369d34fb402_0_0#slide=id.g369d34fb402_0_0

### Query

select \* from transactions.customer_wallet where customer_fk = <customer_id> order by id desc limit 1;
