function hemo = ReponseHemodynamique(freq)
% Cette fonction génère une fonction de réponse à une impulsion,
%  correspondant à un processus hémodynamique.
%
% Syntaxe: hemo = ReponseHemodynamique(freq)
%  freq: (scalaire) la fréquence d'échantillonnage
%  hemo:  (vecteur) la réponse hémodynamique
%
% Remarque:
%  Le code de cette fonction était utilisé dans la question 1.1
%  du laboratoire du cours 8 'Introduction au filtrage'
%
% Exemple:
%  hemo = ReponseHemodynamique(0.5);
%  plot(hemo,'-o')

% ce paramètre fixe le pic de la réponse hémodynamique
pic = 5;

% fonction de réponse hémodynamique modélisée par des droites (linspace)
% D'abord une augmentation de la ligne de base
% puis une diminution sous la ligne de base
% suivie d'un retour à la ligne de base
hemo = [linspace(0,1,(pic*freq)+1) linspace(1,-0.3,(pic*freq)/2) linspace(-0.3,0,(pic*freq)/2)]; 

% On rajoute des zéros au début de la réponse
% de façon a ce que la réponse à une impulsion 
% démarre à l'instant correspondant à l'impulsion
hemo = [zeros(1,length(hemo)-1) hemo]; 

% On normalise la réponse
hemo = hemo/sum(abs(hemo));