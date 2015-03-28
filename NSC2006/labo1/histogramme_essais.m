clear

% Charger les donnees
load('Chap17_Data')

% Definir les centres des intervalles pour l'histogramme
centres = [-0.95:0.1:0.95];

% Initialiser une matrice de zéros histo dont la longueur est égale au nombre d'intervalles:
histo = zeros(1,length(centres));

% Faire une boucle à travers tous les essais et recuperer le nombre de decharges par intervalle avec la fonction histc 
for jj = 1:47 
    % A remplir !
end

% Dessiner l'histograme avec la fonction bar
bar(centres,histo);

%Ajuster les limites de l'axe des x
xlim([-1.1 1]);

% Donner un label à l'axe des x
xlabel('Temps (sec)');

% Donner un label à l'axe des y
ylabel('# essais');