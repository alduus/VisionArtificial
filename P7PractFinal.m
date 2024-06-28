folder = 'imagenes';
colores = ['ro'; 'go'; 'bo'; 'co'; 'mo'; 'yo'; 'ko'; 'wo'];
clases_l = ["Clase 1: Rojo";"Clase 2: Verde2";"Clase 3: Azul";"Clase 4: Cyan";"Clase 5: Magenta"];

% Obtiene una lista de todos los archivos en la carpeta.
files = dir(fullfile(folder, '*.bmp'));  

% Inicializa un arreglo para almacenar las imágenes y sus métricas.
imagenes = cell(length(files), 1);
k = 1;

% Bucle para procesar cada archivo de imagen.
for i = 1:length(files)
    
    % Lee la imagen.
    img_path = fullfile(folder, files(i).name);
    img = imread(img_path);
    
    % Convierte a escala de grises
    
    if size(img, 3) == 3
        img_gray = rgb2gray(img);
    else
        img_gray = img;
    end

    img_gray = medfilt2(img_gray);
   
    % Binariza la imagen.
    bw = imbinarize(img_gray);
    se = strel('square', 5);
    bw = imdilate(bw, se);

    % Encuentra los contornos de los objetos en la imagen.
    [B, L] = bwboundaries(bw, 'noholes');
    [labeledImage, numObjects] = bwlabel(bw, 8);
    [etiquetas, numObjetos] = bwlabel(bw);
    % Calcula el área, el perímetro y el centroide de cada objeto detectado.
    if ~isempty(B)
        for j = 1:length(B)
            boundary = B{j};
            singleObject = labeledImage == j;
            area = polyarea(boundary(:, 2), boundary(:, 1));
            perimetro = sum(sqrt(sum(diff(boundary).^2, 2)));
            [rows, cols] = find(etiquetas==j);  % Encuentra los índices de los píxeles del objeto
            centroide = [mean(cols), mean(rows)];  % Promedio de las columnas y filas
            
            m00 = sum(singleObject(:));
            [y, x] = find(singleObject);
            x_bar = sum(x) / m00;
            y_bar = sum(y) / m00;
            
            % Calcular los segundos momentos
            u20 = sum((x - x_bar).^2);
            u02 = sum((y - y_bar).^2);
            u11 = sum((x - x_bar).*(y - y_bar));
            
            % Calcular la orientación del objeto
            theta = 0.5 * atan2(2*u11, u20 - u02);
            
            % Calcular ejes mayor y menor de la elipse
            a = sqrt(2 * (u20 + u02 + sqrt((u20 - u02)^2 + 4*u11^2)) / m00);
            b = sqrt(2 * (u20 + u02 - sqrt((u20 - u02)^2 + 4*u11^2)) / m00);
            region = regionprops(singleObject,"all");
            %region.EquivDiameter
            if area>30 && perimetro >30
                imagenes{k} = {files(i).name, area, perimetro, a};
                %imshow(bw);
                %figure;
                k = k + 1;
            end
        end
    end
end

headers = {'ID','Imagen', 'Area', 'Perimetro', 'Centroide'};
fileID = fopen('resultados_extraccion.txt', 'w');
fprintf(fileID, '%s\t%s\t%s\t%s\t%s\n', headers{:});

p_area=zeros(1,5);
p_perimetro=zeros(1,5);
p_minoraxis=zeros(1,5);

for i = 1:length(imagenes)
    fprintf(fileID, '%d |', i);
    fprintf(fileID, '%s |', imagenes{i}{1});
    fprintf(fileID, '%f |', imagenes{i}{2});
    fprintf(fileID, '%f |', imagenes{i}{3});
    fprintf(fileID, '%f\n', imagenes{i}{4});
    if(i<16)
        p_area(1,1)=p_area(1,1)+imagenes{i}{2};
        p_perimetro(1,1)=p_perimetro(1,1)+imagenes{i}{3};
        p_minoraxis(1,1)=p_minoraxis(1,1)+imagenes{i}{4};
    elseif(i>=16 && i<31)
        p_area(1,2)=p_area(1,2)+imagenes{i}{2};
        p_perimetro(1,2)=p_perimetro(1,2)+imagenes{i}{3};
        p_minoraxis(1,2)=p_minoraxis(1,2)+imagenes{i}{4};
    elseif(i>=31 && i<46)
        p_area(1,3)=p_area(1,3)+imagenes{i}{2};
        p_perimetro(1,3)=p_perimetro(1,3)+imagenes{i}{3};
        p_minoraxis(1,3)=p_minoraxis(1,3)+imagenes{i}{4};
    elseif(i>=46 && i<61)
        p_area(1,4)=p_area(1,4)+imagenes{i}{2};
        p_perimetro(1,4)=p_perimetro(1,4)+imagenes{i}{3};
        p_minoraxis(1,4)=p_minoraxis(1,4)+imagenes{i}{4};
    elseif(i>=61 && i<76)
        p_area(1,5)=p_area(1,5)+imagenes{i}{2};
        p_perimetro(1,5)=p_perimetro(1,5)+imagenes{i}{3};
        p_minoraxis(1,5)=p_minoraxis(1,5)+imagenes{i}{4};
    
    end
end
p_area=p_area/15;
p_perimetro=p_perimetro/15;
p_minoraxis=p_minoraxis/15;

% Cierra el archivo TXT
fclose(fileID);

features = zeros(length(imagenes), 3); % Inicializar matriz para almacenar características

for i = 1:length(imagenes)
    features(i, 1) = imagenes{i}{2}; % Área
    features(i, 2) = imagenes{i}{3}; % Perímetro
    features(i, 3) = imagenes{i}{4};
end

% Inicialización de centroides
k = 5;
[num_samples, num_features] = size(features);


% Definir el número máximo de iteraciones
max_iterations = 100;

centroids = [
    p_area(1), p_perimetro(1), p_minoraxis(1);
    p_area(2), p_perimetro(2), p_minoraxis(2);
    p_area(3), p_perimetro(3), p_minoraxis(3);
    p_area(4), p_perimetro(4), p_minoraxis(4);
    p_area(5), p_perimetro(5), p_minoraxis(5);
];

for iter = 1:max_iterations
    % Calcular las distancias entre cada muestra y los centroides
    distances = pdist2(features, centroids);
    
    % Asignar cada muestra al cluster con el centroide más cercano
    [~, cluster_indices] = min(distances, [], 2);
    
    for i = 1:k
        cluster_samples = features(cluster_indices == i, :);
        centroids(i, :) = mean(cluster_samples);
    end
    
end

% Graficar asignación de muestras a clusters
figure;

for i = 1:length(features)
    index = cluster_indices(i);  % El índice del cluster para esta muestra
    scatter3(features(i,1), features(i,2), features(i,3), 36, colores(index,:), 'filled');
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
disp('Clase 1 Cuchara: Rojo');
disp('Clase 2 Tenedor: Verde');
disp('Clase 3 Cuchillo: Azul' );
disp('Clase 4 Pelapas: Cyan' );
disp('Clase 5 Popote: Magenta');
grid on;
hold off;

obj_img = zeros(length(files), 5);

for i = 1:length(files)
    
    % Lee la imagen.
    img_path = fullfile(folder, files(i).name);
    img_caso = imread(img_path);
    % Convierte a escala de grises
    if size(img_caso, 3) == 3
        img_gcaso = rgb2gray(img_caso);
    else
        img_gcaso = img_caso;
    end
    img_gcaso= medfilt2(img_gcaso);
    
    
    % Binariza la imagen
    bw_caso = imbinarize(img_gcaso);
    se = strel('square', 5);
    bw_caso = imdilate(bw_caso, se);
    
    % Encuentra los contornos de los objetos en la imagen
    [B2, L2] = bwboundaries(bw_caso, 'noholes');
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
                if area >12000 
                    disp(['El objeto ', num2str(j), ' en la imagen caso 2 pertenece al cluster otros' ]);
                elseif area>50 && perimetro>50 
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
            end
            
        end
    end
    
    obj_img(i,:) = [cont1, cont2, cont3, cont4, cont5];
end

casee=-1;
fprintf('\n');
disp('Desea salir? o prefiere seleccionar otra imagen?');
disp('1. Imagenes del DataSet');
disp('2. Imagenes de Internet');
op = input('Ingrese una opción: ');
switch op
    case 1
        casee=1;
    case 2
        casee=2;
    otherwise
        casee=1;
end

keep=true;

while(keep)
    
    [filename, pathname] = uigetfile({'*.bmp;*.jpg;*.png', 'Images (*.bmp, *.jpg, *.png)'}, 'Seleccione una imagen');
    if isequal(filename, 0)
        disp('El usuario canceló la selección de imagen');
    else
        % Clasificación de una nueva imagen seleccionada por el usuario
        img_caso = imread(fullfile(pathname, filename));
        %figure;
        %legend("Clase 1: Tornillo","Clase 2: Alcayata","Clase 3: Cola de pato","Clase 4: Rondana","Clase 5: Arandela");
        %imshow(img_caso);
        %hold on;

        % Dibujar regiones en la imagen
        %annotation('textbox', [0.8, 0.65, 0.1, 0.1], 'String', 'Clase 1: Cuchara', 'Color', 'k');% Texto 1
        %annotation('textbox', [0.8, 0.55, 0.1, 0.1], 'String', 'Clase 2: Tenedor', 'Color', 'k');
        %annotation('textbox', [0.8, 0.45, 0.1, 0.1], 'String', 'Clase 3: Cuchillo', 'Color', 'k');
        %annotation('textbox', [0.8, 0.35, 0.1, 0.1], 'String', 'Clase 4: Pela papas', 'Color', 'k');
        %annotation('textbox', [0.8, 0.25, 0.1, 0.1], 'String', 'Clase 5: Popote', 'Color', 'k');
        % Muestra la leyenda en la imagen

        % Convierte a escala de grises
        if size(img_caso, 3) == 3
            img_gcaso = rgb2gray(img_caso);
        else
            img_gcaso = img_caso;
        end
        img_gcaso= medfilt2(img_gcaso);
        bw_caso = imbinarize(img_gcaso);
        if casee==1
            se = strel('square', 5);
            bw_caso = imdilate(bw_caso, se);
        end
    
        % Encuentra los contornos de los objetos en la imagen
        [B2, L2] = bwboundaries(bw_caso, 'noholes');
        cont1=0;cont2=0;cont3=0;cont4=0;cont5=0;
        % Calcula el área, el perímetro y el centroide de cada objeto detectado
        distancias_cluster = cell(1, length(centroids));
        bandera=0;
        if ~isempty(B2)
            for j = 1:length(B2)
                singleObject = labeledImage == j;
                
                boundary = B2{j};
                area = polyarea(boundary(:, 2), boundary(:, 1));
                perimetro = sum(sqrt(sum(diff(boundary).^2, 2)));
                [rows, cols] = find(etiquetas==j);  % Encuentra los índices de los píxeles del objeto
                centroide = [mean(cols), mean(rows)];  % Promedio de las columnas y filas
                m00 = sum(singleObject(:));
                [y, x] = find(singleObject);
                x_bar = sum(x) / m00;
                y_bar = sum(y) / m00;
                
                % Calcular los segundos momentos
                u20 = sum((x - x_bar).^2);
                u02 = sum((y - y_bar).^2);
                u11 = sum((x - x_bar).*(y - y_bar));
                
                % Calcular la orientación del objeto
                theta = 0.5 * atan2(2*u11, u20 - u02);
                
                % Calcular ejes mayor y menor de la elipse
                a = sqrt(2 * (u20 + u02 + sqrt((u20 - u02)^2 + 4*u11^2)) / m00);
                b = sqrt(2 * (u20 + u02 - sqrt((u20 - u02)^2 + 4*u11^2)) / m00);
                
                if length(B2)<14
                    if area>12000 
                        disp(['El objeto ', num2str(j), ' en la imagen pertenece al cluster otros' ]);
                    elseif area>30 && perimetro>30
                        
                        for k = 1:length(centroids)
                            distancia_caso1 = 3:1;
                            
                            distancia_caso1(1) = pdist2(area,centroids(k,1),"euclidean");
                            distancia_caso1(2) = pdist2(perimetro,centroids(k,2),"euclidean");
                            distancia_caso1(3) = pdist2(a,centroids(k,3),"euclidean");
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

                end
                
            end
        end
        fprintf('\n');
        if ~cont1==0
            disp(['Hay ', num2str(cont1), ' objetos de cuchara']);
        end
        if ~cont2==0
            disp(['Hay ', num2str(cont2), ' objetos de tenedor']);
        end
        if ~cont3==0
            disp(['Hay ', num2str(cont3), ' objetos de cuchillo']);
        end
        if ~cont4==0
            disp(['Hay ', num2str(cont4), ' objetos de pelapapas']);
        end
        if ~cont5==0
            disp(['Hay ', num2str(cont5), ' objetos de popote']);
        end  
        if cont1==0 && cont2==0 && cont3==0 && cont4==0 && cont5==0
            disp('Objetos desconocidos, no pertenecen a ninguna clase');
            bandera=1;
        end

        fprintf('\n');

        obj_new = [cont1, cont2, cont3, cont4, cont5];
        cercania = pdist2(obj_new, obj_img);
        [~, sorted_indices] = sort(cercania, 'ascend');
        top5_indices = sorted_indices(1:5);
        
        % Mostrar las 5 imágenes más cercanas
        
        if bandera==0
            figure;
            for i = 1:length(top5_indices)
                idx_clase = top5_indices(i);
                if idx_clase <= length(files)
                    img_path = fullfile(folder, files(idx_clase).name);
                    img = imread(img_path);
                    % Mostrar la imagen
                    subplot(3,5,i);
                    imshow(img);
                    title(['Imagen', num2str(idx_clase)]);
                else
                    disp(['Índice de clase ', num2str(idx_clase), ' fuera de rango.']);
                end
            end
            % Inicializar vector para almacenar las diferencias por cada componente de obj_new
            suma_diferencias = zeros(1, length(obj_new));
            
            % Calcular las diferencias por cada componente de obj_new
            for j = 1:length(obj_new)
                for i = 1:length(top5_indices)
                    idx = top5_indices(i);
                    vector_obj_img = obj_img(idx, :);
                    diferencia = abs(obj_new(j) - vector_obj_img(j));
                    suma_diferencias(j) = suma_diferencias(j) + diferencia;
                end
            end
            disp('Suma de diferencias por cada componente de obj_new:');
            disp(suma_diferencias);
        end
        
    end
    fprintf('\n');
    disp('Desea salir? o prefiere seleccionar otra imagen?');
    disp('1. Imagenes del DataSet');
    disp('2. Imagenes de Internet');
    disp('3. Salir');
    op = input('Ingrese una opción: ');
    switch op
        case 1
            keep=true;
            casee=1;
            close all;
        case 2
            keep=true;
            casee=2;
            close all;
        case 3
            keep=false;
            close all;
            break;
        otherwise
            keep=false;
            close all;
            break;
    end
end

