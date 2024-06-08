clc
clear all
close all
warning off all

% Graficar los representantes de la clase
colores = ['ro'; 'go'; 'bo'; 'co'; 'mo'; 'yo'; 'ko'; 'wo'];
fondo_color = ['r'; 'g'; 'b'; 'c'; 'm'; 'y'; 'k'; 'w'];

% Mostrar la imagen
img= imread('peppers.png');
%img = imread("francia.jpg");
imshow(img);

n = input('Dame el numero de clases: ');
rep = input('Dame el numero de representantes para las clases: ');

representantes_clase = cell(1, n);
fprintf('Haz clic en la ubicación de los centroides de las clases:\n');

centroides = zeros(n, 3); 
coor_centro=zeros(n,2);
for i = 1:n
    fprintf('Seleccione el centroide para la clase %d\n', i);
    [x, y] = ginput(1);
    pixel = impixel(img, x, y);
    centroides(i, :) = pixel;
    coor_centro(i,:) = [x,y];
    hold on;
    plot(x, y, 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
    %plot(x, y, 'wo', 'MarkerSize', 5);
    hold off;
end

for i = 1:n

    for j= 1:rep

        % Generar coordenadas aleatorias dentro del radio especificado
        randx = randi([-100, 100]);
        randy = randi([-100, 100]);
        
        % Calcular las coordenadas del representante
        x=coor_centro(i,1);
        y=coor_centro(i,2);

        x = x + randx;
        y = y + randy;
        
        % Garantizar que las coordenadas estén dentro de los límites de la imagen
        x = max(1, min(size(img, 2), x));
        y = max(1, min(size(img, 1), y));

        % Obtener el color del píxel en el punto seleccionado
        pixel = impixel(img, x, y);  % Obtener el color del píxel
        representantes_clase{i}(j, :) = pixel;
        
        % Dibujar un punto negro en el punto seleccionado
       
    end
end


% Mostrar los representantes de cada clase
for i = 1:n
    disp(['Clase ' num2str(i) ':']);
    disp(representantes_clase{i});
end

keep2=true;

while keep2

    fprintf('\nHaz clic en la ubicación del vector extra:\n');
    [x_extra, y_extra] = ginput(1);  % Esperar a que el usuario haga clic
    pixel_punto = impixel(img, x_extra, y_extra);
    r = pixel_punto(1);
    g = pixel_punto(2);
    b = pixel_punto(3);
    vector = [r; g; b]';
    
    hold on;
    plot(x_extra, y_extra, 'black', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
    hold off;

    keep = true;
    
    while keep
        fprintf('\n');
        disp('1 Probabilidad por Euclidiana');
        disp('2. Distancia por Mahalanobis');
        disp('3. Probabilidad Maxima');
        disp('4. Clasificar con KNN');
        disp('5. Salir');
        op = input('Ingrese una opción: ');
        
        switch op
            case 1
                distancias = zeros(n, 1);
                for i = 1:n
                    % Obtener el centroide de la clase actual
                    centroid = mean(representantes_clase{i}, 1);
                    
                    % Calcular la distancia euclidiana entre el punto desconocido y el centroide
                    distancias(i) = sqrt(sum((vector - centroid).^2));
                end
                
                % Mostrar la clase a la que pertenece el punto desconocido
                probabilidades = 1 ./ distancias;
                probabilidades = probabilidades / sum(probabilidades); 
                [~, clasePuntoExtra] = max(probabilidades);
                fprintf('El punto extra pertenece a la clase %d con una "probabilidad" de %.2f%%\n', clasePuntoExtra, probabilidades(clasePuntoExtra) * 100);
           
            case 2
                fprintf('\n');
                disp('Distancia por Mahalanobis');
        
                fprintf('\n');
        
                medias = zeros(3,n);
                sigmas = cell(1,n);
                distanciasM = zeros(n, 1);
                
                for i = 1:n
                    medias(:,i) = mean(representantes_clase{i}, 1);
                    sigmas{i} = ((1/rep)*(transpose(centroides(i,:))-medias(:,i))*(transpose(centroides(i,:))-medias(:,i))');
                    distanciasM(i) = (transpose(vector) - medias(:,i))'*(sigmas{i})*(transpose(vector)-medias(:,i));
                end
                
                [~, clasePuntoExtra] = min(distanciasM);
                fprintf('El punto extra pertenece a la clase %d con una "distancia mínima de" de %.2f%\n', clasePuntoExtra, distanciasM(clasePuntoExtra));
           
    
            case 3
                medias = zeros(3,n);
                sigmas = cell(1,n);
                distanciasM = zeros(n, 1);
                probabilidadesM = zeros(n,1);
                
                for i = 1:n
                    medias(:,i) = mean(representantes_clase{i}, 1);
                    sigmas{i} = ((1/rep)*(transpose(centroides(i,:))-medias(:,i))*(transpose(centroides(i,:))-medias(:,i))');
                    distanciasM(i) = (transpose(vector) - medias(:,i))'*(sigmas{i})*(transpose(vector)-medias(:,i));
                    probabilidadesM(i) = (1 / (2 * pi * (sqrt(det(sigmas{i})))))*exp(-0.5*distanciasM(i));
                end
                    
                probabilidades = 1 ./ distanciasM;
                probabilidades = probabilidades / sum(probabilidades); 
                [~, clasePuntoExtra] = max(probabilidades);
                fprintf('El punto extra pertenece a la clase %d con una "probabilidad" de %.2f%%\n', clasePuntoExtra, probabilidades(clasePuntoExtra) * 100);
    
                % Encuentra el valor maximo y su índice
                %[maximo, indice] = max(pro_total);

            case 4
                k = input('Ingrese el número de vecinos k para KNN: ');
                todasDistancias = [];
                etiquetasClases = [];
                for i = 1:n
                    for j = 1:size(representantes_clase{i}, 1)
                        distancia = sqrt(sum((vector - representantes_clase{i}(j, :)).^2));
                        todasDistancias = [todasDistancias; distancia];
                        etiquetasClases = [etiquetasClases; i];
                    end
                end

                [distanciasOrdenadas, indicesOrdenados] = sort(todasDistancias);
                kVecinosCercanos = etiquetasClases(indicesOrdenados(1:k));

                claseModa = mode(kVecinosCercanos);
                
                fprintf('El punto extra pertenece a la clase %d según KNN con k=%d\n', claseModa, k);
   
            case 5
                fprintf('\n');
                disp('Salir');
                repetir = false;
                break;
            otherwise
                repetir=false;
                break;
        end
    end
    op2 = input('Quieres ingresar otro punto? 1-Si  2-No: ');
    switch op2
        case 1
            keep2=true;
        otherwise
            keep2=false;
            break;
    end
end

fprintf('\nFin del programa...\n');
