% Charger les donnees
load('Chap17_Data')
% Preparer une figure
figure 
% permettre la superposition de plusieurs graphiques dans la meme figure
hold on 
% Donner un label à l'axe des x
xlabel('Temp (sec)'); 
% Donner un label à l'axe des y
ylabel('Essai #')
% Ajuster les limites de l'axe des y
ylim([0 length(spike)])

for num_spike = 1:length(spike) %faire une boucle pour tout les essais
    ...
    ...
    ...
    ...
end