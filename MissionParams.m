% Moon Mission parameters

% Includes universal constants for the planets and some mission parameters
% that can be altered by the user

 %--------------------------------------------------------------------------
    %-----physical constants
    muEarth = 398600;    % whichever units use kilometers
    muMoon = 4904.9;     % which units use kilometers
    aMoon =  384400;     % semi-major axis of moon orbit (km)
    vMoon =  1.022;      % mean moon orbital speed (km/s)
    Rsoi = 66183;        % Sphere of influence of radius of moon (km)
    REarth = 6371;       % Radius of the Earth in km
    RMoon = 1737;        % Radius of the Moon in km
    
    %-------Mission Input Parameters (changed for mission)
    hEarth = 200;        % Altitude in km
    hMoon = 500;         % Altitude in km

    % Derived quantities from input parameters
    rcEarth = REarth + hEarth;      % circular radius at earth (km)
    rcMoon = RMoon + hMoon;        % circular radius at moon (km)
    vcEarth = sqrt(muEarth/rcEarth);% circular velocity in Earth parking orbit (km/s)
    vcMoon = sqrt(muMoon/rcMoon);   % circular velocity at mission radius at moon (km/s)