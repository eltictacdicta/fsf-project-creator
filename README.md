# FSF Project Creator

Script para crear y gestionar proyectos automáticamente con DDEV y FS-Framework.

## Características

- **Instalación de proyectos**: Crea nuevos proyectos con DDEV
- **Tres tipos de proyecto**: FS-Framework, Solo PHP o WordPress
- **WordPress con WP-CLI**: Descarga, instalación y configuración automática de WordPress en español
- **Opciones de base de datos**: MariaDB + phpMyAdmin, PostgreSQL + pgAdmin o sin base de datos para proyectos Solo PHP
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
- Tipo de proyecto:
  - **FS-Framework**: Clona e instala el framework FS
  - **Solo PHP**: Proyecto PHP vacío con DDEV, con opción de usar o no base de datos
  - **WordPress**: Instalación completa de WordPress con WP-CLI

#### Opciones específicas de Solo PHP

Al elegir **Solo PHP**, el script preguntará si el proyecto necesita base de datos:
- Si respondes que **no**, configurará DDEV sin iniciar el contenedor `db` y no instalará phpMyAdmin ni pgAdmin.
- Si respondes que **sí**, podrás elegir entre MariaDB + phpMyAdmin o PostgreSQL + pgAdmin.

#### Opciones específicas de WordPress

Al elegir WordPress, el script te pedirá adicionalmente:
- **Idioma (locale)**: es_ES, es_MX, es_AR, en_US o uno personalizado
- **Versión de WordPress**: última estable por defecto, o una versión específica
- **Título del sitio**
- **Usuario administrador**
- **Email del administrador**
- **Contraseña del administrador** (se pide de forma segura sin mostrar en pantalla)

La base de datos se configura automáticamente como MariaDB + phpMyAdmin (recomendado para WordPress).

### 2. Desinstalar proyecto DDEV

Te permitirá eliminar proyectos DDEV existentes de forma segura, con opción de eliminar también la carpeta del proyecto.
Puedes indicar el nombre del proyecto o la ruta completa; el script también intentará localizar la carpeta en el directorio actual y en el nivel superior.

## Después de crear el proyecto

### FS-Framework / Solo PHP

```bash
cd nombre-del-proyecto
ddev start
```

### WordPress

El proyecto WordPress se inicia automáticamente durante la instalación. Al finalizar, puedes abrir el sitio directamente.

```bash
cd nombre-del-proyecto
ddev launch              # Abrir el sitio
ddev launch /wp-admin    # Abrir el panel de administración
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

### Comandos WordPress (WP-CLI)

```bash
ddev wp plugin install <plugin> --activate   # Instalar y activar un plugin
ddev wp theme activate <tema>                # Activar un tema
ddev wp core update                          # Actualizar WordPress
ddev wp language core update                 # Actualizar traducciones
ddev wp db export backup.sql                 # Exportar base de datos
ddev snapshot                                # Crear punto de restauración
ddev xdebug on                               # Activar depuración XDebug
```

## Autor

[@eltictacdicta](https://github.com/eltictacdicta)
