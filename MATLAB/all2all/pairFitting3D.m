% pairFitting3D  register a pair of particles
%
% SYNOPSIS:
%   param = pairFitting3D(ptc1, ptc2, sig1, sig2, scale, initAng, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST)
%
% INPUT
%   ptc1  
%       point cloud of particle 1
%   ptc2  
%       point cloud of particle 2
%   sig1  
%       uncertainties for points in ptc1
%   sig2  
%       uncertainties for points in ptc2
%   scale
%       scale parameter for GMM registration
%   initAng 
%       parameter setting the sampling of initial transformations. It can be passed as either an integer giving the number of initial
%       angles using euler angles (non-uniformly sampled) or it can be passed as
%       a character vector of the name of a file with a custom grid. These files
%       are stored in '/uniform_sampling_grids'.

%   USE_GPU_GAUSSTRANSFORM 
%       1/0 for using GPU/CPU
%   USE_GPU_EXPDIST 
%       1/0 for using GPU/CPU
%
% OUTPUT
%   param       
%       transformations parameter giving the highest cost
%   maxCost
%       Cost function corresponding to the registration
%
% (C) Copyright 2018-2020      
% Faculty of Applied Sciences
% Delft University of Technology
%
% Hamidreza Heydarian, November 2020.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%    http://www.apache.org/licenses/LICENSE-2.0


function [param, maxCost] = pairFitting3D(ptc1, ptc2, sig1, sig2, scale, initAng, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST)
nIteration = 1; % unused parameter


q_init=[];
if ischar(initAng)      % sampling from file
    % load uniform SO(3) grid
    [x1, x2, x3, x4] = textread(['MATLAB/all2all/uniform_SO3_sampling_grids/',initAng], '%f %f %f %f');
    NN = length(x1);

    %build initial quaternion vector
    for i=1:NN
        q_init(i,:) = [x1(i), x2(i), x3(i), x4(i)];
    end
    
    % repeat quaternion vector to allow for multiple scale fitting
    q_init = repmat(q_init,length(scale),1);
    d=[];   % vector holding the scale
    for i=1:length(scale)
        d = [d;repmat(scale(i),length(x1),1)];
    end
else            % samp[ling using Euler angles
    % multiple start
    if initAng==1
        ang1 = [0 pi/2 pi 3*pi/2];
        ang2 = [0];
        ang3 = [0];
    elseif initAng==2
        ang1 = [0 pi/2 pi 3*pi/2];
        ang2 = [0 pi/2 pi 3*pi/2];
        ang3 = [0 pi/2 pi 3*pi/2];
    else
        ang1 = linspace(-pi,pi,initAng);
        ang2 = linspace(-pi,pi,initAng);
        ang3 = linspace(-pi,pi,initAng);
    end
    
    [a, b, c, d] = ndgrid(ang1,ang2,ang3,scale); % use all combinations of initial angles and scales as in initialization parameters for GMM registration
    
    for i=1:numel(a)
        q_init(i,:) = ang2q(a(i),b(i),c(i));
    end
end


for init_iter=1:size(q_init,1)

    qtmp = q_init(init_iter,:);
   
    % initialize gmmreg
    f_config = initialize_config(double(ptc1), double(ptc2), 'rigid3d', nIteration);
    f_config.init_param = [qtmp(2) qtmp(3) qtmp(4) qtmp(1) 0 0 0];
    f_config.scale = d(init_iter);     
%     f_config.scale = scale;
    
    % perform registration
    tmpParam{1,init_iter} = gmmreg_L23D(f_config,USE_GPU_GAUSSTRANSFORM); 
    
    % calculate cost again and store
    M = double(ptc1);
    S = double(ptc2);
    
    M_points_transformed = transform_pointset(M, 'rigid3d', tmpParam{1,init_iter});
    RM = quaternion2rotation(tmpParam{1,init_iter}(1:4));
    if USE_GPU_EXPDIST
%         cost(init_iter) = mex_expdist(S, M_points_transformed, correct_uncer(sig2), sig1, RM);
        cost(init_iter) = mex_expdist(S,M_points_transformed,sig2,sig1,RM);
    else
        cost(init_iter) = mex_expdist_cpu(S, M_points_transformed, sig2, sig1, RM);
    end

end

% find maximal costs and store results
[maxCost, idx] = max(cost);
param = tmpParam{1,idx};

end