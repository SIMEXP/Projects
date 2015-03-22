function [sig_filt]=FiltrePasseBande(signal,fs,freq_coupure_basse,freq_coupure_haute)
% filtre passe-bande du signal. fs est la fréquence d'échantillonage du signal. 
% freq_coupure_basse est la fréquence basse de coupure du filtre passe-bande
% freq_coupure_haute est la fréquence haute de coupure du filtre passe-bande

dfiltfreqb=freq_coupure_basse/(fs/2);      % calcule la fréquence de coupure normalisée
dfiltfreqh=freq_coupure_haute/(fs/2);      % calcule la fréquence de coupure normalisée
[b,a]=cheby1(5,5,[dfiltfreqb,dfiltfreqh]);   % crée un filtre passe-haut
sig_filt=filtfilt(b,a,signal);      % applique le filtre au signal

return