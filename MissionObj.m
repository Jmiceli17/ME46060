% ME46060 Optimization Final Project
% Paul DeTrempe & Joe Miceli

%-----DEFINITION OF OBJECTIVE FUNCTION (for full optimization)-----
function f = MissionObj(x)
% input   x   :  [1x6] row of design variables (deltaV01,delta01,lambda2,deltaV56,delta56,lambda8)
% output  f   :  [1x1] scalar of objective function value

% assignment of design variables 
deltaV01 = x(1);
delta01 = x(2);
lambda2 = x(3);
deltaV56 = x(4);
delta56 = x(5);
lambda8 = x(6);

% load constant mission parameters
MissionParams;

% calling the model
[tfTotal,deltaVtotal, rpMoon, Vpearth, rpReturn] =...
    MoonMission(deltaV01,delta01,lambda2,deltaV56,delta56,lambda8);

% unscaled objective function
% total travel time
f = tfTotal;
% end 