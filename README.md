# FSF Project Creator

Script para crear y gestionar proyectos automáticamente con DDEV y FS-Framework.

## Características

- **Instalación de proyectos**: Crea nuevos proyectos con DDEV
- **Dos tipos de proyecto**: FS-Framework o Solo PHP
- **Opciones de base de datos**: MariaDB + phpMyAdmin o PostgreSQL + pgAdmin
- **PHP 8.3**: Configuración automática con la última versión de PHP
- **Desinstalación**: Elimina proyectos DDEV de forma segura
- **Interfaz interactiva**: Menú guiado paso a paso

## Requisitos

- Git
- DDEV
- Bash

## Uso

```bash
./crear-poyecto-fsf.sh
```

El script te mostrará un menú con dos opciones:

### 1. Instalar nuevo proyecto

Te pedirá:
- Nombre del proyecto
- Tipo de proyecto (FS-Framework o Solo PHP)
- Stack de base de datos (MariaDB + phpMyAdmin o PostgreSQL + pgAdmin)

### 2. Desinstalar proyecto DDEV

Te permitirá eliminar proyectos DDEV existentes de forma segura, con opción de eliminar también la carpeta del proyecto.

## Después de crear el proyecto

```bash
cd nombre-del-proyecto
ddev start
```

## Comandos DDEV útiles

```bash
ddev start          # Iniciar el proyecto
ddev stop           # Detener el proyecto
ddev list           # Listar proyectos
ddev ssh            # Acceder al contenedor
ddev php -v         # Ver versión de PHP
ddev mysql          # Conectar a MySQL/MariaDB
ddev psql           # Conectar a PostgreSQL
```

## Autor

[@eltictacdicta](https://github.com/eltictacdicta)
