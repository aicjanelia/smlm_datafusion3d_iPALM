% MeanSE3Graph   Lie-algebraic averaging of the relative matrix RM
%
% SYNOPSIS:
%   [M, Iteration]=MeanSE3Graph(RM,I,Minit,Weight)
%
% INPUT
%   RM 
%       'm' number of 4 X 4 Relative Motion Matrices (M_ij) stacked as a 
%       4 X 4 X m Matrix
%   I  
%       Index matrix (ij) of size (2 X m) such that RM(:,:,p) is
%       the relative motion from M(:,:,I(1,p)) to M(:,:,I(2,p))
%   Weight
%       Weight or confidence of different relative motions (1 X m)
%
% OUTPUT
%   M  
%       'n' number of 4 X 4 Absolute Motion matrices stacked as
%                        a  4 X 4 X n Matrix 
%
% NOTES
%   This implementation is based on V. M. Govindu's Lie Algebraic Motion
%   Averaging on SE3 [15, 16]. Feeding of not connected graph is not allowed.
%
% Author:     AVISHEK CHATTERJEE, May 2012
%             PhD Student (S. M. No. 04-03-05-10-12-11-1-08692)
%             Learning System and Multimedia Lab
%             Dept. of Electrical Engineering
%             INDIAN INSTITUTE OF SCIENCE
% Modified: Hamidreza Heydarian, 2017

function  [M, Iteration]=MeanSE3GraphFast(RM,I,Minit,Weight)

    maxIters=250;
    changeThreshold=1e-5;

    N=max(max(I));%Number of cameras or images or nodes in view graph

    if(nargin>2&&~isempty(Minit))
        M=Minit;
    else
        M=eye(4);
        %Compute initial M from a Spanning Tree
        i=zeros(N,1);    i(1)=1;
        while(sum(i)<N)
           SpanFlag=0;
            for j=1:size(I,2)
                if(i(I(1,j))==1&&i(I(2,j))==0)
                    M(:,:,I(2,j))=RM(:,:,j)*M(:,:,I(1,j));
                    i(I(2,j))=1;
                    SpanFlag=1;
                end
                if(i(I(1,j))==0&&i(I(2,j))==1)
                    M(:,:,I(1,j))=RM(:,:,j)\M(:,:,I(2,j));
                    i(I(1,j))=1;
                    SpanFlag=1;
                end
            end
            if(SpanFlag==0&&sum(i)<N)
                error('Relative Motions DO NOT SPAN all the nodes in the VIEW GRAPH\n%s', 'Choose a larger threshold value !');
            end
        end    
    end

    % Formation of A matrix.
    m=size(I,2);
    i=[[1:m];[1:m]];i=i(:);
    j=I(:);
    s=repmat([-1;1],[m,1]);
    k=(j~=1);
    Amatrix=sparse(i(k),j(k)-1,s(k),m,N-1);
    if(nargin>3)
        Amatrix=Amatrix.*repmat(Weight',[1,(N-1)]);
    end

    score=inf;    Iteration=0;
    G = Amatrix;
    Ginv = inv(G'*G)*G';
    GinvSize = size(Ginv,1);

    while((score>changeThreshold)&&(Iteration<maxIters))
        i=I(1,:);j=I(2,:);
        for k=1:size(I,2)
            m=M2mu(M(:,:,(I(2,k)))\RM(:,:,k)*M(:,:,(I(1,k))));
            B(k,:)=[m(3,2),m(1,3),m(2,1),m(1:3,4)'];
        end    

        if(nargin>3)
            B=B.*repmat(Weight',[1,6]);
        end

%         X=Amatrix\B;       

        size1 = size(Amatrix,2);
        size2 = size(B,2);  
        X = zeros(GinvSize, 6);

    %    solving the linear system using cvx library    
    %    for ii=1:size2     

    %        cvx_begin
    %            variable Xp(size1);
    %            minimize(norm(Amatrix*Xp-B(:,ii),1));
    %        cvx_end    
    %        X = [X Xp];

    %    end

    %   solving the linear system using linear programmin, external matlab
    %   toolbox
    %     G = Amatrix;
    %     y = B;
    %     x0 = inv(G'*G)*G'*y;
    %     gfun = @(z) G*z;
    %     gtfun = @(z) G'*z;
    %     X = l1decode_pd(x0, gfun, gtfun, y, 1e-3, 25, 1e-8, 200);

    %   solving the linear system using linear programmin, external matlab
    %   toolbox

        parfor ii=1:size2
%             G = Amatrix;
%             y = B(:,ii);
%             x0 = inv(G'*G)*G'*y;
%             x0 = Ginv*y;
%             gfun = @(z) G*z;
%             gtfun = @(z) G'*z;
            X(:,ii) = l1decode_pd(Ginv*B(:,ii), @(z) G*z, @(z) G'*z, B(:,ii), 1e-3, 25, 1e-8, 200);
%             X = [X Xp];
        end

        score=2*norm(X(:,1:3))+norm(X(:,4:6));

        for k=2:N
            M(:,:,k)=M(:,:,k)*mu2M([crossmat(X(k-1,1:3)),X(k-1,4:6)';0 0 0 0]);
        end

        Iteration=Iteration+1;
%         disp(num2str([Iteration score]));

    end

    if(Iteration>=maxIters);disp('Max iterations reached');end

end
