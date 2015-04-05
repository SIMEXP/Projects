function err = ErreurApproximation(signal1,signal2)
% Cette fonction génère l'erreur d'approximation d'un
% signal 1 par un signal 2
% Syntaxe: err = ErreurApproximation(signal1,signal2)
% signal1: (vecteur, longueur N) un signal
% signal2: (vecteur, longueur N) un signal
% err (scalaire, positif) l'erreur d'approximation de signal 1
%     par signal 2, défini par la racine carrée de la moyenne des 
%     différences au carré (slide 19, cours filtrage)
%
% Exemple:
% signal1 = randn(100,1);
% signal2 = signal1 + 0.3*randn(size(signal1));
% err = ErreurApproximation(signal1,signal2)

if nargin<2
    error('Specifiez SVP signal1 et signal2')
end

if ~isnumeric(signal1)||~isnumeric(signal2)||(length(signal1)~=length(signal2))
    error('signal1 et signal2 doivent être des vecteurs de même longueur')
end

err = sqrt(mean((signal1(:)-signal2(:)).^2));
