function patient = llegir_sessions_easy(nomFitxer, rutaFitxer)

% LLEGIR_SESSIONS_CSV  Llegir fitxer CSV de sessions, exportat des de platform.women-up.eu
%
%   pacient = llegir_sessions_csv(nomFitxer)
%
%   Retorna una estructura de dades amb els camps següents:
%   - EEG:            Matriu amb les dades dels canals (per columnes)
%   - tempsInicial:   Cadena de text amb l'hora d'inici del registre
%   - etiquetes:      Cell-array amb els noms dels canals
%
%   midaDeBloc es calcula automàticament, però pot especificar-se en cas d'importació manual.
%

% IMPORTANT!!: Editeu aquest arxiu en un editor compatible amb UTF8!!
%
% CREAT:   2017.01.26, per Joan F. Alonso
% BASAT:   llegir_EEG_txt.m per llegir fitxers TXT de Mitsar
%
% REVISAT: , per
% Canvis:
%

%% COMPROVACIÓ DELS ARGUMENTS
narginchk(1,2);
nargoutchk(1,1);


%% OBRIM EL FITXER
fprintf('* READING SESSIONS\n');
fprintf('  FILE:   %s\n', nomFitxer);
%fprintf('  LINES:  %d\n\n', comptarLinies(fullfile(rutaFitxer, nomFitxer)));

idFitxer = fopen(fullfile(rutaFitxer, nomFitxer), 'rt');
%assert(idFitxer ~= -1, generatemsgid(mfilename), 'No s''ha pogut obrir: %s', fullfile(rutaFitxer, nomFitxer));
cleanupObj = onCleanup(@() fclose(idFitxer)); % Per tancar el fitxer un cop acabada la funció


%% LLEGIM FITXER LINIA A LINIA
% PRIMERA LINIA

% El fichero de datos no tiene cabecera. Analizando visualmente la se�al
% hemos visto que el fichero de texto incluye informaci�n de:
% - 20 canales (de los c�ales solo 13 captan EEG)
% - 3 acelerometros
% - Un caracter de informaci�n sobre la tarea (trigger information)
% - Informaci�n sobre el instante de tiempo de la muestra

% Esto hace un total de 25 datos por cada l�nea.


%% LLEGIM DADES DE CADA SESSIO (EN BUCLE FINS A ACABAR)
ses = 1;
while ~feof(idFitxer)
  try
    % fprintf('  - sessió %02d', ses);
    
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
