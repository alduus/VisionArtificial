folder = 'imagenes';
colores = ['ro'; 'go'; 'bo'; 'co'; 'mo'; 'yo'; 'ko'; 'wo'];
clases_l = ["Clase 1: Rojo";"Clase 2: Verde2";"Clase 3: Azul";"Clase 4: Cyan";"Clase 5: Magenta"];

% Obtiene una lista de todos los archivos en la carpeta.
files = dir(fullfile(folder, '*.bmp'));  

% Inicializa un arreglo para almacenar las imágenes y sus métricas.
imagenes = cell(length(files), 1);
imagenesp = cell(1, numel(files));
imagenes_bordes = cell(1, numel(files));
k = 1;

% Abre un archivo TXT para escribir los resultados
fileID = fopen('resultados_extraccion.txt', 'w');

% Bucle para procesar cada archivo de imagen.
for i = 1:length(files)
    
    % Lee la imagen.
    img_path = fullfile(folder, files(i).name);
    img = imread(img_path);
    imagenesp{i} = img;
    
    % Convierte a escala de grises
    if size(img, 3) == 3
        img_gray = rgb2gray(img);
    else
        img_gray = img;
    end


    % Binariza la imagen.
    bw = imbinarize(img_gray);

    %Para la muestra de imagenes
    imagen_bordes = edge(bw, 'sobel');
    imagenes_bordes{i} = imagen_bordes;

    
    % Encuentra los contornos de los objetos en la imagen.
    [B, L] = bwboundaries(bw, 'noholes');
    [etiquetas, numObjetos] = bwlabel(bw);

    % Calcula el área, el perímetro y el centroide de cada objeto detectado.
    if ~isempty(B)
        for j = 1:length(B)
            boundary = B{j};
            area = polyarea(boundary(:, 2), boundary(:, 1));
            perimetro = sum(sqrt(sum(diff(boundary).^2, 2)));
            [rows, cols] = find(etiquetas==j);  % Encuentra los índices de los píxeles del objeto
            centroide = [mean(cols), mean(rows)];  % Promedio de las columnas y filas
            if area>2 && perimetro>2
                imagenes{k} = {files(i).name, area, perimetro, centroide};
                fprintf(fileID, 'Imagen %s:\n', imagenes{k}{1});  
                fprintf(fileID, 'Área: %f\n', imagenes{k}{2});
                fprintf(fileID, 'Perímetro: %f\n', imagenes{k}{3});
                fprintf(fileID, 'Centroide: (%f, %f)\n', imagenes{k}{4}(1), imagenes{k}{4}(2));
                %imshow(img_gray);
                %figure;
                k = k + 1;
            end
            
            % Imprime en el archivo TXT
            

        end
    end
end

% Cierra el archivo TXT
fclose(fileID);

% Muestra las imagenes
%figure;
%for i = 1:10
%    subplot(2, 5, i);
%    imshowpair(imagenesp{i}, imagenes_bordes{i}, 'montage');
%    title(['Imagen ', num2str(i)]);
%end

% Extraer características para K-Means
features = zeros(length(imagenes), 3); % Inicializar matriz para almacenar características

for i = 1:length(imagenes)
    features(i, 1) = imagenes{i}{2}; % Área
    features(i, 2) = imagenes{i}{3}; % Perímetro
    %features(i, 3) = imagenes{i}{4}(1); % Coordenada X del centroide
    features(i, 3) = (imagenes{i}{4}(1)+imagenes{i}{4}(2))/2;
    %features(i,3) = imagenes{i}{4}(2);
end

% Normalizar las características
features_norm = features;%normalize(features);

% Inicialización de centroides
k = 5;
[num_samples, num_features] = size(features_norm);
centroids = features_norm(randperm(num_samples, k), :);

% Definir el número máximo de iteraciones
max_iterations = 100;
centroids = [
    266, 112, 94;  % Centroid 1
    292, 232, 100;  % Centroid 2
    1157, 152, 126;  % Centroid 3
    702, 98, 104;  % Centroid 4
    796, 188, 108;  % Centroid 5
];

% Asignación de muestras a los clusters más cercanos
for iter = 1:max_iterations
    % Calcular las distancias entre cada muestra y los centroides
    distances = pdist2(features_norm, centroids);
    
    % Asignar cada muestra al cluster con el centroide más cercano
    [~, cluster_indices] = min(distances, [], 2);
    
    % Actualización de los centroides
    % Para cada cluster, calcular el nuevo centroide como el promedio de las muestras asignadas a ese cluster
    for i = 1:k
        cluster_samples = features_norm(cluster_indices == i, :);
        centroids(i, :) = mean(cluster_samples);
    end
    
end
centroids = [
    266, 112, 94;  % Centroid 1
    292, 232, 100;  % Centroid 2
    1157, 152, 126;  % Centroid 3
    702, 98, 104;  % Centroid 4
    796, 188, 108;  % Centroid 5
];

% Graficar asignación de muestras a clusters
figure;

for i = 1:length(features)
    index = cluster_indices(i);  % El índice del cluster para esta muestra
    if index <= 5  % Solo consideramos los primeros 5 para la leyenda
        scatter3(features(i,1), features(i,2), features(i,3), 36, colores(index,:), 'filled', 'DisplayName', clases_l(index));
    else
        scatter3(features(i,1), features(i,2), features(i,3), 36, colores(index,:), 'filled');
    end
    hold on;
    grid on;
end

% Graficar centroides finales
plot3(centroids(:,1), centroids(:,2), centroids(:,3), 'kx', 'MarkerSize', 15, 'LineWidth', 3);
hold on;
grid on;

title('Asignación de muestras a clusters y centroides finales');
xlabel('Área');
ylabel('Perímetro');
zlabel('Coordenada X del centroide');
legend show;
disp('Clase 1: Rojo');
disp('Clase 2: Verde');
disp('Clase 3: Azul' );
disp('Clase 4: Cyan' );
disp('Clase 5: Magenta');
grid on;
hold off;

centroids = [
    266, 112, 94;  % Centroid 1
    292, 232, 100;  % Centroid 2
    1157, 152, 126;  % Centroid 3
    702, 98, 104;  % Centroid 4
    796, 188, 108;  % Centroid 5
    400, 250, 100; %centroid 5.2
];
keep=true;
while(keep)
    
    [filename, pathname] = uigetfile({'*.bmp;*.jpg;*.png', 'Images (*.bmp, *.jpg, *.png)'}, 'Seleccione una imagen');
    if isequal(filename, 0)
        disp('El usuario canceló la selección de imagen');
    else
        % Clasificación de una nueva imagen seleccionada por el usuario
        img_caso2 = imread(fullfile(pathname, filename));
        figure;
        %legend("Clase 1: Tornillo","Clase 2: Alcayata","Clase 3: Cola de pato","Clase 4: Rondana","Clase 5: Arandela");
        imshow(img_caso2);
        hold on;

        % Dibujar regiones en la imagen
        annotation('textbox', [0.8, 0.65, 0.1, 0.1], 'String', 'Clase 1: Tornillo', 'Color', 'k');% Texto 1
        annotation('textbox', [0.8, 0.55, 0.1, 0.1], 'String', 'Clase 2: Alcayata', 'Color', 'k');
        annotation('textbox', [0.8, 0.45, 0.1, 0.1], 'String', 'Clase 3: Cola de pato', 'Color', 'k');
        annotation('textbox', [0.8, 0.35, 0.1, 0.1], 'String', 'Clase 4: Rondana', 'Color', 'k');
        annotation('textbox', [0.8, 0.25, 0.1, 0.1], 'String', 'Clase 5: Arandela', 'Color', 'k');
         % Muestra la leyenda en la imagen

        
    
        % Convierte a escala de grises
        if size(img_caso2, 3) == 3
            img_gcaso2 = rgb2gray(img_caso2);
        else
            img_gcaso2 = img_caso2;
        end
    
        % Binariza la imagen
        bw_caso2 = imbinarize(img_gcaso2);
    
        % Encuentra los contornos de los objetos en la imagen
        [B2, L2] = bwboundaries(bw_caso2, 'noholes');
        cont1=0;cont2=0;cont3=0;cont4=0;cont5=0;
        % Calcula el área, el perímetro y el centroide de cada objeto detectado
        distancias_cluster = cell(1, length(centroids));
        if ~isempty(B2)
            for j = 1:length(B2)
                boundary = B2{j};
                area = polyarea(boundary(:, 2), boundary(:, 1));
                perimetro = sum(sqrt(sum(diff(boundary).^2, 2)));
                [rows, cols] = find(etiquetas==j);  % Encuentra los índices de los píxeles del objeto
                centroide = [mean(cols), mean(rows)];  % Promedio de las columnas y filas
                if length(B2)<11
                    if area >3000 
                        disp(['El objeto ', num2str(j), ' en la imagen caso 2 pertenece al cluster otros' ]);
                    elseif area>2 && perimetro>2 
                        for k = 1:length(centroids)
                            distancia_caso1 = 3:1;
                            distancia_caso1(1) = pdist2(area,centroids(k,1),"euclidean");
                            distancia_caso1(2) = pdist2(perimetro,centroids(k,2),"euclidean");
                            distancia_caso1(3) = pdist2(centroide(2),centroids(k,3),"euclidean");
                            distancias_cluster{1,k} = mean(distancia_caso1,"all");
                        end
                        % Encontrar el cluster con la distancia mínima
                        distancias_cluster_array = cell2mat(distancias_cluster);
                        [min_distancia, cluster_idx] = min(distancias_cluster_array);
                        if cluster_idx == 6
                            disp(['El objeto ', num2str(j), ' en la imagen escogida pertenece al cluster 5']);
                        else
                            disp(['El objeto ', num2str(j), ' en la imagen escogida pertenece al cluster ', num2str(cluster_idx)]);
                        end
                        if(cluster_idx==1)
                            cont1=cont1+1;
                        elseif(cluster_idx==2)
                            cont2=cont2+1;
                        elseif(cluster_idx==3)
                            cont3=cont3+1;
                        elseif(cluster_idx==4)
                            cont4=cont4+1;
                        elseif(cluster_idx==5 || cluster_idx==6)
                            cont5=cont5+1;
                        end
                    end
                else 
                    disp(['El objeto ', num2str(j), ' en la imagen caso 2 pertenece al cluster otros' ]);
                end
                
            end
        end
        fprintf('\n');
        if ~cont1==0
            disp(['Hay ', num2str(cont1), ' objetos de tornillo']);
        end
        if ~cont2==0
            disp(['Hay ', num2str(cont2), ' objetos de alcayata']);
        end
        if ~cont3==0
            disp(['Hay ', num2str(cont3), ' objetos de cola de pato']);
        end
        if ~cont4==0
            disp(['Hay ', num2str(cont4), ' objetos de rondana']);
        end
        if ~cont5==0
            disp(['Hay ', num2str(cont5), ' objetos de arandela']);
        end  

        fprintf('\n');
    end
    fprintf('\n');
    disp('Desea salir? o prefiere seleccionar otra imagen?');
    disp('1. Otra imagen');
    disp('2. Salir');
    op = input('Ingrese una opción: ');
    switch op
        case 1
            keep=true;
        case 2
            keep=false;
            break;
        otherwise
            keep=false;
            break;
    end
end
