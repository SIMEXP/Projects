function [sig_filt]=FiltrePasseHaut(signal,fs,freq_coupure)
% filtre passe-haut du signal. fs est la fréquence d'échantillonage du
% signal. freq_coupure est la fréquence de coupure du filtre passe-haut

dfiltfreq=freq_coupure/(fs/2);      % calcule la fréquence de coupure normalisée
[b,a]=cheby1(8,dfiltfreq,'high');   % crée un filtre passe-haut
sig_filt=filtfilt(b,a,signal);      % applique le filtre au signal
toto
return