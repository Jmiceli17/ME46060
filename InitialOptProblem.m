% ME46060 Final Project
% Paul DeTrempe & Joe Miceli
%-----Initial Optimization-----

% constant values for delta01,lambda2, delta56,lambda8
clf, hold off clear, close all

% Variables and their ranges (if applicable)
% bounds of deltaV's obtained in try/catch of FullOptimization.m
deltaV01vector = linspace(3.43714, 11.48, 100); 
deltaV56vector = linspace(0.7815, 10.04, 100);
delta01 = -0.0073230;
lambda2 = 5.93820;
delta56 = -0.0020709;
lambda8 = -15.25942;



% RESULTS FROM THIS STARTING VALUE (obtained on FullOptimization:
% fval = 7.695278075874709e+04
% x* = [4.71436,-0.00732298,5.9381987,2.518586,-0.00207087,-15.259420]

% BUILDING MATRICES TO BE PLOTTED
for j=1:1:length(deltaV56vector)
  for i=1:1:length(deltaV01vector)
    % assign all variables in to pass to functions
  	y(1) = deltaV01vector(i);
    y(2) = delta01;
    y(3) = lambda2;
	y(4) = deltaV56vector(j);
    y(5) = delta56;
    y(6) = lambda8;
	%define objective function
	f = MissionObjInitial(y);
	%grid values of objective function
	fobj(j,i) = f;

	g = MissionConInitial(y);   % initial constraint file for plotting
	g1(j,i) = g(1); % total deltaV constraint
	g2(j,i) = g(2);	% rpMoon min constraint
	g3(j,i) = g(3);	% rpMoon max constraint
	g4(j,i) = g(4);	% rpReturn constraint
    
    %---NO LONGER USING THIS CONSTRAINT---
    % g5(j,i)	= g(5);	% Vpearth constraint
    %-------------------------------------
    
  end
end

% OPTIMIZATION OF PROBLEM

% initial values
% same starting values as FullOptimization.m
% x0 = [3.5,1.5];	% deltaV01, deltaV56
% Results:
% x* = 4.714361816720959   2.518588129571907
% fval = 7.695277974842115e+04
% Computation Time:
% interior point = 39.493 s
% sqp = 38.942 s
% sqp-legacy = 39.165 s

% testing a second starting point
% x0 = [4.7, 1.5];
% Results:
% x = 4.714361707405052   2.518588528774341
% fval = 7.695277927964830e+04

% testing a third starting point
x0 = [10.5, 14];    % outside of design space
% Results: INFEASIBLE (with interior-point)
% x = 7.504720167991547   1.806177725607068
% fval = 1.182316058709283e+05
% converges with sqp
% x = 4.714361707405052   2.518588528774341
% fval = 7.695277927964830e+04

Aeq = [];
beq = [];
A = [];
b = [];

% bounds of deltaV's obtained in try/catch of FullOptimization.m
% lower bounds of deltaV's
lb = [3.43714, 0.78145];
% upper bounds of deltaV's
ub = [11.48, 10.04];

% define nonlinear constraints
nonlcon = @MissionConInitialAlg;

% options
opts = optimset('MaxIter', 10000, 'MaxFunEvals', 100000, 'TolX', 1e-9,'Algorithm', 'sqp');

% call optimization algorithm 
[x,fval, exitflag, output, lambda] =...
   fmincon('MissionObjInitialAlg', x0, A, b, Aeq, beq, lb, ub, nonlcon, opts);

% PLOTTING
f1 = figure;
f2 = figure;
contour(deltaV01vector, deltaV56vector, fobj)
xlabel('DeltaV01 (km/s)'), ylabel('DeltaV56 (km/s)'), ...
   title('Intial Problem Optimizaiton')

hold on
contour(deltaV01vector, deltaV56vector, g1, [0,0],'k')             % total deltaV 
contour(deltaV01vector, deltaV56vector, g1, [-0.01 -0.01],'k--')   % feasible region

contour(deltaV01vector, deltaV56vector, g2, [0,0],'r')             % rpMoon min
contour(deltaV01vector, deltaV56vector, g2, [-0.01 -0.01],'r--')   % feasible region

contour(deltaV01vector, deltaV56vector, g3, [0,0],'g')             % rpMoon max
contour(deltaV01vector, deltaV56vector, g3, [-0.01 -0.01],'g--')   % feasible region

contour(deltaV01vector, deltaV56vector, g4, [0,0],'m')           % rpEarth 
contour(deltaV01vector, deltaV56vector, g4, [-0.1 -0.1],'m--')   % feasible region

%---NO LONGER USING THIS CONSTRAINT---
% contour(deltaV01vector, deltaV56vector, g5, [0,0],'b')             % vpEarth
% contour(deltaV01vector, deltaV56vector, g5, [-0.01 -0.01],'b--')   % feasible region
%-------------------------------------

% starting and ending points of algorithm
plot(x0(1),x0(2),'o');
plot(x(1), x(2), '*');

% label parts of the figure 
legend ('Objective function (tfTotal)', 'g1 (Total deltaV constraint)',...
   'g1 feasible region', 'g2 (rpMoon max constraint)', 'g2 feasible region',...
   'g3 (rpMoon min constraint)','g3 feasible region','g4 (rpReturn constraint)',...
   'g4 feasible reagoin', 'starting point', 'optimum from algorithm') 

hold off
figure;
surf(deltaV01vector, deltaV56vector, fobj)
xlabel('DeltaV01 (km/s)'), ylabel('DeltaV56 (km/s)'), ...
   title('Surface Plot of Objective Function')