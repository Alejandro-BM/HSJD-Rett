function [data_path, local_results_path, results_path] = config_function()
    % [data_path, results_path] = CONFIG_FUNCTION()
    % 
    % Funcion de configuracion. Edita las carpetas para ajustarlas a 
    % tu configuracion local, y llamarla al inicio de cada script

    % Donde se guardan los datos
    data_path = 'D:\Alebm\BBDD\BIOART_signals\EEG_Rett_HSJD_2017\BBDD';
    
    % Donde se guardan los resultados
    results_path = 'D:\Alebm\BBDD\BIOART_signals\EEG_Rett_HSJD_2017\Resultados';
    local_results_path = fullfile(pwd, 'Resultados');
   
    % Donde estan las funciones de calculo
    addpath('Funciones')
end

