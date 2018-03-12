function PSDDatos = CalcularPSD(datos,solapamiento,longsegmento,ventana)
% CALCULARPSD Funcion para calcular la densidad espectral de potencia (PSD, 
%       Power Spectral Density) de las series temporales de un conjunto de 
%       canales mediante la transformada de Fourier o la transformada corta
%       de Fourier.
%
%       PSDDATOS = CALCULARPSD(DATOS,SOLAPAMIENTO,LONGSEGMENTO,VENTANA), 
%		calcula la PSD de las series temporales contenidas en DATOS. 
%       SOLAPAMIENTO indica el porcentaje de solapmiento considerado, 
%       LONGSEGMENTO la longitud de los segmentos en los que se van a 
%       dividir los datos para calcular la PSD y VENTANA el nombre de la 
%       ventana temporal que se va a aplicar.
%		Devuelve en PSDDATOS una estructura con la identificacion del 
%       filtro utilizado, la longitud de los segmentos originales,
%       informacion sobre el rechazo de artefactos, informacion sobre el
%       cálculo de la PSD, y la PSD de los datos.
%
%       Variables de entrada requeridas:
%           * DATOS: Estructura con los datos de entrada.
%               - DATOS.NAME: Cadena con el identificador del sujeto.
%               - DATOS.DATA: Matriz con los datos que no tenían artefactos
%                 (filas) de cada sensor (columnas), los datos con 
%                 artefactos se han sustituido por vectores de 'NaN'.
%               - DATOS.CONFIG.FS: Frecuencia de muestreo.
%               - DATOS.CONFIG.CHANNELS: Array con la identificación de los
%                 canales.
%               - DATOS.CONFIG.FILTERNAME: Cadena con el nombre del filtro.
%               - DATOS.CONFIG.FILTER: Datos de configuración del filtro 
%                 utilizado.
%               - DATOS.CONFIG.LENGTHEPOCH: Número de muestras de los
%                 segmentos.
%               - DATOS.CONFIG.ARTIFACTS: Array con el número de segmentos 
%                 con artefactos para cada sensor.
%               - DATOS.CONFIG.EPOCHS: Array con el número de segmentos sin
%                 sin artefactos para cada sensor.
%           * SOLAPAMIENTO: Valor que indica el porcentaje de solapamiento
%             considerado para calcular la PSD.
%           * LONGSEGMENTO: Número de muestras de los trozos de segmento 
%             considerados para calcular la PSD.
%           * VENTANA: Cadena que indica la ventana utilizada para calcular
%             la PSD: 'rectangular' (ventana rectangular), 'hamming' 
%             (ventana de Hamming simétrica), 'hanning' (ventana de Hanning
%             simétrica), 'triangular' (ventana triangular), 'bartlett' 
%             (ventana de Bartlett), 'blackman' (ventana de Blackman 
%             simétrica), 'blackman-harris' (ventana de Blackman-harris 
%             "minimum 4-term"), 'gaussian' (ventana gaussiana), 'kaiser' 
%             (ventana de Kaiser con "beta = 0.5"), 'tukey' (ventana de
%             Tukey con "r = 0.5"), 'chebyshev' (ventana de Chebyshev con 
%             "r = 100.00 dB"), 'parzen' (ventana  de Parzen de la 
%             Valle-Poussin), 'bohman' (ventana de  Bohman), 'flat-top' 
%             (ventana "Flat Top weighted" simétrica).
%
%       Variables de salida:
%           * PSDDATOS: Estructura con la PSD de los datos. Los campos 
%             opcionales aparecen marcados con un asterisco ('*'):
%               - PSDDATOS.NAME: Cadena con el identificador del sujeto.
%               - PSDDATOS.PSD: Matriz de cuatro dimensiones con la PSD de 
%                 los datos: "PSD(tiempo,sensor,psd, época)". La matriz 
%                 está ordenada de manera que hay tantas filas como 
%                 segmentos se consideren en la STFT (1ª dimension, 
%                 "tiempo"), tantas columnas como sensores (2ª dimension, 
%                 "sensor"), tantos elementos en la 3ª dimension como 
%                 puntos tenga la PSD (3ª dimension, "psd") y tantos
%                 elementos en la 4ª dimension como épocas (filas) tuviera 
%                 la estructura de datos de entrada DATOS.DATA (4ª
%                 dimension, "epoca").
%               - PSDDATOS.FREQUENCY: Vector de frecuencias.
%               - PSDDATOS.CONFIG.FS: Frecuencia de muestreo.
%               - PSDDATOS.CONFIG.CHANNELS: Array con la identificación de 
%                 los canales.
%               - PSDDATOS.CONFIG.FILTERNAME: Cadena con el nombre del 
%                 filtro.
%               - PSDDATOS.CONFIG.FILTER: Datos de configuración del filtro
%                 utilizado.
%               - PSDDATOS.CONFIG.LENGTHEPOCH: Número de muestras de los 
%                 segmentos.
%               - PSDDATOS.CONFIG.ARTIFACTS: Array con el número de  
%                 segmentos con artefactos para cada sensor.
%               - PSDDATOS.CONFIG.EPOCHS: Array con el número de épocas  
%                 sin artefactos para cada senor.
%               - PSDDATOS.CONFIG.TFR: Cadena que indica la representacion 
%                 tiempo-frecuencia que se va a cacular, p.ej.: 'STFT'
%                 (Short-Time Fourier Transform), 'CWT' (Continuous Wavelet
%                 Transform) o 'WVD' (Wigner-Ville Distribution).
%               - PSDDATOS.CONFIG.OVERLAP: Valor que indica el porcentaje
%                 de solapamiento considerado para calcular la PSD.
%               - PSDDATOS.CONFIG.LENGTHSEGMENT: Número de muestras de los
%                 trozos de segmento considerados para calcular la PSD.
%               - PSDDATOS.CONFIG.SEGMENTS: Número de trozos de segmento 
%                 que reflejan la variación temporal.
%               - PSDDATOS.CONFIG.WINDOW: Cadena que indica la ventana
%                 utilizada para calcular la PSD.
%               - PSDDATOS.CONFIG.NORMALIZATIONBAND(*): Array que indica la
%                 banda de frecuencias sobre la que se realiza la
%                 normalización.
%               - PSDDATOS.CONFIG.AVERAGE: Cadena que indica el tipo de
%                 promedio realizado sobre la PSD, en su caso.
%
%       Uso:
%           >> load('C:\EEG\Señales\001_Limp_1_40_Esquizo.mat'); % Se carga la estructura 'cleansignals' con las señales sin artefactos
%           >> psdsignals = CalcularPSD(cleansignals,0,1024,'rectangular');
%           >> save('001_PSD_1_40_Esquizo.mat'], 'psdsignals'); % Se guardan las PSDs de los datos
%
%           >> psdsignals = CalcularPSD(cleansignals,50,1024,'blackman');
%
% See also FILTRARDATOS, RECHAZARARTEFACTOS, CALCULARPARAMETRO

%
% Versión: 2.0
%
% Fecha de creación: 04 de Octubre de 2009
%
% Última modificación: 22 de Julio de 2011
%
% Autor: Jesús Poza Crespo


% Se calculan las muestras que hay que solapar
longsolapamiento = floor(longsegmento*(0.01*solapamiento));

% Se construye la ventana temporal a aplicar
if strcmp(ventana,'rectangular'),
    ventanatemp = rectwin(longsegmento);
elseif strcmp(ventana,'hamming'),
    ventanatemp = hamming(longsegmento);
elseif strcmp(ventana,'hanning'),
    ventanatemp = hann(longsegmento);
elseif strcmp(ventana,'triangular'),
    ventanatemp = triang(longsegmento);
elseif strcmp(ventana,'bartlett'),
    ventanatemp = bartlett(longsegmento);
elseif strcmp(ventana,'blackman'),
    ventanatemp = blackman(longsegmento);
elseif strcmp(ventana,'blackman-harris'),
    ventanatemp = blackmanharris(longsegmento);
elseif strcmp(ventana,'gaussian'),
    ventanatemp = gausswin(longsegmento);
elseif strcmp(ventana,'kaiser'),
    ventanatemp = kaiser(longsegmento,0.5);
elseif strcmp(ventana,'tukey'),
    ventanatemp = tukeywin(longsegmento,0.5);
elseif strcmp(ventana,'chebyshev'),
    ventanatemp = chebwin(longsegmento,100);
elseif strcmp(ventana,'parzen'),
    ventanatemp =  parzenwin(longsegmento);
elseif strcmp(ventana,'bohman'),
    ventanatemp =   bohmanwin(longsegmento);
elseif strcmp(ventana,'flat-top'),
    ventanatemp =   flattopwin(longsegmento);
else
    error('La ventana especificada no es válida'),
end

% Se calcula la PSD para cada segmento, como la transformada de Fourier de
% la funcion de autocorrelacion. Para que los resultados coincidan con el
% cálculo teórico hay que dividir entre el número de muestras.
data = [];
aux_indices = [];
% Se comprueba que la longitud de los trozos de segmento no exceda la de los segmentos



% datos.config.lengthepoch
% longsegmento
% floor(size(datos.data,1)/datos.config.lengthepoch)
%size(ventanatemp)

if datos.config.epochs == 0,
    numsegments = 0;
elseif datos.config.lengthepoch >= longsegmento,
    % Al ser la matriz de entrada de 3 dimensiones, se tienen que recorrer
    % las épocas y se extraen los segmentos de longitud "longsegmento"
    for epochs = 1:size(datos.data,1),
            dataepoch = [];
            numsegments = 0;  
            ind1 = 1;
            ind2 = longsegmento;
        while ind2 <= datos.config.lengthepoch,     
            % Se inicializan las estructuras que contendrán la
            % autocorrelacion y la PSD de cada segmento
            autocorrsegment = [];
            psdsegment = [];
            for sensor = 1:size(datos.data,2),
                % Se selecciona el segmento de datos
                segment = [];
                segment = squeeze(datos.data(epochs,sensor,ind1:ind2));
                % Se aplica la ventana a cada segmento
                segment = segment .* ventanatemp;
                % Se calcula la autocorrelacion del segmento
                autocorrsegment = [autocorrsegment xcorr(segment,'biased')];
            end % Fin del 'for' que recorre cada sensor
            % Se calcula la PSD de cada epoca (filas) y para cada sensor (columnas)
            %psdsegment = (1/longsegmento)*abs(fftshift(fft(autocorrsegment, size(autocorrsegment,1)),1));
            psdsegment = (1/longsegmento)*abs(fftshift(fft(autocorrsegment, 256),1));
            size(psdsegment); %tamaño 67x16
            % Se añade (en la 1ª dimension o una fila adicional) el bloque de PSDs para cada sensor.
            dataepoch = cat(1,dataepoch,permute(psdsegment,[3 2 1]));
            %matrizSegment(segmento,:,:) = psdsegment'; 
            % Se actualizan los índices
            aux_indices(numsegments+1,:) = [ind1, ind2];
            ind1 = ind1 + longsegmento - longsolapamiento;
            ind2 = ind2 + longsegmento - longsolapamiento;
            numsegments = numsegments + 1;
        end % Fin del 'while' que recorre cada trozo de segmento
        % Se añade (en la 4ª dimensión) el bloque de PSDs de cada época
        data(:,:,:,epochs) = dataepoch;
    end % Fin del 'for' que recorre las épocas
            
          
% % %             %for epochs = 1:floor(size(datos.data,1)/datos.config.lengthepoch),
% % %             % Se inicializan los índices para cada trozo de segmento
% % %             ind1 = 1;
% % %             ind2 = longsegmento;
% % %             numsegments = 0;
% % %             ind3 = (epochs-1)*datos.config.lengthepoch;
% % %             % Se inicializa la estructura que contendrá la PSD de cada época
% % %             dataepoch = [];
% % %             while ind2 <= datos.config.lengthepoch,
% % %                 % Se inicializan las estructuras que contendrán la autocorrelacion y la PSD de cada segmento
% % %                 autocorrsegment = [];
% % %                 psdsegment = [];
% % %                 for sensor = 1:size(datos.data,2),
% % %                     % Se selecciona el segmento de datos
% % %                     segment = [];
% % %                     segment = datos.data(ind3+ind1:ind3+ind2,sensor);
% % %                     % Se aplica la ventana a cada segmento
% % %                     segment = segment .* ventanatemp;
% % %                     % Se calcula la autocorrelacion del segmento
% % %                     autocorrsegment = [autocorrsegment xcorr(segment,'biased')];
% % %                 end % Fin del 'for' que recorre cada sensor
% % %                 % Se calcula la PSD de cada segmento (filas) para cada sensor (columnas)
% % %                 psdsegment = (1/longsegmento)*abs(fftshift(fft(autocorrsegment, size(autocorrsegment,1)),1));
% % %                 % Se añade (en la 1ª dimension o una fila adicional) el bloque de PSDs para cada sensor.
% % %                 dataepoch = cat(1,dataepoch,permute(psdsegment,[3 2 1]));
% % %                 % Se actualizan los índices
% % %                 ind1 = ind1 + longsegmento - longsolapamiento;
% % %                 ind2 = ind2 + longsegmento - longsolapamiento;
% % %                 numsegments = numsegments + 1;
% % %             end % Fin del 'while' que recorre cada trozo de segmento
% % %             % Se añade (en la 4ª dimensión) el bloque de PSDs de cada época
% % %             data(:,:,:,epochs) = dataepoch;
% % %         end % Fin del 'for' que recorre las épocas
% % %     %numsegments
else
    error('La longitud de los intervalos temporales excede la de los segmentos');
end % Fin del 'if' que comprueba la longitud de los segmentos

% Configuramos los campos de la variable de salida
PSDDatos(1).name = datos.name;
PSDDatos(1).data = data;
PSDDatos(1).frequency = linspace(-datos.config.fs/2,datos.config.fs/2,size(data,3));
PSDDatos(1).config.fs = datos.config.fs;
PSDDatos(1).config.channels = datos.config.channels;
PSDDatos(1).config.filtername = datos.config.filtername;
PSDDatos(1).config.filter = datos.config.filter;
PSDDatos(1).config.lengthepoch = datos.config.lengthepoch;
PSDDatos(1).config.artifacts = datos.config.artifacts;
PSDDatos(1).config.epochs = datos.config.epochs;
PSDDatos(1).config.tfr = 'STFT';
PSDDatos(1).config.overlap = solapamiento;
PSDDatos(1).config.lengthsegment = longsegmento;
PSDDatos(1).config.segments = numsegments;
PSDDatos(1).config.segment_index = aux_indices;
PSDDatos(1).config.window = ventana;
PSDDatos(1).config.normalizationband = [];
PSDDatos(1).config.average = [];

clear data longsolapamiento ventanatemp ind1 ind2 segment autocorrsegment psdsegment numsegments