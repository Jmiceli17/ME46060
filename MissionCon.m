% ME46060 Optimization Final Project
% Paul DeTrempe & Joe Miceli

%-----DEFINITION OF CONSTRAINT FUNCTIONS (for full optimization)-----
function [c, ceq] = MissionCon(x)
% input   x   :  [1x6] row of design variables (deltaV01,delta01,lambda2,deltaV56,delta56,lambda8)
% output  c   :  [1x4] vector of scaled inequality constraint values
%		  ceq :  [] vector containing equality constraints

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

% scaled inequality constraint functions
g(1) = (deltaVtotal/12.26611) - 1;		% total deltaV constraint
g(2) = 1 - (rpMoon/(rcMoon-10));		% circular orbit around moon must be +- 10km within desired target
g(3) = (rpMoon/(rcMoon + 10)) - 1;		% circular orbit around moon must be +- 10km within desired target
g(4) = (rpReturn/(100 + REarth)) - 1;	% SOI-earth transfer orbit perigee constraint

%---NO LONGER USING THESE CONSTRAINTS---
% g(4) = (Vpearth/11.0) - 1;			% ORION reentry velocity constraint
% g(1)= rapo12/(RMoon - Rsoi) - 1;	%earth-moon transfer orbit apogee constraint
% g(2) = rapo67/Rsoi - 1;	%moon-SOI transfer orbit apolune constraint
%-------------------------------------

%-----RELAXED CONSTRAINT ANALYSIS (to be deleted)-----
% relaxing the constraints
% Initial opmitimization converged to infeasible point that produced following constraint vals
% MissionCon(x) = 0.000617289085149  -0.010332649886552  0.001339924920939  0.004139593100985  0.002542847735773
% del values delg1 = 0.0007; delg2 = 0.01; delg3 = 0.002; delg4 = 0.0042; delg5 = 0.0026; 
% produced x = 3.31765298468959	5.33678141940735	20.0590949180213	0.782030768298087	17.5871012055154	-31.0802636734197 
% used as a new starting point x0
% this x0 produced x = 3.32259893237480	5.47580282804868	19.8199385602374	0.781475926482696	19.9995615091918	-31.3673656745829
% this is a local min of f = 0 that satisfies constraints
% use this as starting point and decrease del vals
% decreases these values as much as possible while using f = 0 to find feasible starting point
% delg1 = 0.00059;
% delg2 = 0.0;
% delg3 = 0.0014;
% delg4 = 0.0043;
% delg5 = 0.0026;
% these values produce 
% x = 3.32259893237480	5.47580282804868	19.8199385602374	0.781475926482696	19.9995615091918	-31.3673656745829 (same as above)
% MissionCon(x) = -0.538084751682803  -0.008838916417797  -0.001540513189838  -0.000099886725037  -0.000176180382467
% Using the above starting value, a feasible optimum was obtained in FullOptimization.m (very large step size used for
% deltaVlb to just to see if optimum can be obtained)
% obtained optimum: x = 5.3350648321574 -0.0302417407812576	4.68372451802133	0.781450008619922	-16.1498659846787	-30.9613631453944
% fval = 1.133038861763218e+05
% c = [g(1)-delg1, g(2)-delg2, g(3)-delg3, g(4)-delg4, g(5)-delg5];
%-----------------------------------------------------
c = [g(1), g(2), g(3), g(4)];    % inequality constraint functions
ceq = [];   % equality constraint functions

% end