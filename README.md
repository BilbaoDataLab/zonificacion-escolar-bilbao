# Zonificación por centros escolares en Bilbao

El objetivo es crear el mapa de la zonificación escolar en Bilbao. 

Por increíble que parezca no existe un mapa de cómo se dibujan los contornos que sirven para asignar puntos para acceder a cada centro escolar. Hay una descripción en pdf de qué secciones censales y distritos corresponten a cada centro, hay una aplicación para calcular los puntos en base a una dirección, pero no existe el mapa.

Queremos analizar el sistema de zonas que tiene asignado cada centro para asignar lo puntos porcercanía a la hora de adjudicar las plazas escolares. El proyecto consite en dibujar las zonas de cada centro: una que asigna 5 puntos y otra que asigna 2 puntos.

Hace falta generar estos dos archivos de datos (ver carpeta /data):

- un archivo de contornos con el dibujo de las zonas. Realizado "a mano" sumando y uniendo y restando secciones censales y zonas con las calles.
- una tabla con tres columnas: zona | centro.  escolar | puntos (o baremo).

El script de R importa los contonos de las zonas, el listado que relaciona las zonas con los centros escolares y dibujar (ver /images) un mapa por cada centro escolar.

Más info https://wiki.bilbaodatalab.org/educacion#zonificacion_escolar_en_bilbao
