# Clasificación Digital de Mariposas con Redes Neuronales en MATLAB 🦋

Este proyecto implementa un sistema inteligente de procesamiento digital de imágenes enfocado en la clasificación automatizada de especímenes de mariposas a partir de una imagen compuesta. 

El sistema utiliza una arquitectura clásica de **Extracción de Características (Feature Extraction)** combinada con una **Red Neuronal Artificial Prealimentada (`patternnet`)** y cuenta con una interfaz gráfica funcional para el usuario.

---

###  Metodología y Módulos del Procesamiento

El sistema se divide en dos fases técnicas principales:

#### 1. Extracción de Descriptores y Momentos Estadísticos (`extraccion_caracteristicas_color.m`)
Segmenta la imagen original en sub-regiones utilizando una rejilla paramétrica y extrae características de color avanzadas filtrando el fondo mediante binarización por canal de Valor ($V > 0.2$):
* **Tono Dominante:** Identificación del *Hue* predominante mediante análisis fino de histogramas (100 bins).
* **Momentos Estadísticos de Color:** Cálculo de descriptores matemáticos de **1º, 2º y 3º orden** (Media, Varianza y Sesgo/*Skewness*) aplicados de forma paralela en los espacios de color **RGB** y **HSV**.
* **Exportación de Datos:** Los vectores se consolidan de manera automática en una tabla indexada exportable a formatos `.xlsx` y `.mat`.

#### 2. Entrenamiento de la Red Neuronal (`entrenamiento_mariposas.m`)
* **Vector Híbrido:** Integración de los descriptores de color junto con descriptores de textura (**LBP - Patrones Binarios Locales**) y forma geométrica (`regionprops`).
* **Clasificación:** Entrenamiento de una arquitectura `patternnet` utilizando codificación *one-hot* (`dummyvar`), evaluando el desempeño mediante matrices de confusión y curvas de *accuracy*.

---

### 🛠️ Requisitos y Tecnologías
* **Entorno:** MATLAB (Recomendado R2021a o superior)
* **Toolboxes necesarios:**
  * *Image Processing Toolbox*
  * *Deep Learning Toolbox*

---

###  Cómo Ejecutar el Proyecto
1. Clona o descarga este repositorio.
2. Asegúrate de tener la imagen de prueba `prueba_descrip.png` en el mismo directorio de trabajo.
3. Ejecuta `extraccion_caracteristicas_color.m` para generar la base de datos de descriptores en Excel.
4. Ejecuta el script principal de entrenamiento o interactúa directamente con la interfaz gráfica (`.fig` o `.mlapp`).

---
📩 **Contacto:** Elizabeth Muñoz Buitrón
