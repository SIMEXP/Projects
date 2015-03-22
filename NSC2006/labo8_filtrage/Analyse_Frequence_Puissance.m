function [F,Yd,A,Pu]=Analyse_Frequence_Puissance(x,t)
%
% [F,Yd,A,Pu]=Analyse_Frequence_Puissance(x,t)                
%       retourne les coefficients FFT (Yd), l'amplitude des coefficients FFT (A) 
%       en fonction de la fréquence (F) pour le signal (x) donné en fonction du temps (t). 
%       Retourne aussi la puissance (Pu) aux fréquences F.
%       (La phase n'est pas calculée)
%
% Christophe Martin - 03/2015

l=size(x,2);                % nombre de points
Yd=fft(x)/l;                % Fast Fourier Transform, normalisé par le nombre de points: donne un spectre double
Y=Yd(1:(l/2+1));            % Retourner seulement le spectre pour des fréquences positives

fs=1/(t(2)-t(1));           % Fréquence d'échantillonage
Ny=fs/2;                    % Fréquence de Nyquist: le spectre est défini jusqu'à la fréquence fs/2
F=linspace(0,1,l/2+1)*Ny;   % FFT retourne des coefficients pour l fréquences F linéairement distribuées entre 0 et Ny

A=2*sqrt(Y.*conj(Y));       % Calcul de l'amplitude pour les fréquences F: multipliée par 2 car nous avons uniquement la partie positive du spectre

Pu=A.^2;                     % Calcul de la puissance : carré de l'amplitude

plot(F,Pu);                 % spectre de puissance
title('Spectre de Puissance')
xlabel('Frequence (Hz)')    %
ylabel({'Puissance (dB)'})
set(gca,'yscale','log');
grid on
grid minor
end % fin de la fonction
