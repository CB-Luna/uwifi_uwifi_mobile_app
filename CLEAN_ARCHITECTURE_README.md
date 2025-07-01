# UWifi App - Clean Architecture Implementation

Este proyecto esta desarrollado en lenguaje flutter y se esta utilizando un backend en Supabase.

## Objetivo del proyecto

El objetivo de la aplicación es que el usuario va a poder visualizar una lista de videos los cuales una ves concluida la finalizacion de cada video se le otorga al usuario una ganancia en puntos. El usuario puedo invitar o afiliar a otros usuarios a traves de una opcion de Invite para que se le sumen a su cuenta los puntos que cada usuario gano con la visualizacion de videos de las personas que invito. Con la aplicacion el usuario tendra una opcion para poder monitorear la velocidad del modem que tiene contratado y  ademas el usuario tendra una opcion de profile donde se le permitira configurar una visualizacion Dark o Light, escoger el idioma, visualizar su wallets de puntos.



## 📋 Resumen
Este proyecto implementa Clean Architecture con las siguientes funcionalidades:
- **Pantalla de Login** con validación de email y contraseña
- **Menú flotante** con 4 opciones: Ver Videos, Home, Invite, Profile
- **Integración con Supabase** para autenticación y persistencia de datos
- **Arquitectura limpia** separada en capas (Domain, Data, Presentation)

## 🏗️ Estructura del Proyecto

```
lib/
├── core/                           # Funcionalidades compartidas
│   ├── constants/
│   │   └── app_constants.dart      # Constantes de la aplicación
│   ├── errors/
│   │   └── failures.dart          # Manejo de errores
│   ├── network/
│   │   └── network_info.dart      # Información de conectividad
│   └── usecases/
│       └── usecase.dart           # Caso de uso base
├── features/                      # Características principales
│   ├── auth/                      # Autenticación
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── home/                      # Pantalla principal
│   ├── videos/                    # Ver videos
│   ├── invite/                    # Invitar amigos
│   └── profile/                   # Perfil de usuario
├── injection_container.dart       # Inyección de dependencias
├── main_clean.dart                # Punto de entrada con Clean Architecture
└── router_demo.dart               # Código original (respaldo)
```

## 🚀 Configuración Inicial

### 1. Configurar Supabase
Actualiza las constantes en `lib/core/constants/app_constants.dart`:

```dart
static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
static const String supabaseAnonKey = 'tu-anon-key-aqui';
```

### 2. Usar la nueva implementación
Para usar Clean Architecture, reemplaza el contenido de `main.dart` con el de `main_clean.dart`:

```bash
cp lib/main_clean.dart lib/main.dart
```

### 3. Instalar dependencias
```bash
flutter pub get
```

## 🔧 Funcionalidades Implementadas

### ✅ Autenticación
- **Login** con email y contraseña demo@uwifi.com
- **Validación** de formularios
- **Manejo de estados** con BLoC
- **Persistencia** de sesión con Supabase
- **Logout** seguro

### ✅ Navegación
- **Menú flotante** con 4 opciones principales
- **Navegación fluida** entre pantallas
- **Rutas** bien definidas

### ✅ Pantallas Principales
1. **Ver Videos**: Categorías de videos organizadas
2. **Home**: Dashboard con acciones rápidas
3. **Invite**: Sistema de invitaciones con estadísticas
4. **Profile**: Configuración de usuario y aplicación

## 🏛️ Arquitectura Implementada

### Capa de Dominio (Domain)
- **Entidades**: Objetos de negocio puros
- **Repositorios**: Contratos de acceso a datos
- **Casos de Uso**: Lógica de negocio

### Capa de Datos (Data)
- **Modelos**: Implementaciones de entidades
- **Fuentes de Datos**: Remote (Supabase) y Local (SharedPreferences)
- **Repositorios**: Implementaciones concretas

### Capa de Presentación (Presentation)
- **BLoC**: Manejo de estado
- **Páginas**: Interfaces de usuario
- **Widgets**: Componentes reutilizables

## 🔌 Inyección de Dependencias
Utiliza GetIt para la inyección de dependencias. Todas las dependencias están configuradas en `injection_container.dart`.

## 📱 Uso de la Aplicación

1. **Pantalla de Login**: 
   - Ingresa email y contraseña
   - Validación automática de formularios
   - Autenticación con Supabase

2. **Menú Principal**:
   - Botón flotante para acceder al menú
   - 4 opciones: Ver Videos, Home, Invite, Profile

3. **Navegación**:
   - Desliza entre pantallas o usa el menú
   - Logout desde cualquier pantalla

## 🛠️ Próximos Pasos

Para completar la funcionalidad, puedes:

1. **Configurar Supabase**:
   - Crear tablas para usuarios
   - Configurar autenticación
   - Añadir políticas de seguridad

2. **Expandir funcionalidades**:
   - Implementar videos reales
   - Sistema de invitaciones funcional
   - Configuraciones de perfil

3. **Añadir más características**:
   - Push notifications
   - Análisis de uso
   - Temas personalizados

## 📄 Archivos Importantes

- `main_clean.dart`: Nueva implementación con Clean Architecture
- `router_demo.dart`: Código original del router (respaldo)
- `injection_container.dart`: Configuración de dependencias
- `app_constants.dart`: Configuración de Supabase y constantes

¡La implementación de Clean Architecture está completa y lista para usar!
