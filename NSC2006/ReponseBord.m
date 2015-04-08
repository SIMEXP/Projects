function bord = ReponseBord(taille)
% Cette fonction génère une fonction de réponse à une impulsion,
% correspondant à une détection de bord.
%
% Syntaxe: bord = ReponseBord(taille)
%  taille: (entier, impair) le nombre de points dans la réponse
%  bord: (vecteur) la réponse associée a la détection de bords
%
% Remarque:
%  Si le paramétre taille n'est pas impair, la taille de la variable
%  bord sera (taille+1)
%
% Remarque:
%  Le code de cette fonction a été rencontré à la question 1.4
%  du laboratoire du cours 6 (introduction au traitement  des signaux)
%
% Exemple:
%  bord = ReponseBord(5);
%  plot(bord,'-o')

% La réponse a N valeurs négatives, un zéro, puis N valeurs positives
% Pour choisir N, on divise taille-1 par deux (le -1 est pour le zéro central)
% On applique la fonction ceil pour s'assurer que le résultat soit un nombre entier
% Même si taille n'est pas un chiffre impair
nb_points = ceil((taille-1)/2);

% On construit bord avec N valeurs de -1, puis un 0, puis N valeurs de 1
bord = [-ones(1,nb_points) 0 ones(1,nb_points)];

% Enfin on divise par N, afin que la convolution corresponde à une différence 
% de moyennes. 
bord = bord / nb_points;