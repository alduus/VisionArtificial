clc
close all
clear all
warning off all

% Datos de entrada para la función AND
X = [0 0; 0 1; 1 0; 1 1];
y = [0; 0; 0; 1];

% Inicializar los pesos
pesos = rand(2,1);
bias = rand;
learning_rate = 0.1;
max_iteraciones = 1000;

% Función de activación
activation = @(x) x >= 0;

itera = 0;
converged = false;

% Entrenamiento del perceptrón
while ~converged && itera < max_iteraciones
    itera = itera + 1;
    converged = true;
    
    for i = 1:size(X, 1)
        % Calcular la salida del perceptrón
        output = activation(pesos' * X(i,:)' + bias);
        
        % Actualizar los pesos y el sesgo
        error = y(i) - output;
        if error ~= 0
            converged = false;
            pesos = pesos + learning_rate * error * X(i,:)';
            bias = bias + learning_rate * error;
        end
    end
end

% Calcular los coeficientes de la ecuación de la recta
a = -pesos(1) / pesos(2);
b = -bias / pesos(2);

% Mostrar el número de iteraciones y los pesos ajustados
disp(['No.final iteraciones: ', num2str(itera)]);
disp('Pesos:');
disp(pesos);
disp(['Ecuación final: y = ', num2str(a), '(x) + ', num2str(b)]);

% Graficar los puntos y la línea de separación
figure;
hold on;

% Graficar los puntos de datos
for i = 1:size(X, 1)
    if y(i) == 0
        plot(X(i, 1), X(i, 2), 'o', 'MarkerSize', 10, 'LineWidth', 2);
    else
        plot(X(i, 1), X(i, 2), 'o', 'MarkerSize', 10, 'LineWidth', 2);
    end
end

% Graficar la línea de separación
x_values = linspace(-0.5, 1.5, 100);
y_values = a * x_values + b;
plot(x_values, y_values, 'r-', 'LineWidth', 2);

% Configurar los ejes
xlim([-0.5, 1.5]);
ylim([-0.5, 1.5]);
xlabel('X1');
ylabel('X2');
title('Perceptrón AND');
%legend('Clase 0', 'Clase 1', 'Línea de Separación');

hold off;