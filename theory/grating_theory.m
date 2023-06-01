%%  grating_theory.m
%   Designing the dispersion for the diffraction grating
%
%   Description:
%       The angular dispersion per wavelength depends on the incident
%       illumination and the periodicity of the grating. This script
%       calculates the desired parameters for a diven dispersion and also
%       the tunability range.

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   main
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% The diffraction grating equation is given as:
%
%       n(lambda) = d(sin(theta)+sin(theta')), where                    (1)
%
% n is the order of difraction (here, 1);
% theta and theta' are the angles of incidence and refraction,
% respectively;
% d is the distance between grooves

% We are interested in the dispersion property quantified by
% d(Beta)/d(lambda), i.e., change in dispersion angle per change in
% wavelength in units of mrad/nm; here, as per (1), d(theta')/d(lambda)

% Differentiating (1) gives:
%
%   d(theta')/d(lambda) = 1/[d sqrt(1 - ((lambda)/d - sin(theta))^2)]
%

% Let
lambda = 680e-9;

% Thorlabs produce transmission gratings with {300, 600, 830, 1200}
% gratings/mm
grating.frequency = [300,600,830,1200]; % /mm
% which equates to a 'd' of
grating.spacing = 1e-3./grating.frequency; % m
grating.spacing_nm = 1e9*1e-3./grating.frequency; % m

% At a zero incident angle (for comparison)
grating.dispersion_0incident = 1./(grating.spacing .* sqrt(1 - (lambda./grating.spacing - sin(0)).^2));
% At a 10deg incident angle (for comparison)
grating.dispersion_10incident = 1./(grating.spacing .* sqrt(1 - (lambda./grating.spacing - sind(10)).^2));
% At a 30deg incident angle (for comparison)
grating.dispersion_30incident = 1./(grating.spacing .* sqrt(1 - (lambda./grating.spacing - sind(30)).^2));

grating.dispersion_plot = []; c=0;
for incident_angle_ = 0:45
    c = c+1;
    grating.dispersion_plot(c,:) = 1./(grating.spacing .* sqrt(1 - (lambda./grating.spacing - sind(incident_angle_)).^2));
end
figure;
plot(grating.dispersion_plot)




% We want
desired.dispersion_MradPerNm = 0.4640;
desired.dispersion_RadPerM = desired.dispersion_MradPerNm*1e6;

% Thus, the incident angle required is:
grating.incidentAngleNeeded = asin(lambda./grating.spacing - sqrt(1 - (1./(grating.spacing*desired.dispersion_RadPerM)).^2));


