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

        # Si es solo el nombre, buscar el directorio
        if [ ! -d "$PROJECT_TO_DELETE" ]; then
            # Buscar en directorio actual
            if [ -d "$(pwd)/$PROJECT_TO_DELETE" ]; then
                PROJECT_PATH="$(pwd)/$PROJECT_TO_DELETE"
            # Buscar en la carpeta de nivel superior
            elif [ -d "$(dirname "$(pwd)")/$PROJECT_TO_DELETE" ]; then
                PROJECT_PATH="$(dirname "$(pwd)")/$PROJECT_TO_DELETE"
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
read -p "Elige una opción [1-2]: " PROJECT_TYPE_OPTION

case "$PROJECT_TYPE_OPTION" in
    1)
        PROJECT_TYPE="fs-framework"
        ;;
    2)
        PROJECT_TYPE="php"
        ;;
    *)
        echo -e "${RED}Error: Opción de tipo de proyecto no válida${NC}"
        exit 1
        ;;
esac

# Preguntar stack de base de datos
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

# Validar que se ha introducido un nombre
if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Error: Debes proporcionar un nombre de proyecto${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Creando proyecto: $PROJECT_NAME${NC}"
echo -e "${YELLOW}Tipo de proyecto: $PROJECT_TYPE${NC}"
echo -e "${YELLOW}Base de datos: $DB_LABEL${NC}"
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
echo -e "${YELLOW}2. Configurando DDEV con PHP 8.3 y ${DB_TYPE}...${NC}"
ddev config --php-version 8.3 --database "$DB_TYPE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✓ DDEV configurado correctamente${NC}"
else
    echo -e "${RED}Error: Error al configurar DDEV${NC}"
    exit 1
fi

# Instalar addon de administración de base de datos
echo ""
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
echo -e "Para iniciar el proyecto:"
echo -e "  ${YELLOW}cd $PROJECT_NAME${NC}"
echo -e "  ${YELLOW}ddev start${NC}"
echo -e ""
if [ "$DB_ENGINE" = "mariadb" ]; then
    echo -e "Panel recomendado: ${YELLOW}phpMyAdmin${NC}"
else
    echo -e "Panel recomendado: ${YELLOW}pgAdmin${NC}"
fi

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

echo ""
