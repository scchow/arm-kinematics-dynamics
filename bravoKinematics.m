function [bravo_joint_frames, Slist] = bravoKinematics()
%BRAVOKINEMATICS Summary of this function goes here
%   Detailed explanation goes here

    bravoArm = bravoSetup();
    
%% ---------- TWISTS ----------
    % Twists calculated by hand by Hannah 01/2021, arm straight up
    % Format: [w, v]
    Slist = [[0; 0; 1;  0;      0;      0], ...
        [0; -1;   0;    .1074;  0;      .046], ...
        [0; -1;   0;    .401;   0;      .046], ...
        [0;  0;  -1;    0;     -.0052;  0], ...
        [0;  1;   0;   -.561;   0;     -.046], ...
        [0;  0;  -1;    0;     -.0052;  0], ...
        [0;  1;   0;   -.7845;  0;     -.0052]];

%% ---------- Homogeneous Transforms (joints) ----------
    QspaceStraight =[0 0 0 0 0 0 0];
    [~, all] = bravoArm.fkine(QspaceStraight);
    
    Tnaught = SE3();
    T_0g = SE3(all(1));
    T_0f = SE3(all(2));
    T_0e = SE3(all(3));
    T_0d = SE3(all(4));
    T_0c = SE3(all(5));
    T_0b = SE3(all(6));
    T_0a = SE3(all(7));
    
    bravo_joint_frames = [Tnaught, T_0g, T_0f, T_0e, T_0d, T_0c, T_0b, T_0a];
end

