%% Preparer les données

% Charger les donnees
load('Chap17_Data') 
% Donner une liste des variables
whos
% Trouver les champs de la varialbe "spike"
fieldnames(spike)
% Nombre de décharges pour l'essai 1
size(spike(1).times)
% Afficher tous les temps de décharge pour l'essai 1
spike(1).times
% Assigner les donnee du premier essai a la variable t1.
t1=spike(1).times; 
% Assigner les donnee du deuxième essai a la variable t2.
t2=spike(2).times; 

%% Construire la figure

% Preparer une figure
figure 
% permettre la superposition de plusieurs graphiques dans la meme figure
hold on 
% Tracer la première ligne du diagramme 
for num_temps = 1:length(t1) % on boucle sur toutes les décharges du premier essai
    line([t1(num_temps) t1(num_temps)], [0 1]) % tracer un ligne correspondant au temps d'une décharge
end
% Tracer la deuxième ligne du diagramme 
for num_temps = 1:length(t2) 
    line([t2(num_temps) t2(num_temps)], [1 2])
end
% Donner un label à l'axe des x
xlabel('Temp (sec)'); 
% Donner un label à l'axe des y
ylabel('Essai #')
% Ajuster les limites de l'axe des y
ylim([0 3])