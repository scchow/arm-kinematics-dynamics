clf

addpath('C:\Users\hkolano\Documents\GitHub\ModernRobotics\packages\MATLAB\mr')

%% Import arm setup
bravoArm = bravoSetup();
[b_joint_frames, Slist] = bravoKinematics();

%% Home position
Qspace0 = zeros(1, 7);
Qspace1 = pi/180*[70 60 50 40 30 20 10]
M_home = bravoArm.fkine(Qspace0);
T_end = FKinSpace(M_home.T, Slist, Qspace1.')

% Qspace1 = pi/180*[0 10 0 0 0 0 0];
% Qspace2 = pi/180*[20, 0, 20, 45, 10, 30, 10];

bravoArm.teach(Qspace1, 'jointdiam', 1, 'jaxes');
hold on
trplot(T_end, 'length', 0.2, 'thick', 1, 'rviz')

% s_jacob = bravoArm.jacob0(Qspace1)
% b_jacob = bravoArm.jacobe(Qspace1)
