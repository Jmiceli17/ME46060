% ME46060 Optimization Final Project
% Paul DeTrempe & Joe Miceli

%-----DEFINITION OF CONSTRAINT FUNCTIONS (for algorithm)-----
function [c, ceq] = MissionConInitialAlg(x)
% input   x   :  [1x2] row of design variables (deltaV01, deltaV56)
% output  g   :  [1x4] vector of scaled inequality constraint values

% assignment of design variables 
% these are the starting values from FullOptimization.m also using
% deltaV01 = 3.5, deltaV56 = 1.5
deltaV01 = x(1);
delta01 = -0.0073230;
lambda2 = 5.93820;
deltaV56 = x(2);
delta56 = -0.0020709;
lambda8 = -15.25942;

% load constant mission parameters
MissionParams;

[tfTotal,deltaVtotal, rpMoon, Vpearth, rpReturn] =...
    MoonMission(deltaV01,delta01,lambda2,deltaV56,delta56,lambda8);

% scaled constraint functions
g(1) = (deltaVtotal/12.26611) - 1;	% total deltaV constraint
g(2) = 1 - (rpMoon/(rcMoon-10));	% circular orbit around moon must be +- 10km within desired target, testing removal of g2,g3
g(3) = (rpMoon/(rcMoon + 10)) - 1;	% circular orbit around moon must be +- 10km within desired target
g(4) = rpReturn/(100 + REarth) - 1;	% SOI-earth transfer orbit perigee constraint

%---NO LONGER USING THESE CONSTRAINTS---
%g(2) = (Vpearth/11.0) - 1;			% ORION reentry velocity constraint
% g(1) = (rapo12/(RMoon - Rsoi)) - 1;
% g(2) = (rapo67/Rsoi) - 1;
% g(3) = (rpReturn/(100 + REarth)) - 1;
%-------------------------------------

c = [g(1), g(2), g(3), g(4)];	% inequality constraints
ceq = [];						% equality constraints
% end