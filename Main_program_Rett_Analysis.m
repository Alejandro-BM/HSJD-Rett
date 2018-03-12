%% Programa principal señales EEG Sindome de Reet (Dra. García Cazorla)

%% LIMPIAMOS EL ESPACIO DE TRABAJO
clearvars; close all; home;

%% DEFINICIONES
% Carpetas
[dir_datos, ~, dir_result] = config_function();

% % Log y contar tiempo de ejecucion
%inicio = inicio_de_programa(mfilename);



% Parametros de interés de las señales
fs = 500;
long_epoch = 5 * fs;

% Filtro paso banda
filtro = generar_filtro__0_5_45(fs);


% Se leen los sujetos:
% Para leer los nombres de los archivos de una carpeta
% Se crea una estructura 'sujetos' donde en la variable name se guardan los nombres de los archivos
    %sujetos_=dir([dir_datos 'easy/']); 
    sujetos_=dir([dir_datos 'easy/Archivo_unico/']);
    sujetos_=dir([dir_datos 'easy/Varios_archivos/']);
    sujetos_=dir([dir_datos 'datos_mat/']);
    

    %mkdir([dir_datos 'datos_mat/Varios_archivos/']);

% Para eliminar el directorio punto y dos puntos
sujetos=sujetos_(3:end,:);


% SE LEEN LOS DATOS Y SE GUARDAN EN FORMATO ".mat"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
for nsuj = 1 : length(sujetos),
    nsuj
    % Se crea una variable cabecera "headers", con datos relevantes. Se debería
    % optimizar leyendo esta información del archivo '.info'
    headers = struct();
        headers.name = sujetos(nsuj).name;
        headers.fs = 500;
        headers.EEG_units = 'nV';
        headers.EEG_channels = {'T8','F8','F4','C4','P4','Fz','Cz','Pz','P3','C3','F3','F7','T7'} ; % En el orden en el que figuran en la matriz de datos

    %aux_data = llegir_sessions_easy(sujetos(nsuj).name, [dir_datos 'easy/Archivo_unico/']);  
    aux_data = llegir_sessions_easy(sujetos(nsuj).name, [dir_datos 'easy/Varios_archivos/']);  

    % Nos quedamos solamente con las columnas de interés
    EEG_data = [aux_data(:,2:6), aux_data(:,9:10), aux_data(:,14:19)];
    Acelerometer_data = aux_data(:,21:23);
    Triger_data = aux_data(:,24);
    Time_course_data = aux_data(:,25);

    save([dir_datos 'datos_mat/Varios_archivos/' sujetos(nsuj).name(1:(end-13)) '_extracted.mat'],'headers','EEG_data','Acelerometer_data','Triger_data','Time_course_data');
end
%}



   
% PROCESADO DE LA SEÑAL DE EEG:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for nsuj = 4 % : length(sujetos),
    nsuj
%{
    load([dir_datos 'datos_mat/Varios_archivos/' sujetos(nsuj).name(1:(end-14)) '_extracted.mat'],'headers','EEG_data','Acelerometer_data','Triger_data','Time_course_data','age');
  
    num_channels = size(EEG_data,2);
    % SE ORGANIZA LA INFORMACIÓN EN ÉPOCAS DE 5 s. Y SE ELIMINA EL DETREND LINEAL EN CADA ÉPOCA 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % Se organiza la información en épocas
    EEG_data = EEG_data(1:floor(size(EEG_data,1)/long_epoch)*long_epoch,:);
    EEG_epochs = reshape(EEG_data,long_epoch,floor(size(EEG_data,1)/long_epoch),num_channels);

    % FILTRADO DE LA SEÑAL entre 0.5 y 45 Hz
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    filtered_senyals = [];
    for nEpoch = 1 : size(EEG_epochs,2),
        for nchan = 1 : num_channels,
            aux_data = detrend(EEG_epochs(:,nEpoch,nchan));
            filtered_senyals(:,nEpoch,nchan) = filtfilt(filtro.SOSMatrix, filtro.ScaleValues, aux_data);   
        end
    end
    mkdir([dir_result 'filtered/'])
    save([dir_result 'filtered/' sujetos(nsuj).name(1:(end-14)) '_filtered.mat'],'headers','filtered_senyals','Acelerometer_data','Triger_data','Time_course_data','age');     
%}

    % Prueba piloto de segmentación y rechazo de artefactos:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %{    
    load([dir_result 'filtered/' sujetos(nsuj).name(1:(end-14)) '_filtered.mat'],'headers','filtered_senyals','Acelerometer_data','Triger_data','Time_course_data','age');  

%     factor_k = 4;
%     min_canales = 2;
% 
     senyal_EEG_completa = reshape(filtered_senyals,[size(filtered_senyals,1)*size(filtered_senyals,2),size(filtered_senyals,3)]);
%     media_f = median(senyal_EEG_completa,1);
%     std_f = std(senyal_EEG_completa,0,1);
       
    % Se segmenta la señal en cada canal en segmentos de 5 segundos
%     umbral = media_f + factor_k * std_f;
    umbral = 150000;
    min_canales = 2;
   
    % Se inicializan las matrices de datos
    matriz_rechazo = zeros(size(filtered_senyals,2),size(filtered_senyals,3));
    clean_signal = filtered_senyals;
    artefactos = 0;
    for nSegmento = 1 : size(filtered_senyals,2),
        canales_artefactos = 0;
        % Se recorren los canales
        for nCanal = 1 : size(filtered_senyals,3),
            [nArtefactos ind] = find(abs(filtered_senyals(:,nSegmento,nCanal)) > umbral); %umbral(nCanal) );
            if (sum(nArtefactos) >= 2),   % Elimino la posibilidad de que una única muestra este fuera del umbral (un outlier)
                matriz_rechazo(nSegmento,nCanal) = 1;
                canales_artefactos = canales_artefactos + 1;
            end
        end
        if (canales_artefactos >= min_canales),
           artefactos = artefactos + 1;
           clean_signal(:,nSegmento,:) = NaN;
        end
    end

    mkdir([dir_result 'cleaned_150000/']);
    save([dir_result 'cleaned_150000/' sujetos(nsuj).name(1:(end-14)) '_cleaned.mat'],'headers','Acelerometer_data','Triger_data','Time_course_data','clean_signal','age');

%     mkdir([dir_datos 'cleaned_4-std/']);
%     save([dir_datos 'cleaned_4-std/' num2str(nsuj) '_' sujetos(nsuj).name(1:(end-13)) '_cleaned_k_' num2str(factor_k) '.mat'],'headers','Acelerometer_data','Triger_data','Time_course_data','clean_signal','age');

    
    n_artefactos(nsuj) = artefactos;
    Porcentaje_artefactos(nsuj) = artefactos / size(filtered_senyals,2);

    n_artefactos(nsuj)
    Porcentaje_artefactos(nsuj)
    valid_epochs(nsuj) = size(filtered_senyals,2) - n_artefactos(nsuj)
    total_epochs(nsuj) = size(filtered_senyals,2);

    % Para saber con que umbrales estamos trabajando:
    umbrales(nsuj,:) = umbral;


    figure
    plot(senyal_EEG_completa(:,7))
    hold on
    clean_seynal_EEG_completa = reshape(clean_signal,[size(clean_signal,1)*size(clean_signal,2),size(clean_signal,3)]);
    plot(clean_seynal_EEG_completa(:,7),'r')
    ylim([-500000 500000])
    legend('Senyal original', 'Senyal tras el rechazo de artefactos')
    %title(['Umbral:  ' num2str(umbral(7))]);
    title(['Umbral:  ' num2str(umbral)]);
    
    mkdir([dir_result 'Figures/Artefactos_150000/'])
    nombre_figure = [dir_result 'Figures/Artefactos_150000/' '_Limpieza_Artefactos_' sujetos(nsuj).name(1:end-14)];
    
%     mkdir([dir_datos 'Figures/Artefactos_4-std/'])
%     nombre_figure = [dir_datos 'Figures/Artefactos_4-std/' num2str(nsuj) '_Limpieza_Artefactos_' sujetos(nsuj).name(1:end-14)];

    print('-djpeg', nombre_figure)


    clear EEG_data filtered filtered_senyals clean_signal;
%}
end



% % % % data_artifacts = [total_epochs; valid_epochs; n_artefactos; Porcentaje_artefactos];
% % % % save([dir_datos 'Figures/Artefactos_150000/info_artefactos.mat','data_artifacts']);
% % % % % save([dir_datos 'Figures/Artefactos_4-std/info_artefactos.mat','data_artifacts']);




%% Identificación de diferentes fases en la señal a partir del "Triger_data"

% % Pequeño esbozo de programa para entender la información contenida en la
% % variable "Triger_data":
% % Según la cabecera '.info':
%     % Trigger information:
%     % 	Code	Description
%     % 	1	MOVIMIENTOS
%     % 	2	CRISIS
%     % 	3	APNEA
%     % 	4	SUENYO
%     % 	5	ARTIFACTO POR EQUIPO
%     % 	6	actividades
%     % 	7	musica
%     %   8
%     %   9
%     
%     % Según he observado:
%     % - Aproximadamente sobre la muestra 300.000 (10 min) aparece un 
%     % "Triger_data" igual a 6, lo cúal indica el inicio de la fase en la 
%     % que realizán eye tracking.
%     % - Aproximadamente sobre la muestra 600.000 (20 min) aparece un 
%     % "Triger_data" igual a 7, lo cúal puede indicar el fin de la anterior
%     % fase y el inicio de la fase final en la que escuchan música.



% Según he visto, el triger es siempre 0 y sólo en 2/3 muestras toma otro 
% valor que generalmente es 6 o 7. Por lo tanto pienso que está muestra 
% diferente de 0 se utiliza para marcar el momento del cambio de tarea.

long_epoch = 5 * fs;
NFFT = 4096;
for nsuj =   9  : length(sujetos),
    nsuj
%%{    

%    load([dir_datos 'cleaned_150000/selected/' num2str(nsuj) '_' sujetos(nsuj).name(1:(end-13)) '_cleaned_k_' num2str(factor_k) '.mat'],'headers','Acelerometer_data','Triger_data','Time_course_data','clean_signal');
    
    %load([dir_datos 'cleaned_150000/selected/' sujetos(nsuj).name(1:(end-14)) '_cleaned.mat'],'headers','Acelerometer_data','Triger_data','Time_course_data','clean_signal');
    load([dir_result 'cleaned_150000/' sujetos(nsuj).name(1:(end-14)) '_cleaned.mat'],'headers','Acelerometer_data','Triger_data','Time_course_data','clean_signal','age');

    %load([dir_datos 'datos_mat/cleaned/selected/' sujetos(nsuj).name]);  
    
    % Se identifican las muestras que son diferentes de 0
    [fila,columna]=find(Triger_data~=0);
    Triger_data(fila)  % Se obtiene que tipo de Triger es

    
%     % Por defecto 10 min iniciales, 10 min actividad y 10 min final
%     fin_fase_INICIAL = 10 * 60 * fs;
%     inicio_fase_ACTIVIDADES = (10*60*fs)+1;
%     fin_fase_ACTIVIDADES = 20 * 60 * fs;
%     inicio_fase_FINAL = (20*60*fs)+1;
%     fin_fase_FINAL = floor(size(clean_signal,1)/long_epoch)*long_epoch;
%     
%     for ind = 1 : length(fila)
%         if(Triger_data(fila(ind)) == 6)
%             fin_fase_INICIAL = floor(fila(ind)/long_epoch)*long_epoch;
%             inicio_fase_ACTIVIDADES = ceil(fila(ind)/long_epoch)*long_epoch +1;
%         elseif(Triger_data(fila(ind)) == 7)
%             fin_fase_ACTIVIDADES = floor(fila(ind)/long_epoch)*long_epoch;
%             inicio_fase_FINAL = ceil(fila(ind)/long_epoch)*long_epoch +1;
%         else
%             artefacto = 1
%             index_artifacted_epoch = (floor(fila(ind)/long_epoch)*long_epoch +1) : (ceil(fila(ind)/long_epoch)*long_epoch);
%             clean_signal(index_artifacted_epoch,:) = NaN;
%         end
%     end
%     
%     % Se extraen los datos de cada una de las fases:
%     INICIAL_data = clean_signal(1:fin_fase_INICIAL,:);
%     ACTIVIDAD_data = clean_signal(inicio_fase_ACTIVIDADES:fin_fase_ACTIVIDADES,:);
%     FINAL_data = clean_signal(inicio_fase_FINAL:fin_fase_FINAL,:);
%     
%     % Se organiza la información en épocas
%     INICIAL_epochs = reshape(INICIAL_data,long_epoch,(size(INICIAL_data,1)/long_epoch),13);
%     ACTIVIDAD_epochs = reshape(ACTIVIDAD_data,long_epoch,(size(ACTIVIDAD_data,1)/long_epoch),13);
%     FINAL_epochs = reshape(FINAL_data,long_epoch,(size(FINAL_data,1)/long_epoch),13);

    
 % Por defecto 10 min iniciales, 10 min actividad y 10 min final
    fin_fase_INICIAL = (10 * 60 * fs) / long_epoch;
    inicio_fase_ACTIVIDADES = ((10*60*fs)/long_epoch)+1;
    fin_fase_ACTIVIDADES = (20 * 60 * fs)/long_epoch;
    inicio_fase_FINAL = ((20*60*fs)/long_epoch)+1;
    fin_fase_FINAL = size(clean_signal,2);
    
    for ind = 1 : length(fila)
        if(Triger_data(fila(ind)) == 6)
            fin_fase_INICIAL = floor(fila(ind)/long_epoch);
            inicio_fase_ACTIVIDADES = ceil(fila(ind)/long_epoch);
        elseif(Triger_data(fila(ind)) == 7)
            fin_fase_ACTIVIDADES = floor(fila(ind)/long_epoch);
            inicio_fase_FINAL = ceil(fila(ind)/long_epoch);
        else
            artefacto = 1
            index_artifacted_epoch = floor(fila(ind)/long_epoch);
            clean_signal(:,index_artifacted_epoch,:) = NaN;
        end
    end
    
        % Se extraen los datos de cada una de las fases:
    INICIAL_data = clean_signal(:,1:fin_fase_INICIAL,:);
    ACTIVIDAD_data = clean_signal(:,inicio_fase_ACTIVIDADES:fin_fase_ACTIVIDADES,:);
    FINAL_data = clean_signal(:,inicio_fase_FINAL:fin_fase_FINAL,:);
    
%     % Se organiza la información en épocas
%     INICIAL_epochs = reshape(INICIAL_data,long_epoch,(size(INICIAL_data,1)/long_epoch),13);
%     ACTIVIDAD_epochs = reshape(ACTIVIDAD_data,long_epoch,(size(ACTIVIDAD_data,1)/long_epoch),13);
%     FINAL_epochs = reshape(FINAL_data,long_epoch,(size(FINAL_data,1)/long_epoch),13);
INICIAL_epochs = INICIAL_data;
ACTIVIDAD_epochs = ACTIVIDAD_data;
FINAL_epochs = FINAL_data;

% size(INICIAL_epochs)
% size(ACTIVIDAD_epochs)
% size(FINAL_epochs)
 
%     % Se calcula la PSD a través del periodograma de Welch:
%     for n_channel =  1 : size(INICIAL_epochs,3),
%         for n_epoch = 1 : size(INICIAL_epochs,2),
%             INICIAL_PSD(:,n_epoch,n_channel) = pwelch(INICIAL_epochs(:,n_epoch,n_channel),[],[],[],fs);
%         end
%         for n_epoch = 1 : size(ACTIVIDAD_epochs,2),
%             ACTIVIDAD_PSD(:,n_epoch,n_channel) = pwelch(ACTIVIDAD_epochs(:,n_epoch,n_channel),[],[],[],fs);
%         end
%         for n_epoch = 1 : size(FINAL_epochs,2),
%             FINAL_PSD(:,n_epoch,n_channel) = pwelch(FINAL_epochs(:,n_epoch,n_channel),[],[],[],fs);
%         end
%     end
    
    
    
    
    
     % Se selecciona el segmento de datos   
     INICIAL_PSD = [];   INICIAL_Norm_PSD = [];
     ACTIVIDAD_PSD = []; ACTIVIDAD_Norm_PSD = [];
     FINAL_PSD = [];     FINAL_Norm_PSD = [];
     autocorrsegment = [];
     segment = [];
     NFFT = 4096;
     
     for n_channel =  1 : size(INICIAL_epochs,3),
         for n_epoch = 1 : size(INICIAL_epochs,2),
             segment = squeeze(INICIAL_epochs(:,n_epoch,n_channel));
                 % Se aplica la ventana a cada segmento
                 %segment = segment .* ventanatemp;
             % Se calcula la autocorrelacion del segmento
             autocorrsegment = xcorr(segment,'biased');
             % Se calcula la PSD de cada epoca (filas) y para cada sensor (columnas)
             psdsegment = (1/length(autocorrsegment))*abs(fftshift(fft(autocorrsegment, NFFT),1));
             INICIAL_PSD(:,n_epoch,n_channel) = psdsegment;
             INICIAL_Norm_PSD(:,n_epoch,n_channel) = psdsegment ./ sum(psdsegment);
         end
         for n_epoch = 1 : size(ACTIVIDAD_epochs,2),
             segment = squeeze(ACTIVIDAD_epochs(:,n_epoch,n_channel));
                 % Se aplica la ventana a cada segmento
                 %segment = segment .* ventanatemp;
             % Se calcula la autocorrelacion del segmento
             autocorrsegment = xcorr(segment,'biased');
             % Se calcula la PSD de cada epoca (filas) y para cada sensor (columnas)
             psdsegment = (1/length(autocorrsegment))*abs(fftshift(fft(autocorrsegment, NFFT),1));
             ACTIVIDAD_PSD(:,n_epoch,n_channel) = psdsegment;
             ACTIVIDAD_Norm_PSD(:,n_epoch,n_channel) = psdsegment ./ sum(psdsegment);
         end
         for n_epoch = 1 : size(FINAL_epochs,2),
             segment = squeeze(FINAL_epochs(:,n_epoch,n_channel));
                 % Se aplica la ventana a cada segmento
                 %segment = segment .* ventanatemp;
             % Se calcula la autocorrelacion del segmento
             autocorrsegment = xcorr(segment,'biased');
             % Se calcula la PSD de cada epoca (filas) y para cada sensor (columnas)
             psdsegment = (1/length(autocorrsegment))*abs(fftshift(fft(autocorrsegment, NFFT),1));
             FINAL_PSD(:,n_epoch,n_channel) = psdsegment;
             FINAL_Norm_PSD(:,n_epoch,n_channel) = psdsegment ./ sum(psdsegment);
         end
     end
     
     mean_PSD.INICIAL = squeeze(nanmean(INICIAL_PSD,2));
     mean_Norm_PSD.INICIAL = squeeze(nanmean(INICIAL_Norm_PSD,2));  
     mean_PSD.ACTIVIDAD = squeeze(nanmean(ACTIVIDAD_PSD,2));
     mean_Norm_PSD.ACTIVIDAD = squeeze(nanmean(ACTIVIDAD_Norm_PSD,2));
     mean_PSD.FINAL = squeeze(nanmean(FINAL_PSD,2));
     mean_Norm_PSD.FINAL = squeeze(nanmean(FINAL_Norm_PSD,2));

     mkdir([dir_result 'PSD/']);
     save([dir_result 'PSD/' sujetos(nsuj).name(1:(end-14)) '_PSD.mat'], 'mean_PSD', 'mean_Norm_PSD','age');
     
load([dir_result 'PSD/' sujetos(nsuj).name(1:(end-14)) '_PSD.mat'], 'mean_PSD', 'mean_Norm_PSD','age');
     

% Se representan las figuras del espectro:     
mkdir([dir_result 'Figures/PSD/']);
%frequency = linspace(-250,250,2048);
frequency = linspace(-250,250,NFFT);

% figure
%     subplot(2,1,1)
%     plot(frequency,mean_PSD.INICIAL(:,1))
%     xlim([0,50])
% 
%     subplot(2,1,2)
%     plot(frequency,mean_Norm_PSD.INICIAL(:,1))
%     xlim([0,50])
% 
% 
% figure
%     subplot(2,1,1)
%     plot(frequency,mean_PSD.ACTIVIDAD(:,1))
%     xlim([0,50])
% 
%     subplot(2,1,2)
%     plot(frequency,mean_Norm_PSD.ACTIVIDAD(:,1))
%     xlim([0,50])
% 
% 
% figure
%     subplot(2,1,1)
%     plot(frequency,mean_PSD.FINAL(:,1))
%     xlim([0,50])
% 
%     subplot(2,1,2)
%     plot(frequency,mean_Norm_PSD.FINAL(:,1))
%     xlim([0,50])

figure
    subplot(3,1,1)
    plot(frequency,mean_Norm_PSD.INICIAL(:,1))
    xlim([0,50])
    title('Fase Inicial')

    subplot(3,1,2)
    plot(frequency,mean_Norm_PSD.ACTIVIDAD(:,1))
    xlim([0,50])
    title('Fase de Actividad')

    subplot(3,1,3)
    plot(frequency,mean_Norm_PSD.FINAL(:,1))
    xlim([0,50])
    title('Fase Final')
    
    nombre_figure = [dir_result 'Figures/PSD/PSD_' sujetos(nsuj).name(1:(end-14))];
    print('-djpeg', nombre_figure)
    
figure
    plot(frequency,mean_Norm_PSD.INICIAL(:,1),'b')
    hold on
    plot(frequency,mean_Norm_PSD.ACTIVIDAD(:,1),'r')
    plot(frequency,mean_Norm_PSD.FINAL(:,1),'g')
    xlim([0,50])
    title('PSD para cada una de las fases')
    legend('Fase Inicial', 'Fase de Actividad', 'Fase Final')
    
    nombre_figure = [dir_result 'Figures/PSD/PSD_junto_' sujetos(nsuj).name(1:(end-14))];
    print('-djpeg', nombre_figure)


    % Se calcula la potencia relativa:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkdir([dir_result 'Parameters/']);

PotenciaRelativa_Absoluta.INICIAL = CalculoAP(INICIAL_PSD,frequency,[1 29],[1 4; 4 7; 8 13; 14 29]);
PotenciaRelativa_Norm.INICIAL = CalculoRP(INICIAL_Norm_PSD,frequency,[1 29],[1 4; 4 7; 8 13; 14 29]);

PotenciaRelativa_Absoluta.ACTIVIDAD = CalculoAP(ACTIVIDAD_PSD,frequency,[1 29],[1 4; 4 7; 8 13; 14 29]);
PotenciaRelativa_Norm.ACTIVIDAD = CalculoRP(ACTIVIDAD_Norm_PSD,frequency,[1 29],[1 4; 4 7; 8 13; 14 29]);

PotenciaRelativa_Absoluta.FINAL = CalculoAP(FINAL_PSD,frequency,[1 29],[1 4; 4 7; 8 13; 14 29]);
PotenciaRelativa_Norm.FINAL = CalculoRP(FINAL_Norm_PSD,frequency,[1 29],[1 4; 4 7; 8 13; 14 29]);

save([dir_result 'Parameters/' sujetos(nsuj).name(1:(end-14)) '_Parameters_PSD.mat'], 'PotenciaRelativa_Absoluta', 'PotenciaRelativa_Norm','age');

MF.INICIAL = CalculoMF(INICIAL_PSD,frequency,[1 29],[],[]);
MF.ACTIVIDAD = CalculoMF(ACTIVIDAD_PSD,frequency,[1 29],[]);
MF.FINAL = CalculoMF(FINAL_PSD,frequency,[1 29],[]);

save([dir_result 'Parameters/' sujetos(nsuj).name(1:(end-14)) '_Parameters_PSD.mat'], 'MF','-append');

SE.INICIAL = CalculoSE(INICIAL_PSD,frequency,[1 29],[]);
SE.ACTIVIDAD = CalculoSE(ACTIVIDAD_PSD,frequency,[1 29],[]);
SE.FINAL = CalculoSE(FINAL_PSD,frequency,[1 29],[]);

save([dir_result 'Parameters/' sujetos(nsuj).name(1:(end-14)) '_Parameters_PSD.mat'], 'SE','-append');


% Se calcula el BSI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% El orden de los canales es:
% 1. T8;  2. F8;  3. F4;  4. C4;  5. P4; 6. Fz; 7. Cz; 8. Pz; 
% 9. P3; 10. C3; 11. F3; 12. F7; 13. T7

% BSI en T7/T8:
%BSI_T7_8 = (PotenciaRelativa_Norm.INICIAL(:,:,13) - PotenciaRelativa_Norm.INICIAL(:,:,1)) ./ (PotenciaRelativa_Norm.INICIAL(:,:,13) + PotenciaRelativa_Norm.INICIAL(:,:,1));
%mean_BSI_T7_8 = mean((PotenciaRelativa_Norm.INICIAL(:,:,13) - PotenciaRelativa_Norm.INICIAL(:,:,1)) ./ (PotenciaRelativa_Norm.INICIAL(:,:,13) + PotenciaRelativa_Norm.INICIAL(:,:,1)),2);
%m_BSI_T7_8 = (mean(PotenciaRelativa_Norm.INICIAL(:,:,13),2) - mean(PotenciaRelativa_Norm.INICIAL(:,:,1),2)) ./ (mean(PotenciaRelativa_Norm.INICIAL(:,:,13),2) + mean(PotenciaRelativa_Norm.INICIAL(:,:,1),2));

RP_aux = squeeze(nanmean(PotenciaRelativa_Norm.INICIAL,2));
m_BSI_T7_8{1} = (RP_aux(:,13) - RP_aux(:,1)) ./ (RP_aux(:,13) + RP_aux(:,1));
m_BSI_F7_8{1} = (RP_aux(:,12) - RP_aux(:,2)) ./ (RP_aux(:,12) + RP_aux(:,2));
m_BSI_F3_4{1} = (RP_aux(:,11) - RP_aux(:,3)) ./ (RP_aux(:,11) + RP_aux(:,3));
m_BSI_C3_4{1} = (RP_aux(:,10) - RP_aux(:,4)) ./ (RP_aux(:,10) + RP_aux(:,4));
m_BSI_P3_4{1} = (RP_aux(:,9)  - RP_aux(:,5)) ./ (RP_aux(:,9)  + RP_aux(:,5));


RP_aux = squeeze(nanmean(PotenciaRelativa_Norm.ACTIVIDAD,2));
m_BSI_T7_8{2} = (RP_aux(:,13) - RP_aux(:,1)) ./ (RP_aux(:,13) + RP_aux(:,1));
m_BSI_F7_8{2} = (RP_aux(:,12) - RP_aux(:,2)) ./ (RP_aux(:,12) + RP_aux(:,2));
m_BSI_F3_4{2} = (RP_aux(:,11) - RP_aux(:,3)) ./ (RP_aux(:,11) + RP_aux(:,3));
m_BSI_C3_4{2} = (RP_aux(:,10) - RP_aux(:,4)) ./ (RP_aux(:,10) + RP_aux(:,4));
m_BSI_P3_4{2} = (RP_aux(:,9)  - RP_aux(:,5)) ./ (RP_aux(:,9)  + RP_aux(:,5));

RP_aux = squeeze(nanmean(PotenciaRelativa_Norm.FINAL,2));
m_BSI_T7_8{3} = (RP_aux(:,13) - RP_aux(:,1)) ./ (RP_aux(:,13) + RP_aux(:,1));
m_BSI_F7_8{3} = (RP_aux(:,12) - RP_aux(:,2)) ./ (RP_aux(:,12) + RP_aux(:,2));
m_BSI_F3_4{3} = (RP_aux(:,11) - RP_aux(:,3)) ./ (RP_aux(:,11) + RP_aux(:,3));
m_BSI_C3_4{3} = (RP_aux(:,10) - RP_aux(:,4)) ./ (RP_aux(:,10) + RP_aux(:,4));
m_BSI_P3_4{3} = (RP_aux(:,9)  - RP_aux(:,5)) ./ (RP_aux(:,9)  + RP_aux(:,5));


mean_BSI{1} = mean([m_BSI_T7_8{1}, m_BSI_F7_8{1}, m_BSI_F3_4{1}, m_BSI_C3_4{1}, m_BSI_P3_4{1}],2);
mean_BSI{2} = mean([m_BSI_T7_8{2}, m_BSI_F7_8{2}, m_BSI_F3_4{2}, m_BSI_C3_4{2}, m_BSI_P3_4{2}],2);
mean_BSI{3} = mean([m_BSI_T7_8{3}, m_BSI_F7_8{3}, m_BSI_F3_4{3}, m_BSI_C3_4{3}, m_BSI_P3_4{3}],2);

save([dir_result 'Parameters/' sujetos(nsuj).name(1:(end-14)) '_Parameters_PSD.mat'], 'm_BSI_T7_8', 'm_BSI_F7_8','m_BSI_F3_4','m_BSI_C3_4','m_BSI_P3_4','mean_BSI','-append');

%}
end
    

