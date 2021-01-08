
function [alpha_joint_frames, alpha_link_frames, Mlist, Glist, Slist] = urdfConstructionAlpha()
    clf; 
    alphaArm = alphaSetup();
    Base = alphaArm.links(1);
    Link1 = alphaArm.links(2);
    Link2 = alphaArm.links(3);
    Link3 = alphaArm.links(4);
    Link4 = alphaArm.links(5);
    in_meters = 1; % if == 1, outputs values in m instead of mm
    
    %% ---------- JOINT FRAMES ----------
    displacements = cell(5, 1);
    rotations = cell(5, 1);
    Joint_to_joint_transforms = cell(5, 1); %  order:  T_0e, T_ed, T_dc, T_cb, T_ba 
    
    % Joint E frame wrt Base
    displacements{1} = [0 0 0];
    rotations{1} = [0 0 pi];
    % Joint D wrt Joint E
    displacements{2} = [20 0 46.2];
    rotations{2} = [1.57075 1.302 0];
    % Joint C wrt Joint D
    displacements{3} = [150.71 0 0];
    rotations{3} = [pi 0 1.302];
    % Joint B wrt Joint C
    displacements{4} = [20 0 0];
    rotations{4} = [-1.57075 -1.57075 0]; % was -1.57075 -0.5 0
    % Joint A wrt Joint B
    displacements{5} = [0 0 -180]; % was 0 0 -190
    rotations{5} = [0 1.5707 1.5707]; % was 0 0 1.5707
    
    % Transform to meters if necessary
    if in_meters == 1
        for i = 1:5
            displacements{i} = displacements{i}/1000.0;
        end
    end
    
    % Get joint transforms in SE3 form
    for i = 1:5
        % transform RPY into rotation matrix
        RotMat = rpy2r(rotations{i});
        % Form SE3 object from rotation matrix and displacement
        Joint_to_joint_transforms{i} = SE3(RotMat, displacements{i});
        % order:  T_0e, T_ed, T_dc, T_cb, T_ba 
    end
    
    % Get joint coordinate frames from origin (at home position)
    Tnaught = SE3();
    T_0e = Joint_to_joint_transforms{1};
    T_0d = SE3(T_0e.T*Joint_to_joint_transforms{2}.T);
    T_0c = SE3(T_0d.T*Joint_to_joint_transforms{3}.T);
    T_0b = SE3(T_0c.T*Joint_to_joint_transforms{4}.T);
    T_0a = SE3(T_0b.T*Joint_to_joint_transforms{5}.T);

    alpha_joint_frames = [Tnaught, T_0e, T_0d, T_0c, T_0b, T_0a];
    
    %% ---------- TWISTS ----------
    [TW, T0] = alphaArm.twists();
    Slist = [];
    for i = 1:length(TW)
        Slist = [Slist TW(i).S];
    end
    
    %% ---------- LINK FRAMES ----------
    R0 = rpy2r([0 0 0]);
    T_base_from_jointE = SE3(R0, Base.r);
    T_0_base = SE3(T_0e.T*T_base_from_jointE.T);
        
    T_link1_from_jointE = SE3(R0, Link1.r);
    T_0_L1 = SE3(T_0e.T*T_link1_from_jointE.T);
    
    T_link2_from_jointD = SE3(R0, Link2.r);
    T_0_L2 = SE3(T_0d.T*T_link2_from_jointD.T);
    
    T_link3_from_jointC = SE3(R0, Link3.r);
    T_0_L3 = SE3(T_0c.T*T_link3_from_jointC.T);
    
    T_link4_from_jointB = SE3(R0, Link4.r);
    T_0_L4 = SE3(T_0b.T*T_link4_from_jointB.T);
    
    T_ee_from_jointA = SE3(R0, [0 0 -82]); % jaw1 x=-10, jaw2 x=-10; both y = -45
    T_0_ee = SE3(T_0_L4.T*T_ee_from_jointA.T);
    
    alpha_link_frames = [Tnaught, T_0_L1, T_0_L2, T_0_L3, T_0_L4, T_0_ee];
    
    %% ---------- Relative link frames (M) ----------
    num_links = length(alpha_link_frames);
    inv_a_link_frames = [];
    M_backward = [];
    M_forward = [];
    
    %T_L1_0 = T_0_L1.inv;
    for i = 1:num_links
        inv_a_link_frames = [inv_a_link_frames alpha_link_frames(i).inv];
    end
    
    for j = 2:num_links
        M_j_jminus1 = SE3(inv_a_link_frames(j).T*alpha_link_frames(j-1).T);
        M_backward = [M_backward M_j_jminus1];
        
        M_jminus1_j = SE3(inv_a_link_frames(j-1).T*alpha_link_frames(j).T);
        M_forward = [M_forward M_jminus1_j];
    end

    Mlist = cat(3, M_forward(1).T, M_forward(2).T, M_forward(3).T, M_forward(4).T, M_forward(5).T);
    
    %% ---------- Spatial Inertia Matrices Gi ----------
    Gi_matrices = {};
    
    for i = 1:4
        % Ignore base
        link = alphaArm.links(i+1);
        G_i = [link.I(1,:) 0 0 0; link.I(2,:) 0 0 0; link.I(3,:) 0 0 0; ...
            0 0 0 link.m 0 0; 0 0 0 0 link.m 0; 0 0 0 0 0 link.m;];
        Gi_matrices{i} = G_i;
    end
    
    Glist = cat(3, Gi_matrices{1}, Gi_matrices{2}, Gi_matrices{3}, Gi_matrices{4})

    %% ---------- VIEWING ----------
%     hold on
%     for i = 1:6
%         frame = alpha_link_frames(i);
%         trplot(frame.T, 'length', 100, 'thick', 1, 'rviz', 'frame', '0')
%     end
%         trplot(T_0a.T, 'color', 'k', 'frame', 'Joint A');
%     trplot(T_0a.T, 'length', 100, 'thick', 1, 'rviz', 'frame', '0')%'color', 'm', 'frame', 'Link 0')
%     xlabel('X')
%     ylabel('Y')
%     grid on
end

