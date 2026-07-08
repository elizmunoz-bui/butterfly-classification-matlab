% ----------------------------------------------
% EXTRACCIÓN DE CARACTERÍSTICAS DE COLOR DE IMAGEN REGIONAL
% ----------------------------------------------

% 1. Leer imagen completa
I = imread('prueba_descrip.png');
[alto, ancho, ~] = size(I);

% 2. Definir número de filas y columnas (para dividir la imagen)
n_filas = 3;
n_columnas = 4;

% 3. Calcular dimensiones de cada recorte
h = floor(alto / n_filas);
w = floor(ancho / n_columnas);

% 4. Inicializar variables
especies = {};
hues_dom = [];
porcentajes_dom = [];

media_HSV = [];
desv_HSV = [];
momentos_RGB = [];
momentos_HSV = [];

% 5. Recorrer cada recorte (mariposa)
k = 1;
for i = 1:n_filas
    for j = 1:n_columnas
        % --- 5.1 Recorte de región ---
        y1 = (i-1)*h + 1;
        y2 = min(i*h, alto);  % asegurarse que no sobrepase
        x1 = (j-1)*w + 1;
        x2 = min(j*w, ancho);
        recorte = I(y1:y2, x1:x2, :);
        
        % --- 5.2 Conversión a HSV ---
        hsv_img = rgb2hsv(recorte);
        hue = hsv_img(:,:,1);
        sat = hsv_img(:,:,2);
        val = hsv_img(:,:,3);
        
        % --- 5.3 Máscara para eliminar fondo negro ---
        mascara = val > 0.2;

        % --- 5.4 Histogramas y hue dominante ---
        hue_m = hue(mascara);
        num_bins = 100;
        [cuentas, edges] = histcounts(hue_m, num_bins);
        [~, idx_max] = max(cuentas);
        dominante = (edges(idx_max) + edges(idx_max+1)) / 2;
        porcentaje = (sum(hue_m >= edges(idx_max) & hue_m < edges(idx_max+1)) / numel(hue_m)) * 100;

        % --- 5.5 Estadísticas HSV ---
        mediaHSV = [mean(hue_m), mean(sat(mascara)), mean(val(mascara))];
        desvHSV = [std(hue_m), std(sat(mascara)), std(val(mascara))];

        % --- 5.6 Momentos RGB y HSV ---
        R = double(recorte(:,:,1)) / 255;
        G = double(recorte(:,:,2)) / 255;
        B = double(recorte(:,:,3)) / 255;

        r_mask = R(mascara);
        g_mask = G(mascara);
        b_mask = B(mascara);

        h_mask = hue_m;
        s_mask = sat(mascara);
        v_mask = val(mascara);

        % Primer momento = media, Segundo = varianza, Tercer = sesgo
        moments_rgb = [
            mean(r_mask), var(r_mask), skewness(r_mask);
            mean(g_mask), var(g_mask), skewness(g_mask);
            mean(b_mask), var(b_mask), skewness(b_mask)
        ];
        moments_hsv = [
            mean(h_mask), var(h_mask), skewness(h_mask);
            mean(s_mask), var(s_mask), skewness(s_mask);
            mean(v_mask), var(v_mask), skewness(v_mask)
        ];

        % --- 5.7 Guardar resultados ---
        especies{k} = sprintf('mariposa_%02d', k);
        hues_dom(k) = dominante;
        porcentajes_dom(k) = porcentaje;
        media_HSV(k,:) = mediaHSV;
        desv_HSV(k,:) = desvHSV;
        momentos_RGB(k,:) = reshape(moments_rgb', 1, []);
        momentos_HSV(k,:) = reshape(moments_hsv', 1, []);

        % --- 5.8 Visualización ---
        figure;
        subplot(1,3,1);
        imshow(recorte);
        title(sprintf('Mariposa %d', k));

        subplot(1,3,2);
        rectangle('Position',[0 0 1 1],'FaceColor', hsv2rgb([dominante 1 1]));
        axis off;
        title(sprintf('Hue dom = %.2f (%.1f%%)', dominante, porcentaje));

        subplot(1,3,3);
        histogram(hue_m, num_bins);
        title('Histograma Hue');

        k = k + 1;
    end
end

% 6. Crear tabla de resultados
T = table(especies', hues_dom', porcentajes_dom', ...
          media_HSV(:,1), media_HSV(:,2), media_HSV(:,3), ...
          desv_HSV(:,1), desv_HSV(:,2), desv_HSV(:,3), ...
          momentos_RGB(:,1), momentos_RGB(:,2), momentos_RGB(:,3), ...
          momentos_RGB(:,4), momentos_RGB(:,5), momentos_RGB(:,6), ...
          momentos_RGB(:,7), momentos_RGB(:,8), momentos_RGB(:,9), ...
          momentos_HSV(:,1), momentos_HSV(:,2), momentos_HSV(:,3), ...
          momentos_HSV(:,4), momentos_HSV(:,5), momentos_HSV(:,6), ...
          momentos_HSV(:,7), momentos_HSV(:,8), momentos_HSV(:,9), ...
          'VariableNames', {
            'Especie', 'HueDominante', 'PorcentajeHueDominante', ...
            'Media_H', 'Media_S', 'Media_V', ...
            'Desv_H', 'Desv_S', 'Desv_V', ...
            'R1_Media', 'R1_Var', 'R1_Sesgo', ...
            'G2_Media', 'G2_Var', 'G2_Sesgo', ...
            'B3_Media', 'B3_Var', 'B3_Sesgo', ...
            'H1_Media', 'H1_Var', 'H1_Sesgo', ...
            'S2_Media', 'S2_Var', 'S2_Sesgo', ...
            'V3_Media', 'V3_Var', 'V3_Sesgo'
          });

% 7. Mostrar y guardar tabla
disp(T);
writetable(T, 'caracteristicas_color_completa.xlsx');
save('caracteristicas_color_completa.mat', 'T');

% 8. Visualización de momentos estadísticos RGB y HSV
% RGB
figure('Name','Momentos Estadísticos RGB','NumberTitle','off', 'Position', [100 100 1000 800]);
rgb_media = momentos_RGB(:, [1 4 7]);
rgb_var = momentos_RGB(:, [2 5 8]);
rgb_sesgo = momentos_RGB(:, [3 6 9]);

subplot(3,1,1); hold on;
plot(1:12, rgb_media(:,1), 'o-r', 'LineWidth', 1.5);
plot(1:12, rgb_media(:,2), 'o-g', 'LineWidth', 1.5);
plot(1:12, rgb_media(:,3), 'o-b', 'LineWidth', 1.5);
title('Primer Momento: Media de Color (RGB)');
legend('Rojo', 'Verde', 'Azul', 'Location', 'best');
xlabel('Mariposa'); ylabel('Media RGB'); grid on; xticks(1:12);

subplot(3,1,2); hold on;
plot(1:12, rgb_var(:,1), 'o-r', 'LineWidth', 1.5);
plot(1:12, rgb_var(:,2), 'o-g', 'LineWidth', 1.5);
plot(1:12, rgb_var(:,3), 'o-b', 'LineWidth', 1.5);
title('Segundo Momento: Varianza de Color (RGB)');
xlabel('Mariposa'); ylabel('Varianza RGB'); grid on; xticks(1:12);

subplot(3,1,3); hold on;
plot(1:12, rgb_sesgo(:,1), 'o-r', 'LineWidth', 1.5);
plot(1:12, rgb_sesgo(:,2), 'o-g', 'LineWidth', 1.5);
plot(1:12, rgb_sesgo(:,3), 'o-b', 'LineWidth', 1.5);
title('Tercer Momento: Sesgo de Color (RGB)');
xlabel('Mariposa'); ylabel('Sesgo RGB'); grid on; xticks(1:12);

% HSV
figure('Name','Momentos Estadísticos HSV','NumberTitle','off', 'Position', [150 150 1000 800]);
hsv_media = momentos_HSV(:, [1 4 7]);
hsv_var = momentos_HSV(:, [2 5 8]);
hsv_sesgo = momentos_HSV(:, [3 6 9]);

subplot(3,1,1); hold on;
plot(1:12, hsv_media(:,1), 'o-m', 'LineWidth', 1.5);
plot(1:12, hsv_media(:,2), 'o-c', 'LineWidth', 1.5);
plot(1:12, hsv_media(:,3), 'o-y', 'LineWidth', 1.5);
title('Primer Momento: Media de Color (HSV)');
legend('Hue', 'Saturación', 'Valor', 'Location', 'best');
xlabel('Mariposa'); ylabel('Media HSV'); grid on; xticks(1:12);

subplot(3,1,2); hold on;
plot(1:12, hsv_var(:,1), 'o-m', 'LineWidth', 1.5);
plot(1:12, hsv_var(:,2), 'o-c', 'LineWidth', 1.5);
plot(1:12, hsv_var(:,3), 'o-y', 'LineWidth', 1.5);
title('Segundo Momento: Varianza de Color (HSV)');
xlabel('Mariposa'); ylabel('Varianza HSV'); grid on; xticks(1:12);

subplot(3,1,3); hold on;
plot(1:12, hsv_sesgo(:,1), 'o-m', 'LineWidth', 1.5);
plot(1:12, hsv_sesgo(:,2), 'o-c', 'LineWidth', 1.5);
plot(1:12, hsv_sesgo(:,3), 'o-y', 'LineWidth', 1.5);
title('Tercer Momento: Sesgo de Color (HSV)');
xlabel('Mariposa'); ylabel('Sesgo HSV'); grid on; xticks(1:12);
