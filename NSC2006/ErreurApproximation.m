function err = ErreurApproximation(signal1,signal2)
% Cette fonction génère l'erreur d'approximation d'un
% signal 1 par un signal 2
%
% Syntaxe: err = ErreurApproximation(signal1,signal2)
%  signal1: (vecteur, longueur N) un signal
%  signal2: (vecteur, longueur N) un signal
%  err (scalaire, positif) l'erreur d'approximation de signal 1
%   par signal 2, tel que défini dans la diapositive 19 du cours 8 (filtrage)
%
% Remarque:
%  Le code de cette fonction a été rencontré à la question 2.2
%  du laboratoire du cours 8 (introduction au filtrage)
%
% Exemple:
%  signal1 = randn(100,1);
%  signal2 = signal1 + 0.3*randn(size(signal1));
%  err = ErreurApproximation(signal1,signal2)

% Cette ligne correspond à l'équation de la diapositive 19 du cours 8 (filtrage)
err = sqrt(mean((signal1(:)-signal2(:)).^2));
