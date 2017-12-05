function patient = llegir_sessions_csv(nomFitxer, rutaFitxer)

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
fprintf('  LINES:  %d\n\n', comptarLinies(fullfile(rutaFitxer, nomFitxer)));

idFitxer = fopen(fullfile(rutaFitxer, nomFitxer), 'rt');
assert(idFitxer ~= -1, generatemsgid(mfilename), 'No s''ha pogut obrir: %s', fullfile(rutaFitxer, nomFitxer));
cleanupObj = onCleanup(@() fclose(idFitxer)); % Per tancar el fitxer un cop acabada la funció


%% LLEGIM FITXER LINIA A LINIA
% PRIMERA LINIA
header = textscan(idFitxer, '%s', 2, 'delimiter', '\n');

% Extreiem etiquetes dels canals
headerData = textscan(header{1}{1}, '%s', 'delimiter', ';');
headerData = headerData{1};
patient.ID = strtrim(headerData{1});

clear('header');

%% LLEGIM DADES DE CADA SESSIO (EN BUCLE FINS A ACABAR)
ses = 1;
while ~feof(idFitxer)
  try
    % fprintf('  - sessió %02d', ses);
    
    session = textscan(idFitxer, '%s', 22, 'delimiter', '\n');
    sessionData = session{1};
    clear('session');
    
    % idSession
    aux = textscan(sessionData{1}, '%s%u', 'delimiter', ';');
    patient.sessions(ses).ID = aux{2};
    % fprintf(' (id: %4d)\n', patient.sessions(ses).ID);
    
    % Date
    aux = textscan(sessionData{2}, '%s%D', 'delimiter', ';');
    patient.sessions(ses).date = aux{2};
    
    % Game-Version
    aux = textscan(sessionData{3}, '%s', 'delimiter', ';');
    aux = textscan(strtrim(aux{1}{2}), '%s', 'delimiter', '-');
    patient.sessions(ses).game = aux{1}{2};
    patient.sessions(ses).version = aux{1}{3};
    
    % Platform Score
    [~, pos] = textscan(sessionData{12}, '%s', 1,'delimiter', ';');
    aux = textscan(strrep(sessionData{12}(pos+1:end), ',', '.'), '%f', 'delimiter', ';');
    patient.sessions(ses).platformScore = aux{1};
    
    % idWorkplan
    aux = textscan(sessionData{4}, '%s%u', 'delimiter', ';');
    patient.sessions(ses).workPlanID = aux{2};
    
    % Complete?
    patient.sessions(ses).complete = 'unknown';
    
    % Quality of the calibration
    patient.sessions(ses).calQualityPFMsignal = 'unknown';
    patient.sessions(ses).calQualityABDsignal = 'unknown';
    patient.sessions(ses).calQualityPFMcont   = 'unknown';
    patient.sessions(ses).calQualityABDcont   = 'unknown';
    patient.sessions(ses).calError            = 'unknown';
    
    % Quality of the recording
    patient.sessions(ses).recQualityPFMsignal = 'unknown';
    patient.sessions(ses).recQualityABDsignal = 'unknown';
    
    % Target
    [~, pos] = textscan(sessionData{5}, '%s', 1,'delimiter', ';');
    aux = textscan(strrep(sessionData{5}(pos+1:end), ',', '.'), '%f', 'delimiter', ';');
    patient.sessions(ses).target.signal = aux{1};
    
    % Vaginal
    [~, pos] = textscan(sessionData{6}, '%s', 1,'delimiter', ';');
    aux = textscan(strrep(sessionData{6}(pos+1:end), ',', '.'), '%f', 'delimiter', ';');
    patient.sessions(ses).PFM.signal = aux{1};
    
    % Abdominal
    [~, pos] = textscan(sessionData{7}, '%s', 1,'delimiter', ';');
    aux = textscan(strrep(sessionData{7}(pos+1:end), ',', '.'), '%f', 'delimiter', ';');
    patient.sessions(ses).ABD.signal = aux{1};
    
    % VaginalCalibration
    [~, pos] = textscan(sessionData{8}, '%s', 1,'delimiter', ';');
    try
      aux = textscan(strrep(sessionData{8}(pos+1:end), ',', '.'), '%f', 'delimiter', ';');
      patient.sessions(ses).PFM.calibration = aux{1};
    catch
      fprintf('\nNO PFM CALIBRATION DATA for session %d (%s)\n', patient.sessions(ses).ID, patient.sessions(ses).date);
      patient.sessions(ses).PFM.calibration = [];
    end
    
    % WaistCalibration
    [~, pos] = textscan(sessionData{9}, '%s', 1,'delimiter', ';');
    try
      aux = textscan(strrep(sessionData{9}(pos+1:end), ',', '.'), '%f', 'delimiter', ';');
      patient.sessions(ses).ABD.calibration = aux{1};
    catch
      fprintf('\nNO ABD CALIBRATION DATA for session %d (%s)\n', patient.sessions(ses).ID, patient.sessions(ses).date);
      patient.sessions(ses).ABD.calibration = [];
    end
    
    % VaginalMinMax
    [~, pos] = textscan(sessionData{10}, '%s', 1,'delimiter', ';');
    aux = textscan(strrep(sessionData{10}(pos+1:end), ',', '.'), '%f', 'delimiter', ';');
    patient.sessions(ses).PFM.adjSignal = NaN;
    patient.sessions(ses).PFM.mvc = aux{1}(2);
    patient.sessions(ses).PFM.rest = aux{1}(1);
    patient.sessions(ses).PFM.max = NaN;
    patient.sessions(ses).PFM.llindar = NaN;
    
    % WaistMinMax
    [~, pos] = textscan(sessionData{11}, '%s', 1,'delimiter', ';');
    aux = textscan(strrep(sessionData{11}(pos+1:end), ',', '.'), '%f', 'delimiter', ';');
    patient.sessions(ses).ABD.adjSignal = NaN;
    patient.sessions(ses).ABD.mvc = aux{1}(2);
    patient.sessions(ses).ABD.rest = aux{1}(1);
    patient.sessions(ses).ABD.max = NaN;
    
    % Dummy field for later use
    patient.sessions(ses).matlabScores.PFMscore = 'unknown';
    
    % AppContractionsPlanned
    aux = textscan(sessionData{13}, '%s%u', 'delimiter', ';');
    patient.sessions(ses).appScores.contractionsPlanned = aux{2};
    
    % AppContractionsDetected
    aux = textscan(sessionData{14}, '%s%u', 'delimiter', ';');
    patient.sessions(ses).appScores.contractionsDetected = aux{2};
    
    % AppContractionsPerformed
    aux = textscan(sessionData{15}, '%s%u', 'delimiter', ';');
    patient.sessions(ses).appScores.contractionsPerformed = aux{2};
    
    % AppRelaxScore
    aux = textscan(sessionData{16}, '%s%u', 'delimiter', ';');
    patient.sessions(ses).appScores.RELAXscore = aux{2};
    
    % AppFastContractionsOver80
    aux = textscan(sessionData{17}, '%s%u', 'delimiter', ';');
    patient.sessions(ses).appScores.fastContractionsOver80 = aux{2};
    
    % AppHoldContractionsOver80
    aux = textscan(sessionData{18}, '%s%u', 'delimiter', ';');
    patient.sessions(ses).appScores.sustContractionsOver80 = aux{2};
    
    % AppABDSustScore
    aux = textscan(sessionData{19}, '%s%u', 'delimiter', ';');
    patient.sessions(ses).appScores.ABDscore = aux{2};
    
    % AppPFMScore
    aux = textscan(sessionData{20}, '%s%u', 'delimiter', ';');
    patient.sessions(ses).appScores.PFMscore = aux{2};
    
    % Questionnaire
    [~, pos] = textscan(sessionData{21}, '%s', 1,'delimiter', ';');
    aux = textscan(sessionData{21}(pos+1:end), '%s', 'delimiter', ';');
    %patient.sessions(ses).questionnaire = aux{1};
    
    % Did you like the game?
    switch aux{1}{1}
      case '0'
        response = '';
      case '1'
        response = 'yes';
      case '2'
        response = 'no';
      otherwise
        response = '??';
    end
    patient.sessions(ses).questions.like_game = response;
    
    % Was it difficult?
    switch aux{1}{2}
      case '0'
        response = '';
      case '1'
        response = 'yes';
      case '2'
        response = 'no';
      otherwise
        response = '??';
    end
    patient.sessions(ses).questions.difficult = response;
    
    % Was it difficult due to?
    switch aux{1}{3}
      case '0'
        response = '';
      case '1'
        response = 'muscle fatigue';
      case '2'
        response = 'game difficulty';
      case '12'
        if verLessThan('matlab', '9.1')
          response = char({'muscle fatigue', 'game difficulty'});
        else
          response = string({'muscle fatigue', 'game difficulty'});
        end
      otherwise
        response = '??';
    end
    patient.sessions(ses).questions.why_difficult = response;
    
    % Did you experience any problem since last session?
    switch aux{1}{4}
      case '0'
        response = '';
      case '1'
        response = 'yes';
      case '2'
        response = 'no';
      otherwise
        response = '??';
    end
    patient.sessions(ses).questions.problem = response;
    
    % Type of problem?
    if length(aux{1}{5}) > 1
      aux = aux{1}{5};
      aux = aux(2:end);
    else
      aux = aux{1}{5};
    end
    aux = textscan(aux, '%u', 'delimiter', '_');
    response = cell(0);
    for num = 1:length(aux{1})
      switch aux{1}(num)
        case 0
          response{num} = '';
        case 1
          response{num} = 'vaginal dryness';
        case 2
          response{num} = 'weight sensation';
        case 3
          response{num} = 'pain during training';
        case 4
          response{num} = 'pain during urination';
        case 5
          response{num} = 'menstruation';
        case 6
          response{num} = 'change in vaginal discharge';
        case 7
          response{num} = 'pain during urination';
        case 8
          response{num} = 'problem with the gadgets';
        otherwise
          response{num} = '??';
      end
    end
    if verLessThan('matlab', '9.1')
      patient.sessions(ses).questions.which_problem = char(response);
    else
      patient.sessions(ses).questions.which_problem = string(response);
    end
    
    ses = ses + 1;
  end
end
% fprintf(' SESSIONS: %d\n\n', length(patient.sessions));
