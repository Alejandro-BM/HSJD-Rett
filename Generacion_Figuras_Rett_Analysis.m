
%% Programa principal señales EEG Sindome de Reet (Dra. García Cazorla)

%% LIMPIAMOS EL ESPACIO DE TRABAJO
clearvars; close all; home;

%% DEFINICIONES
% Carpetas
[dir_datos, ~, dir_result, dir_Dropbox] = config_function();

% % Log y contar tiempo de ejecucion
%inicio = inicio_de_programa(mfilename);

% Se leen los sujetos:
    % Para leer los nombres de los archivos de una carpeta
    % Se crea una estructura 'sujetos' donde en la variable name se guardan los nombres de los archivos
    sujetos_=dir([dir_result 'Parameters/']);

    % Para eliminar el directorio punto y dos puntos
    sujetos=sujetos_(3:end-1,:);


% Datos de las señales
Fs = 500;
long_epoch = 5 * Fs;

locfile = [dir_Dropbox '1_Recerca/1_Software/locs/EEG_Rett-10-20-Cap13.locs'];
elocs = readlocs(locfile);


% SE LEEN LOS DATOS DE POTENCIAS RELATIVAS Y BSI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
INICIAL_RP = []; ACTIVIDAD_RP=[]; FINAL_RP=[];
INICIAL_AP = []; ACTIVIDAD_AP=[]; FINAL_AP=[];
INICIAL_MF = []; ACTIVIDAD_MF=[]; FINAL_MF=[];
INICIAL_SE = []; ACTIVIDAD_SE=[]; FINAL_SE=[];
Matriz_diferencia_RP = []; Matriz_diferencia_AP = []; 
Matriz_diferencia_SE = []; Matriz_diferencia_MF = []; 

for nsuj = 1 : length(sujetos),
    nsuj
    
    load([dir_result 'Parameters/' sujetos(nsuj).name(1:end-19) '_Parameters_PSD.mat']);


    INICIAL_RP(:,:,nsuj) = squeeze(nanmedian(PotenciaRelativa_Norm.INICIAL,2));
    ACTIVIDAD_RP(:,:,nsuj) = squeeze(nanmedian(PotenciaRelativa_Norm.ACTIVIDAD,2));
    FINAL_RP(:,:,nsuj) = squeeze(nanmedian(PotenciaRelativa_Norm.FINAL,2));

    INICIAL_AP(:,:,nsuj) = squeeze(nanmedian(PotenciaRelativa_Absoluta.INICIAL,2));
    ACTIVIDAD_AP(:,:,nsuj) = squeeze(nanmedian(PotenciaRelativa_Absoluta.ACTIVIDAD,2));
    FINAL_AP(:,:,nsuj) = squeeze(nanmedian(PotenciaRelativa_Absoluta.FINAL,2));

    INICIAL_MF(:,nsuj) = squeeze(nanmedian(MF.INICIAL,1));
    ACTIVIDAD_MF(:,nsuj) = squeeze(nanmedian(MF.ACTIVIDAD,1));
    FINAL_MF(:,nsuj) = squeeze(nanmedian(MF.FINAL,1));

    INICIAL_SE(:,nsuj) = squeeze(nanmedian(SE.INICIAL,1));
    ACTIVIDAD_SE(:,nsuj) = squeeze(nanmedian(SE.ACTIVIDAD,1));
    FINAL_SE(:,nsuj) = squeeze(nanmedian(SE.FINAL,1));
    
    
    % Se hallan las matrices diferencia:
    Matriz_diferencia_RP(:,:,1,nsuj) = squeeze(nanmedian(PotenciaRelativa_Norm.ACTIVIDAD,2) - nanmedian(PotenciaRelativa_Norm.INICIAL,2));
    Matriz_diferencia_RP(:,:,2,nsuj) = squeeze(nanmedian(PotenciaRelativa_Norm.FINAL,2) - nanmedian(PotenciaRelativa_Norm.INICIAL,2));
    Matriz_diferencia_RP(:,:,3,nsuj) = squeeze(nanmedian(PotenciaRelativa_Norm.FINAL,2) - nanmedian(PotenciaRelativa_Norm.ACTIVIDAD,2));
    
    Matriz_diferencia_AP(:,:,1,nsuj) = squeeze(nanmedian(PotenciaRelativa_Absoluta.ACTIVIDAD,2) - nanmedian(PotenciaRelativa_Absoluta.INICIAL,2));
    Matriz_diferencia_AP(:,:,2,nsuj) = squeeze(nanmedian(PotenciaRelativa_Absoluta.FINAL,2) - nanmedian(PotenciaRelativa_Absoluta.INICIAL,2));
    Matriz_diferencia_AP(:,:,3,nsuj) = squeeze(nanmedian(PotenciaRelativa_Absoluta.FINAL,2) - nanmedian(PotenciaRelativa_Absoluta.ACTIVIDAD,2));
    
    Matriz_diferencia_SE(1,:,1,nsuj) = squeeze(nanmedian(SE.ACTIVIDAD,1) - nanmedian(SE.INICIAL,1));
    Matriz_diferencia_SE(1,:,2,nsuj) = squeeze(nanmedian(SE.FINAL,1) - nanmedian(SE.INICIAL,1));
    Matriz_diferencia_SE(1,:,3,nsuj) = squeeze(nanmedian(SE.FINAL,1) - nanmedian(SE.ACTIVIDAD,1));
    
    Matriz_diferencia_MF(1,:,1,nsuj) = squeeze(nanmedian(MF.ACTIVIDAD,1) - nanmedian(MF.INICIAL,1));
    Matriz_diferencia_MF(1,:,2,nsuj) = squeeze(nanmedian(MF.FINAL,1) - nanmedian(MF.INICIAL,1));
    Matriz_diferencia_MF(1,:,3,nsuj) = squeeze(nanmedian(MF.FINAL,1) - nanmedian(MF.ACTIVIDAD,1));
    
    % BSI 
    mean_BSI{1} = mean([m_BSI_T7_8{1}, m_BSI_F7_8{1}, m_BSI_F3_4{1}, m_BSI_C3_4{1}, m_BSI_P3_4{1}],2);
    mean_BSI{2} = mean([m_BSI_T7_8{2}, m_BSI_F7_8{2}, m_BSI_F3_4{2}, m_BSI_C3_4{2}, m_BSI_P3_4{2}],2);
    mean_BSI{3} = mean([m_BSI_T7_8{3}, m_BSI_F7_8{3}, m_BSI_F3_4{3}, m_BSI_C3_4{3}, m_BSI_P3_4{3}],2);

    INICIAL_BSI(:,nsuj) = mean_BSI{1};
    ACTIVIDAD_BSI(:,nsuj) = mean_BSI{2};
    FINAL_BSI(:,nsuj) = mean_BSI{3};
    
end





%%
% SE REPRESENTAN LOS TOPOPLOTS PROMEDIO:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%{
ruta_Figuras = [dir_result 'Figures/Topoplot/Promedio/'];
mkdir(ruta_Figuras);
for n_RP = 1 : 4,
    min_global = 1.02 * min(min([mean(INICIAL_RP(n_RP,:,:),3), mean(ACTIVIDAD_RP(n_RP,:,:),3), mean(FINAL_RP(n_RP,:,:),3)]));
    max_global = 0.98 * max(max([mean(INICIAL_RP(n_RP,:,:),3), mean(ACTIVIDAD_RP(n_RP,:,:),3), mean(FINAL_RP(n_RP,:,:),3)]));

    figure(n_RP)
    subplot(1,4,1)
    topoplot(squeeze(mean(INICIAL_RP(n_RP,:,:),3)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    subplot(1,4,2)
    topoplot(squeeze(mean(ACTIVIDAD_RP(n_RP,:,:),3)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    subplot(1,4,3)
    topoplot(squeeze(mean(FINAL_RP(n_RP,:,:),3)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    subplot(1,4,4)
    topoplot(squeeze(mean(INICIAL_RP(n_RP,:,:),3)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    colorbar
    
    nombre_figure = [ruta_Figuras 'Topoplot_RP_' num2str(n_RP)];
    print('-djpeg', nombre_figure)
    
   im_aux = imread([nombre_figure '.jpg']);
%    aux_im = im_aux(245:394,100:619,:);
%    im_banda_RP((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

   aux_im = im_aux(321:520,141:840,:);
   im_banda_RP((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

   
    
    min_global = log10(min(min([median(INICIAL_AP(n_RP,:,:),3), median(ACTIVIDAD_AP(n_RP,:,:),3), median(FINAL_AP(n_RP,:,:),3)])));
    max_global = log10(max(max([median(INICIAL_AP(n_RP,:,:),3), median(ACTIVIDAD_AP(n_RP,:,:),3), median(FINAL_AP(n_RP,:,:),3)])));

    figure(n_RP+10)
    subplot(1,4,1)
    topoplot(squeeze(log10(median(INICIAL_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    subplot(1,4,2)
    topoplot(squeeze(log10(median(ACTIVIDAD_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    subplot(1,4,3)
    topoplot(squeeze(log10(median(FINAL_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    subplot(1,4,4)
    topoplot(squeeze(log10(median(INICIAL_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    colorbar
    
    nombre_figure = [ruta_Figuras 'Topoplot_AP_' num2str(n_RP)];
    print('-djpeg', nombre_figure)  
    
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(235:404,100:619,:);
%     im_banda_AP((n_RP-1)*170+1:n_RP*170,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

   aux_im = im_aux(321:520,141:840,:);
   im_banda_AP((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

    
%     figure(n_RP+20)
%     hold on
%     subplot(1,4,1)
%     topoplot(squeeze(log10(median(INICIAL_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'style', 'blank', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%     topoplot(squeeze(log10(median(INICIAL_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'plotgrid',[12 11 6 3 2;13 10 7 4 1;0 9 8 5 0]);
%     %topoplot(squeeze(log10(median(INICIAL_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%     subplot(1,4,2)
%     topoplot(squeeze(log10(median(ACTIVIDAD_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'style', 'blank', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%     topoplot(squeeze(log10(median(ACTIVIDAD_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'plotgrid',[12 11 6 3 2;13 10 7 4 1;0 9 8 5 0]);
%     %topoplot(squeeze(log10(median(ACTIVIDAD_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%     subplot(1,4,3)
%     topoplot(squeeze(log10(median(FINAL_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'style', 'blank', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%     topoplot(squeeze(log10(median(FINAL_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'plotgrid',[12 11 6 3 2;13 10 7 4 1;0 9 8 5 0]);
%     %topoplot(squeeze(log10(median(FINAL_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%     subplot(1,4,4)
%     topoplot(squeeze(log10(median(INICIAL_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'style', 'blank', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%     topoplot(squeeze(log10(median(INICIAL_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'plotgrid',[12 11 6 3 2;13 10 7 4 1;0 9 8 5 0]);
%     %topoplot(squeeze(log10(median(INICIAL_AP(n_RP,:,:),3))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%     colorbar
%     
%     nombre_figure = [ruta_Figuras 'Topoplot_AP_box' num2str(n_RP)];
%     print('-djpeg', nombre_figure)  
%     
%     im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(235:404,100:619,:);
%     im_banda_AP_box((n_RP-1)*170+1:n_RP*170,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
   
%     figure(n_RP+20)
%     boxplot([INICIAL_BSI(n_RP,:); ACTIVIDAD_BSI(n_RP,:); FINAL_BSI(n_RP,:)]');
end

%nombre_figure = [ruta_Figuras 'Topoplot_RP_Promedio'];
nombre_figure = [ruta_Figuras 'Topoplot_RP_Mediana'];
imwrite(im_banda_RP, [nombre_figure '.jpg']);

%nombre_figure = [ruta_Figuras 'Topoplot_AP_Promedio'];
nombre_figure = [ruta_Figuras 'Topoplot_AP_Mediana'];
imwrite(im_banda_AP, [nombre_figure '.jpg']);

% nombre_figure = [ruta_Figuras 'Topoplot_AP_Promedio_Box'];
% imwrite(im_banda_AP_box, [nombre_figure '.jpg']);


% Representación para la MF y la SE
close all
    min_global = min(min([mean(INICIAL_SE,2), mean(ACTIVIDAD_SE,2), mean(FINAL_SE,2)]));
    max_global = max(max([mean(INICIAL_SE,2), mean(ACTIVIDAD_SE,2), mean(FINAL_SE,2)]));

    figure(99)
    subplot(1,4,1)
    topoplot(squeeze(mean(INICIAL_SE,2)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    subplot(1,4,2)
    topoplot(squeeze(mean(ACTIVIDAD_SE,2)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    subplot(1,4,3)
    topoplot(squeeze(mean(FINAL_SE,2)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    subplot(1,4,4)
    topoplot(squeeze(mean(INICIAL_SE,2)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    colorbar
    
    nombre_figure = [ruta_Figuras 'Topoplot_SE'];
    print('-djpeg', nombre_figure)
    
    n_RP = 1;
   im_aux = imread([nombre_figure '.jpg']);
%    aux_im = im_aux(245:394,100:619,:);
%    im_SE_MF((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

   aux_im = im_aux(321:520,141:840,:);
   im_SE_MF((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);


    min_global = min(min([mean(INICIAL_MF,2), mean(ACTIVIDAD_MF,2), mean(FINAL_MF,2)]));
    max_global = max(max([mean(INICIAL_MF,2), mean(ACTIVIDAD_MF,2), mean(FINAL_MF,2)]));

    figure(98)
    subplot(1,4,1)
    topoplot(squeeze(mean(INICIAL_MF,2)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    subplot(1,4,2)
    topoplot(squeeze(mean(ACTIVIDAD_MF,2)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    subplot(1,4,3)
    topoplot(squeeze(mean(FINAL_MF,2)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    subplot(1,4,4)
    topoplot(squeeze(mean(INICIAL_MF,2)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    caxis([min_global max_global])
    colorbar
    
    nombre_figure = [ruta_Figuras 'Topoplot_MF'];
    print('-djpeg', nombre_figure)
    
    n_RP = 2;
   im_aux = imread([nombre_figure '.jpg']);
%    aux_im = im_aux(245:394,100:619,:);
%    im_SE_MF((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

   aux_im = im_aux(321:520,141:840,:);
   im_SE_MF((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

%nombre_figure = [ruta_Figuras 'Topoplot_SE_MF_Promedio'];
nombre_figure = [ruta_Figuras 'Topoplot_SE_MF_Mediana'];
imwrite(im_SE_MF, [nombre_figure '.jpg']);
   


    figure(80)
    matriz_boxplot = [INICIAL_BSI(1,:); ACTIVIDAD_BSI(1,:); FINAL_BSI(1,:);INICIAL_BSI(2,:); ACTIVIDAD_BSI(2,:); FINAL_BSI(2,:);INICIAL_BSI(3,:); ACTIVIDAD_BSI(3,:); FINAL_BSI(3,:);INICIAL_BSI(4,:); ACTIVIDAD_BSI(4,:); FINAL_BSI(4,:)]';
    
    banda = [repmat({'theta'},1,3), repmat({'alfa'},1,3), repmat({'beta'},1,3), repmat({'gamma'},1,3)]; %1,6);
    diagnostico = repmat({'INICIAL','ACTIVIDAD','FINAL'},1,4); 

    boxplot(matriz_boxplot, {banda,diagnostico},'factorgap',[7 1],'labelverbosity','minor','labelorientation','inline')
    h = findobj(gca,'Tag','Box');

    for j=1:3:length(h)
        patch(get(h(j),'XData'),get(h(j),'YData'),'y','FaceColor',[0.1 0.1 0.1],'FaceAlpha',.8);
        patch(get(h(j+1),'XData'),get(h(j+1),'YData'),'y','FaceColor',[0.5 0.5 0.5],'FaceAlpha',.7);
        patch(get(h(j+2),'XData'),get(h(j+2),'YData'),'y','FaceColor',[1 1 1],'FaceAlpha',.1);
    end
    legend('  Inicial','  Actividad','  Final')
   
    nombre_figure = [ruta_Figuras 'Boxplot_BSI'];
    print('-djpeg', nombre_figure)  

%}

%%


%%
% SE REPRESENTAN LOS "TOPOPLOTS DIFERENCIA" PROMEDIO:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
ruta_Figuras = [dir_result 'Figures/Topoplot/Promedio/'];
mkdir(ruta_Figuras);
for n_RP = 1 : 4,
    % RP
    min_global = 1*min(min(squeeze(mean(Matriz_diferencia_RP(n_RP,:,:,:),4))));
    max_global = 0.95*max(max(squeeze(mean(Matriz_diferencia_RP(n_RP,:,:,:),4))));
    lim_simetrico = max(abs([min_global max_global]));

    figure(10+n_RP)
    for n_fase = 1 : 3,
        subplot(1,4,n_fase)
        topoplot(squeeze(mean(Matriz_diferencia_RP(n_RP,:,n_fase,:),4)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
        %caxis([min_global max_global])
        caxis([-lim_simetrico lim_simetrico])
    end
    subplot(1,4,4)
    topoplot(squeeze(mean(Matriz_diferencia_RP(n_RP,:,1,:),4)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    %caxis([min_global max_global])
    caxis([-lim_simetrico lim_simetrico])
    polarmap(jet,0.7);
    colorbar
    
    nombre_figure = [ruta_Figuras 'Topoplot_Diferencia_RP_' num2str(n_RP)];
    print('-djpeg', nombre_figure)
    
   im_aux = imread([nombre_figure '.jpg']);
%    aux_im = im_aux(245:394,100:619,:);
%    im_banda_RP((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

   aux_im = im_aux(321:520,141:840,:);
   im_banda_RP((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

   
   % AP
   min_global = 1*min(min(squeeze(mean(Matriz_diferencia_AP(n_RP,:,:,:),4))));
   max_global = 0.95*max(max(squeeze(mean(Matriz_diferencia_AP(n_RP,:,:,:),4))));
   lim_simetrico = max(abs([min_global max_global]));

    figure(20+n_RP)
    for n_fase = 1 : 3,
        subplot(1,4,n_fase)
        topoplot(squeeze(mean(Matriz_diferencia_AP(n_RP,:,n_fase,:),4)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
        %caxis([min_global max_global])
        caxis([-lim_simetrico lim_simetrico])
    end
    subplot(1,4,4)
    topoplot(squeeze(mean(Matriz_diferencia_AP(n_RP,:,1,:),4)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    %caxis([min_global max_global])         
    caxis([-lim_simetrico lim_simetrico])
    polarmap(jet,0.7);
    colorbar
    
    nombre_figure = [ruta_Figuras 'Topoplot_Diferencia_AP_' num2str(n_RP)];
    print('-djpeg', nombre_figure)
    
   im_aux = imread([nombre_figure '.jpg']);
%    aux_im = im_aux(245:394,100:619,:);
%    im_banda_AP((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

   aux_im = im_aux(321:520,141:840,:);
   im_banda_AP((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

end

nombre_figure = [ruta_Figuras 'Topoplot_Diferencia_RP_Promedio_mediana'];
imwrite(im_banda_RP, [nombre_figure '.jpg']);

nombre_figure = [ruta_Figuras 'Topoplot_Diferencia_AP_Promedio_mediana'];
imwrite(im_banda_AP, [nombre_figure '.jpg']);



% Representación para la MF y la SE
%close all
    
    % SE:    
    min_global = min(min(squeeze(mean(Matriz_diferencia_SE,4))));
    max_global = max(max(squeeze(mean(Matriz_diferencia_SE,4))));
    lim_simetrico = max(abs([min_global max_global]));
    
    figure(30)
    subplot(1,4,1)
    topoplot(squeeze(mean(Matriz_diferencia_SE(:,:,1,:),4)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    %caxis([min_global max_global])
    caxis([-lim_simetrico lim_simetrico])
    subplot(1,4,2)
    topoplot(squeeze(mean(Matriz_diferencia_SE(:,:,2,:),4)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    %caxis([min_global max_global])
    caxis([-lim_simetrico lim_simetrico])
    subplot(1,4,3)
    topoplot(squeeze(mean(Matriz_diferencia_SE(:,:,3,:),4)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    %caxis([min_global max_global])
    caxis([-lim_simetrico lim_simetrico])
    subplot(1,4,4)
    topoplot(squeeze(mean(Matriz_diferencia_SE(:,:,1,:),4)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    %caxis([min_global max_global])
    caxis([-lim_simetrico lim_simetrico])
    polarmap(jet,0.7);
    colorbar
    
    nombre_figure = [ruta_Figuras 'Topoplot_Diferencia_SE'];
    print('-djpeg', nombre_figure)
    
    n_RP = 1;
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_SE_MF((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

   aux_im = im_aux(321:520,141:840,:);
   im_SE_MF((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

    
    % MF:
    min_global = min(min(squeeze(mean(Matriz_diferencia_MF,4))));
    max_global = max(max(squeeze(mean(Matriz_diferencia_MF,4))));
    lim_simetrico = max(abs([min_global max_global]));
    
    figure(40)
    subplot(1,4,1)
    topoplot(squeeze(mean(Matriz_diferencia_MF(:,:,1,:),4)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    %caxis([min_global max_global])
    caxis([-lim_simetrico lim_simetrico])
    subplot(1,4,2)
    topoplot(squeeze(mean(Matriz_diferencia_MF(:,:,2,:),4)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    %caxis([min_global max_global])
    caxis([-lim_simetrico lim_simetrico])
    subplot(1,4,3)
    topoplot(squeeze(mean(Matriz_diferencia_MF(:,:,3,:),4)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    %caxis([min_global max_global])
    caxis([-lim_simetrico lim_simetrico])
    subplot(1,4,4)
    topoplot(squeeze(mean(Matriz_diferencia_MF(:,:,1,:),4)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    %caxis([min_global max_global])
    caxis([-lim_simetrico lim_simetrico])
    polarmap(jet,0.7);
    colorbar
    
    nombre_figure = [ruta_Figuras 'Topoplot_Diferencia_MF'];
    print('-djpeg', nombre_figure)
    
    n_RP = 2;
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_SE_MF((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

   aux_im = im_aux(321:520,141:840,:);
   im_SE_MF((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

     
    nombre_figure = [ruta_Figuras 'Topoplot_Diferencia_SE_MF_Promedio_mediana'];
    imwrite(im_SE_MF, [nombre_figure '.jpg']);
   


%}

%%
close all
% ESTADÍSTICA ENTRE LAS DIFERENTES FASES:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
ruta_Figuras = [dir_result 'Figures/Topoplot/Estadistica/'];
%mkdir(ruta_Figuras);
  % Se inicializa la variable con los p-valores estadísticos
    p_IN_AC  = ones(4,size(INICIAL_RP,2));
    p_IN_FI  = ones(4,size(INICIAL_RP,2));
    p_AC_FI  = ones(4,size(INICIAL_RP,2));
    
for n_RP = 1 : 4,
      
    % Se recorren los canales del EEG
    for n_chan = 1 : size(INICIAL_RP,2),
        [p_IN_AC(n_RP,n_chan),h, stats] = signrank(squeeze(INICIAL_RP(n_RP,n_chan,:)),   squeeze(ACTIVIDAD_RP(n_RP,n_chan,:)),'alpha', 0.05); 
        [p_IN_FI(n_RP,n_chan),h, stats] = signrank(squeeze(INICIAL_RP(n_RP,n_chan,:)),   squeeze(FINAL_RP(n_RP,n_chan,:)),'alpha', 0.05); 
        [p_AC_FI(n_RP,n_chan),h, stats] = signrank(squeeze(ACTIVIDAD_RP(n_RP,n_chan,:)), squeeze(FINAL_RP(n_RP,n_chan,:)),'alpha', 0.05); 
    end
    
    
    
    % Se representa la estadística:
    figure(70 + n_RP)
    colormap(hot)
    subplot(1,4,1)
    topoplot(squeeze(log10(p_IN_AC(n_RP,:))), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,2)
    topoplot(squeeze(log10(p_IN_FI(n_RP,:))), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,3)
    topoplot(squeeze(log10(p_AC_FI(n_RP,:))), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,4)
    topoplot(squeeze(log10(p_IN_AC(n_RP,:))), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colormap(hot)
    colorbar
    
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_RP_Significacion' num2str(n_RP)];
    print('-djpeg', nombre_figure) 
    
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_banda_pvalue((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

    aux_im = im_aux(321:520,141:840,:);
   im_banda_pvalue((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

    
    % Se representa la estadística:
    figure(80 + n_RP)
    colormap(hot)
    subplot(1,4,1)
    topoplot(squeeze(p_IN_AC(n_RP,:)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,2)
    topoplot(squeeze(p_IN_FI(n_RP,:)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,3)
    topoplot(squeeze(p_AC_FI(n_RP,:)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,4)
    topoplot(squeeze(p_IN_AC(n_RP,:)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colormap(hot)
    colorbar
    
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_Diferencias_nosignificativas_RP_' num2str(n_RP)];
    print('-djpeg', nombre_figure) 
    
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_banda_pvalueNO((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

   aux_im = im_aux(321:520,141:840,:);
   im_banda_pvalueNO((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

    
    % EStadística para el parámetro BSI:
    [p_BSI_IN_AC(n_RP),h(n_RP,n_chan), stats] = signrank(squeeze(INICIAL_BSI(n_RP,:)),   squeeze(ACTIVIDAD_BSI(n_RP,:)),'alpha', 0.05); 
    [p_BSI_IN_FI(n_RP),h(n_RP,n_chan), stats] = signrank(squeeze(INICIAL_BSI(n_RP,:)),   squeeze(FINAL_BSI(n_RP,:)),'alpha', 0.05); 
    [p_BSI_AC_FI(n_RP),h(n_RP,n_chan), stats] = signrank(squeeze(ACTIVIDAD_BSI(n_RP,:)), squeeze(FINAL_BSI(n_RP,:)),'alpha', 0.05); 
   
end  

nombre_figure = [ruta_Figuras 'Topoplot_RP_Significacion'];
imwrite(im_banda_pvalue, [nombre_figure '.jpg']);

nombre_figure = [ruta_Figuras 'Topoplot_Diferencias_nosignificativas_RP'];
imwrite(im_banda_pvalueNO, [nombre_figure '.jpg']);

close all


  % Se inicializa la variable con los p-valores estadísticos
    p_IN_AC  = ones(4,size(INICIAL_RP,2));
    p_IN_FI  = ones(4,size(INICIAL_RP,2));
    p_AC_FI  = ones(4,size(INICIAL_RP,2));
    
for n_RP = 1 : 4,
      
    % Se recorren los canales del EEG
    for n_chan = 1 : size(INICIAL_RP,2),
        [p_IN_AC(n_RP,n_chan),h, stats] = signrank(squeeze(INICIAL_AP(n_RP,n_chan,:)),   squeeze(ACTIVIDAD_AP(n_RP,n_chan,:)),'alpha', 0.05); 
        [p_IN_FI(n_RP,n_chan),h, stats] = signrank(squeeze(INICIAL_AP(n_RP,n_chan,:)),   squeeze(FINAL_AP(n_RP,n_chan,:)),'alpha', 0.05); 
        [p_AC_FI(n_RP,n_chan),h, stats] = signrank(squeeze(ACTIVIDAD_AP(n_RP,n_chan,:)), squeeze(FINAL_AP(n_RP,n_chan,:)),'alpha', 0.05); 
    end


    % Se representa la estadística:
    figure(70 + n_RP)
    colormap(hot)
    subplot(1,4,1)
    topoplot(squeeze(log10(p_IN_AC(n_RP,:))), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,2)
    topoplot(squeeze(log10(p_IN_FI(n_RP,:))), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,3)
    topoplot(squeeze(log10(p_AC_FI(n_RP,:))), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,4)
    topoplot(squeeze(log10(p_IN_AC(n_RP,:))), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colormap(hot)
    colorbar
    
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_AP_Significacion' num2str(n_RP)];
    print('-djpeg', nombre_figure) 
    
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_banda_pvalue((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

   aux_im = im_aux(321:520,141:840,:);
   im_banda_pvalue((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

    
    % Se representa la estadística:
    figure(80 + n_RP)
    colormap(hot)
    subplot(1,4,1)
    topoplot(squeeze(p_IN_AC(n_RP,:)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,2)
    topoplot(squeeze(p_IN_FI(n_RP,:)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,3)
    topoplot(squeeze(p_AC_FI(n_RP,:)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,4)
    topoplot(squeeze(p_IN_AC(n_RP,:)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colormap(hot)
    colorbar
    
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_Diferencias_nosignificativas_AP_' num2str(n_RP)];
    print('-djpeg', nombre_figure) 
    
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_banda_pvalueNO((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

   aux_im = im_aux(321:520,141:840,:);
   im_banda_pvalueNO((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

end  

nombre_figure = [ruta_Figuras 'Topoplot_AP_Significacion'];
imwrite(im_banda_pvalue, [nombre_figure '.jpg']);

nombre_figure = [ruta_Figuras 'Topoplot_Diferencias_nosignificativas_AP'];
imwrite(im_banda_pvalueNO, [nombre_figure '.jpg']);


% Estadística para SE y MF:

  % Se inicializa la variable con los p-valores estadísticos
    p_IN_AC  = ones(1,size(INICIAL_SE,1));
    p_IN_FI  = ones(1,size(INICIAL_SE,1));
    p_AC_FI  = ones(1,size(INICIAL_SE,1));
    
    % Se recorren los canales del EEG
    for n_chan = 1 : size(INICIAL_RP,2),
        [p_IN_AC(n_chan),h, stats] = signrank(squeeze(INICIAL_SE(n_chan,:)),   squeeze(ACTIVIDAD_SE(n_chan,:)),'alpha', 0.05); 
        [p_IN_FI(n_chan),h, stats] = signrank(squeeze(INICIAL_SE(n_chan,:)),   squeeze(FINAL_SE(n_chan,:)),'alpha', 0.05); 
        [p_AC_FI(n_chan),h, stats] = signrank(squeeze(ACTIVIDAD_SE(n_chan,:)), squeeze(FINAL_SE(n_chan,:)),'alpha', 0.05); 
    end


    % Se representa la estadística:
    figure(96)
    colormap(hot)
    subplot(1,4,1)
    topoplot(squeeze(log10(p_IN_AC)), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,2)
    topoplot(squeeze(log10(p_IN_FI)), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,3)
    topoplot(squeeze(log10(p_AC_FI)), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colormap(hot)
       
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_SE_Significacion'];
    print('-djpeg', nombre_figure) 
    
    n_RP = 1;
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_SE_MF_pvalue((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

   aux_im = im_aux(321:520,141:840,:);
   im_SE_MF_pvalue((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

    % Se representa la estadística:
    figure(97)
    colormap(hot)
    subplot(1,4,1)
    topoplot(squeeze((p_IN_AC)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,2)
    topoplot(squeeze((p_IN_FI)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,3)
    topoplot(squeeze((p_AC_FI)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colormap(hot)
       
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_SE_Diferencias_NO_significativas'];
    print('-djpeg', nombre_figure) 
    
    n_RP = 1;
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_SE_MF_pvalue_NO((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

   aux_im = im_aux(321:520,141:840,:);
   im_SE_MF_pvalue_NO((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);


  % Se inicializa la variable con los p-valores estadísticos
    p_IN_AC  = ones(1,size(INICIAL_MF,1));
    p_IN_FI  = ones(1,size(INICIAL_MF,1));
    p_AC_FI  = ones(1,size(INICIAL_MF,1));
    
    % MF recorren los canales del EEG
    for n_chan = 1 : size(INICIAL_RP,2),
        [p_IN_AC(n_chan),h, stats] = signrank(squeeze(INICIAL_MF(n_chan,:)),   squeeze(ACTIVIDAD_MF(n_chan,:)),'alpha', 0.05); 
        [p_IN_FI(n_chan),h, stats] = signrank(squeeze(INICIAL_MF(n_chan,:)),   squeeze(FINAL_MF(n_chan,:)),'alpha', 0.05); 
        [p_AC_FI(n_chan),h, stats] = signrank(squeeze(ACTIVIDAD_MF(n_chan,:)), squeeze(FINAL_MF(n_chan,:)),'alpha', 0.05); 
    end


    % Se representa la estadística:
    figure(94)
    colormap(hot)
    subplot(1,4,1)
    topoplot(squeeze(log10(p_IN_AC)), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,2)
    topoplot(squeeze(log10(p_IN_FI)), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,3)
    topoplot(squeeze(log10(p_AC_FI)), elocs,'maplimits', [log10(0.01) log10(0.1)], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colormap(hot)
       
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_MF_Significacion'];
    print('-djpeg', nombre_figure) 
    
    n_RP = 2;
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_SE_MF_pvalue((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
   aux_im = im_aux(321:520,141:840,:);
   im_SE_MF_pvalue((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);


        % Se representa la estadística:
    figure(95)
    colormap(hot)
    subplot(1,4,1)
    topoplot(squeeze((p_IN_AC)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,2)
    topoplot(squeeze((p_IN_FI)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,3)
    topoplot(squeeze((p_AC_FI)), elocs,'maplimits', [0 0.3], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colormap(hot)
       
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_MF_Diferencias_NO_significativas'];
    print('-djpeg', nombre_figure) 

    n_RP = 2;
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_SE_MF_pvalue_NO((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
   aux_im = im_aux(321:520,141:840,:);
   im_SE_MF_pvalue_NO((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);


nombre_figure = [ruta_Figuras 'Topoplot_SE_MF_Significacion'];
imwrite(im_SE_MF_pvalue, [nombre_figure '.jpg']);

nombre_figure = [ruta_Figuras 'Topoplot_SE_MF_Diferencias_nosignificativas'];
imwrite(im_SE_MF_pvalue_NO, [nombre_figure '.jpg']);

%}        

close all

% ESTADÍSTICA ENTRE LAS DIFERENTES FASES (INCREMENTOS/DECREMENTOS):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ruta_Figuras = [dir_result 'Figures/Topoplot/Estadistica/'];
%mkdir(ruta_Figuras);
%{

lim_NO_significacion = 0.2;

for n_RP = 1 : 4,
    % Se representa la estadística:
    p_value  = ones(size(INICIAL_RP,2),1);
    p_repre  = zeros(size(INICIAL_RP,2),1);
    p_repre2  = zeros(size(INICIAL_RP,2),1);
    % Se recorren los canales del EEG
    for n_chan = 1 : size(INICIAL_RP,2),
        [p_value(n_chan),h, stats] = signrank(squeeze(ACTIVIDAD_RP(n_RP,n_chan,:)), squeeze(INICIAL_RP(n_RP,n_chan,:)),'alpha', 0.05); 
        if (p_value(n_chan) < 0.1),
            if (median( ACTIVIDAD_RP(n_RP,n_chan,:) -  INICIAL_RP(n_RP,n_chan,:)) > 0),
                    p_repre(n_chan) = abs(log10(p_value(n_chan)))-1;
            else,
                    p_repre(n_chan) = log10(p_value(n_chan))+1;
            end
        end
        if (p_value(n_chan) < lim_NO_significacion),
            if (median( ACTIVIDAD_RP(n_RP,n_chan,:) -  INICIAL_RP(n_RP,n_chan,:)) > 0),
                    p_repre2(n_chan) = -p_value(n_chan) + lim_NO_significacion;
            else,
                    p_repre2(n_chan) = p_value(n_chan) - lim_NO_significacion;
            end
        end
    end
    figure(70 + n_RP)
    subplot(1,4,1)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    figure(80 + n_RP)
    subplot(1,4,1)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);


    
    p_value  = ones(size(INICIAL_RP,2),1);
    p_repre  = zeros(size(INICIAL_RP,2),1);
    p_repre2  = zeros(size(INICIAL_RP,2),1);
    for n_chan = 1 : size(INICIAL_RP,2),
        [p_value(n_chan),h, stats] = signrank(squeeze(FINAL_RP(n_RP,n_chan,:)), squeeze(INICIAL_RP(n_RP,n_chan,:)),'alpha', 0.05); 
        if (p_value(n_chan) < 0.1),
            if (median( FINAL_RP(n_RP,n_chan,:) - INICIAL_RP(n_RP,n_chan,:)) > 0),
                    p_repre(n_chan) = abs(log10(p_value(n_chan)))-1;
            else,
                    p_repre(n_chan) = log10(p_value(n_chan))+1;
            end
        end
        if (p_value(n_chan) < lim_NO_significacion),
            if (median( FINAL_RP(n_RP,n_chan,:) - INICIAL_RP(n_RP,n_chan,:)) > 0),
                    p_repre2(n_chan) = -p_value(n_chan) + lim_NO_significacion;
            else,
                    p_repre2(n_chan) = p_value(n_chan) - lim_NO_significacion;
            end
        end

    end
    figure(70 + n_RP)
    subplot(1,4,2)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    figure(80 + n_RP)
    subplot(1,4,2)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);

    
    p_value  = ones(size(INICIAL_RP,2),1);
    p_repre  = zeros(size(INICIAL_RP,2),1);
    p_repre2  = zeros(size(INICIAL_RP,2),1);
    for n_chan = 1 : size(INICIAL_RP,2),
        [p_value(n_chan),h, stats] = signrank(squeeze(FINAL_RP(n_RP,n_chan,:)), squeeze(ACTIVIDAD_RP(n_RP,n_chan,:)),'alpha', 0.05);         
        if (p_value(n_chan) < 0.1),
            if (median( FINAL_RP(n_RP,n_chan,:) - ACTIVIDAD_RP(n_RP,n_chan,:)) > 0),
                    p_repre(n_chan) = abs(log10(p_value(n_chan)))-1;
            else,
                    p_repre(n_chan) = log10(p_value(n_chan))+1;
            end
        end
        if (p_value(n_chan) < lim_NO_significacion),
            if (median( FINAL_RP(n_RP,n_chan,:) - ACTIVIDAD_RP(n_RP,n_chan,:)) > 0),
                    p_repre2(n_chan) = -p_value(n_chan) + lim_NO_significacion;
            else,
                    p_repre2(n_chan) = p_value(n_chan) - lim_NO_significacion;
            end
        end
    end
    figure(70 + n_RP)
    subplot(1,4,3)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,4)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colorbar
    polarmap(jet,0.5)
    
    figure(80 + n_RP)
    subplot(1,4,3)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,4)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colorbar
    polarmap(jet,0.5)
    
    figure(70 + n_RP)
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_RP_Significacion' num2str(n_RP)];
    print('-djpeg', nombre_figure) 
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_banda_pvalue((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
    
    aux_im = im_aux(321:520,141:840,:);
    im_banda_pvalue((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

    figure(80 + n_RP)
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_Diferencias_nosignificativas_RP_' num2str(n_RP)];
    print('-djpeg', nombre_figure) 
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_banda_pvalueNO((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
    
    aux_im = im_aux(321:520,141:840,:);
    im_banda_pvalueNO((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

end
nombre_figure = [ruta_Figuras 'Topoplot_RP_Significacion'];
imwrite(im_banda_pvalue, [nombre_figure '.jpg']);

nombre_figure = [ruta_Figuras 'Topoplot_Diferencias_nosignificativas_RP'];
imwrite(im_banda_pvalueNO, [nombre_figure '.jpg']);

close all


% Se representa la AP
ruta_Figuras = [dir_result 'Figures/Topoplot/Estadistica/'];
for n_AP = 1 : 4,
    % Se representa la estadística:
    p_value  = ones(size(INICIAL_AP,2),1);
    p_repre  = zeros(size(INICIAL_AP,2),1);
    p_repre2  = zeros(size(INICIAL_AP,2),1);
    % Se recorren los canales del EEG
    for n_chan = 1 : size(INICIAL_AP,2),
        [p_value(n_chan),h, stats] = signrank(squeeze(ACTIVIDAD_AP(n_AP,n_chan,:)), squeeze(INICIAL_AP(n_AP,n_chan,:)),'alpha', 0.05); 
        if (p_value(n_chan) < 0.1),
            if (median( ACTIVIDAD_AP(n_AP,n_chan,:) -  INICIAL_AP(n_AP,n_chan,:)) > 0),
                    p_repre(n_chan) = abs(log10(p_value(n_chan)))-1;
            else,
                    p_repre(n_chan) = log10(p_value(n_chan))+1;
            end
        end
        if (p_value(n_chan) < lim_NO_significacion),
            if (median( ACTIVIDAD_AP(n_AP,n_chan,:) -  INICIAL_AP(n_AP,n_chan,:)) > 0),
                    p_repre2(n_chan) = -p_value(n_chan) + lim_NO_significacion;
            else,
                    p_repre2(n_chan) = p_value(n_chan) - lim_NO_significacion;
            end
        end
    end    
    figure(70 + n_AP)
    subplot(1,4,1)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    figure(80 + n_AP)
    subplot(1,4,1)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);


    
    p_value  = ones(size(INICIAL_AP,2),1);
    p_repre  = zeros(size(INICIAL_AP,2),1);
    p_repre2  = zeros(size(INICIAL_AP,2),1);
    for n_chan = 1 : size(INICIAL_AP,2),
        [p_value(n_chan),h, stats] = signrank(squeeze(FINAL_AP(n_AP,n_chan,:)), squeeze(INICIAL_AP(n_AP,n_chan,:)),'alpha', 0.05); 
        if (p_value(n_chan) < 0.1),
            if (median( FINAL_AP(n_AP,n_chan,:) - INICIAL_AP(n_AP,n_chan,:)) > 0),
                    p_repre(n_chan) = abs(log10(p_value(n_chan)))-1;
            else,
                    p_repre(n_chan) = log10(p_value(n_chan))+1;
            end
        end
        if (p_value(n_chan) < lim_NO_significacion),
            if (median( FINAL_AP(n_AP,n_chan,:) - INICIAL_AP(n_AP,n_chan,:)) > 0),
                    p_repre2(n_chan) = -p_value(n_chan) + lim_NO_significacion;
            else,
                    p_repre2(n_chan) = p_value(n_chan) - lim_NO_significacion;
            end
        end
    end
    figure(70 + n_AP)
    subplot(1,4,2)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    figure(80 + n_AP)
    subplot(1,4,2)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);

    
    p_value  = ones(size(INICIAL_AP,2),1);
    p_repre  = zeros(size(INICIAL_AP,2),1);
    p_repre2  = zeros(size(INICIAL_AP,2),1);
    for n_chan = 1 : size(INICIAL_AP,2),
        [p_value(n_chan),h, stats] = signrank(squeeze(FINAL_AP(n_AP,n_chan,:)), squeeze(ACTIVIDAD_AP(n_AP,n_chan,:)),'alpha', 0.05);         
        if (p_value(n_chan) < 0.1),
            if (median( FINAL_AP(n_AP,n_chan,:) - ACTIVIDAD_AP(n_AP,n_chan,:)) > 0),
                    p_repre(n_chan) = abs(log10(p_value(n_chan)))-1;
            else,
                    p_repre(n_chan) = log10(p_value(n_chan))+1;
            end
        end
        if (p_value(n_chan) < lim_NO_significacion),
            if (median( FINAL_AP(n_AP,n_chan,:) - ACTIVIDAD_AP(n_AP,n_chan,:)) > 0),
                    p_repre2(n_chan) = -p_value(n_chan) + lim_NO_significacion;
            else,
                    p_repre2(n_chan) = p_value(n_chan) - lim_NO_significacion;
            end
        end
    end
    figure(70 + n_AP)
    subplot(1,4,3)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,4)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colorbar
    polarmap(jet,0.5)
    
    figure(80 + n_AP)
    subplot(1,4,3)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,4)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colorbar
    polarmap(jet,0.5)
    
    figure(70 + n_AP)
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_AP_Significacion' num2str(n_AP)];
    print('-djpeg', nombre_figure) 
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_banda_pvalue((n_AP-1)*150+1:n_AP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
    
     aux_im = im_aux(321:520,141:840,:);
   im_banda_pvalue((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

    figure(80 + n_AP)
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_Diferencias_nosignificativas_AP_' num2str(n_AP)];
    print('-djpeg', nombre_figure) 
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_banda_pvalueNO((n_AP-1)*150+1:n_AP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
    
     aux_im = im_aux(321:520,141:840,:);
   im_banda_pvalueNO((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

end
nombre_figure = [ruta_Figuras 'Topoplot_AP_Significacion'];
imwrite(im_banda_pvalue, [nombre_figure '.jpg']);

nombre_figure = [ruta_Figuras 'Topoplot_Diferencias_nosignificativas_AP'];
imwrite(im_banda_pvalueNO, [nombre_figure '.jpg']);

close all


% Estadística para SE y MF:

  % Se inicializa la variable con los p-valores estadísticos
%     p_IN_AC  = ones(1,size(INICIAL_SE,1));
%     p_IN_FI  = ones(1,size(INICIAL_SE,1));
%     p_AC_FI  = ones(1,size(INICIAL_SE,1));
    
    % Se recorren los canales del EEG
    p_value  = ones(size(INICIAL_SE,1),1);
    p_repre  = 0.0001*ones(size(INICIAL_SE,1),1);
    p_repre2  = 0.0001*ones(size(INICIAL_SE,1),1);
    for n_chan = 1 : size(INICIAL_SE,1),
        [p_value(n_chan),h, stats] = signrank(squeeze(ACTIVIDAD_SE(n_chan,:)),squeeze(INICIAL_SE(n_chan,:)),'alpha', 0.05); 
         if (p_value(n_chan) < 0.1),
            if (median(ACTIVIDAD_SE(n_chan,:) - INICIAL_SE(n_chan,:)) > 0),
                    p_repre(n_chan) = abs(log10(p_value(n_chan)))-1;
            else,
                    p_repre(n_chan) = log10(p_value(n_chan))+1;
            end
        end
        if (p_value(n_chan) < lim_NO_significacion),
            if (median(ACTIVIDAD_SE(n_chan,:) - INICIAL_SE(n_chan,:)) > 0),
                    p_repre2(n_chan) = -p_value(n_chan) + lim_NO_significacion;
            else,
                    p_repre2(n_chan) = p_value(n_chan) - lim_NO_significacion;
            end
        end
    end

    figure(96)
    subplot(1,4,1)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    figure(97)
    subplot(1,4,1)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);

    p_value  = ones(size(INICIAL_SE,1),1);
    p_repre  = zeros(size(INICIAL_SE,1),1);
    p_repre2  = zeros(size(INICIAL_SE,1),1);
    for n_chan = 1 : size(INICIAL_SE,1),    
        [p_value(n_chan),h, stats] = signrank(squeeze(FINAL_SE(n_chan,:)),squeeze(INICIAL_SE(n_chan,:)),'alpha', 0.05); 
         if (p_value(n_chan) < 0.1),
            if (median( FINAL_SE(n_chan,:) - INICIAL_SE(n_chan,:)) > 0),
                    p_repre(n_chan) = abs(log10(p_value(n_chan)))-1;
            else,
                    p_repre(n_chan) = log10(p_value(n_chan))+1;
            end
        end
        if (p_value(n_chan) < lim_NO_significacion),
            if (median( FINAL_SE(n_chan,:) - INICIAL_SE(n_chan,:)) > 0),
                    p_repre2(n_chan) = -p_value(n_chan) + lim_NO_significacion;
            else,
                    p_repre2(n_chan) = p_value(n_chan) - lim_NO_significacion;
            end
        end
    end
    figure(96)
    subplot(1,4,2)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    figure(97)
    subplot(1,4,2)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);

    
    p_value  = ones(size(INICIAL_SE,1),1);
    p_repre  = zeros(size(INICIAL_SE,1),1);
    p_repre2  = zeros(size(INICIAL_SE,1),1);
    for n_chan = 1 : size(INICIAL_SE,1),
        [p_value(n_chan),h, stats] = signrank(squeeze(FINAL_SE(n_chan,:)),squeeze(ACTIVIDAD_SE(n_chan,:)),'alpha', 0.05); 
         if (p_value(n_chan) < 0.1),
            if  (median( FINAL_SE(n_chan,:) - ACTIVIDAD_SE(n_chan,:)) > 0),
                    p_repre(n_chan) = abs(log10(p_value(n_chan)))-1;
            else,
                    p_repre(n_chan) = log10(p_value(n_chan))+1;
            end
        end
        if (p_value(n_chan) < lim_NO_significacion),
            if  (median( FINAL_SE(n_chan,:) - ACTIVIDAD_SE(n_chan,:)) > 0),
                    p_repre2(n_chan) = -p_value(n_chan) + lim_NO_significacion;
            else,
                    p_repre2(n_chan) = p_value(n_chan) - lim_NO_significacion;
            end
        end
    end
    figure(96)
    subplot(1,4,3)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,4)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colorbar
    polarmap(jet,0.5)
    
    figure(97)
    subplot(1,4,3)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,4)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colorbar
    polarmap(jet,0.5)

    figure(96)
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_SE_Significacion'];
    mkdir([ruta_Figuras 'Topoplot/']);
    print('-djpeg', nombre_figure) 
    
    n_RP = 1;
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_SE_MF_pvalue((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
    
    aux_im = im_aux(321:520,141:840,:);
    im_SE_MF_pvalue((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

    
    figure(97) 
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_SE_Diferencias_NO_significativas'];
    print('-djpeg', nombre_figure) 
    
    n_RP = 1;
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_SE_MF_pvalue_NO((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
    
     aux_im = im_aux(321:520,141:840,:);
    im_SE_MF_pvalue_NO((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

    close all
 % Lo mismo para la MF:
 
     % Se recorren los canales del EEG
    p_value  = ones(size(INICIAL_MF,1),1);
    p_repre  = zeros(size(INICIAL_MF,1),1);
    p_repre2  = zeros(size(INICIAL_MF,1),1);
    for n_chan = 1 : size(INICIAL_MF,1),
        [p_value(n_chan),h, stats] = signrank(squeeze(ACTIVIDAD_MF(n_chan,:)),squeeze(INICIAL_MF(n_chan,:)),'alpha', 0.05); 
         if (p_value(n_chan) < 0.1),
            if (median(ACTIVIDAD_MF(n_chan,:) - INICIAL_MF(n_chan,:)) > 0),
                    p_repre(n_chan) = abs(log10(p_value(n_chan)))-1;
            else,
                    p_repre(n_chan) = log10(p_value(n_chan))+1;
            end
        end
        if (p_value(n_chan) < lim_NO_significacion),
            if (median(ACTIVIDAD_MF(n_chan,:) - INICIAL_MF(n_chan,:)) > 0),
                    p_repre2(n_chan) = -p_value(n_chan) + lim_NO_significacion;
            else,
                    p_repre2(n_chan) = p_value(n_chan) - lim_NO_significacion;
            end
        end
    end
    figure(96)
    subplot(1,4,1)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    figure(97)
    subplot(1,4,1)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);

    p_value  = ones(size(INICIAL_MF,1),1);
    p_repre  = zeros(size(INICIAL_MF,1),1);
    p_repre2  = zeros(size(INICIAL_MF,1),1);
    for n_chan = 1 : size(INICIAL_RP,2),    
        [p_value(n_chan),h, stats] = signrank(squeeze(FINAL_MF(n_chan,:)),squeeze(INICIAL_MF(n_chan,:)), 'alpha', 0.05); 
         if (p_value(n_chan) < 0.1),
            if (median( FINAL_MF(n_chan,:) - INICIAL_MF(n_chan,:)) > 0),
                    p_repre(n_chan) = abs(log10(p_value(n_chan)))-1;
            else,
                    p_repre(n_chan) = log10(p_value(n_chan))+1;
            end
        end
        if (p_value(n_chan) < lim_NO_significacion),
            if (median( FINAL_MF(n_chan,:) - INICIAL_MF(n_chan,:)) > 0),
                    p_repre2(n_chan) = -p_value(n_chan) + lim_NO_significacion;
            else,
                    p_repre2(n_chan) = p_value(n_chan) - lim_NO_significacion;
            end
        end
    end
    figure(96)
    subplot(1,4,2)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    figure(97)
    subplot(1,4,2)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);

    
    p_value  = ones(size(INICIAL_MF,1),1);
    p_repre  = zeros(size(INICIAL_MF,1),1);
    p_repre2  = zeros(size(INICIAL_MF,1),1);
    for n_chan = 1 : size(INICIAL_RP,2),
        [p_value(n_chan),h, stats] = signrank(squeeze(FINAL_MF(n_chan,:)),squeeze(ACTIVIDAD_MF(n_chan,:)),'alpha', 0.05); 
         if (p_value(n_chan) < 0.1),
            if (median( FINAL_MF(n_chan,:) - ACTIVIDAD_MF(n_chan,:)) > 0),
                    p_repre(n_chan) = abs(log10(p_value(n_chan)))-1;
            else,
                    p_repre(n_chan) = log10(p_value(n_chan))+1;
            end
        end
        if (p_value(n_chan) < lim_NO_significacion),
            if (median( FINAL_MF(n_chan,:) - ACTIVIDAD_MF(n_chan,:)) > 0),
                    p_repre2(n_chan) = -p_value(n_chan) + lim_NO_significacion;
            else,
                    p_repre2(n_chan) = p_value(n_chan) - lim_NO_significacion;
            end
        end
    end
    figure(96)
    subplot(1,4,3)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,4)
    topoplot(squeeze(p_repre), elocs,'maplimits', [-1 1], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colorbar
    polarmap(jet,0.5)
    
    figure(97)
    subplot(1,4,3)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    subplot(1,4,4)
    topoplot(squeeze(p_repre2), elocs,'maplimits', [-lim_NO_significacion  lim_NO_significacion], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
    colorbar
    polarmap(jet,0.5)

    figure(96)
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_MF_Significacion'];
    print('-djpeg', nombre_figure) 
    
    n_RP = 2;
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_SE_MF_pvalue((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
    
     aux_im = im_aux(321:520,141:840,:);
    im_SE_MF_pvalue((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

    
    figure(97)
    nombre_figure = [ruta_Figuras 'Topoplot/Topoplot_MF_Diferencias_NO_significativas'];
    print('-djpeg', nombre_figure) 
    
    n_RP = 2;
    im_aux = imread([nombre_figure '.jpg']);
%     aux_im = im_aux(245:394,100:619,:);
%     im_SE_MF_pvalue_NO((n_RP-1)*150+1:n_RP*150,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
    
     aux_im = im_aux(321:520,141:840,:);
    im_SE_MF_pvalue_NO((n_RP-1)*200+1:n_RP*200,1:700,:) = aux_im; %im_aux(235:404,100:619,:);

nombre_figure = [ruta_Figuras 'Topoplot_SE_MF_Significacion'];
imwrite(im_SE_MF_pvalue, [nombre_figure '.jpg']);

nombre_figure = [ruta_Figuras 'Topoplot_SE_MF_Diferencias_nosignificativas'];
imwrite(im_SE_MF_pvalue_NO, [nombre_figure '.jpg']);
%}


% SE REPRESENTAN LOS TOPOPLOTS EN CADA SUJETO:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
ruta_Figuras = [dir_result 'Figures/Topoplot/Subjects/'];
mkdir(ruta_Figuras);
% Diferencia entre fases para cada sujeto
Dif_IN_AC_RP = INICIAL_RP - ACTIVIDAD_RP;
Dif_IN_FI_RP = INICIAL_RP - FINAL_RP;
Dif_AC_FI_RP = ACTIVIDAD_RP - FINAL_RP;

Dif_IN_AC_AP = INICIAL_AP - ACTIVIDAD_AP;
Dif_IN_FI_AP = INICIAL_AP - FINAL_AP;
Dif_AC_FI_AP = ACTIVIDAD_AP - FINAL_AP;

Dif_dB_IN_AC_AP = 20*log10(INICIAL_AP) - 20*log10(ACTIVIDAD_AP);
Dif_dB_IN_FI_AP = 20*log10(INICIAL_AP) - 20*log10(FINAL_AP);
Dif_dB_AC_FI_AP = 20*log10(ACTIVIDAD_AP) - 20*log10(FINAL_AP);

Div_IN_AC_AP = (20*log10(INICIAL_AP))   ./ (20*log10(ACTIVIDAD_AP));
Div_IN_FI_AP = (20*log10(INICIAL_AP))   ./ (20*log10(FINAL_AP));
Div_AC_FI_AP = (20*log10(ACTIVIDAD_AP)) ./ (20*log10(FINAL_AP));

for n_RP = 1 : 4,
    close all
    %im_banda = ones(170*length(sujetos),520,3);
    for nsuj = 1 : length(sujetos),
%         min_global = 0.8*min(min([mean(INICIAL_RP(n_RP,:,:),3), mean(ACTIVIDAD_RP(n_RP,:,:),3), mean(FINAL_RP(n_RP,:,:),3)]));
%         max_global = 1.2*max(max([mean(INICIAL_RP(n_RP,:,:),3), mean(ACTIVIDAD_RP(n_RP,:,:),3), mean(FINAL_RP(n_RP,:,:),3)]));
% 
%         figure(n_RP*20 + nsuj)
%         subplot(1,4,1)
%         topoplot(squeeze(INICIAL_RP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,2)
%         topoplot(squeeze(ACTIVIDAD_RP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,3)
%         topoplot(squeeze(FINAL_RP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,4)
%         topoplot(squeeze(INICIAL_RP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         colorbar
% 
%         nombre_figure = [ruta_Figuras 'RP/Topoplot_RP_Sujetos_' num2str(n_RP) '_' num2str(nsuj) '_' sujetos(nsuj).name(1:end-4)];
%         print('-djpeg', nombre_figure)
% 
%         im_aux = imread([nombre_figure '.jpg']);
%         aux_im = im_aux(235:404,100:619,:);
%         im_banda_RP((nsuj-1)*170+1:nsuj*170,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
% 
% 
%         % REPRESENTACIÖN DE LA DIFERENCIA:
%         % Se hace una representación simétrica:
%         max_global = 1.5*max(max(abs([mean(Dif_IN_AC_RP(n_RP,:,:),3), mean(Dif_IN_FI_RP(n_RP,:,:),3), mean(Dif_AC_FI_RP(n_RP,:,:),3)])));
%         min_global = -max_global;
%         
%         figure(n_RP*10 + nsuj)
%         subplot(1,4,1)
%         topoplot(squeeze(Dif_IN_AC_RP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,2)
%         topoplot(squeeze(Dif_IN_FI_RP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,3)
%         topoplot(squeeze(Dif_AC_FI_RP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,4)
%         topoplot(squeeze(Dif_AC_FI_RP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         polarmap(jet,0.5)
%         colorbar
% 
%         nombre_figure = [ruta_Figuras 'RP/Topoplot_DiferenciaRP_Sujetos_' num2str(n_RP) '_' num2str(nsuj) '_' sujetos(nsuj).name(1:end-4)];
%         print('-djpeg', nombre_figure)
% 
%         im_aux = imread([nombre_figure '.jpg']);
%         aux_im = im_aux(235:404,100:619,:);
%         im_banda_diferenciaRP((nsuj-1)*170+1:nsuj*170,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
% 
%         
%        
%         min_global = 1*log10(min(min([mean(INICIAL_AP(n_RP,:,:),3), mean(ACTIVIDAD_AP(n_RP,:,:),3), mean(FINAL_AP(n_RP,:,:),3)])));
%         max_global = 1*log10(max(max([mean(INICIAL_AP(n_RP,:,:),3), mean(ACTIVIDAD_AP(n_RP,:,:),3), mean(FINAL_AP(n_RP,:,:),3)])));
% 
%         figure((n_RP+5)*20 + nsuj)
%         subplot(1,4,1)
%         topoplot(squeeze(log10(INICIAL_AP(n_RP,:,nsuj))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,2)
%         topoplot(squeeze(log10(ACTIVIDAD_AP(n_RP,:,nsuj))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,3)
%         topoplot(squeeze(log10(FINAL_AP(n_RP,:,nsuj))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,4)
%         topoplot(squeeze(log10(INICIAL_AP(n_RP,:,nsuj))), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         colorbar
% 
%         nombre_figure = [ruta_Figuras 'AP/Topoplot_AP_Sujetos_' num2str(n_RP) '_' num2str(nsuj) '_' sujetos(nsuj).name(1:end-4)];
%         print('-djpeg', nombre_figure)
%         
%         im_aux = imread([nombre_figure '.jpg']);
%         aux_im = im_aux(235:404,100:619,:);
%         im_banda_AP((nsuj-1)*170+1:nsuj*170,1:520,:) = aux_im; %im_aux(235:404,100:619,:);       

%         % REPRESENTACIÖN DE LA DIFERENCIA:
%         % Se hace una representación simétrica:
%         max_global = 1.5*max(max(abs([mean(Dif_IN_AC_AP(n_RP,:,:),3), mean(Dif_IN_FI_AP(n_RP,:,:),3), mean(Dif_AC_FI_AP(n_RP,:,:),3)])));
%         min_global = -max_global;
%         
%         figure(n_RP*10 + nsuj)
%         subplot(1,4,1)
%         topoplot(squeeze(Dif_IN_AC_AP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,2)
%         topoplot(squeeze(Dif_IN_FI_AP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,3)
%         topoplot(squeeze(Dif_AC_FI_AP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,4)
%         topoplot(squeeze(Dif_AC_FI_AP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         polarmap(jet,0.5)
%         colorbar
% 
%         nombre_figure = [ruta_Figuras 'AP/Topoplot_DiferenciaAP_Sujetos_' num2str(n_RP) '_' num2str(nsuj) '_' sujetos(nsuj).name(1:end-4)];
%         print('-djpeg', nombre_figure)
% 
%         im_aux = imread([nombre_figure '.jpg']);
%         aux_im = im_aux(235:404,100:619,:);
%         im_banda_diferenciaAP((nsuj-1)*170+1:nsuj*170,1:520,:) = aux_im; %im_aux(235:404,100:619,:);
  

        % REPRESENTACIÖN DE LA DIFERENCIA:
        % Se hace una representación simétrica:
        max_global = 1.5*max(max(abs([mean(Dif_dB_IN_AC_AP(n_RP,:,:),3), mean(Dif_dB_IN_FI_AP(n_RP,:,:),3), mean(Dif_dB_AC_FI_AP(n_RP,:,:),3)])));
        min_global = -max_global;
        
        figure(n_RP*10 + nsuj)
        subplot(1,4,1)
        topoplot(squeeze(Dif_dB_IN_AC_AP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
        caxis([min_global max_global])
        subplot(1,4,2)
        topoplot(squeeze(Dif_dB_IN_FI_AP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
        caxis([min_global max_global])
        subplot(1,4,3)
        topoplot(squeeze(Dif_dB_AC_FI_AP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
        caxis([min_global max_global])
        subplot(1,4,4)
        topoplot(squeeze(Dif_dB_AC_FI_AP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
        caxis([min_global max_global])
        polarmap(jet,0.5)
        colorbar

        nombre_figure = [ruta_Figuras 'AP/Topoplot_DiferenciaAP_Sujetos_' num2str(n_RP) '_' num2str(nsuj) '_' sujetos(nsuj).name(1:end-4)];
        mkdir([ruta_Figuras 'AP/']);
        print('-djpeg', nombre_figure)

        im_aux = imread([nombre_figure '.jpg']);
        aux_im = im_aux(235:404,100:619,:);
        im_banda_diferenciaAP_dB((nsuj-1)*170+1:nsuj*170,1:520,:) = aux_im; %im_aux(235:404,100:619,:);


%             % REPRESENTACIÖN DE LA DIVISIÓN LOGARÍTMICA:
%         % Se hace una representación simétrica:
%         max_global = max(max(abs([mean(Div_IN_AC_AP(n_RP,:,:),3), mean(Div_IN_FI_AP(n_RP,:,:),3), mean(Div_AC_FI_AP(n_RP,:,:),3)])));
%         min_global = 1 - (max_global-1);
%         
%         figure(n_RP*10 + nsuj)
%         subplot(1,4,1)
%         topoplot(squeeze(Div_IN_AC_AP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,2)
%         topoplot(squeeze(Div_IN_FI_AP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,3)
%         topoplot(squeeze(Div_AC_FI_AP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         subplot(1,4,4)
%         topoplot(squeeze(Div_AC_FI_AP(n_RP,:,nsuj)), elocs,'maplimits', [min_global, max_global], 'electrodes', 'on', 'shading', 'interp', 'style', 'both', 'plotrad', 0.6, 'headrad', 0.59, 'intrad', 0.63);
%         caxis([min_global max_global])
%         %polarmap(jet,0.5)
%         colorbar
% 
%         nombre_figure = [ruta_Figuras 'AP/Topoplot_DiferenciaAP_Sujetos_' num2str(n_RP) '_' num2str(nsuj) '_' sujetos(nsuj).name(1:end-4)];
%         print('-djpeg', nombre_figure)
% 
%         im_aux = imread([nombre_figure '.jpg']);
%         aux_im = im_aux(235:404,100:619,:);
%         im_banda_divisionAP((nsuj-1)*170+1:nsuj*170,1:520,:) = aux_im; %im_aux(235:404,100:619,:);

    end
%     nombre_figure = [ruta_Figuras 'Topoplot_RP_Sujetos' num2str(n_RP)];
%     imwrite(im_banda_RP, [nombre_figure '.jpg']);
% 
%     nombre_figure = [ruta_Figuras 'Topoplot_DiferenciaRP_Sujetos' num2str(n_RP)];
%     imwrite(im_banda_diferenciaRP, [nombre_figure '.jpg']);

%     nombre_figure = [ruta_Figuras 'Topoplot_AP_Sujetos' num2str(n_RP)];
%     imwrite(im_banda_AP, [nombre_figure '.jpg']);
    
%     nombre_figure = [ruta_Figuras 'Topoplot_DiferenciaAP_Sujetos' num2str(n_RP)];
%     imwrite(im_banda_diferenciaAP, [nombre_figure '.jpg']);

    nombre_figure = [ruta_Figuras 'Topoplot_DiferenciaAP_dB_Sujetos' num2str(n_RP)];
    imwrite(im_banda_diferenciaAP_dB, [nombre_figure '.jpg']);
    
%     nombre_figure = [ruta_Figuras 'Topoplot_DivisionAP_Sujetos' num2str(n_RP)];
%     imwrite(im_banda_divisionAP, [nombre_figure '.jpg']);


end

%}

