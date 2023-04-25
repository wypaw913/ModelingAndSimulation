%EE372 Modeling and Simulation
%01/30/2022
%Conway's Game of Life

clc; clear; close all; clf;

%dimension of game arena NxN matrix
N = 100;

%number of timesteps or iterations to simulate
%1= Initial Condition
timesteps = 2000;

%initialize matrix A
A =  zeros(N, N);

%cell change assignment matrix
B = zeros(N+1, N+1);

%%%%Populate matrix A with initial condition%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %floating point random values in NxN matrix
%A = rand(N);
% %round to nearest integer to get 1's and 0's
%A = round(A);

%glider
%A(1,3)=1; A(2, 1)=1; A(3, 2)=1; A(3 ,3)=1; A(2, 3)=1;

% %blinker
 A(round(N/2),round(N/2)-1) = 1; A(round(N/2),round(N/2))=1; 
 A(round(N/2),round(N/2)+1)=1;

%tee
%A(round(N/2),round(N/2)-1) = 1; A(round(N/2),round(N/2))=1; 
%A(round(N/2),round(N/2)+1)=1;   A(round(N/2) +1 ,round(N/2))=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Simulate%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%pad matrix A with zeros to make boundary simulation easier
A = padarray(A, [1,1]);

%holds the total number of living cells
population =0;

%main loop for each iteration
for L=1: timesteps
    
    %find initial population
     if L==1
        for I=2: size(A,1)-1
            for J=2: size(A,1)-1
                if A(I,J) ==1
                    population = population + 1;
                end
            end
        end
    end
    %need this so we can assign changes to cell without disturbing the
    %arena state in each iteration
    B = A;
    
    if L~=1
         %raster scan to neighbor check
        %scan Left to Right, Top to Bottom
        %outer loop for vertical increment of interior pts
        for I=2: size(A,1)-1

            %horizontal increment of interior pts
            for J=2: size(A,1)-1

                %count living cell neighbors (1's)
                neighbors = A(I-1, J-1) + A(I-1, J) + A(I-1, J+1) + ...
                            A(I,   J-1) +             A(I,   J+1) + ...
                            A(I+1, J-1) + A(I+1, J) + A(I+1, J+1);

                %decide cell fate       
                %update matrix B with change

                %kill the live cell if it has under or over population
                if A(I,J) == 1 && (neighbors<2 || neighbors>3)

                    B(I,J) = 0;
                    population = population -1;

                else
                %if dead cell and has three live neighbors
                %make it live
                    if A(I,J) == 0 && neighbors ==3

                        B(I,J) = 1;
                        population = population + 1;

                    end
                end
            end
        end
    
    %make updated matrix the new one
    A = B;
    end
    
   
    
    %%%Plot%%%%%%%%%%%
    %unpad matrix for display
    output = A(2:N+1, 2:N+1);
    figure(1);
    imagesc(output);
    title(['Conways Game of Life'...
        ,', Timelevel= ',num2str(L),', Population= ',...
        num2str(population)])
    
    %pause(0.5);
    
    %end the simulation if there are no living cells left
    if population ==0
       break 
    end
end

