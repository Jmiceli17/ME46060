% ME46060 Final Project
% Paul DeTrempe & Joe Miceli


%-----Initial Full Optimization-----
clear % clear all variables
% Starting Point #1
% values from preliminary test of MoonMission
% output is very sensitive to changes in initaial deltas and lambdas
% deltaV01 = 3.5;     % maneuver to leave Earth (km/s)
% delta01  = 0.30;    % thrust angle (degrees)
% lambda2  = 76.1;    % arrival angle at Moon SOI (degrees)
% deltaV56 = 1.5;     % maneuver to leave Moon (km/s)
% delta56  = 0.5;     % txhrust angle at moon departure (degrees)
% lambda8  = 40;      % departure angle at Moon SOI (degrees)
% RESULTS FROM THIS STARTING VALUE (interior pt):
% fval = 7.707898526777898e+04
% x* = [4.716245459038539  -0.006284346685641  10.023655338692528   2.513746310143193   0.001913946560449 -15.281804299263568]
% (sqp): 6.801 sec
% fval = 7.695277902641839e+04
% x* = [4.714353895498174  -0.000337865517362   5.938219958903390   2.518611293526064  -0.004798832517102 -15.259304634846632]

% Starting Point #2
% deltaV01 = 5.0;   % maneuver to leave Earth (km/s)
% delta01  = 19;    % thrust angle (degrees)
% lambda2  = 45;    % arrival angle at Moon SOI (degrees)
% deltaV56 = 2.0;   % maneuver to leave Moon (km/s)
% delta56  = 19;    % thrust angle at moon departure (degrees)
% lambda8  = 45;    % departure angle at Moon SOI (degrees)
% RESULTS FROM THIS STARTING VALUE (interior pt):
% fval = 7.695277966166868e+04
% x* = [4.714354010056908   0.001534958815671   5.938219853521296   2.518610888622807   0.015304289664836 -15.259306426900674]
%(sqp)
% converges to infeasible point

% Starting Point #3
deltaV01 = 0.5;   % maneuver to leave Earth (km/s), below lb
delta01  = 35;    % thrust angle (degrees)
lambda2  = 100;    % arrival angle at Moon SOI (degrees)
deltaV56 = 15.0;   % maneuver to leave Moon (km/s)
delta56  = 0.0;    % thrust angle at moon departure (degrees)
lambda8  = 45;    % departure angle at Moon SOI (degrees)
% RESULTS FROM THIS STARTING VALUE (interior pt):
% fval =  7.695277910521018e+04
% x* = [4.714368469743381   0.002389241081763   5.938182633516827   2.518568733904532  -0.000000000000000 -15.259500916242757]
% (sqp): 5.281 sec
% fval = 4.670162717182647e+05
% x* = [3.273640000002223  20.000000000000000  88.505363736426048   8.232557681402692                   0  -5.798164336235518]

%---RELAXED CONSTRAINT ANALYSIS (to be deleted)---
% starting value obtained from relaxed constraints and f = 0 method
% explained in MissionCon.m
% x0 = [3.31765298468959	5.33678141940735	20.0590949180213...
% 0.782030768298087	17.5871012055154	-31.0802636734197];
% new starting value obtained from previous starting value
% x0 = [3.32259893237480	5.47580282804868	19.8199385602374...
%     0.781475926482696	19.9995615091918	-31.3673656745829];
%---------------------------------


% fmincon input arguments
% starting point
x0 = [deltaV01, delta01, lambda2, deltaV56, delta56, lambda8];
% linear inequality constraints
A = [];
b = [];
% linear equality constraints
Aeq = []; 
beq = [];
% upper bounds
% deltaV01, delta01, lambda2, deltaV56, delta56, lambda8
ub = [11.48466, 20, 90.0, 10.04567, 20.0, 90.0];
% define nonlinear constraints
nonlcon = @MissionCon;
% algorithm options for fmincon
% tolerance obtained from sensitivity analysis
% default alg = 'interior point'
% also try 'sqp' and 'sqp-legacy' and 'active set'
opts = optimoptions('fmincon','Algorithm', 'sqp', 'MaxIter', 10000, 'MaxFunEvals',...
    100000, 'ConstraintTolerance',1e-9, 'TolFun', 1e-9, 'TolX', 1e-9);
% Starting values of lower bounds of deltaV01 from preliminary calculations
deltaV01lb = 2.22004;   % km/s
deltaV56lb = .78145; % km/s


exitflag = 0;
while exitflag ~= 1 && exitflag ~= 2 && exitflag ~= 3 && exitflag ~= 4 && exitflag ~= 5
% exitflag 1 = 1st order optimality measure less than options.constraintTol
% exitflag 2 = change in x was less than options.stepTol
% exitflag 3 = change in obj function less than options.FunctionTol and 
% max constraint violation was less than
% options.constraintTol (active set alg only)
% note that loop will not exit if convergence occurs to infeasible point

% check if lower bounds produce real values in MoonMission
    try
        try
            % lower bounds
            % deltaV01, delta01, lambda2, deltaV56, delta56, lambda8
            lb = [deltaV01lb, -20.0, 0.0, deltaV56lb, -20.0, -90.0];
    		deltaV01 = lb(1);
    		delta01 = lb(2);
    		lambda2 = lb(3);
    		deltaV56 = lb(4);
    		delta56 = lb(5);
    		lambda8 = lb(6);
     		% check if MoonMission produces real values
     		[tfTotal,deltaVtotal, rpMoon, Vpearth, rpReturn] =...
         	MoonMission(deltaV01,delta01,lambda2,deltaV56,delta56,lambda8);
            
			% calling the algorithm
            % (below 2 lines to be delted)
            % trying to find feasible starting point with f = 0
            % f = @(x) 0;
            [x,fval, exitflag, output, lambda] =...
                fmincon('MissionObj' ,x0, A, b, Aeq, beq, lb, ub, nonlcon, opts);
    % (below 3 lines to be deleted)
    %         if exitflag == 1
    %             break
    %         end
        % if unreal values produced, increment deltaV01lb
        catch
            deltaV01lb = deltaV01lb + .0001; % increment deltaV01lb
    % (below 3 lines to be delted)
    % 		lb = [deltaV01lb, -30.0, -90.0, 1.4, -30.0, -90.0];
    % 		err_count = err_count + 1;
    % 	count = count + 1;
        end
    catch
        deltaV56lb = deltaV56lb + .0001;	% increment deltaV56lb
    end
end
x 
fval