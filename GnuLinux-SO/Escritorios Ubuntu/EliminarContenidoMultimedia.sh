#!/bin/bash
# Definir un array con las extensiones multimedia a eliminar
# Uso: ./EliminarContenidoMultimedia.sh /ruta/al/directorio del/preserve

extensiones=("*.mp3" "*.mp4" "*.avi" "*.mkv" "*.flv" "*.mov" "*.wmv")
# el directerio se pasara como argumento al script
directorio="$1"

#Creamos variables para verificar el argumento, aceptamos ( del | preserve) directorio
# Verificar si se proporcionó un argumento
acciones="$2"
if [ -z "$acciones" ]; then
    echo "Por favor, proporciona un valor valido ( del - preserve )."
    exit 1
fi


# Verificar si se proporcionó un directorio
if [ -z "$directorio" ]; then
    echo "Por favor, proporciona un directorio."
    exit 1
fi

# Verificar si el directorio existe
if [ ! -d "$directorio" ]; then
    echo "El directorio '$directorio' no existe."
    exit 1
fi


function mostrarContedio() {
    for extension in "${extensiones[@]}"; do
        echo "Mostramos archivos encontrado extensión $extension en el directorio $directorio..."
        find "$directorio" -type f -name "$extension" -exec ls -l {} \;
    done
}   

function eliminamosContenido() {
    for extension in "${extensiones[@]}"; do
        echo "Eliminando archivos con extensión $extension en el directorio $directorio..."
        find "$directorio" -type f -name "$extension" -exec rm -f {} \;
    done
    echo "Eliminación completada."
}

#Verificamos cual es el contenido de la variable acciones
if [ "$acciones" == "del" ]; then
    eliminamosContenido

elif [ "$acciones" == "preserve" ]; then
    echo "Preservando contenido multimedia, no se eliminará nada."
    mostrarContedio
else
    echo "Acción no reconocida. Usa 'del' para eliminar o 'preserve' para mostrar."
    exit 1
fi

# Fin del script
