function bord = ReponseBord(taille)
% Cette fonction génère une fonction de réponse 
% telle que la convolution corresponde à une détection de bord
% Syntaxe: moy = ReponseBord(taille)
% taille: (entier, impair) le nombre de points dans la réponse
% bord: le vecteur associé a la détection de bords
%
% Exemple:
% bord = ReponseBord(5);
% stem(bord)
if ~isnumeric(taille)||(numel(taille)>1)||(round(taille)~=taille)||((2*floor(taille/2)+1)~=taille)||(taille<0)
    error('Le paramétre taille doit être un nombre entier impair positif')
end
nb_points = (taille-1)/2;
bord = [-ones(1,nb_points) 0 ones(1,nb_points)];
bord = bord / nb_points;