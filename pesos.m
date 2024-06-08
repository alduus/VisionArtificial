clc
clear all
close all
warning off all

ternary = @(varargin) varargin{end - varargin{1}};
digits(100);
imagen = imread("peppers.png");
[alto, ancho] = size(imagen);
ancho = ancho/3;
figure(1)
imshow(imagen)
cantidadC = input("Ingrese la cantidad de clases\n");
cantidadR = input("Ingrese la cantidad de representantes en la nube de puntos \n");
cantidadN = input("Ingrese el n para k-nn\n");
close

nombres = "";
longitudN = 1;

centroides = zeros(cantidadC, 3);
centro_xy = zeros(cantidadC, 2);
figure(2)
imshow(imagen)
for i = 1:cantidadC
    fprintf('Seleccione el centroide para la clase %d\n', i);
    [x, y] = ginput(1);
    pixel = impixel(imagen, x, y);
    centroides(i, :) = pixel;
    centro_xy(i, 1) = x;
    centro_xy(i, 2) = y;
    hold on;
    scatter(x, y, 'filled', 'DisplayName', sprintf('clase%d', i), 'MarkerEdgeColor', 'black', 'MarkerFaceColor', (pixel/255))
end
legend;
hold off;

representantes_clase = cell(1, cantidadC);
clases_xy = cell(1, cantidadC);
for i = 1:cantidadC
    for j = 1:cantidadR
        % Generar coordenadas para xy
        randx = randi([-25, 25]);
        randy = randi([-25, 25]);
        
        x = centro_xy(i, 1);
        y = centro_xy(i, 2);

        x = x + randx;
        y = y + randy;
        clases_xy{i}(j, 1) = x;
        clases_xy{i}(j, 2) = y;

        pixel = impixel(imagen, x, y);
        
        % Calcular las coordenadas del representante
        representantes_clase{i}(j, 1) = pixel(1);
        representantes_clase{i}(j, 2) = pixel(2);
        representantes_clase{i}(j, 3) = pixel(3);
    end
end

figure(3)
imshow(imagen)
hold on
grid on
plot(clases_xy{1}(:, 1), clases_xy{1}(:, 2), 'og', 'Markersize', 10, 'MarkerFaceColor', 'c')
plot(clases_xy{2}(:, 1), clases_xy{2}(:, 2), 'og', 'Markersize', 10, 'MarkerFaceColor', 'g')
plot(clases_xy{3}(:, 1), clases_xy{3}(:, 2), 'og', 'Markersize', 10, 'MarkerFaceColor', 'y')
legend('Clase 1', 'Clase 2', 'Clase 3')

ochenta = round(cantidadR);
cincuenta = round(cantidadR / 2);

promedioE = zeros(1, 20);

for w = 1:20
    train = zeros(1, cantidadC * cantidadR);
    test = zeros(1, cantidadC * cantidadR);
    k = 0;
    for i = 1:cantidadC
        centroid1 = mean(representantes_clase{1}, 1);
        centroid2 = mean(representantes_clase{2}, 1);
        centroid3 = mean(representantes_clase{3}, 1);
        for j = 1:cantidadR
            k = k + 1;
            vector = representantes_clase{i}(j, :);
                        
            % Calcular la distancia euclidiana entre el punto desconocido y el centroide
            distancias = zeros(3, 1);
            distancias(1) = sqrt(sum((vector - centroid1).^2));
            distancias(2) = sqrt(sum((vector - centroid2).^2));
            distancias(3) = sqrt(sum((vector - centroid3).^2));
            probabilidades = 1 ./ distancias;
            probabilidades = probabilidades / sum(probabilidades); 
            [~, clasePuntoExtra] = max(probabilidades);
            train(k) = clasePuntoExtra;
        end
    end
    k = 0;
    for i = 1:cantidadC
        centroid1 = mean(representantes_clase{1}, 1);
        centroid2 = mean(representantes_clase{2}, 1);
        centroid3 = mean(representantes_clase{3}, 1);
        for j = 1:cantidadR
            k = k + 1;
            vector = representantes_clase{i}(j, :);
                        
            % Calcular la distancia euclidiana entre el punto desconocido y el centroide
            distancias = zeros(3, 1);
            distancias(1) = sqrt(sum((vector - centroid1).^2));
            distancias(2) = sqrt(sum((vector - centroid2).^2));
            distancias(3) = sqrt(sum((vector - centroid3).^2));
            probabilidades = 1 ./ distancias;
            probabilidades = probabilidades / sum(probabilidades); 
            [~, clasePuntoExtra] = max(probabilidades);
            test(k) = clasePuntoExtra;
        end
    end
    clase1 = 0;
    clase2 = 0;
    clase3 = 0;
    for t = 1:cantidadR * cantidadC
        if train(t) == test(t)
            if train(t) == 1
                clase1 = clase1 + 1;
            elseif train(t) == 2
                clase2 = clase2 + 1;
            elseif train(t) == 3
                clase3 = clase3 + 1;
            end
        end
    end
    sumadiag = clase1 + clase2 + clase3;
    promedioE(w) = sumadiag / (cantidadR * cantidadC);
end
promedioPromedio = mean(promedioE);

% Imprimir promedioPromedio en la consola
fprintf('El valor de promedioPromedio es: %.4f\n', promedioPromedio);
