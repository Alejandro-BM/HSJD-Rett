function filtro = generar_filtro__0_5_45(fm)

    % Datos de diseño del filtro (0.5 a 45 Hz)
    Fstop1 = 0.4;         % First Stopband Frequency
    Fpass1 = 0.5;         % First Passband Frequency
    Fpass2 = 35;          % Second Passband Frequency
    Fstop2 = 35.05;       % Second Stopband Frequency
    Astop1 = 20;          % First Stopband Attenuation (dB)
    Apass  = 1;           % Passband Ripple (dB)
    Astop2 = 20;          % Second Stopband Attenuation (dB)
    match  = 'passband';  % Band to match exactly

    % Construct an FDESIGN object and call its CHEBY2 method.
    h  = fdesign.bandpass(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, Astop2, fm);
    filtro = design(h, 'cheby2', 'MatchExactly', match, 'SystemObject', true);
    reorder(filtro, 'up');
    
end