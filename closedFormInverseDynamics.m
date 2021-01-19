%{
Attempting closed form dynamics with the Alpha arm. 
Last modified by Hannah Kolano 1/12/2021

%}

function MassMatrix = closedFormInverseDynamics(dof, thetalist, dthetalist, ddthetalist, Ftip, g)
    % Get kinematic and dynamic values
    [~, ~, ~, MlistBackward, ~, Alist, Glist] = AlphaKinematics();
    alphaArm = alphaSetup();
    
    % Joint configuration 
    Qspace = thetalist;
%     b_jacob = alphaArm.jacobe(Qspace);
    
    % Construct matrix of A_i (twists in link frames) and G_i (spatial
    % inertia matrix)
    A_mat = zeros(30, 5);
    G_mat = zeros(30, 30);
    for i = 1:5
        A_mat((i*6)-5:i*6, i) = Alist(:, i);
        G_mat((i*6)-5:i*6, (i*6)-5:i*6) = Glist(:,:,i);
    end    
    
    W_mat = zeros(30,30);
    
    for i = 2:5
        % Get variables for this link
        A_i = Alist(:, i);
        theta_i = Qspace(i);
        M_i_iminus1 = MlistBackward(:,:,i);
        T_i_iminus1 = FKinSpace(M_i_iminus1, [-A_i], [theta_i]);
        W_mat(i*6-5:i*6,(i-1)*6-5:(i-1)*6) = Adjoint(T_i_iminus1); 
    end
    
    W_mat;
    L_mat = inv(eye(30)-W_mat);
    
    MassMatrix = A_mat.'*L_mat.'*G_mat*L_mat*A_mat;
   
end