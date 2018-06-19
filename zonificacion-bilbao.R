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
library(gsubfn) # select text in the parenthesis with regex
library(OpenStreetMap)

# ------ Carga datos ------
# Carga relación de centros escolares y zonas
centros_zonas <- read.delim("data/centros-zonas.csv",sep = ",")

# Locacalización centros escolares
# centros_loc2 <- read.delim("data/centros-escolares-bilbao.csv",sep = ",")
centros_loc <- readOGR("data/centros-escolares-bilbao.geojson")

# Carga contornos de zonas escolares
zonas <- readOGR("data/zonificacion-escolar-bilbao.geojson")
distritos <- readOGR("data/distritos-bilbao.geojson")
ria <- readOGR("data/ria.geojson")

levels(zonas@data$SEC_PROV_D)
levels(centros_zonas$zona)

# ---- Prepara datos ------

# Crea campo de listado centros zonas con nombre limpio y en mayúsculas, para que coincida con listado de centros
centros_zonas$centro_sin <- toupper(strapplyc( as.character(centros_zonas$centro), "[0-9]* - (.*)", simplify = TRUE))

# Crea campo con el nº identificador de cada centro
centros_zonas$centro_code <- strapplyc( as.character(centros_zonas$centro), "([0-9]*) - .*", simplify = TRUE)
centros_zonas$centro_code <- as.factor(centros_zonas$centro_code)

# Preparar data frame con ubiación de centros escolares 
centros_df <- as.data.frame(centros_loc)
names(centros_df)[6:7] <- c("lon","lat")

# Guarda solamente los centros escolares (y no muestra los centros administrativos (3) o centros de apoyo(10))
# centros_df <- centros_df[centros_df$Zentro_mot=="Ikastetxea / Centro escolar",]
# Guarda solamente
centros_df <- centros_df[centros_df$EAEKOD_COD %in% levels(centros_zonas$centro_code),]

# ------ Plot map con todas las zonas y centros escolares ------
png(filename=paste("images/centros_zonas-escolares_distritos-bilbao.png", sep = ""),width = 600,height = 450)
ggplot() +
  # dibuja distritos
  geom_path(data=distritos,aes(x=long, y=lat,group=group), colour="orange",size = 1) +
  geom_path(data=zonas,aes(x=long, y=lat,group=group), colour="black",size = 0.1) +
  # geom_polygon(data = zonas[zonas@data$SEC_PROV_D =="430601-ABANDO", ], aes(x = long, y = lat, group = group), color = "black", alpha = 0.3, size = 0.05) +
  # dibuja puntos de centros escolares
  geom_point(data=centros_df,aes(x=lon, y=lat),size = 0.05) +
  theme_nothing(legend = TRUE) +
  theme(legend.position="bottom",
        plot.title = element_text(size=16),
        legend.text=element_text(size=12))
# close save image
dev.off()

# ------------ Dibuja zonas de un centro --------------
centro_select <- "015360 - CEIP Miribilla HLHI"
centro_select_name <- toupper(strapplyc( centro_select, "[0-9]* - (.*)", simplify = TRUE))
centro_select_code <- strapplyc( centro_select, "([0-9]*) - .*", simplify = TRUE)
# centros_zonas[centros_zonas$centro == centro_select,]

# check projection of map
proj4string(distritos)

# Descarga base cartográfica
map <- openmap(c(lat = 43.26596 + 0.027, lon = -2.93141  - 0.09), 
               c(lat = 43.26596 - 0.065, lon = -2.93141 + 0.055),
              type = "osm") # fuerza mayor número de tiles descargados: minNumTiles=9
mapLatLon <- openproj(map, projection = "+proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs" )
# Ejemplo de mapa sencillo
# g <- autoplot(mapLatLon)
# g <- g + geom_path(data=distritos,aes(x=long, y=lat,group=group), 
#                    colour="red",alpha=0.6,size = 2) # linetype="dotted"

# Save image
# png(filename=paste("images/base-cartografica/",centro_select,"_osm_gg.png", sep = ""),width = 6400,height = 4800)
png(filename=paste("images/base-cartografica/",centro_select,"_osm.png", sep = ""),width = 1600,height = 1200)
# ggplot() +
  # añade base cartográfica
  autoplot(mapLatLon) +
  # dibuja distritos
  geom_path(data=distritos,aes(x=long, y=lat,group=group), colour="grey",alpha=0.6,size = 2) + # linetype="dotted"
  # rellena regiones con valor max
  geom_polygon(data = zonas[zonas@data$SEC_PROV_D %in% centros_zonas[centros_zonas$centro == centro_select & centros_zonas$puntos == "max","zona"], ],
            aes(x=long, y=lat,group=group), fill="orange",alpha=0.8,size = 0.1) +
  # rellena regiones con valor min
  geom_polygon(data = zonas[zonas@data$SEC_PROV_D %in% centros_zonas[centros_zonas$centro == centro_select & centros_zonas$puntos == "min","zona"], ],
               aes(x=long, y=lat,group=group), fill="orange", alpha=0.3,size = 0.1) +
  # dibuja contornos de todas las zonas
  geom_path(data=zonas,aes(x=long, y=lat,group=group), colour="black",size = 0.1) +
  # dibuja puntos de centros escolares
  geom_point(data=centros_df,aes(x=lon, y=lat),size = 0.05) +
  # Ría
  geom_polygon(data = ria, aes(x=long, y=lat,group=group), fill="#00aeef", alpha=0.4,size = 0.1) +
  # dibuja punto de centro destacado
  geom_point(data=centros_df[centros_df$EAEKOD_COD==centro_select_code,],aes(x=lon, y=lat),size = 3,color="red") +
  geom_point(data=centros_df[centros_df$EAEKOD_COD==centro_select_code,],aes(x=lon, y=lat),size = 3,color="black",shape=3) +
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
centros_list <- levels(centros_zonas$centro)

for (i in 1:length(centros_list)) {
  # Zonas de un centro
  centro_select <- centros_list[i]
  centro_select_name <- toupper((strapplyc( centro_select, "[0-9]* - (.*)", simplify = TRUE)))
  centro_select_code <- strapplyc( centro_select, "([0-9]*) - .*", simplify = TRUE)
  # elimina espacios del nombre
  centro_select_clean <- str_replace_all(centro_select, pattern=" - ", repl="-")
  centro_select_clean <- str_replace_all(centro_select_clean, pattern=" ", repl="-")
  
  print(i)
  print(centro_select)
  
  # Save image
  png(filename=paste("images/",centro_select_clean,".png", sep = ""),width = 720,height = 600)
  p <- ggplot() +
    # dibuja distritos
    geom_path(data=distritos,aes(x=long, y=lat,group=group), colour="grey",alpha=0.6,size = 2) + # linetype="dotted"
    # rellena regiones con valor max
    geom_polygon(data = zonas[zonas@data$SEC_PROV_D %in% centros_zonas[centros_zonas$centro == centro_select & centros_zonas$puntos == "max","zona"], ],
                 aes(x=long, y=lat,group=group), fill="orange", alpha=0.8,size = 0.1) +
    # rellena regiones con valor min
    geom_polygon(data = zonas[zonas@data$SEC_PROV_D %in% centros_zonas[centros_zonas$centro == centro_select & centros_zonas$puntos == "min","zona"], ],
                 aes(x=long, y=lat,group=group), fill="orange", alpha=0.3,size = 0.1) +
    # dibuja contornos de todas las zonas
    geom_path(data=zonas,aes(x=long, y=lat,group=group), colour="black",size = 0.1) +
    # dibuja puntos de centros escolares
    geom_point(data=centros_df,aes(x=lon, y=lat),size = 0.05) +
    # Ría
    geom_polygon(data = ria, aes(x=long, y=lat,group=group), fill="#00aeef", alpha=0.4,size = 0.1) +
    # dibuja punto de centro destacado
    geom_point(data=centros_df[centros_df$EAEKOD_COD==centro_select_code,],aes(x=lon, y=lat),size = 3,color="red") +
    geom_point(data=centros_df[centros_df$EAEKOD_COD==centro_select_code,],aes(x=lon, y=lat),size = 3,color="black",shape=3) +
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
