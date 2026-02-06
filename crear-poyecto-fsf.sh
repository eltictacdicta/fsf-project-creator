#!/bin/bash

# Script para crear un nuevo proyecto con DDEV y FS-Framework

# Colores para输出的
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  Nuevo Proyecto con DDEV y FS-Framework${NC}"
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

# Pedir el nombre del proyecto
read -p "Introduce el nombre del proyecto (ej: proyecto-nuevo): " PROJECT_NAME

# Validar que se ha introducido un nombre
if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Error: Debes proporcionar un nombre de proyecto${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Creando proyecto: $PROJECT_NAME${NC}"
echo ""

# Obtener el directorio actual
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
echo -e "${YELLOW}2. Configurando DDEV con PHP 8.3...${NC}"
ddev config --php-version 8.3

if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✓ DDEV configurado correctamente${NC}"
else
    echo -e "${RED}Error: Error al configurar DDEV${NC}"
    exit 1
fi

# Clonar el repositorio
echo ""
echo -e "${YELLOW}3. Clonando FS-Framework...${NC}"
git clone https://github.com/eltictacdicta/fs-framework.git

if [ ! -d "fs-framework" ]; then
    echo -e "${RED}Error: No se pudo clonar el repositorio${NC}"
    exit 1
fi

echo -e "${GREEN}   ✓ Repositorio clonado${NC}"

# Mover el contenido de fs-framework a la raíz
echo ""
echo -e "${YELLOW}4. Moviendo archivos de fs-framework a la raíz...${NC}"
mv fs-framework/* .
mv fs-framework/.* . 2>/dev/null || true

echo -e "${GREEN}   ✓ Archivos movidos${NC}"

# Borrar la subcarpeta fs-framework
echo ""
echo -e "${YELLOW}5. Borrando subcarpeta fs-framework...${NC}"
rm -rf fs-framework

echo -e "${GREEN}   ✓ Subcarpeta eliminada${NC}"

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
echo ""
