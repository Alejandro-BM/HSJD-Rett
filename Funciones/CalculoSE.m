function EntropiaShannon = CalculoSE(PSD,freq,banda,bandasfrecuencia, q)
% CALCULOSE Calcula la entropía de Shannon de la distribucion indicada.
%
%		ENTROPIASHANNON = CALCULOSE(PSD,F,INDBANDA), calcula la  
%       entropía de Shannon de la de la distribucion PSD, indexada por el 
%       vector de frecuencias F, entre las frecuencias indicadas en BANDA.
%       Entradas:
%           - PSD: Matriz compleja de 3 dimensiones con los datos de los
%             coeficientes de la TW. En la primera dimensión se encuentran
%             los valores del tiempo. En la segunda dimensión la frecuencia
%             y la tercera dimensión se corresponde con las épocas/trials.
%           - F : [] No se usa en esta función.
%           - INDBANDA: Representa los coeficientes de la TW que están 
%             dentro de la COI de la banda de frecuencia considerada. 
%           - Q: [] No se usa en esta función.
%
%       En ENTROPIASHANNON se devuelve la entropía de Shannon.
%
% See also CALCULARPARAMETRO, CALCULOTE, CALCULORE, CALCULOETE

%
% Versión: 2.0
%
% Fecha de creación: 08 de Mayo de 2006
%
% Última modificación: 11 de Marzo de 2014
%
% Autor: Jesús Poza Crespo
% Modificación: Alejandro Bachiller Matarranz
%


% Se inicializa el vector de retorno.
EntropiaShannon = [];

% Se buscan los índices positivos en la banda de paso
indbanda = min(find(freq >= banda(1))) : max(find(freq <= banda(2)));

% Se calcula el valor de la potencia total en la banda de frecuencia 
% seleccionada mediante "indbanda".
potenciatotal = sum(PSD(indbanda,:,:),1);

% Se calcula la función densidad de probabilidad en la banda

fdp = PSD(indbanda,:,:) ./ repmat(potenciatotal, [length(indbanda),1,1]);

% Se calcula la entropía de Shannon normalizada
EntropiaShannon = squeeze(-sum(fdp.*log(fdp),1)/log(size(fdp,1)));

clear PSD f banda indbanda potenciatotal fdp i j v
end


% % Se inicializa el vector de retorno.
% EntropiaShannon = [];
% 
% % Se buscan los índices positivos en la banda de paso considerada.
% %indbanda = find(f >= banda(1) & f <= banda(2));
% 
% % Se halla la "Wavelet Energy" de la PSD
% WE_PSD = abs(PSD).^2;
% 
% % Se calcula el valor de la potencia total para el espectro positivo.
% potenciatotal = sum(WE_PSD(indbanda));
% % Se calcula la función densidad de probabilidad en la banda
% fdp = WE_PSD(indbanda)/potenciatotal;
% % Se obtiene la entropia de Shannon normalizada
% [i,j,v] = find(fdp);
% 
% % Se calcula la entropía de Shannon normalizada
% EntropiaShannon = -sum(v.*log(v))/log(length(v));
% 
% clear PSD f banda indbanda potenciatotal fdp i j v
% end