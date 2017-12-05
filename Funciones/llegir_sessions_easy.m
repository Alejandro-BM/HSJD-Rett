function patient = llegir_sessions_easy(nomFitxer, rutaFitxer)

% LLEGIR_SESSIONS_CSV  Llegir fitxer CSV de sessions, exportat des de platform.women-up.eu
%
%   pacient = llegir_sessions_csv(nomFitxer)
%
%   Retorna una estructura de dades amb els camps segÃ¼ents:
%   - EEG:            Matriu amb les dades dels canals (per columnes)
%   - tempsInicial:   Cadena de text amb l'hora d'inici del registre
%   - etiquetes:      Cell-array amb els noms dels canals
%
%   midaDeBloc es calcula automÃ ticament, perÃ² pot especificar-se en cas d'importaciÃ³ manual.
%

% IMPORTANT!!: Editeu aquest arxiu en un editor compatible amb UTF8!!
%
% CREAT:   2017.01.26, per Joan F. Alonso
% BASAT:   llegir_EEG_txt.m per llegir fitxers TXT de Mitsar
%
% REVISAT: , per
% Canvis:
%

%% COMPROVACIÃ“ DELS ARGUMENTS
narginchk(1,2);
nargoutchk(1,1);


%% OBRIM EL FITXER
fprintf('* READING SESSIONS\n');
fprintf('  FILE:   %s\n', nomFitxer);
%fprintf('  LINES:  %d\n\n', comptarLinies(fullfile(rutaFitxer, nomFitxer)));

idFitxer = fopen(fullfile(rutaFitxer, nomFitxer), 'rt');
%assert(idFitxer ~= -1, generatemsgid(mfilename), 'No s''ha pogut obrir: %s', fullfile(rutaFitxer, nomFitxer));
cleanupObj = onCleanup(@() fclose(idFitxer)); % Per tancar el fitxer un cop acabada la funciÃ³


%% LLEGIM FITXER LINIA A LINIA
% PRIMERA LINIA

% El fichero de datos no tiene cabecera. Analizando visualmente la señal
% hemos visto que el fichero de texto incluye información de:
% - 20 canales (de los cúales solo 13 captan EEG)
% - 3 acelerometros
% - Un caracter de información sobre la tarea (trigger information)
% - Información sobre el instante de tiempo de la muestra

% Esto hace un total de 25 datos por cada línea.


%% LLEGIM DADES DE CADA SESSIO (EN BUCLE FINS A ACABAR)
ses = 1;
while ~feof(idFitxer)
  try
    % fprintf('  - sessiÃ³ %02d', ses);
    
    session = textscan(idFitxer, '%f', 25, 'delimiter', '\n');
    sessionData = session{1};
    clear('session');
    
    matriz_session(ses,:) = sessionData;
    
    ses = ses + 1;
  catch
  end
end

patient = matriz_session;

clear matriz_sesions ses idFitxer session
