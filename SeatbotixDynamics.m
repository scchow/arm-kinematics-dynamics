%{
Set up the dynamics of the Seabotix vehicle
Last modified by Hannah Kolano 3/30/2021
%}

syms u v w p q r
syms udot vdot wdot pdot qdot rdot
syms x y z phi theta psi
syms u0 u1 u2 u3 u4 u5
V = [u v w p q r].';  % V
Vdot = [udot vdot wdot pdot qdot rdot].'; % Vdot
eta = [x y z phi theta psi].'; % wrt earth
thrustforces = [u0 u1 u2 u3 u4 u5].';


%% ------------              CONSTANTS                ---------------------
% ------------------------------------------------------------------------

% ----- M_RB Mass of the Rigid Body -----
% Assume body fixed frame at estimated COM (0.06m above geometric center)
% MMoI matrix assumes vehicle density = water density
m = 22.2; % original vehicle mass
Ixx = 0.75; Iyy = 1.4; Izz = 1.6; % from SW model
M_RB = diag([m m m Ixx Iyy Izz]);

% ----- M_A Added Mass -----
% Scaled values from REXROV paper (see tab of google sheet)
M_A = [ 8.1     -0.07   -1.07   0.09    -1.71   -0.08;
       -0.07    12.69   0.53    4.25    -0.06   0.65;
       -1.07    0.53    38.02   0.06    -4.01   0.11;
       0.09     4.25    0.06    5.56    -0.10   0.22;
       -1.71    -0.06   -4.01   -0.10   8.75    -0.01;
       -0.08    0.65    0.11    0.22    -0.01   2.33];
% Diagonals of matrix X_ud, Y_vd, Z_wd...
am = diag(M_A);

% ----- TCM Thruster Control Matrix -----
% Each thruster is a column
TCM = [0        0       0.7071  0.7071  -0.7071 -0.7071;
       -0.5     0.5     -0.7071 0.7071  -0.7071 0.7071;
       -0.866   -0.866  0       0       0       0;
       0.0011   -0.0011 -0.0495 0.0495  -0.0495 0.0495;
       0        0       0.0495  0.0495  -0.0495 -0.0495;
       0        0       -.2506  0.2506  0.2506  -0.2506];
   
% ----- Constants for changing terms -----
% DAMPING
% Nonlinear damping from drag, linear damping scaled from REXROV
lin_damp = [3.44 4.61 52.92 4.55 8.02 2.71];
nonlin_damp = [34.40 65.86 132.29 11.37 20.04 13.54];

% RESTORING FORCES
% Assume distance between R_B and R_G is 0.05m
z_b = 0.05;
B = m*9.81; % Buoyancy force (assume neutrally buoyant)


%% ------------               Changing Terms                  --------------
%-------------------------------------------------------------------------

% ----- C_RB Coriolis Matrix for the Rigid Body ----- 
% Fossen 1994, eqns 2.99 and 2.102
C_RB = [0       0       0       0       m*w     -m*v;
        0       0       0       -m*w    0       m*u;
        0       0       0       m*v     -m*u    0;
        0       m*w     -m*v    0       Izz*r   -Iyy*q;
        -m*w    0       m*u     -Izz*r  0       Ixx*p;
        m*v     -m*u    0       Iyy*q   -Ixx*p  0];
    
% ----- C_A Coriolis Matrix for the Added Mass ----- 
% Antonelli 2006, p27
C_A = [0           0           0           0           am(3)*w     -am(2)*v;
        0           0           0           -am(3)*w    0           am(1)*u;
        0           0           0           am(2)*v     -am(1)*u    0;
        0           am(3)*w     -am(2)*v    0           am(6)*r     -am(5)*q;
        -am(3)*w    0           am(1)*u     -am(6)*r    0           am(4)*p;
        am(2)*v     -am(1)*u    0           am(5)*q     -am(4)*p    0];

% ----- D Damping -----
% ~ Three degrees of estimation ~
damp_diags = lin_damp+nonlin_damp.*V.^2;
D = diag(damp_diags);

% ----- G Restoring Forces -----
[0; 0; 0; -z_b*B*cos(theta)*sin(phi); -z_b*B*sin(theta); 0];
   
%% ----- Equations of motion -----
% First: M*vdot + C*v = Thrusters
LHS = M_RB*Vdot + C_RB*V;
RHS = TCM*thrustforces;
eom = RHS == LHS;

%% Iterate Dynamics
% Initial conditions
curr_V = [0 0 0 0 0 0].';
curr_Vdot = [0 0 0 0 0 0].';
curr_u = [1 1 0 0 0 0].';
curr_eta = [0 0 0 0 0 0].';

dt = 0.05;

function [new_V, new_Vdot, new_eta] = step_dynamics_forward(curr_V, curr_eta, curr_u)
numeric_eom = subs(eom, [V, eta, thrustforces], [curr_V, curr_eta, curr_u])
new_acc = solve(numeric_eom, Vdot) % TODO: replace with inverse matrix

dqdt = curr_V;
dqdot_dt = new_acc;

end


   
