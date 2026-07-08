clear; clc; close all;

%--- Cargar imagen con múltiples mariposas ---
img = imread('prueba_descrip.png');
figure; imshow(img); title('Imagen Original');

%--- Parámetros de partición ---
filas = 3; columnas = 4;
alto = size(img,1) / filas;
ancho = size(img,2) / columnas;
num_muestras = filas * columnas;

%--- Definir tamaños de descriptores ---
tam_color = 16 * 3;

% Calcular tamaño real de LBP usando un ejemplo redimensionado
ejemplo = rgb2gray(imresize(img(1:round(alto), 1:round(ancho), :), [128 128]));
tam_lbp = length(extractLBPFeatures(ejemplo, 'CellSize', [32 32]));

tam_forma = 2;
tam_total = tam_color + tam_lbp + tam_forma;

%--- Inicializar matriz de características y etiquetas ---
X = zeros(num_muestras, tam_total);
Y = (1:num_muestras)';  % Cada mariposa es una clase

%--- Loop para extraer cada mariposa y calcular descriptores ---
k = 1;
for i = 1:filas
    for j = 1:columnas
        x1 = round((j-1)*ancho + 1);
        y1 = round((i-1)*alto + 1);
        x2 = round(j*ancho);
        y2 = round(i*alto);

        recorte = img(y1:y2, x1:x2, :);
        recorte_gray = rgb2gray(recorte);

        %--- COLOR: Histograma HSV ---
        hsv = rgb2hsv(recorte);
        h_hist = imhist(hsv(:,:,1), 16);
        s_hist = imhist(hsv(:,:,2), 16);
        v_hist = imhist(hsv(:,:,3), 16);
        color_descriptor = [h_hist; s_hist; v_hist]';
        color_descriptor = color_descriptor / sum(color_descriptor);

        %--- TEXTURA: LBP con tamaño fijo ---
        recorte_gray_resized = imresize(recorte_gray, [128 128]);
        lbp = extractLBPFeatures(recorte_gray_resized, 'CellSize', [32 32]);

        %--- FORMA: área y excentricidad ---
        bw = imbinarize(recorte_gray, 'adaptive');
        bw = imfill(bw, 'holes');
        bw = bwareafilt(bw, 1); % solo el objeto mayor
        props = regionprops(bw, 'Area', 'Eccentricity');
        if isempty(props)
            forma = [0, 0];
        else
            forma = [props.Area, props.Eccentricity];
        end

        %--- Concatenar descriptores ---
        X(k,:) = [color_descriptor, lbp, forma];
        k = k + 1;
    end
end

%--- Normalizar características ---
X = normalize(X);

%--- Red neuronal ---
net = patternnet(10);
net.trainParam.showWindow = true;

% Entrenar (Y a codificación one-hot)
net = train(net, X', dummyvar(Y)');

%--- Predicción y evaluación ---
Y_pred = net(X');
[~, clase_predicha] = max(Y_pred);

accuracy = sum(clase_predicha' == Y) / num_muestras;
fprintf('✅ Precisión de clasificación: %.2f%%\n', accuracy * 100);

%--- Matriz de confusión ---
figure;
plotconfusion(dummyvar(Y)', Y_pred);
title('Matriz de Confusión');

%--- Guardar modelo ---
save('modelo_red_mariposas.mat', 'net', 'X', 'Y');
disp('✔ Modelo entrenado y guardado.');
