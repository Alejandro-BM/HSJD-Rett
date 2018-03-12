function [data_path, local_results_path, results_path, dir_Dropbox] = config_function()
    % [data_path, results_path] = CONFIG_FUNCTION()
    % 
    % Funcion de configuracion. Edita las carpetas para ajustarlas a 
    % tu configuracion local, y llamarla al inicio de cada script

    % Donde se guardan los datos
    %data_path = 'D:\Alebm\BBDD\BIOART_signals\EEG_Rett_HSJD_2017\BBDD';
    data_path = '/Volumes/PC_GIB_VALL/UPC/EEG_Rett_HSJD_2017/BBDD_2018/';
    %data_path = 'F:\UPC\EEG_Rett_HSJD_2017\BBDD_2018\';
    %data_path = 'F:\UPC\EEG_Rett_HSJD_2017\BBDD_2018\Resultados\';
    
    % Donde se guardan los resultados
    %results_path = 'D:\Alebm\BBDD\BIOART_signals\EEG_Rett_HSJD_2017\Resultados';
    results_path = '/Volumes/PC_GIB_VALL/UPC/EEG_Rett_HSJD_2017/BBDD_2018/Resultados/';
    %results_path = 'F:\UPC\EEG_Rett_HSJD_2017\BBDD_2018\Resultados\';
    local_results_path = fullfile(pwd, 'Resultados');
    
    %dir_Dropbox = 'C:\Users\UTGAEIB\Dropbox\';
    dir_Dropbox = '/Users/alejandro.bachiller/Dropbox/';
   
    % Donde estan las funciones de calculo
    addpath('Funciones')
end

