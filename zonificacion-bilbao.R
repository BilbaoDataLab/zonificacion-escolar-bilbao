# Script para imprimir mapas de zonificación escolar para cada centro escolar de Bilbao
# Se distinguen dos zonas para cada centor, la de máxima puntuación (5 puntos) y las limítrofes (2 puntos)
# Las zonas han sido compuestas a partir de las secciones censales y los distritos.
# Los distritos han sido dibujados a partir de la agregación de los barrios que los componen (al no encontrarse disponible los contornos de barrios)
# TODO: por hacer las zonas escolares definidas por calles.
# Para más información: https://wiki.bilbaodatalab.org/educacion

# Instala y carga librerías
library(tidyverse)
library(ggmap)
library(rgdal)
# library(dplyr)

# ------ Carga datos ------
# Carga relación de centros escolares y zonas
centros <- read.delim("data/centros-zonas.csv",sep = ",")
# Carga contornos de zonas escolares
zonas <- readOGR("data/zonificacion-escolar-bilbao.geojson")

levels(zonas@data$SEC_PROV_D)
levels(centros$zona)

# ------ Plot map con todas las zonas ------
ggplot() +
  geom_path(data=zonas,aes(x=long, y=lat,group=group), colour="black",size = 0.1) +
  # geom_polygon(data = zonas[zonas@data$SEC_PROV_D =="430601-ABANDO", ], 
               # aes(x = long, y = lat, group = group), 
               # color = "black", alpha = 0.3, size = 0.05) +
  theme_nothing(legend = TRUE) +
  theme(legend.position="bottom",
        plot.title = element_text(size=16),
        legend.text=element_text(size=12))

# ------------ Dibuja zonas de un centro --------------
centro_select <- "014105 - CEIP Artatse HLHI"
centros[centros$centro == centro_select,]

# Save image
png(filename=paste("images/",centro_select,".png", sep = ""),width = 600,height = 450)
ggplot() +
  # rellena regiones con valor max
  geom_polygon(data = zonas[zonas@data$SEC_PROV_D %in% centros[centros$centro == centro_select & centros$puntos == "max","zona"], ],
            aes(x=long, y=lat,group=group), fill="orange",size = 0.1) +
  # rellena regiones con valor min
  geom_polygon(data = zonas[zonas@data$SEC_PROV_D %in% centros[centros$centro == centro_select & centros$puntos == "min","zona"], ],
               aes(x=long, y=lat,group=group), fill="orange", alpha=0.3,size = 0.1) +
  # dibuja contornos de todas las zonas
  geom_path(data=zonas,aes(x=long, y=lat,group=group), colour="black",size = 0.1) +
  theme_minimal(base_family = "Roboto Condensed", base_size = 12) +
  theme(
    panel.grid.minor.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.text.x=element_blank(),
    axis.text.y=element_blank()
  ) +
  labs(title=paste("Zonificación escolar para",centro_select),
     subtitle = "",
     x = "",
     y = "",
     caption = "Zonificación escolar en Bilbao. Bilbao Data Lab")
# close save image
dev.off()

# ------- Plot zonas de todos los centros -------------------
centros_list <- levels(centros$centro)

for (i in 1:length(centros_list)) {
  # Zonas de un centro
  centro_select <- centros_list[i]
  print(i)
  print(centro_select)
  
  # Save image
  png(filename=paste("images/",centro_select,".png", sep = ""),width = 600,height = 500)
  p <- ggplot() +
    # rellena regiones con valor max
    geom_polygon(data = zonas[zonas@data$SEC_PROV_D %in% centros[centros$centro == centro_select & centros$puntos == "max","zona"], ],
                 aes(x=long, y=lat,group=group), fill="orange",size = 0.1) +
    # rellena regiones con valor min
    geom_polygon(data = zonas[zonas@data$SEC_PROV_D %in% centros[centros$centro == centro_select & centros$puntos == "min","zona"], ],
                 aes(x=long, y=lat,group=group), fill="orange", alpha=0.3,size = 0.1) +
    # dibuja contornos de todas las zonas
    geom_path(data=zonas,aes(x=long, y=lat,group=group), colour="black",size = 0.1) +
    theme_minimal(base_family = "Roboto Condensed", base_size = 12) +
    theme(
      panel.grid.minor.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.text.x=element_blank(),
      axis.text.y=element_blank()
    ) +
    labs(title=paste("Zonificación escolar para",centro_select),
         subtitle = "",
         x = "",
         y = "",
         caption = "Zonificación escolar en Bilbao. Bilbao Data Lab")
  print(p) 
  # close save image
  dev.off()
}