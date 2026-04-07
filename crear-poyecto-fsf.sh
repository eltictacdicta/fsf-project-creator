#!/bin/bash

# Script para crear un nuevo proyecto con DDEV y FS-Framework

# Colores para输出的
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  Proyectos DDEV y FS-Framework${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

WP_ALREADY_STARTED=false

# Verificar que git está instalado
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git no está instalado${NC}"
    exit 1
fi

# Verificar que ddev está instalado
if ! command -v ddev &> /dev/null; then
    echo -e "${RED}Error: ddev no está instalado${NC}"
    exit 1
fi

# Opción inicial: Instalar o Desinstalar
echo "¿Qué deseas hacer?"
echo "  1) Instalar nuevo proyecto"
echo "  2) Desinstalar proyecto DDEV"
read -p "Elige una opción [1-2]: " MAIN_OPTION

case "$MAIN_OPTION" in
    2)
        # === ASISTENTE DE DESINSTALACIÓN ===
        echo ""
        echo -e "${YELLOW}=== Asistente de desinstalación de proyectos DDEV ===${NC}"
        echo ""
        echo "Proyectos DDEV disponibles:"
        ddev list
        echo ""
        read -p "Introduce el nombre del proyecto a desinstalar (o ruta completa): " PROJECT_TO_DELETE

        if [ -z "$PROJECT_TO_DELETE" ]; then
            echo -e "${RED}Error: Debes proporcionar un nombre de proyecto${NC}"
            exit 1
        fi

        CURRENT_DIR="$(pwd -P)"
        PARENT_DIR="$(dirname "$CURRENT_DIR")"

        # Si es solo el nombre, buscar el directorio
        if [ ! -d "$PROJECT_TO_DELETE" ]; then
            # Buscar en directorio actual
            if [ -d "$CURRENT_DIR/$PROJECT_TO_DELETE" ]; then
                PROJECT_PATH="$CURRENT_DIR/$PROJECT_TO_DELETE"
            # Buscar en la carpeta de nivel superior
            elif [ "$PARENT_DIR" != "$CURRENT_DIR" ] && [ -d "$PARENT_DIR/$PROJECT_TO_DELETE" ]; then
                PROJECT_PATH="$PARENT_DIR/$PROJECT_TO_DELETE"
            else
                PROJECT_PATH="$PROJECT_TO_DELETE"
            fi
        else
            PROJECT_PATH="$PROJECT_TO_DELETE"
        fi

        if [ ! -d "$PROJECT_PATH" ]; then
            echo -e "${RED}Error: No se encontró el directorio del proyecto: $PROJECT_PATH${NC}"
            exit 1
        fi

        echo ""
        echo -e "${YELLOW}Se eliminará el proyecto en: $PROJECT_PATH${NC}"
        read -p "¿Estás seguro? Esto eliminará contenedores, volúmenes y datos (s/n): " CONFIRM_DELETE

        case "$CONFIRM_DELETE" in
            s|S|si|SI|Si|sí|SÍ|Sí)
                cd "$PROJECT_PATH"
                echo -e "${YELLOW}Deteniendo y eliminando proyecto DDEV...${NC}"
                if ddev delete -O -y 2>/dev/null || ddev delete --omit-snapshot -y 2>/dev/null || ddev delete -y; then
                    echo -e "${GREEN}   ✓ Proyecto DDEV eliminado correctamente${NC}"
                    read -p "¿Deseas eliminar también la carpeta del proyecto? (s/n): " DELETE_FOLDER
                    case "$DELETE_FOLDER" in
                        s|S|si|SI|Si|sí|SÍ|Sí)
                            cd ..
                            rm -rf "$PROJECT_PATH"
                            echo -e "${GREEN}   ✓ Carpeta del proyecto eliminada${NC}"
                            ;;
                        *)
                            echo -e "${YELLOW}   Carpeta conservada en: $PROJECT_PATH${NC}"
                            ;;
                    esac
                else
                    echo -e "${RED}Error al eliminar el proyecto DDEV${NC}"
                    exit 1
                fi
                ;;
            *)
                echo -e "${YELLOW}Desinstalación cancelada.${NC}"
                ;;
        esac
        echo ""
        exit 0
        ;;
    1)
        # Continuar con instalación
        ;;
    *)
        echo -e "${RED}Error: Opción no válida${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${YELLOW}=== Instalación de nuevo proyecto ===${NC}"
echo ""

# Pedir el nombre del proyecto
read -p "Introduce el nombre del proyecto (ej: proyecto-nuevo): " PROJECT_NAME

# Preguntar tipo de proyecto
echo ""
echo "Selecciona el tipo de proyecto:"
echo "  1) FS-Framework"
echo "  2) Solo PHP"
echo "  3) WordPress"
read -p "Elige una opción [1-3]: " PROJECT_TYPE_OPTION

case "$PROJECT_TYPE_OPTION" in
    1)
        PROJECT_TYPE="fs-framework"
        ;;
    2)
        PROJECT_TYPE="php"
        ;;
    3)
        PROJECT_TYPE="wordpress"
        ;;
    *)
        echo -e "${RED}Error: Opción de tipo de proyecto no válida${NC}"
        exit 1
        ;;
esac

# Opciones específicas de WordPress
WP_LOCALE="es_ES"
WP_VERSION=""
WP_TITLE=""
WP_ADMIN_USER=""
WP_ADMIN_EMAIL=""
PROJECT_NEEDS_DB=true
DDEV_OMIT_CONTAINERS=""

if [ "$PROJECT_TYPE" = "wordpress" ]; then
    echo ""
    echo -e "${YELLOW}=== Configuración de WordPress ===${NC}"

    echo ""
    echo "Selecciona el idioma (locale):"
    echo "  1) es_ES - Español (España)"
    echo "  2) es_MX - Español (México)"
    echo "  3) es_AR - Español (Argentina)"
    echo "  4) en_US - Inglés (USA)"
    echo "  5) Otro (introducir manualmente)"
    read -p "Elige una opción [1-5] (por defecto 1): " WP_LOCALE_OPTION
    WP_LOCALE_OPTION=${WP_LOCALE_OPTION:-1}

    case "$WP_LOCALE_OPTION" in
        1) WP_LOCALE="es_ES" ;;
        2) WP_LOCALE="es_MX" ;;
        3) WP_LOCALE="es_AR" ;;
        4) WP_LOCALE="en_US" ;;
        5)
            read -p "Introduce el locale (ej: fr_FR, pt_BR): " WP_LOCALE
            if [ -z "$WP_LOCALE" ]; then
                WP_LOCALE="es_ES"
            fi
            ;;
        *) WP_LOCALE="es_ES" ;;
    esac

    read -p "Versión de WordPress (dejar vacío para la última estable): " WP_VERSION
    read -p "Título del sitio (por defecto: Mi-WordPress): " WP_TITLE
    WP_TITLE=${WP_TITLE:-Mi-WordPress}
    read -p "Usuario administrador (por defecto: admin): " WP_ADMIN_USER
    WP_ADMIN_USER=${WP_ADMIN_USER:-admin}
    read -p "Email del administrador (por defecto: admin@example.com): " WP_ADMIN_EMAIL
    WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-admin@example.com}
fi

# Preguntar stack de base de datos
if [ "$PROJECT_TYPE" = "wordpress" ]; then
    DB_ENGINE="mariadb"
    DB_TYPE="mariadb:10.11"
    DB_LABEL="MariaDB + phpMyAdmin (recomendado para WordPress)"
    echo ""
    echo -e "${GREEN}   Base de datos: $DB_LABEL (selección automática)${NC}"
elif [ "$PROJECT_TYPE" = "php" ]; then
    echo ""
    read -p "¿Este proyecto PHP necesita base de datos? (s/n) [n]: " PHP_NEEDS_DB
    PHP_NEEDS_DB=${PHP_NEEDS_DB:-n}

    case "$PHP_NEEDS_DB" in
        s|S|si|SI|Si|sí|SÍ|Sí)
            PROJECT_NEEDS_DB=true
            echo ""
            echo "Selecciona el stack de base de datos:"
            echo "  1) MariaDB + phpMyAdmin"
            echo "  2) PostgreSQL + pgAdmin"
            read -p "Elige una opción [1-2]: " DB_OPTION

            case "$DB_OPTION" in
                1)
                    DB_ENGINE="mariadb"
                    DB_TYPE="mariadb:10.11"
                    DB_LABEL="MariaDB + phpMyAdmin"
                    ;;
                2)
                    DB_ENGINE="postgres"
                    DB_TYPE="postgres:16"
                    DB_LABEL="PostgreSQL + pgAdmin"
                    ;;
                *)
                    echo -e "${RED}Error: Opción de base de datos no válida${NC}"
                    exit 1
                    ;;
            esac
            ;;
        *)
            PROJECT_NEEDS_DB=false
            DB_ENGINE=""
            DB_TYPE="mariadb:10.11"
            DB_LABEL="Sin base de datos (contenedor db omitido)"
            DDEV_OMIT_CONTAINERS="db"
            echo -e "${GREEN}   Proyecto PHP configurado sin base de datos${NC}"
            ;;
    esac
else
    echo ""
    echo "Selecciona el stack de base de datos:"
    echo "  1) MariaDB + phpMyAdmin"
    echo "  2) PostgreSQL + pgAdmin"
    read -p "Elige una opción [1-2]: " DB_OPTION

    case "$DB_OPTION" in
        1)
            DB_ENGINE="mariadb"
            DB_TYPE="mariadb:10.11"
            DB_LABEL="MariaDB + phpMyAdmin"
            ;;
        2)
            DB_ENGINE="postgres"
            DB_TYPE="postgres:16"
            DB_LABEL="PostgreSQL + pgAdmin"
            ;;
        *)
            echo -e "${RED}Error: Opción de base de datos no válida${NC}"
            exit 1
            ;;
    esac
fi

# Validar que se ha introducido un nombre
if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Error: Debes proporcionar un nombre de proyecto${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Creando proyecto: $PROJECT_NAME${NC}"
echo -e "${YELLOW}Tipo de proyecto: $PROJECT_TYPE${NC}"
echo -e "${YELLOW}Base de datos: $DB_LABEL${NC}"
if [ "$PROJECT_TYPE" = "wordpress" ]; then
    echo -e "${YELLOW}Locale: $WP_LOCALE${NC}"
    if [ -n "$WP_VERSION" ]; then
        echo -e "${YELLOW}Versión WordPress: $WP_VERSION${NC}"
    else
        echo -e "${YELLOW}Versión WordPress: última estable${NC}"
    fi
    echo -e "${YELLOW}Título: $WP_TITLE${NC}"
    echo -e "${YELLOW}Admin: $WP_ADMIN_USER ($WP_ADMIN_EMAIL)${NC}"
fi
echo ""

# Obtener el directorio actual y subir un nivel
cd ..
BASE_DIR=$(pwd)
PROJECT_DIR="$BASE_DIR/$PROJECT_NAME"

# Crear la carpeta del proyecto
echo -e "${YELLOW}1. Creando carpeta del proyecto...${NC}"
mkdir -p "$PROJECT_DIR"

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: No se pudo crear la carpeta $PROJECT_NAME${NC}"
    exit 1
fi

echo -e "${GREEN}   ✓ Carpeta creada: $PROJECT_NAME${NC}"

# Ir a la carpeta del proyecto
cd "$PROJECT_DIR"
echo -e "${GREEN}   ✓ Cambiado al directorio: $PROJECT_DIR${NC}"

# Ejecutar ddev config
echo ""
if [ "$PROJECT_NEEDS_DB" = true ]; then
    echo -e "${YELLOW}2. Configurando DDEV con PHP 8.3 y ${DB_TYPE}...${NC}"
else
    echo -e "${YELLOW}2. Configurando DDEV con PHP 8.3 sin base de datos...${NC}"
fi

if [ "$PROJECT_TYPE" = "wordpress" ]; then
    ddev config --project-type=wordpress --php-version 8.3 --database "$DB_TYPE"
elif [ -n "$DDEV_OMIT_CONTAINERS" ]; then
    ddev config --php-version 8.3 --database "$DB_TYPE" --omit-containers="$DDEV_OMIT_CONTAINERS"
else
    ddev config --php-version 8.3 --database "$DB_TYPE"
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✓ DDEV configurado correctamente${NC}"
else
    echo -e "${RED}Error: Error al configurar DDEV${NC}"
    exit 1
fi

# Instalar addon de administración de base de datos
echo ""
if [ "$PROJECT_NEEDS_DB" = true ]; then
    echo -e "${YELLOW}3. Instalando herramienta de administración de base de datos...${NC}"

    ADDON_INSTALLED=false
    ADDON_INSTALLED_NAME=""
    if [ "$DB_ENGINE" = "mariadb" ]; then
        DB_ADDON_LABEL="phpMyAdmin"
        DB_ADDON_CANDIDATES=("ddev/ddev-phpmyadmin" "ddev/ddev-adminer")
    else
        DB_ADDON_LABEL="pgAdmin"
        DB_ADDON_CANDIDATES=("MurzNN/ddev-pgadmin" "ddev/ddev-adminer")
    fi

    for addon in "${DB_ADDON_CANDIDATES[@]}"; do
        if ddev add-on get "$addon"; then
            ADDON_INSTALLED=true
            ADDON_INSTALLED_NAME="$addon"
            echo -e "${GREEN}   ✓ Addon instalado: $addon (${DB_ADDON_LABEL})${NC}"
            break
        fi
    done

    if [ "$ADDON_INSTALLED" = false ]; then
        echo -e "${YELLOW}   ⚠ No se pudo instalar automáticamente ${DB_ADDON_LABEL}.${NC}"
        echo -e "${YELLOW}   Puedes instalarlo manualmente con: ddev add-on get <nombre-del-addon>${NC}"
    elif [ "$DB_ENGINE" = "postgres" ] && [ "$ADDON_INSTALLED_NAME" = "ddev/ddev-adminer" ]; then
        echo -e "${YELLOW}   ℹ Se instaló Adminer como alternativa compatible con PostgreSQL.${NC}"
    fi
else
    echo -e "${YELLOW}3. Proyecto sin base de datos: se omite la instalación del gestor.${NC}"
fi

if [ "$PROJECT_TYPE" = "fs-framework" ]; then
    # Clonar el repositorio
    echo ""
    echo -e "${YELLOW}4. Clonando FS-Framework...${NC}"
    git clone https://github.com/eltictacdicta/fs-framework.git

    if [ ! -d "fs-framework" ]; then
        echo -e "${RED}Error: No se pudo clonar el repositorio${NC}"
        exit 1
    fi

    echo -e "${GREEN}   ✓ Repositorio clonado${NC}"

    # Mover el contenido de fs-framework a la raíz
    echo ""
    echo -e "${YELLOW}5. Moviendo archivos de fs-framework a la raíz...${NC}"
    shopt -s dotglob
    mv fs-framework/* .
    shopt -u dotglob

    echo -e "${GREEN}   ✓ Archivos movidos${NC}"

    # Borrar la subcarpeta fs-framework
    echo ""
    echo -e "${YELLOW}6. Borrando subcarpeta fs-framework...${NC}"
    rm -rf fs-framework

    echo -e "${GREEN}   ✓ Subcarpeta eliminada${NC}"

elif [ "$PROJECT_TYPE" = "wordpress" ]; then
    # Verificar otros proyectos DDEV corriendo que puedan consumir memoria
    RUNNING_PROJECTS=$(ddev list 2>/dev/null | grep -c " OK ")
    if [ "$RUNNING_PROJECTS" -gt 1 ]; then
        echo ""
        echo -e "${YELLOW}   ⚠ Hay $RUNNING_PROJECTS proyectos DDEV corriendo actualmente.${NC}"
        echo -e "${YELLOW}   Si la instalación falla por falta de memoria (error 137),${NC}"
        echo -e "${YELLOW}   considera detener otros proyectos con: ddev stop --all${NC}"
        echo ""
        read -p "¿Quieres detener los demás proyectos para liberar memoria? (s/n): " STOP_OTHERS
        case "$STOP_OTHERS" in
            s|S|si|SI|Si|sí|SÍ|Sí)
                echo -e "${YELLOW}   Deteniendo otros proyectos...${NC}"
                ddev poweroff 2>/dev/null
                echo -e "${GREEN}   ✓ Proyectos detenidos${NC}"
                ;;
        esac
    fi

    # Iniciar DDEV antes de descargar WordPress
    echo ""
    echo -e "${YELLOW}4. Iniciando DDEV para descargar WordPress...${NC}"

    ddev start 2>&1 &
    DDEV_PID=$!
    DDEV_TIMEOUT=120
    DDEV_ELAPSED=0

    while kill -0 "$DDEV_PID" 2>/dev/null; do
        sleep 5
        DDEV_ELAPSED=$((DDEV_ELAPSED + 5))
        if [ "$DDEV_ELAPSED" -ge "$DDEV_TIMEOUT" ]; then
            echo -e "${YELLOW}   ⚠ ddev start está tardando más de lo esperado (${DDEV_TIMEOUT}s)${NC}"
            echo -e "${YELLOW}   Verificando si los contenedores están listos...${NC}"
            kill "$DDEV_PID" 2>/dev/null
            break
        fi
    done

    wait "$DDEV_PID" 2>/dev/null
    DDEV_EXIT=$?

    # Verificar que los contenedores estén funcionando aunque ddev start haya fallado parcialmente
    WP_CONTAINERS_OK=false
    if ddev describe 2>/dev/null | grep -q "OK"; then
        WP_CONTAINERS_OK=true
        echo -e "${GREEN}   ✓ Contenedores DDEV funcionando correctamente${NC}"
    elif [ "$DDEV_EXIT" -eq 0 ]; then
        WP_CONTAINERS_OK=true
        echo -e "${GREEN}   ✓ DDEV iniciado correctamente${NC}"
    fi

    if [ "$WP_CONTAINERS_OK" = false ]; then
        echo -e "${YELLOW}   Reintentando ddev start...${NC}"
        if ddev start; then
            echo -e "${GREEN}   ✓ DDEV iniciado en segundo intento${NC}"
        else
            echo -e "${RED}Error: No se pudo iniciar DDEV${NC}"
            echo -e "${YELLOW}   Intenta liberar memoria (ddev poweroff) y ejecuta el script de nuevo.${NC}"
            exit 1
        fi
    fi

    # Descargar WordPress con WP-CLI (con reintentos para error 137/OOM)
    echo ""
    echo -e "${YELLOW}5. Descargando WordPress (locale: $WP_LOCALE)...${NC}"

    WP_DOWNLOAD_CMD="ddev wp core download --locale=$WP_LOCALE"
    if [ -n "$WP_VERSION" ]; then
        WP_DOWNLOAD_CMD="$WP_DOWNLOAD_CMD --version=$WP_VERSION"
    fi

    WP_DL_RETRIES=3
    WP_DL_SUCCESS=false
    for i in $(seq 1 $WP_DL_RETRIES); do
        if eval "$WP_DOWNLOAD_CMD"; then
            WP_DL_SUCCESS=true
            echo -e "${GREEN}   ✓ WordPress descargado correctamente${NC}"
            break
        else
            WP_DL_EXIT=$?
            if [ "$WP_DL_EXIT" -eq 137 ] || [ "$WP_DL_EXIT" -eq 1 ]; then
                echo -e "${YELLOW}   ⚠ Intento $i/$WP_DL_RETRIES falló (exit: $WP_DL_EXIT). Esperando 10s antes de reintentar...${NC}"
                sleep 10
            else
                echo -e "${RED}   Error inesperado (exit: $WP_DL_EXIT)${NC}"
                break
            fi
        fi
    done

    if [ "$WP_DL_SUCCESS" = false ]; then
        echo -e "${RED}Error: No se pudo descargar WordPress tras $WP_DL_RETRIES intentos${NC}"
        echo -e "${YELLOW}   Posibles soluciones:${NC}"
        echo -e "${YELLOW}   - Detener otros proyectos: ddev poweroff${NC}"
        echo -e "${YELLOW}   - Aumentar memoria de WSL2 en .wslconfig${NC}"
        echo -e "${YELLOW}   - Descargar manualmente: cd $PROJECT_DIR && ddev wp core download --locale=$WP_LOCALE${NC}"
        exit 1
    fi

    # Instalar WordPress
    echo ""
    echo -e "${YELLOW}6. Instalando WordPress...${NC}"
    echo -e "${YELLOW}   Título: $WP_TITLE${NC}"
    echo -e "${YELLOW}   Admin: $WP_ADMIN_USER ($WP_ADMIN_EMAIL)${NC}"
    echo ""

    read -s -p "Introduce la contraseña del administrador: " WP_ADMIN_PASS
    echo ""

    if [ -z "$WP_ADMIN_PASS" ]; then
        echo -e "${RED}Error: La contraseña no puede estar vacía${NC}"
        exit 1
    fi

    if ddev wp core install \
        --url="\$DDEV_PRIMARY_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --admin_password="$WP_ADMIN_PASS"; then
        echo -e "${GREEN}   ✓ WordPress instalado correctamente${NC}"
    else
        echo -e "${YELLOW}   ⚠ No se pudo instalar WordPress automáticamente.${NC}"
        echo -e "${YELLOW}   Puedes completar la instalación desde el navegador con: ddev launch${NC}"
    fi

    # Actualizar traducciones
    echo ""
    echo -e "${YELLOW}7. Actualizando traducciones...${NC}"
    if ddev wp language core update 2>/dev/null; then
        echo -e "${GREEN}   ✓ Traducciones actualizadas${NC}"
    else
        echo -e "${YELLOW}   ⚠ No se pudieron actualizar las traducciones (no crítico)${NC}"
    fi

    WP_ALREADY_STARTED=true

else
    echo ""
    echo -e "${YELLOW}4. Proyecto solo PHP seleccionado, se omite clonado de FS-Framework.${NC}"
fi

# Verificar estructura
echo ""
echo -e "${YELLOW}Estructura del proyecto:${NC}"
ls -la

echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  ¡Proyecto creado exitosamente!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

if [ "$PROJECT_TYPE" = "wordpress" ]; then
    echo -e "Tipo: ${YELLOW}WordPress ($WP_LOCALE)${NC}"
    echo -e "Base de datos: ${YELLOW}$DB_LABEL${NC}"
    echo -e "Admin: ${YELLOW}$WP_ADMIN_USER ($WP_ADMIN_EMAIL)${NC}"
    echo ""
    echo -e "Comandos útiles de WordPress:"
    echo -e "  ${YELLOW}ddev launch${NC}                          → Abrir el sitio en el navegador"
    echo -e "  ${YELLOW}ddev launch /wp-admin${NC}                → Abrir el panel de administración"
    echo -e "  ${YELLOW}ddev wp plugin install <plugin> --activate${NC} → Instalar un plugin"
    echo -e "  ${YELLOW}ddev wp theme activate <tema>${NC}        → Activar un tema"
    echo -e "  ${YELLOW}ddev wp core update${NC}                  → Actualizar WordPress"
    echo -e "  ${YELLOW}ddev xdebug on${NC}                      → Activar depuración XDebug"
    echo -e "  ${YELLOW}ddev snapshot${NC}                        → Crear punto de restauración"
else
    echo -e "Para iniciar el proyecto:"
    echo -e "  ${YELLOW}cd $PROJECT_NAME${NC}"
    echo -e "  ${YELLOW}ddev start${NC}"
fi

echo -e ""
if [ "$PROJECT_NEEDS_DB" = true ]; then
    if [ "$DB_ENGINE" = "mariadb" ]; then
        echo -e "Panel de base de datos: ${YELLOW}phpMyAdmin${NC}"
    else
        echo -e "Panel de base de datos: ${YELLOW}pgAdmin${NC}"
    fi
else
    echo -e "Panel de base de datos: ${YELLOW}no instalado${NC}"
fi

if [ "$WP_ALREADY_STARTED" = true ]; then
    echo ""
    echo -e "${GREEN}DDEV ya está en ejecución.${NC}"
    echo ""
    read -p "¿Quieres abrir WordPress en el navegador con ddev launch? (s/n): " LAUNCH_NOW

    case "$LAUNCH_NOW" in
        s|S|si|SI|Si|sí|SÍ|Sí)
            echo -e "${YELLOW}Abriendo WordPress...${NC}"
            ddev launch
            ;;
        *)
            echo -e "${YELLOW}Puedes abrirlo luego con: ddev launch${NC}"
            ;;
    esac
else
    echo ""
    read -p "¿Quieres iniciar el proyecto ahora con ddev start? (s/n): " START_NOW

    case "$START_NOW" in
        s|S|si|SI|Si|sí|SÍ|Sí)
            echo -e "${YELLOW}Iniciando proyecto con ddev...${NC}"
            if ddev start; then
                echo -e "${GREEN}   ✓ Proyecto iniciado correctamente${NC}"
            else
                echo -e "${YELLOW}   ⚠ No se pudo iniciar automáticamente con ddev start${NC}"
                echo -e "${YELLOW}   Inténtalo manualmente dentro del proyecto.${NC}"
            fi
            ;;
        *)
            echo -e "${YELLOW}Inicio automático omitido.${NC}"
            ;;
    esac
fi

echo ""
