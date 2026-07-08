# Clasificación Digital de Mariposas con Redes Neuronales en MATLAB 

Este proyecto implementa un sistema inteligente de procesamiento digital de imágenes enfocado en la clasificación automatizada de especímenes de mariposas a partir de una imagen compuesta. 

El sistema utiliza una arquitectura clásica de **Extracción de Características (Feature Extraction)** combinada con una **Red Neuronal Artificial Prealimentada (`patternnet`)** y cuenta con una interfaz gráfica funcional para el usuario.

---

###  Metodología del Procesamiento
El script segmenta la imagen original en sub-regiones y extrae un vector de características híbrido por cada elemento:
1. **Descriptor de Color:** Histograma normalizado de los canales H, S y V (Espacio de color HSV).
2. **Descriptor de Textura:** Características de Patrones Binarios Locales (**LBP**) adaptadas a una escala fija.
3. **Descriptor de Forma:** Extracción geométrica del área y la excentricidad del espécimen mediante binarización adaptativa y `regionprops`.

---

###  Requisitos y Tecnologías
* **Entorno:** MATLAB (Recomendado R2021a o superior)
* **Toolboxes necesarios:**
  * *Image Processing Toolbox*
---

###  Cómo Ejecutar el Proyecto
1. Clona o descarga este repositorio.
2. Asegúrate de tener la imagen de prueba `prueba_descrip.png` en el mismo directorio.
3. Ejecuta el script principal de entrenamiento o abre el archivo de la interfaz gráfica (`.fig` o `.mlapp`) desde MATLAB.

---
📩 **Contacto:** Elizabeth Muñoz Buitrón
