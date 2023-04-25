clc; clear; close all;

%this code compares three different matrix inversion techniques
%used to solve a linear system of equations Ax=b

%%%%Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%max array dimension cannot exceed 7
N = 4;
%max entry value
max = 5;

%matrix on which svd is performed
%dimension must be NxN-1
%A = [3 1; -1 3; 7 3;];
%A = [3 1; -1 3; -7 -3;];

%generate matrix of random integers of appropriate dim

A = randi(max, [N N]);

B = randi(max, [N 1]);

%%%%Main Program%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%pseudo inverse sVD%%%%%%%%%%%%%%%
U = findU(A);
[V, Sp] = findVTandS(A);
%compute pseudoinverse of A
Ap = V*Sp*U'
%compute I = Ainv*V
MP = Ap*B;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% solving using inv%%%%%%%%%%%%%%
inv_inv = inv(A)*B;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%using rref%%%%%%%%%%%%%%%%%%%%%%
rref_b = A\B;


figure(1)
subplot(1,3,1)
imagesc(MP)
title('B from M-P Pseudoinv. SVD')
%colormap(gray)
subplot(1,3,2)
imagesc(inv_inv)
title('B Using inv()')
%colormap(gray)
subplot(1,3,3)
imagesc(rref_b)
title('B Using \')
%colormap(gray)
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
function [V, Sp] = findVTandS(A)
    
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
                
                %compute sigmas and take inverse
                S(i,j) = sqrt(evals1(i,j)) ^-1;
                
            end 
        end
    end
    
    %add row of zeroes to the bottom of S so it has proper dimension
    zerovect= zeros(1, count);
    S = [S; zerovect];
    

    Sp = S';
end