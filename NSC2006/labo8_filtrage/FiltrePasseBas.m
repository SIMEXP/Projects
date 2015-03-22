function [sig_filt]=FiltrePasseBas(signal,fs,freq_coupure)
% filtre passe-bas du signal. fs est la fréquence d'échantillonage du
% signal. freq_coupure est la fréquence de coupure du filtre passe-bas

dfiltfreq=freq_coupure/(fs/2);      % calcule la fréquence de coupure normalisée
[b,a]=butter(8,dfiltfreq);          % crée un filtre passe-bas
sig_filt=filtfilt(b,a,signal);      % applique le filtre au signal

return