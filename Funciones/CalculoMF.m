function FrecuenciaMediana = CalculoMF(PSD, freq, banda, bandasfrecuencia,q)
% CALCULOMF Calcula la frecuencia mediana de la distribucion
%       contenida en PSD.
%
%		FRECUENCIAMEDIANA = CALCULOMF(PSD, F, BANDA), calcula la frecuencia 
%       mediana de la distribucion PSD, indexada por el vector F, entre las 
%       frecuencias indicadas en BANDA.
%
%       En FRECUENCIAMEDIANA se devuelve la frecuencia mediana calculada.
%
% See also CALCULARPARAMETRO, CALCULOSEF, CALCULOIAFTF

%
% Versi�n: 2.0
%
% Fecha de creaci�n: 13 de Junio de 2005
%
% �ltima modificaci�n: 25 de ctubre de 2010
%
% Autor: Jes�s Poza Crespo
%

%%%% MODIFICADO PARA WAVELET CON COI  %%%%

% Se inicializa la variable de salida.
FrecuenciaMediana = [];


% Se buscan los �ndices positivos en la banda de paso
indbanda = min(find(freq >= banda(1))) : max(find(freq <= banda(2)));


 % Se recorren las �pocas (2� dimensi�n)
for epoch = 1:size(PSD,2),
    % Se recorren los canales (3� dimensi�n)
    for channel = 1:size(PSD,3),

        % Potencia total para el espectro positivo
        potenciatotal = sum(PSD(indbanda,epoch,channel));
        % Se suman los valores de potencia relativa para el espectro positivo
        vectorsuma = cumsum(PSD(indbanda,epoch,channel));

        % Se coge el �ndice para el cual se tiene la mitad de la potencia total.
        indmitad = max(find(vectorsuma <= (potenciatotal/2)));
        indmedia = indbanda(indmitad);

        % Se toma la frecuencia con la potencia media (frecuencia mediana)
        % En caso de que la PSD no est� definida, la MF tampoco
        if isnan(PSD(indbanda(1),epoch,channel)),
            FrecuenciaMediana(epoch,channel) = NaN;
        % Si no se ha seleccionado ning�n �ndice es porque en el primer valor esta
        % mas del 50% de la potencia total
        else
            if isempty(indmedia),
                indmedia = indbanda(1);
                FrecuenciaMediana(epoch,channel) = freq(indmedia);
            else
                FrecuenciaMediana(epoch,channel) = freq(indmedia);
            end
        end % Fin del 'if' que comprueba si hay algun �ndice
    end
end

clear PSD f banda indbanda potencia toal vectorsuma indmitad indmedia


