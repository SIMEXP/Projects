function moy = ReponseMoyenne(taille)
% Cette fonction génère une fonction de réponse 
% telle que la convolution corresponde à une moyenne mobile
% Syntaxe: moy = ReponseMoyenne(taille)
% taille: (entier) le nombre de points dans la moyenne
% moy: le vecteur associé a la moyenne mobile
%
% Exemple:
% moy = ReponseMoyenne(4);
% stem(moy)

if ~isnumeric(taille)||(numel(taille)>1)||(round(taille)~=taille)
    error('Le paramétre taille doit être un nombre entier')
end
moy = ones(1,taille);
moy = moy/sum(moy(:));