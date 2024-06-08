imagen = imread('fondo.jpeg');
[m,n] = size(imagen);

%%gris
bw = rgb2gray(imagen);

%%rojo
r=imagen;
r(:,:,1);
r(:,:,2) = 0;
r(:,:,3) = 0;

%%verde
g=imagen;
g(:,:,1)=0;
g(:,:,2);
g(:,:,3)=0;

%%azul
b=imagen;
b(:,:,1)=0;
b(:,:,2)=0;
b(:,:,3);

%%magenta
m=imagen;
m=r+b;

%%amarillo
y=imagen;
y=r+g;

%%cyan
c= imagen;
c=b+g;

%%negro
k=imagen;
k(:,:,1)=0;
k(:,:,2)=0;
k(:,:,3)=0;

%%blanco
w=imagen;
w(:,:,1)=255; 
w(:,:,2)=255;
w(:,:,3)=255;


result = imtile({r,g,b,c,m,y,k,bw,w}, 'GridSize', [3 3]); % Asegura un formato de cuadrícula de 3x3 para la disposición

imshow(result);
imwrite(result, 'imagen_resultante.jpg'); % Guarda la imagen resultante


% Mostrar la imagen
img= imread('imagen_resultante.jpg');
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

    scatter(x,y,'filled','DisplayName',sprintf('clase%d',i),'MarkerEdgeColor','black', 'MarkerFaceColor',(pixel/255))    
end
legend;
hold off;

for i = 1:n

    for j= 1:rep
        randr = randi([-30, 30]);
        randg = randi([-30, 30]);
        randb = randi([-30, 30]);

        r=centroides(i,1);
        g=centroides(i,2);
        b=centroides(i,3);

        r = r + randr;
        g = g + randg;
        b = b + randb;

        representantes_clase{i}(j, 1) = r;
        representantes_clase{i}(j, 2) = g;
        representantes_clase{i}(j, 3) = b;
       
    end
end

for i = 1:n
    disp(['Clase ' num2str(i) ':']);
    disp(representantes_clase{i});
end

keep2=true;

while keep2

    fprintf('\nHaz clic en la ubicación del vector extra:\n');
    [x_extra, y_extra] = ginput(1);  
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
        disp('4. K-NN');
        disp('5. Salir')
        op = input('Ingrese una opción: ');
        
        switch op
            case 1
                distancias = zeros(n, 1);
                for i = 1:n
                    centroid = mean(representantes_clase{i}, 1);

                    distancias(i) = sqrt(sum((vector - centroid).^2));
                end

                probabilidades = 1 ./ distancias;
                probabilidades = probabilidades / sum(probabilidades); 
                [~, clasePuntoExtra] = max(probabilidades);
                fprintf('El punto extra pertenece a la clase %d con una "probabilidad" de %.2f%%\n', clasePuntoExtra, probabilidades(clasePuntoExtra) * 100);
           
            case 2
                fprintf('\n');
                disp('Distancia por Mahalanobis');
        
                fprintf('\n');
        
                mediasA = zeros(3,n);
                sigmas = cell(1,n);
                distanciasM = zeros(1, n);
                probabilidadesM = zeros(n,1);
                
                for i = 1:n
                    mediasA(:,i) = mean(representantes_clase{i}, 1);
                    medias=transpose(mediasA);
                    sigmas{i} = ((1/rep)*((representantes_clase{i}-medias(i,:))')*(representantes_clase{i}-medias(i,:)));
                    distanciasM(i) = (vector - medias(i,:))*(sigmas{i})*(vector-medias(i,:))';
                end
                
                [~, clasePuntoExtra] = min(distanciasM);
                fprintf('El punto extra pertenece a la clase %d con una "distancia mínima de" de %.2f%\n', clasePuntoExtra, distanciasM(clasePuntoExtra));
           
    
            case 3
                mediasA = zeros(3,n);
                sigmas = cell(1,n);
                distanciasM = zeros(1, n);
                probabilidadesM = zeros(n,1);
                
                for i = 1:n
                    mediasA(:,i) = mean(representantes_clase{i}, 1);
                    medias=transpose(mediasA);
                    sigmas{i} = ((1/rep)*((representantes_clase{i}-medias(i,:))')*(representantes_clase{i}-medias(i,:)));
                    distanciasM(i) = (vector - medias(i,:))*(sigmas{i})*(vector-medias(i,:))';
                    probabilidadesM(i) = (1 / (2 * pi * (sqrt(det(sigmas{i})))))*exp(-0.5*distanciasM(i));
                end
                    
                probabilidades = 1 ./ distanciasM;
                probabilidades = probabilidades / sum(probabilidades); 
                [~, clasePuntoExtra] = max(probabilidades);
                fprintf('El punto extra pertenece a la clase %d con una "probabilidad" de %.2f%%\n', clasePuntoExtra, probabilidades(clasePuntoExtra) * 100);
                   
            case 4
                keep3 = true;
                while keep3
                    k = input('Ingrese el número de vecinos k para KNN: ');
                    if k>rep || (rem(k,2)==0) || k<=0
                        disp('El número de vecinos no puede rebasar al número de representantes por clase ni ser par');
                    else
                        keep3=false;
                        break;
                    end
                end
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
