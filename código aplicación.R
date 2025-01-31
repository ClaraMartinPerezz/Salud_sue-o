install.packages("dplyr")
library(dplyr)


#Lectura de los datos de un csv
datos <- read.csv("base1.csv")
head(datos) 


#PREPARACIÓN DE LA BASE DE DATOS

#Comprobación de que no hay valores nulos
sum(is.na(datos))


# Modificación de la columna Presion.arterial, obteniendo una nueva con la media 
datos_media <- cbind(datos, do.call("rbind", strsplit(as.character(datos$Presion.arterial), "/")))
names(datos_media)[(ncol(datos_media)-1):ncol(datos_media)]<- c("systolic", "diastolic")
datos_media$systolic <- as.integer(datos_media$systolic)
datos_media$diastolic <- as.integer(datos_media$diastolic)

datos2 <- datos_media %>%
  mutate(Presion.arterial = (systolic + diastolic) / 2)

#Recodificación de la columna Categoria.BMI
table(datos2$Categoria.BMI)
datos2 <- datos2 %>%
  mutate(Categoria.BMI = recode(Categoria.BMI,
                               "Normal" = "Peso normal", "Normal Weight" = "Peso normal", 
                               "Overweight"= "Sobrepeso", "Obese"= "Obeso"))


#Recodificación de la columna Sexo; 
table(datos2$Sexo)
datos2 <- datos2 %>%
  mutate(Sexo = recode(Sexo,"Male" = "Hombre", "Female" = "Mujer"))


#Recodificación de la columna Trastorno.sueño; 
table(datos2$Trastorno.sueno)
datos2 <- datos2 %>%
  mutate(Trastorno.sueno = recode(Trastorno.sueno,"None" = "Ninguno", "Insomnia" = "Insomnio",
                                  "Sleep Apnea" = "Apnea del sueño"))


#Eliminación de las columnas que no son necesarias para el estudio
datos2 <- subset(datos2, select = -Person.ID)
datos2<- subset(datos2, select = -systolic)
datos2<- subset(datos2, select = -diastolic)
datos2<- subset(datos2, select = -Occupation)


#División en 2 dataframes distintos
x1 <- select_if(datos2, is.numeric) #dataframe que contiene las variables numéricas 
x2<- select_if(datos2, is.character) #dataframe que contiene las variables categóricas
x1 <- as.data.frame(x1)
x2<- as.data.frame(x2)



install.packages("e1071")
library(e1071)

#ANÁLISIS DESCRIPTIVO de x1

#Cálculo del mínimo, máximo, media, mediana, primer y tercer cuartil de todas las variables
summary(x1)

#Cálculo de la desviación típica de las variables
sapply(x1,sd) 

#Cálculo del coeficiente de asimetría de Pearson de las variables
sapply(x1,skewness)

#Comprobación de la existencia de valores atípicos
boxplot(x1$Edad)
boxplot(x1$Duracion.sueno)
boxplot(x1$Calidad.sueno)
boxplot(x1$Actividad.fisica)
boxplot(x1$Nivel.estres)
boxplot(x1$Ritmo.cardiaco, main = 'Ritmo cardíaco' )
boxplot(x1$Pasos)
boxplot(x1$Presion.arterial)


#Estandarización de los datos
x1 <- scale(x1)


#Cálculo de la matriz de correlaciones
install.packages("corrplot")
library(corrplot)

matriz_corr<-cor(x1)
print(matriz_corr) 


#Representación gráfica de la matriz de correlaciones
corrplot(matriz_corr, method = "color", type = "lower",
         tl.col = 'black', main = "Correlaciones entre variables")


# ANÁLISIS DESCRIPTIVO de x2

# Cálculo de frecuencias absolutas para todas las variables
frec_abs <- lapply(x2, table)
print(frec_abs)


# Cálculo de frecuencias relativas para todas las variables
frec_rel <- lapply(x2, function(x) prop.table(table(x)))
print(frec_rel)


#Cálculo de tablas de contingencia 
table(x2$Sexo, x2$Categoria.BMI)
table(x2$Sexo, x2$Trastorno.sueno)
table(x2$Trastorno.sueno, x2$Categoria.BMI)





#Aplicación de PCA: 
install.packages("factoextra")
library(factoextra)

#PCA de la base de datos
pca<-prcomp(x1)


# Extracción de la matriz de puntuaciones de las componentes principales
pca_puntuaciones<- pca$x


# Cálculo de la matriz de correlación entre las componentes principales
matriz_corrPCA <- cor(pca_puntuaciones)
print(matriz_corrPCA)

corrplot(matriz_corrPCA, method = "color", type = "lower",
         tl.col = 'black', main = "Correlaciones entre variables")


#Desviación típica, varianza explicada y varianza explicada acumulada de cada una de las pc
summary(pca) 


#Valores propios de cada una de las pc
pca$sdev^2

#Cálculo de matriz de cargas
print(pca)


library(cli)

# Representación de las puntuaciones en el espacio de las 2 primeras componentes
p <- fviz_pca_ind(pca, geom.ind = c("text"), 
                  col.ind = "orange", 
                  axes = c(1, 2), 
                  labelsize = 3) + 
  ggtitle("PCA - Individuos")

# Añadir círculos para los diferentes grupos
p + 
  annotate("path",
           x = c(-1, 0.5, 0.5, -1, -1), 
           y = c(-1, -1, 0.5, 0.5, -1),
           color = "red", size = 1) +  
  
  annotate("path",
           x = c(-2.6, -1.5, -1.5, -2.6, -2.6), 
           y = c(2, 2, 4, 4, 2),
           color = "red", size = 1) +  

  annotate("path",
           x = c(2, 4, 4, 2, 2), 
           y = c(0.5, 0.5, 2.2, 2.2, 0.5),
           color = "red", size = 1) +  
  annotate("path",
           x = c(2, 4, 4, 2, 2), 
           y = c(-2, -2, -1, -1, -2),
           color = "red", size = 1) +  
  annotate("path",
           x = c(-4, -1.3, -1.3, -4, -4), 
           y = c(-2, -2, -0.2, -0.2, -2),
           color = "red", size = 1)    




#Aplicación de CDPCA:

install.packages("biplotbootGUI")
library(biplotbootGUI)


# CDPCA sobre la base de datos y representación gráfica
cdpca <- CDpca(data = x1, P = 5, Q = 2, maxit = 100, r = 10) 

  
#Número de observaciones perteneciente a cada cluster
U <- cdpca$U  
cluster_counts <- colSums(U)
print(cluster_counts)

#Cálculo de porcentajes: 
porcentajes_cluster <- cluster_counts / 374 * 100
porcentajes_cluster <- round(porcentajes_cluster, 2)
print(porcentajes_cluster)


# Cálculo del número óptimo de clusters usando el método del codo
fviz_nbclust(x1, kmeans, method = "wss") + 
  geom_vline(xintercept = 5, linetype = 2) + 
  labs(title = "Número óptimo de clusters", subtitle = "Método del codo")



#Aplicación de RPCA:

install.packages("rpca")
library(rpca)


#Conversión del dataframe a una matriz numérica
x1_matriz <- as.matrix(x1)


#RPCA de la base de datos
rpca <- rpca(x1_matriz)


# Obtención la matriz de bajo rango L y la matriz dispersa E
L <- rpca$L
E <- rpca$S
print(E) #se observa que es dispersa


# Visualización de la aproximación a la matriz original
cat("\nAproximación de la matriz original (L + E):\n")
print(L + E)
print(x1) 


#PCA sobre la matriz de bajo rango L
pca_robusto <- prcomp(L, center = TRUE, scale. = TRUE)


#desviación típica, varianza explicada y varianza explicada acumulada de cada una de las pc
summary(pca_robusto)


# Visualización de las puntuaciones sobre el espacio de las componentes principales 
fviz_pca_ind(pca_robusto, geom.ind = c("text"), 
             col.ind = "orange", 
             axes = c(1, 2), 
             labelsize = 3) + ggtitle("RPCA - Individuos") 


# Comparación de los pesos de  las componentes (PCA-RPCA)
pca_cargas <- data.frame(pca$rotation)
rpca_cargas <- data.frame(pca_robusto$rotation)


variables <- c("Edad", "Duracion.sueno", "Calidad.sueno", 
               "Actividad.fisica", "Nivel.estres", "Presión arterial", "Ritmo.cardiaco", 
               "Pasos")


par(mfrow = c(1, 2), mar = c(8, 4, 4, 2) + 0.1) 

# Gráfico comparación de las cargas de la primera componente
bar_positions <- barplot(pca_cargas[, 1], main = "PCA - Cargas de PC1", 
                         ylab = "Cargas", col = "blue", 
                         ylim = c(min(pca_cargas[, 1], rpca_cargas[, 1]), 
                                  max(pca_cargas[, 1], rpca_cargas[, 1])))

axis(side = 1, at = bar_positions, labels = FALSE)
text(x = bar_positions, y = par("usr")[3] - 0.05, labels = variables, 
     srt = 90, adj = 1, xpd = TRUE, cex = 0.8)


bar_positions <- barplot(rpca_cargas[, 1], main = "RPCA - Cargas de PC1",
                         ylab = "Cargas", col = "red",
                         ylim = c(min(pca_cargas[, 1], rpca_cargas[, 1]),
                                  max(pca_cargas[, 1], rpca_cargas[, 1])))

axis(side = 1, at = bar_positions, labels = FALSE)
text(x = bar_positions, y = par("usr")[3] - 0.05, labels = variables, 
     srt = 90, adj = 1, xpd = TRUE, cex = 0.8)


# Gráfico comparación de las cargas de la segunda componente

bar_positions <- barplot(pca_cargas[, 2], main = "PCA - Cargas de PC2", 
                         ylab = "Cargas", col = "blue", 
                         ylim = c(min(pca_cargas[, 1], rpca_cargas[, 1]),
                                  max(pca_cargas[, 1], rpca_cargas[, 1])))

axis(side = 1, at = bar_positions, labels = FALSE)
text(x = bar_positions, y = par("usr")[3] - 0.05, labels = variables, 
     srt = 90, adj = 1, xpd = TRUE, cex = 0.8)

bar_positions <- barplot(rpca_cargas[, 2], main = "RPCA - Cargas de PC2", 
                         ylab = "Cargas", col = "red", 
                         ylim = c(min(pca_cargas[, 1], rpca_cargas[, 1]),
                                  max(pca_cargas[, 1], rpca_cargas[, 1])))

axis(side = 1, at = bar_positions, labels = FALSE)
text(x = bar_positions, y = par("usr")[3] - 0.05, labels = variables, 
     srt = 90, adj = 1, xpd = TRUE, cex = 0.8)





# Aplicación de PCAMIX:

install.packages("PCAmixdata")
library(PCAmixdata)

#PCAMIX sobre la base de datos 
pcamix<- PCAmix(X.quanti = x1, X.quali = x2, 
                    rename.level = TRUE, graph = FALSE)

#Valores propios, % de varianza explicada y % de varianza explicada acumulada  de las pc
pcamix$eig 

#cargas de las variables en la componentes
pcamix$coef

#representación de los individuos sobre el espacio de las componentes
par(mfrow = c(1, 1))  

x2$Sexo <- as.factor(x2$Sexo)
print(x2$Sexo)
str(x2$Sexo)
plot(pcamix, choice = "ind", coloring.ind = x2$Sexo, label = FALSE,
     posleg = "bottomright", leg = FALSE,  main = '')
legend("bottomright", legend = c("Mujer", "Hombre"), 
       col = c("black", "red"), pch = 16, title = "Sexo", bg = "white", cex = 0.8, text.col = "black")




#Aplicación de PC Regression: 

install.packages("pls")
library(pls)


x1 <- as.data.frame(x1)


# Definición de la variable dependiente y las variables regresoras
y <- x1$Nivel.estres
X <- subset(x1, select = -Nivel.estres)


# División de los datos en conjuntos de entrenamiento y prueba

set.seed(123) 
indices_entrenamiento <- sample(1:nrow(x1), 0.7*nrow(x1)) 
datos_entrenamiento <- x1[indices_entrenamiento, ]
datos_prueba <- x1[-indices_entrenamiento, ]

y_prueba <- datos_prueba$Nivel.estres
X_prueba <- subset(datos_prueba, select = -Nivel.estres)


# Ajuste del modelo PCR utilizando validación cruzada para determinar el número óptimo de PC
pcr_model <- pcr(Nivel.estres ~ ., data = datos_entrenamiento, scale = TRUE, validation = "LOO")


# Resumen del modelo
summary(pcr_model)


#Selección del número óptimo de componentes principales
validationplot(pcr_model, val.type = "MSEP")


#Coeficientes de regresión (son los de las variables originales)
coeficientes <- coef(pcr_model, ncomp = 2)


# Predicciones en el conjunto de prueba
predictions <- predict(pcr_model, X_prueba, ncomp = 2)


# Calculamos el error de predicción 
error_prediccion <- sqrt(mean((y_prueba - predictions)^2))
error_prediccion 




