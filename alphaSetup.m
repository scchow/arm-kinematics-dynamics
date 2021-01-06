%{
Set up the kinematic and dynamic properties of the Alpha arm. 
Last modified by Hannah Kolano 1/5/2021

Current assumptions:
In air
Motors are frictionless
No added mass due to being in water
No drag
Weight of end effector not included
%}

function alphaArm = alphaSetup()

    clf;

    %% Kinematics
    theta_a = atan2(145.3, 40);
    % dhparams in order: [a alpha d theta]
    % dhparams = [20   	pi/2	46.2    pi;
    %            150.71	pi      0       -theta_a;
    %             20      -pi/2	0   	-theta_a;
    %             0   	pi/2	-180	pi/2;
    %             0       0       0   	-pi/2];


    % Set up robot with DH Parameters
    % in mm
    Link1 = Revolute('a',   20,     'alpha', pi/2,  'd',    46.2,   'offset', pi,       'qlim', [-175*pi/180, 175*pi/180]);
    Link2 = Revolute('a',   150.71, 'alpha', pi,    'd',    0,      'offset', -theta_a, 'qlim', [0, 200*pi/180]);
    Link3 = Revolute('a',   20,     'alpha', -pi/2, 'd',    0,      'offset', -theta_a, 'qlim', [0, 200*pi/180]);
    Link4 = Revolute('a',   0,      'alpha', pi/2,  'd',    -180,   'offset', pi/2,     'qlim', [-175*pi/180, 175*pi/180]);
    Link5 = Revolute('a',   0,      'alpha', 0,     'd',    0,      'offset', -pi/2,    'qlim', [0, pi/2]);

    %% Dynamics

    % masses in kg
    Link1.m = .341;
    Link2.m = .194;
    Link3.m = .429;
    Link4.m = .115;
    Link5.m = .333;

    % center of mass location wrt link frame 
    % in mm
    Link1.r = [-75, -6, -3];
    Link2.r = [5, -1, 16];
    Link3.r = [73, 0, 0];
    Link4.r = [17 -26 -2];
    Link5.r = [0 3 -98];

    % Mass Moment of inertia (kg mm^2)
    Link1.I = [99 139 115; 139 2920 3; 115 3 2934];
    Link2.I = [189 5 54; 5 213 3; 54 3 67];
    Link3.I = [87 -76 -10; -76 3190 0; -10 0 3213];
    Link4.I = [120 -61 -1; -61 62 0; -1 0 156];
    Link5.I = [3709 2 -4; 2 3734 0; -4 0 79];
    

    %% make serial link object
    alphaArm = Link1 + Link2 + Link3 + Link4 + Link5;
    alphaArm.name = 'Alpha';
    
end
