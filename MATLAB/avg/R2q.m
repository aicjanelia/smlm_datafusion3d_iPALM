% R2q   Rotation matrix to quaternion
%
% SYNOPSIS:
%   [q]=R2q(R)
%
% INPUT
%   R 
%       3x3 rotation matrix
%
% OUTPUT
%   q
%       quaternion representation
%
% NOTES
%
% Author: Avishek Chatterjee, Venu Madhav Govindu
% 

function [qout]=R2q(R)

    q=[(trace(R)-1), R(3,2)-R(2,3),R(1,3)-R(3,1),R(2,1)-R(1,2)]/2;
    q(1,1)=sqrt((q(1,1)+1)/2);
    q(1,2:4)=q(1,2:4)/2/q(1,1);
    
    % gmmreg convention 
%     qout(1:3) = q(2:end);
%     qout(4) = q(1);
    qout = q;
    
end