function moy = ReponseMoyenne(taille)
% Cette fonction génère une fonction de réponse à une impulsion,
% correspondant à une moyenne mobile
%
% Syntaxe: moy = ReponseMoyenne(taille)
%  taille: (entier) le nombre de points dans la moyenne
%  moy: (vecteur) réponse associée a la moyenne mobile
%
% Remarque:
%  Le code de cette fonction a été rencontré à la question 1.2 
%  du laboratoire du cours 6 (introduction au traitement  des signaux)
%
% Exemple:
%  moy = ReponseMoyenne(4);
%  plot(moy,'bo')

% On commence par une réponse composée de 1
moy = ones(1,taille);

% On divise par le nombre de points pour avoir une moyenne
moy = moy/taille;