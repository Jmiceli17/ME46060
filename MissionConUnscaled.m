% ME46060 Optimization Final Project
% Paul DeTrempe & Joe Miceli
%-----defnition of constraint functions-----

function [c] = MissionConUnscaled(x)
% input  x   :   [1x6] row of design variables (deltaV01,delta01,lambda2,deltaV56,delta56,lambda8)
% output  c   :  [1x3] vector of scaled inequality constraint values
%		  ceq :  [] vector containing equality constraints

% assignment of design variables 
% !!!!!!!!!!!!!!1can do with a for loop but not sure of syntax!!!!!!!!!!!!!!!!
currentfunc = 'Mission Con is Running';
deltaV01 = x(1);
delta01 = x(2);
lambda2 = x(3);
deltaV56 = x(4);
delta56 = x(5);
lambda8 = x(6);

% load constant mission parameters
MissionParams;

[tfTotal,deltaVtotal, rpMoon, rpReturn, Vpearth] =...
    MoonMission(deltaV01,delta01,lambda2,deltaV56,delta56,lambda8);


% scaled inequality constraint functions

% g(1) = rapo12/(RMoon - Rsoi) - 1;	%earth-moon transfer orbit apogee constraint
% g(2) = rapo67/Rsoi - 1;	%moon-SOI transfer orbit apolune constraint
% g(3) = rpReturn/(100 + REarth) - 1;	%SOI-earth transfer orbit perigee constraint

g(1) = (deltaVtotal - 12.2661);	% total deltaV constraint
g(2) = rcMoon-10 - rpMoon;	% circular orbit around moon must be +- 10km within desired target
g(3) = (rpMoon) - (rcMoon + 10);	% circular orbit around moon must be +- 10km within desired target
g(4) = (Vpearth) - 11;			% ORION reentry velocity constraint
g(5) = rpReturn - (100 + REarth);	%SOI-earth transfer orbit perigee constraint

% Output with Names

deltaVtotaldiff = (deltaVtotal - 12.2661);	% total deltaV constraint
MoonPeriapsediff1 = rcMoon-10 - rpMoon;	% circular orbit around moon must be +- 10km within desired target
MoonPeriapsediff2 = (rpMoon) - (rcMoon + 10);	% circular orbit around moon must be +- 10km within desired target
Vdeathdiff = (Vpearth) - 11;			% ORION reentry velocity constraint
EarthPeriapsediff = rpReturn - (100 + REarth);

c = [g(1), g(2), g(3), g(4), g(5)];


% end