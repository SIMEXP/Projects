function hrf = ReponseHemodynamique(freq)
% Cette fonction génère une fonction de réponse 
% telle que la convolution corresponde à une réponse hémodynamique
% Syntaxe: hrf = ReponseHemodynamique(taille)
% freq (scalaire) la fréquence d'échantillonnage
% hrf: le vecteur associé a la réponse hémodynamique
%
% Exemple:
% hrf = ReponseHemodynamique(0.5);
% stem(hrf)

if nargin<1
    error('SVP spécifiez freq')
end

if ~isnumeric(freq)||(numel(freq)>1)
    error('Le paramétre freq est un scalaire')
end

% paramétres de la réponse
hrf_parameters = [5.4 5.2 10.8 7.35 0.35];
peak1 = hrf_parameters(1);
fwhm1 = hrf_parameters(2);
peak2 = hrf_parameters(3);
fwhm2 = hrf_parameters(4);
dip   = hrf_parameters(5);
   
taille = ceil(20*freq)*2+1;
nb_points = (taille-1)/2;
time = (0:nb_points)/freq;
tinv=(time>0)./(time+(time<=0));
alpha1    = peak1^2/fwhm1^2*8*log(2);
beta1     = fwhm1^2/peak1/8/log(2);
gamma1    = (time/peak1).^alpha1.*exp(-(time-peak1)./beta1);
d_gamma1  = -(alpha1*tinv-1/beta1).*gamma1;
alpha2    = peak2^2/fwhm2^2*8*log(2);
beta2     = fwhm2^2/peak2/8/log(2);
gamma2    = (time/peak2).^alpha2.*exp(-(time-peak2)./beta2);
d_gamma2  = -(alpha2*tinv-1/beta2).*gamma2;
hrf   = gamma1-dip*gamma2;
d_hrf = d_gamma1-dip*d_gamma2;
hrf = [zeros(1,nb_points) hrf];