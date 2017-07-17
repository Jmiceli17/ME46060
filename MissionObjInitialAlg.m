% ME46060 Optimization Final Project
% Paul DeTrempe & Joe Miceli

%-----DEFINITION OF OBJECTIVE FUNCTION (for algorithm)-----
function f = MissionObjInitialAlg(x)
% input   x   :  [1x2] row of design variables (deltaV01,deltaV56)
% output  f   :  [1x1] scalar of objective function value

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

% calling the model
[tfTotal,deltaVtotal, rpMoon, Vpearth, rpReturn] =...
    MoonMission(deltaV01,delta01,lambda2,deltaV56,delta56,lambda8);

% unscaled objective function
% total travel time
f = tfTotal;
% end 