function final_de_programa(varargin)

% FINAL_DE_PROGRAMA Calcula el tiempo de ejecucion de un script
%
%   FINAL_DE_PROGRAMA(INICIO), calcula el tiempo entre el valor guardado en
%       INICIO y el instante de llamada de la funcion.
%       Muestra en pantalla un mensaje y para el registro de ejecucion
%       (diary) si fuera necesario.
%
%   Ejemplos de uso (en un script):
%
%   inicio = inicio_de_programa();   [ini, p_act, f, d] = inicio_de_programa(mfilename);
%          .                                            .
%          .                                            .
%          .                                            .
%
%   final_de_programa(inicio);       final_de_programa(inici);
%                                    copyfile(fullfile(d, f), '/home/user/logs');
%                                    path(p_act);


%% LECTURA Y GESTION DE LOS ARGUMENTOS DE LA FUNCIÓN
narginchk(1, 2);


%% CALCULO DEL TIEMPO DE EJECUCION Y RESTAURACION DEL PATH
temps = etime(clock, varargin{1});
if nargin > 1
  path(varargin{2});
end

%% CONVERSION A HORAS, MINUTOS Y SEGUNDOS
hores  = floor(temps/3600);
minuts = floor((temps-hores*3600)/60);
segons = ceil(temps - hores*3600 - minuts*60);


%% MENSAJE
disp(' ');
disp(['Tiempo de ejecucion: ' num2str(hores) ' horas, ' num2str(minuts) ' minutos y ' num2str( ...
  segons) ' segundos']);
disp(' ');
disp(['FINAL!!!  [ '  datestr(now) ' ]']);
disp(' ');
diary('off');
