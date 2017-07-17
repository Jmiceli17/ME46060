% ME46060 Optimization Final Project
% Paul DeTrempe & Joe Miceli

function [tfTotal,deltaVtotal, rpMoon, Vpearth, rpReturn] =...
    MoonMission(deltaV01,delta01,lambda2,deltaV56,delta56,lambda8)

    %outputs:   tfTotal : total travel time
    %           deltaVtotal : total mission deltaV
    %           rpMoon : Periapse radius at moon
    %           Vpearth : reentry velocity

    %----- load Mission Parameters
    MissionParams;
    
    %--------------------------------------------------------------------------
    %-----print design variables to console
%     deltaV01 = 3.5;   % maneuver to leave Earth (km/s)
%     delta01  = .30;   % thrust angle (degrees)
%     lambda2 = 76.1;  % arrival angle at Moon SOI (degrees)
%     deltaV56 = 1.5;  % maneuver to leave Moon (km/s)
%     delta56  = .5;  % thrust angle at moon departure (degrees)
%     lambda8 = 40;  % departure angle at Moon SOI (degrees)


    %-------------------------------------------------------------------------
    %-----Calculate tf1 based on given info

    % Distance in Earth frame at arrival at Moon SOI
    r2 = sqrt(aMoon^2+Rsoi^2-2*aMoon*Rsoi*cosd(lambda2));

    % Departure Velocity magnitude
    V1 = sqrt(vcEarth^2+deltaV01^2+2*vcEarth*deltaV01*cosd(delta01));

    % Departure flight path angle (degrees)
    gamma1 = acosd((deltaV01^2-vcEarth^2-V1^2)/(-2*V1*vcEarth));

    % Angular momentum of transfer trajectory
    H12 = rcEarth*vcEarth*cosd(gamma1);

    % Orbital Energy at departure
    Epsilon12 = .5*V1^2-muEarth/rcEarth;

    % Semi-major axis of transfer orbit
    a12 = -muEarth/(2*Epsilon12);

    % Parameter of transfer orbit
    p12 = (H12^2)/muEarth;

    % Eccentricity of transfer orbit
    e12 = sqrt(1-p12/a12);

    % Apoapse radius of earth departure orbit
    rapo12 = a12*(1+e12);

    % adjust for if on hyperbolic or elliptical trajectory to moon
    if e12<1
        % True Anomaly at translunar injection
        theta1 = acosd((p12-rcEarth)/(e12*rcEarth));

        % Eccentric anomaly at translunar injection
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % currently unsure about input args, just put over 1 for now
        E1 = 2*atan2d(sqrt((1-e12)/(1+e12))*tand(theta1/2),1);

        % True Anomaly at lunar SOI arrival
        theta2 = acosd((p12-r2)/(e12*r2));

        % Eccentric anomaly at Lunar arrival
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % currently unsure about input args, just put over 1 for now
        E2 = 2*atan2d(sqrt((1-e12)/(1+e12))*tand(theta2/2),1);

        % Flight time from Earth to Moon SOI (assumes start at true anomaly = mean
        % anomaly = 0
        tf12 = sqrt(a12^3/muEarth)*(degtorad(E2)-degtorad(E1)-e12*(sind(E2)-sind(E1)));
    else
        % True Anomaly at TLI
        theta1 = acosd(1/e12*((a12*(1-e12^2))/rcEarth-1));

        % True Anomaly at lunar SOI arrival
        theta2 = acosd(1/e12*((a12*(1-e12^2))/r2-1));

        % Hyperbolic anomaly in geocentric reference frame at TLI
        F1 = radtodeg(2*atanh(sqrt((e12-1)/(e12+1))*tand(theta1/2)));

        % Hyperbolic anomaly in geocentric reference frame at Moon SOI
        F2 = radtodeg(2*atanh(sqrt((e12-1)/(e12+1))*tand(theta2/2)));

        % Time since periapsis passage at TLI
        t1 = sqrt(-a12^3/muEarth)*(e12*(sinh(degtorad(F1)))-degtorad(F1));

        % Time since periapsis passage at Moon SOI
        t2 = sqrt(-a12^3/muEarth)*(e12*(sinh(degtorad(F2)))-degtorad(F2));

        % Flight time from TLI to Moon SOI
        tf12 = t2-t1;
    end
    %--------------------------------------------------------------------------
    %---------Calculate tf2 (from Rsoi to first maneuver)

    % Speed in Earth reference frame
    V2 = sqrt(2*(Epsilon12+muEarth/r2));

    % Flight path angle in Earth reference frame @ r2
    gamma2 = acosd(H12/(r2*V2));

    % Angle between Moon location vector and spacecraft location vector in
    % Earth frame of reference
    beta2 = Rsoi/r2 *sind(lambda2);

    % Velocity magnitude in moon frame of reference
    V3 = sqrt(V2^2 + vMoon^2-2*V2*vMoon*cosd(gamma2-beta2));

    % Velocity angle relative to spacecraft/moon location vector (Moon frame of
    % reference)
    epsilon3 = asind((vMoon*cosd(lambda2)-V2*cosd(lambda2+beta2-gamma2))/V3);

    % Angular Momentum in Moon reference frame
    H34 = Rsoi*V3*sind(epsilon3);

    % Orbital Energy in Moon reference frame
    Energy34 = .5*V3^2-muMoon/Rsoi;

    % Semi-major axis of entry hyperbola
    a34 = -1/((V3^2)/muMoon-2/Rsoi);

    % Orbital Parameter in Moon reference frame
    p34 = H34^2/muMoon;

    % Eccentricity in Moon reference frame
    e34 = sqrt(1+2*H34^2*Energy34/muMoon^2);

    % True anomaly in Moon reference frame at Rsoi
    theta3 = acosd((p34-Rsoi)/(e34*Rsoi));

    % Periapsis radius at moon !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Should be same
    % as rcMoon
    rpMoon = p34/(1+e34);

    % Velocity at periapsis
    VpMoon = sqrt(2*(Energy34+muMoon/rpMoon));

    % DeltaV required at lunar periapsis
    deltaV45 = VpMoon-vcMoon;

    % Hyperbolic anomaly in lunar reference frame
    F3 = radtodeg(2*atanh(sqrt((e34-1)/(e34+1))*tand(theta3/2)));

    % Flight time from SOI entry until periapsis
    tf34 = sqrt(-a34^3/muMoon)*(e34*sinh(degtorad(F3))-degtorad(F3));

    %-------------------------------------------------------------------------
    %---------Calculate tf34 based at deltaV2, time from moon orbit to SOI

    % Selenocentric Departure Velocity magnitude
    V6 = sqrt(vcMoon^2+deltaV56^2+2*vcMoon*deltaV56*cosd(delta56));

    % Selenocentric Departure flight path angle (degrees)
    gamma6 = acosd((deltaV56^2-vcMoon^2-V6^2)/(-2*V6*vcMoon));

    % Angular momentum of selenocentric departure orbit
    H67 = rcMoon*vcMoon*cosd(gamma6);

    % Orbital Energy of selenocentric return orbit
    Epsilon67 = .5*V6^2-muMoon/rcMoon;

    % Semi-major axis of selenocentric return orbit
    a67 = -muMoon/(2*Epsilon67);

    % Parameter of selenocentric return orbit
    p67 = (H67^2)/muMoon;

    % Eccentricity of selenocentric transfer orbit
    e67 = sqrt(1+2*H67^2*Epsilon67/muMoon^2);

    % Apoapse radius of lunar departure orbit
    rapo67 = a67*(1-e67);

    % Different calculations if elliptic or hyperbolic SOI escape
    if e67<1
        % True Anomaly at lunar departure after maneuver
        theta6 = acosd((p67-rcMoon)/(e67*rcMoon));

        % Eccentric anomaly at Lunar departure after maneuver
        E6 = 2*atan2d(sqrt((1-e67)/(1+e67))*tand(theta6/2),1);

        % Selenocentric True Anomaly at lunar SOI arrival
        theta7 = acosd((p67-Rsoi)/(e67*Rsoi));

        % Selenocentric Eccentric anomaly at Lunar SOI arrival
        E7 = 2*atan2d(sqrt((1-e67)/(1+e67))*tand(theta7/2),1);

        % Flight time from perilune to Moon SOI (assumes start at true anomaly = mean
        % anomaly = 0
        tf67 = sqrt(a67^3/muMoon)*(degtorad(E7)-degtorad(E6)-e67*(sind(E7)-sind(E6)));
    else
        % True Anomaly at Lunar escape maneuver
        theta6 = acosd((p67-rcMoon)/(e67*rcMoon));

        % True Anomaly at lunar SOI arrival
        theta7 = acosd((p67-Rsoi)/(e67*Rsoi));

        % Hyperbolic anomaly in selenocentric reference frame at lunar escape
        % maneuver
        F6 = 2*radtodeg(atanh(sqrt((e67-1)/(e67+1))*tand(theta6/2)));

        % Hyperbolic anomaly in selenocentric reference frame at Moon SOI
        F7 = 2*radtodeg(atanh(sqrt((e67-1)/(e67+1))*tand(theta7/2)));

        % Time since periapsis passage at lunar escape maneuver
        t6 = sqrt(-a67^3/muMoon)*(e67*(sinh(degtorad(F6)))-degtorad(F6));

        % Time since periapsis passage at Moon SOI
        t7 = sqrt(-a67^3/muMoon)*(e67*(sinh(degtorad(F7)))-degtorad(F7));

        % Flight time from moon escape maneuver to Moon SOI
        tf67 = t7-t6;

    end
    %-------------------------------------------------------------------------
    % Find tf4, time back to Earth from Moon SOI

    % --first change properties from selenocentric to geocentric

    % Distance in Earth frame at arrival at Moon SOI
    r8 = sqrt(aMoon^2+Rsoi^2-2*aMoon*Rsoi*cosd(lambda8));

    % Angle between Moon location vector and spacecraft location vector in
    % Earth frame of reference
    beta8 = Rsoi/r8 *sind(lambda8);

    % selenocentric velocity at SOI arrival
    V7 = sqrt(2*(Epsilon67+muMoon/Rsoi^2));

    % selenocentric flight path angle at SOI arrival
    gamma7 = acosd(H67/(Rsoi*V7));

    %!!!!!!!!!! See Equation 17.12 in book, pretty sure this is right
    % geocentric velocity at SOI arrival
    % this is ok becaause cos(gamma_selenocentric) = sin(epsilon) by trig
    V8 = sqrt(V7^2+vMoon^2-2*V7*vMoon*cosd(gamma7-beta8));                  %originally V8 = sqrt(V7^2+vMoon^2-2*V7*vMoon*cosd(gamma7-lambda8));   

    % flight path angle in geocentric frame from equation 17.13
    gamma8 = lambda8 + beta8 - acosd((vMoon*cosd(lambda8)-V7*cosd(gamma7))/V8);

    % geocentric angular momentum
    H89 = r8*V8*cosd(gamma8);

    % geocentric orbital energy
    Epsilon89 = (V8^2)/2-muEarth/r8;

    % geocentric orbital parameter
    p89 = (H89^2)/muEarth;

    % geocentric semimajor axis
    a89 = -muEarth/(2*Epsilon89);

    % geocentric eccentricity
    e89 = sqrt(1-p89/a89);%%%
    
    % periapsis radius on return
    rpReturn = a89*(1-e89);

    % reentry velocity
    % if within radius of Earth's atmosphere...
    if rpReturn < (REarth + 100)
        Vpearth = sqrt(muEarth*(2/(REarth + 100)-1/a89)); % km/s
    % if outside Earth's atmosphere...
    else
        Vpearth = sqrt(muEarth*(2/rpReturn-1/a89));   % km/s
    end
    
    if e89<1
        % geocentric true anomaly at moon SOI
        theta8 = acosd((p89-r8)/(e89*r8));

        % Selenocentric Eccentric anomaly at Lunar SOI arrival
        E8 = 2*atan2d(sqrt((1-e89)/(1+e89))*tand(theta8/2),1);

        % geocentric eccentric anomaly at Earth atmosphere arrival
        E9 = 0; % By definition of start of true anomaly and eccentric anomaly, both are 0 at closest approach

        % Time of flight from MoonSOI to Earth atmosphere
        tf89 = sqrt(a89/muEarth)*(degtorad(E8)-degtorad(E9)-e89*(sind(E8)-sind(E9)));
    
    else
        % True anomaly in Earth reference frame at Rsoi
        theta8 = acosd((p89-r8)/(e89*r8));

        % Hyperbolic anomaly in Earth reference frame at SOI
        F8 = radtodeg(2*atanh(sqrt((e89-1)/(e89+1)*tand(theta8/2))));

        % Flight time from SOI exit until periapsis
        tf89 = sqrt(-a89^3/muMoon)*(e89*sinh(degtorad(F8))-degtorad(F8));
    end
%----------------------create outputs
tfTotal = tf12+tf34+tf67+tf89;
deltaVtotal = deltaV01 + deltaV45 + deltaV56;

end