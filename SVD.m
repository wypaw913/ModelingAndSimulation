clc; clear; close all;

%this code performs singular value decomposition on a matrix A

%%%%Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%max array dimension cannot exceed 7
N = 2;
%max entry value
max = 10;

%matrix on which svd is performed
%dimension must be NxN-1
%A = [3 1; -1 3; 7 3;];
%A = [3 1; -1 3; -7 -3;];

%generate matrix of random integers of appropriate dim

A = randi([-max max], [N N]);

% imdata = imread('cat.jpg');
% imdata = rgb2gray(imdata);
% imdata = double(imdata);
% 
% r = centerCropWindow2d(size(imdata), [1000 1000]);
% 
% A = imcrop(imdata, r);

%%%%Main Program%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

U = findU(A);

[VT, S] = findVTandS(A);

%compute A = U*S*VT
output = round(U*S*VT);


[U1,S1,V1]=svd(A);

test = round(U1*S1*transpose(V1));

figure(1)
subplot(1,2,1)
imagesc(output)
title('Using Self-made SVD')
colormap(gray)
subplot(1,2,2)
imagesc(test)
title('Using Built-in SVD() Function')
colormap(gray)
% if test == output
%     success=1
% end

%%%%Function Definitions%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Find U%%%%%%%%%%%%
function U = findU(A)
    
    %Transpose of A
    A_T = transpose(A);

    %AT*A
    ATA = A_T * A;
    
    %find eigenvalues and normalized eigenvectors of A*AT
    [evectors, evals] = eig(ATA);
    
    %sort eigenvals in descending order
    [evals,ind] = sort(diag(evals), 'ascend');
    
    %sort eigen vectors in order according to evals
    evectors = evectors(:,ind);
    
    
    %init sigma vector
    sigmas = zeros(length(evals), 1);
    
    %compute sigma
    for i=1: length(evals)
        
        sigmas(i) = sqrt(evals(i));
    
    end
    
    nullvect = null(A_T);
    
    
    %find magnitude of nullvect
    sum = 0;
    null_col = zeros(length(evectors(:, 1)),1);
    for i=1: length(nullvect)
        
        sum = nullvect(i)^2+sum;
        
        if i==length(nullvect)
            null_col = nullvect./sqrt(sum);
        end
    end
 
    %initialize U to proper dim
    U = zeros(length(null_col));
    
    %populate U with proper column entries
    for i=1: length(evectors(:,1))+1
        
        if i~=length(evectors(:,1))+1
            U(:, i) = A*evectors(:,i)*(1/sigmas(i));
        else
            U(:, i) = null_col;
        end
    end
  
end

%%%%Find V%%%%%%%%%%%%
function [VT, S] = findVTandS(A)
    
    %Transpose of A
    A_T = transpose(A);
    
    %AT*A
    ATA = A_T * A;
    
    %find eigenvalues and normalized eigenvectors of A*AT
    [evectors, evals1] = eig(ATA);
    
    %sort eigenvals in descending order
    [evals,ind] = sort(diag(evals1), 'ascend');
    
    %sort eigen vectors in order according to evals
    evectors = evectors(:,ind);
    
    V=evectors;
    
    VT = transpose(V);
 
    
    %first count how many non-zero eigen values there are
    %and place eigenvalues in vector
    count = 0;
    for i=1: length(evals1)
        for j=1: length(evals1)
            
            if evals1(i,j)>10e-15
                
                count = count +1;
                
            end 
        end
    end
        
    %compute S from evectors diagonal matrix
    %take square root of non-negative values
    S = zeros(count);
    
    for i=1: length(S)
        for j=1: length(S)
            
            if evals1(i,j)~=0 && i==j
                
                S(i,j) = sqrt(evals1(i,j));
                
            end 
        end
    end
    
    %add row of zeroes to the bottom of S so it has proper dimension
    zerovect= zeros(1, count);
    S = [S; zerovect];
    
end


