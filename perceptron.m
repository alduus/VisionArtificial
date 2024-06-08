% Limpiar el entorno de trabajo
clc;
clear;
close all;
warning off all;

    X = [0 0 0; 1 0 0; 1 0 1; 1 1 0];
    Y = [0 0 1; 0 1 1; 1 1 1; 0 1 0];

while true
    % Solicitar al usuario ingresar los pesos y el coeficiente de error
    w=zeros(4,1);
    disp('Ingrese los  pesos  [wx, wy, w0]: ');
    w(1) = input('ingrese valor de w1');
    w(2) = input('ingrese valor de w2');
    w(3) = input('ingrese valor de w3');
    w(4) = input('ingrese valor de w4');



    % Definimos las clases

    %X = [2 1 1; 1 2 -1; -2 -1 1; -1 -2 -1];
    %X = [4 2 1; 2 4 1; -4 -2 1; -2 -4 1];


    %X = [4 2 1; -2 -4 1; -4 -2 -1; -2 -4 -1];

    % Inicialización de variables de control
    converge = false;
    errores = 1;
    % Bucle principal para el aprendizaje del perceptrón
    while errores==1
        errores=0;
        disp(' ');
        disp('Etapa de aprendizaje:');

        for i = 1:1:4
            vector=cat(2,X(i,:),1);
            fsal=vector*w;
            if fsal>=0
                w=w-vector';
                errores=1;
            end
        end
        for i = 1:1:4
            vector=cat(2,Y(i,:),1);
            fsal=vector*w;
            if fsal<=0
                w=w+vector';
                errores=1;
            end
        end
          
    end

    % Mostrar los valores finales de los pesos
    disp(' ');
    disp(['Valores finales de los pesos: ' mat2str(w)]);

    % Crear una nueva figura para el gráfico
    figure;

    % Crear el eje
    axis = axes('Parent', gcf);


    % Dibujar los puntos de datos y las clases

   for i = 1:length(X)
        plot3(X(i, 1), X(i, 2),X(i,3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'magenta');
        grid("on");
        hold("on");
   end
   for i = 1:length(Y)
   
        grid("on");
        hold("on");
        plot3(Y(i, 1), Y(i, 2),Y(i,3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'yellow');

    end

    a = (w(1));
    b = (w(2));
    c = (w(3));
    d = (w(4));


    [x,y] = meshgrid(-4:4:4);
    % dx = yp*zp;
    % dy = -xp*zp;
    % dz = xp*yp;
    % a = -dx/dz;
    % b = dy/dz;
    % c = ((xp*dx - yp*dy)/dz) - zp;

    %a = -zp/xp;
    %b = -zp/yp;
    %c = zp;
    %z = a*x + b*y + c;
    z = (-a*x - b*y -d)/c;

    surf(x, y, z);
    hold off;

    
    % Preguntar al usuario si desea realizar nuevos cálculos
    respuesta = input('\n¿Desea realizar nuevos cálculos? (S/N): ', 's');
    
    % Si la respuesta no es 'S' o 's', terminar el programa
    if ~(respuesta == 'S' || respuesta == 's')
        break;
    end
end