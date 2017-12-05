function varargout = inicio_de_programa(varargin)

% INICIO_DE_PROGRAMA Muestra un mensaje de inicio con fecha y hora, retorna
%                    el instante de inicio y el path actual (obtenidos con
%                    CLOCK y PATH).
%
%
%  [INICIO, PATH_ACTUAL] = INICIO_DE_PROGRAMA();
%
%  [INICIO, PATH_ACTUAL, FICHERO, CARPETA] = INICIO_DE_PROGRAMA(ETIQUETA) 
%    Utilitza la funcion GUARDA_LOG para generar un registro de ejecucion.
%    Opcionalmente retorna también en nombre de fichero y la carpeta donde
%    se ha guardado.
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


%% LECTURA Y GESTIÓN DE LOS ARGUMENTOS
narginchk(0, 1);
if nargin == 0
  nargoutchk(0, 2);
else
  nargoutchk(0, 4);
end


%% MENSAJE DE INICIO
disp(['INICIO!!!  [ '  datestr(now) ' ]']);


%% ASIGNAMOS ARGUMENTOS DE SALIDA
varargout{1} = clock;
varargout{2} = path;
if nargin > 0
  [varargout{3}, varargout{4}] = guarda_log(varargin{1});
end
