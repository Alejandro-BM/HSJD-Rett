function PotenciaRelativa = CalculoRP(PSD, freq, banda, bandasfrecuencia)
% CALCULORP Calcula la potencia relativa para las subbandas indicadas en 
%       BANDASFRECUENCIA.
%
%		POTENCIARELATIVA = CALCULORP(PSD, F, BANDA, BANDASFRECUENCIA), 
%       calcula la potencia relativa a partir de la densidad espectral de
%       potencia de PSD, , indexada por el vector F, entre las frecuencias 
%       indicadas en BANDA. Para ello se suman los valores correspondientes 
%       en cada banda de frecuencia de la matriz BANDASFRECUENCIA, que
%       contiene las bandas consideradas (filas) y los límites
%       correspondientes (columnas), y se divide por la potencia total en
%       la banda de paso considerada BANDA.
%
%       En POTENCIARELATIVA se devuelve la potencia relativa para cada 
%       subbanda.
%
% See also CALCULARPARAMETRO, CALCULOAP

%
% Versión: 2.0
%
% Fecha de creación: 11 de Marzo de 2005
%
% Última modificación: 14 de Octubre de 2009
%
% Autor: Jesús Poza Crespo
%

% Se inicializa el vector de retorno.
PotenciaRelativa = [];

% Se buscan los índices positivos en la banda de paso
indbanda = min(find(freq >= banda(1))) : max(find(freq <= banda(2)));

 % Se recorren las épocas (2ª dimensión)
for epoch = 1:size(PSD,2),
    % Se recorren los canales (3ª dimensión)
    for channel = 1:size(PSD,3),
        

        % Se buscan los índices positivos en la banda de paso
        %edit%%%indbanda = find((f >= banda(1)) & (f <= banda(2)));
        % Se recorren las bandas de frecuencia consideradas
        for i = 1:size(bandasfrecuencia, 1),
            aux_RP = [];
            % Se buscan los índices positivos en las bandas de frecuencia
            indbandasfrecuencia = min(find(freq >= bandasfrecuencia(i, 1))):max(find(freq <= bandasfrecuencia(i, 2)));
            % Se haya la potencia absoluta en las bandas consideradas
            PotenciaRelativa(i,epoch,channel)= sum(PSD(indbandasfrecuencia,epoch,channel));
        end % Fin del 'for' que recorre las bandas de frecuencia elegidas

        % Se haya la potencia relativa en las bandas consideradas.
        PotenciaRelativa(:,epoch,channel) = PotenciaRelativa(:,epoch,channel) ./ sum(PSD(indbanda,epoch,channel));
    end
end

        
clear PSD f banda bandasfrecuencia indbanda indbandasfrecuencia