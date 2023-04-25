clc; clear; close all;

%%%parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%number of time steps
timesteps = 3000;

%dimension of arena NxN matrix
N = 200;

% x domain [a, b] in mm
a = 0;
b = N;

% y domain [c, d] in mm
c = a;
d = b;

%resolution/spacing/dx
dx =(b-a)/N;

%resolution/spacing/dy
dy = dx;

%x vector of interior points from dx to b-dx with spacing dx
x=(a+1:dx:b);

%y vector of interior points from dy to d-dy with spacing dy
y=(c+1:dy:d);

%mesh grid for circle
[X,Y] = meshgrid(x,y);

%initialize matrix A
A =  zeros(N, N);

%cell change assignment matrix
B = zeros(N, N);

%nutrient/colony radius
radius = N*0.05;

%inner circle radius
inner_rad = radius-1;

%distance nuts/cols are apart from nearest edge to nearest edge
dist_edge = N*0.04;

%center of A
center_A = ((length(A)-1)/2);

%distance from center of node
cent_dist = (dist_edge/2)+ radius; 

%%%%Create Initial Condition%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%Flat case nutrients%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %make left colony node 
% A = (10)*((X-center_A+ (cent_dist*2)).^2+(Y-center_A).^2 - radius^2 <0);
% 
% %make right nutrient node
% A = (-10)*((X-center_A-cent_dist).^2+(Y-center_A).^2 - radius^2 <0) +A;
% 
% %make right lower nutrient node
% A = (-10)*((X-center_A-cent_dist).^2+...
%     (Y-center_A+cent_dist*2).^2 - radius^2 <0) +A;
% 
% %make right upper nutrient node
% A = (-10)*((X-center_A-cent_dist).^2+...
%     (Y-center_A-cent_dist*2).^2 - radius^2 <0) +A;
%%%End flat case%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%angled case nutrients%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %make left colony node 
% A = (10)*((X-center_A+cent_dist*2).^2+(Y-center_A).^2 - radius^2 <0);
% 
% %make right nutrient node
% A = (-10)*((X-center_A-cent_dist).^2+(Y-center_A).^2 - radius^2 <0) +A;
% 
% %make right lower nutrient node
% A = (-10)*((X-center_A-cent_dist-(N*0.15)).^2+...
%     (Y-center_A+cent_dist*2).^2 - radius^2 <0) +A;
% 
% %make right upper nutrient node
% A = (-10)*((X-center_A-cent_dist+(N*0.15)).^2+...
%     (Y-center_A-cent_dist*2).^2 - radius^2 <0) +A;

%%%End angled case%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%Diamond Case nutrients%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%make left colony node 
A = (10)*((X-center_A+cent_dist*2).^2+(Y-center_A).^2 - radius^2 <0);
%make just a perimeter
A = (-7)*((X-center_A+cent_dist*2).^2+(Y-center_A).^2 - ...
    (inner_rad)^2 <0)+A;



%make right nutrient node
A = (-10)*((X-center_A-cent_dist*2).^2+(Y-center_A).^2 - radius^2 <0) +A;
%make just a perimeter
A = (7)*((X-center_A-cent_dist*2).^2+(Y-center_A).^2 - ...
    (inner_rad)^2 <0) +A;

%make right lower nutrient node
A = (-10)*((X-center_A).^2+...
    (Y-center_A+cent_dist*2).^2 - radius^2 <0) +A;
%make perimeter
A = (7)*((X-center_A).^2+...
    (Y-center_A+cent_dist*2).^2 - (inner_rad)^2 <0) +A;

%make right upper nutrient node
A = (-10)*((X-center_A).^2+...
    (Y-center_A-cent_dist*2).^2 - radius^2 <0) +A;
%make perimeter
A = (7)*((X-center_A).^2+...
    (Y-center_A-cent_dist*2).^2 - (inner_rad)^2 <0) +A;

%%%End Diamond Case%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Pre simulation Prep%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pad matrix A with -2's to make boundary simulation easier
A = padarray(A, [1,1], -2);
%node location matrix %never accidentally comment this!!!!!!
C = A;

%find length of perimeter
perimLength = findPerimeter(C);

%value that stores number of colonies init to 1
numColony = 1;

%number of times the growFilament function has been called
%this is to create more straightness
numTimesGrown = 1;

%straightness parameter to increase decrease curling
straightness = 5;

%boolean for whether its time to bud
newFilament =1;

%boolean for whether nutrient has been reached
nutrGoal = 0;

%boolen for whether filament is terminated
terminated=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Main Simulation Loop%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for time=1: timesteps
    
    %need this so we can assign changes to cell without disturbing the
    %arena state in each iteration
    B = A;
    
    
    if newFilament==0 && terminated==0
        
        [B, terminated] = growFilament(A,B, numTimesGrown, straightness);
        numTimesGrown = numTimesGrown +1;
    end
    if terminated ==1
        newFilament=1;
    end
    if newFilament==1
        B = budFilament(A,B, perimLength, numColony);
        newFilament=0;
        terminated =0;
    end
    
    
    %make updated matrix the new one
    A = B;
    
    %%%Plot%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %unpad matrix for display
    output = A(2:N+1, 2:N+1);
    %output = A;
    figure(1);
    imagesc(output);
    %title(['SlimeMold'...
       % ,', Timelevel= ',num2str(time)])
    %flip axis for intuitiveness
    set(gca,'YDir','normal')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%End of Main Simulation Loop%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%Functions%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%finds the length of the node perimeter
function perimNum = findPerimeter(C)
    
    perimNum=0;
    %raster scan to count length of perimeter
    for i=2: length(C)-1
        for j=2: length(C)-1
            if C(i,j)==10
                perimNum=perimNum+1;
            end
        end
    end

end

%pick random perimeter value of nutrient source and create 
%one filament terminus
%scans entire arena to populate cell array with possible bud sites
%randomly picks one bud location and creates bud with value 7
function B = budFilament(A, B, perimLength, numColony)
    
    %create empty array of matrix indexes where buds can form
    budSites = zeros(perimLength*numColony,2);
    
    bsCounter = 1;
    %%%raster scan to populate matrix with indexes of budsites
    for i=2: length(A)-1
        for j=2: length(A)-1
            
            if A(i,j) ==10
                
                budSites(bsCounter, 1) = i;
                budSites(bsCounter, 2) = j;
                bsCounter = bsCounter+1;
            end
            
        end
    end
    
    %pick random row from budsite and try to bud. keep trying until a 0
    %location become filled
    loopCtr = 0;
    while 1
        
        %generate random integer 1-bud
        indexBud = randi([1 bsCounter-1]);
        
        %raster scan 3x3 square around index to bud and try to place bud
        %failure and restart if index chosen not zero. Uses random number
        %between -1 and 1 to choose
        squareBud = randi([-1 1], 1, 2);
        if A( budSites(indexBud, 1)+squareBud(1), ...
                budSites(indexBud, 2)+squareBud(2))==0
            
            B(budSites(indexBud, 1)+squareBud(1), ...
                budSites(indexBud, 2)+squareBud(2))=7;
            break;
            
        end
        loopCtr=loopCtr+1;
        if loopCtr>8
            break
        end
    end
end

%Finds the filament terminus and grows it by one element
%growth is always three opposite cells of other connection
%straighness parameter indicates how many straight moves will be made
%before a random number picks between the three opposite cells
function [B, terminated] = growFilament(A, B, numTimesGrown, straightness)
    
    %default output for terminated
    terminated = 0;
    
    %create empty 2xtermNum array to hold indexes
    termSite = zeros(1, 2);
    
    %raster scan entire arena to find and store terminus location
    for i=2: length(A)-1
        for j=2: length(A)-1
            if A(i,j)==7

                termSite(1) = i;
                termSite(2) = j;

            end
        end
    end
    
    %create empty 2xtermNum array to hold indexes
    nextSite = zeros(1, 2);
    
    %determine nextminus location, can also be perimeter 10 valued if bud
    for i=-1:1
        for j=-1:1
            if (A(termSite(1)+i, termSite(2)+j)==6)||...
                    (A(termSite(1)+i, termSite(2)+j)==10)%||...
                    %(A(termSite(1)+i, termSite(2)+j)==5)
                
                nextSite(1) = termSite(1)+i;
                nextSite(2) = termSite(2)+j;
                
                %save relative index location of nextminus
                %one of eight possibilities around terminus
                theI = i;
                theJ = j;

            end
        end
    end 
    
    %based on location of nextminus, determine the three opposite cells
    %to put the new terminus. Use random number to decide which of three
    %every straightness times
    %default is 2
    
    if mod(numTimesGrown, straightness)==0
        %generate random int between 1-3
        randomNum = randi([1 3]);
    else
        randomNum = 2;
    end
    
    
    %holds the index of the potential next terminus
    growthSite= zeros(1, 2);
    
    %keep trying to place next terminus until the value is not
    %boundary of -2, col perim of 10, col inter of 3, body of 5, 
    endLoop = 0;
    badTerminus=0;
    loopCtr = 1;
    while 1
        
        %handle each nextminus case individually
        if (theI==-1)&&(theJ==-1)

            %clockwise opposite three
            if randomNum ==1
                %B(termSite(1)+1, termSite(2)) = 7; 
                growthSite(1) = termSite(1)+1;
                growthSite(2) = termSite(2);
            end
            if randomNum ==2
                %B(termSite(1)+1, termSite(2)+1) = 7;
                growthSite(1) = termSite(1)+1;
                growthSite(2) = termSite(2)+1;
            end
            if randomNum ==3
                %B(termSite(1), termSite(2)+1) = 7;
                growthSite(1) = termSite(1);
                growthSite(2) = termSite(2)+1;
            end

        end

        if (theI==0)&&(theJ==-1)

            %clockwise opposite three
            if randomNum ==1
                %B(termSite(1)+1, termSite(2)+1) = 7;
                growthSite(1) = termSite(1)+1;
                growthSite(2) = termSite(2)+1;
            end
            if randomNum ==2
                %B(termSite(1), termSite(2)+1) = 7;
                growthSite(1) = termSite(1);
                growthSite(2) = termSite(2)+1;
            end
            if randomNum ==3
                %B(termSite(1)-1, termSite(2)+1) = 7;
                growthSite(1) = termSite(1)-1;
                growthSite(2) = termSite(2)+1;
            end

        end

        if (theI==1)&&(theJ==-1)

            %clockwise opposite three
            if randomNum ==1
                %B(termSite(1), termSite(2)+1) = 7;
                growthSite(1) = termSite(1);
                growthSite(2) = termSite(2)+1;
            end
            if randomNum ==2
                %B(termSite(1)-1, termSite(2)+1) = 7;
                growthSite(1) = termSite(1)-1;
                growthSite(2) = termSite(2)+1;
            end
            if randomNum ==3
                %B(termSite(1)-1, termSite(2)) = 7;
                growthSite(1) = termSite(1)-1;
                growthSite(2) = termSite(2);
            end

        end

        if (theI==1)&&(theJ==0)

            %clockwise opposite three
            if randomNum ==1
                %B(termSite(1)-1, termSite(2)+1) = 7;
                growthSite(1) = termSite(1)-1;
                growthSite(2) = termSite(2)+1;
            end
            if randomNum ==2
                %B(termSite(1)-1, termSite(2)) = 7;
                growthSite(1) = termSite(1)-1;
                growthSite(2) = termSite(2);
            end
            if randomNum ==3
                %B(termSite(1)-1, termSite(2)-1) = 7;
                growthSite(1) = termSite(1)-1;
                growthSite(2) = termSite(2)-1;
            end

        end

        if (theI==1)&&(theJ==1)

            %clockwise opposite three
            if randomNum ==1
                %B(termSite(1)-1, termSite(2)) = 7;
                growthSite(1) = termSite(1)-1;
                growthSite(2) = termSite(2);
            end
            if randomNum ==2
                %B(termSite(1)-1, termSite(2)-1) = 7;
                growthSite(1) = termSite(1)-1;
                growthSite(2) = termSite(2)-1;
            end
            if randomNum ==3
                %B(termSite(1), termSite(2)-1) = 7;
                growthSite(1) = termSite(1);
                growthSite(2) = termSite(2)-1;
            end

        end

        if (theI==0)&&(theJ==1)

            %clockwise opposite three
            if randomNum ==1
                %B(termSite(1)-1, termSite(2)-1) = 7;
                growthSite(1) = termSite(1)-1;
                growthSite(2) = termSite(2)-1;
            end
            if randomNum ==2
                %B(termSite(1), termSite(2)-1) = 7;
                growthSite(1) = termSite(1);
                growthSite(2) = termSite(2)-1;
            end
            if randomNum ==3
                %B(termSite(1)+1, termSite(2)-1) = 7;
                growthSite(1) = termSite(1)+1;
                growthSite(2) = termSite(2)-1;
            end

        end

        if (theI==-1)&&(theJ==1)

            %clockwise opposite three
            if randomNum ==1
                %B(termSite(1), termSite(2)-1) = 7;
                growthSite(1) = termSite(1);
                growthSite(2) = termSite(2)-1;
            end
            if randomNum ==2
                %B(termSite(1)+1, termSite(2)-1) = 7;
                growthSite(1) = termSite(1)+1;
                growthSite(2) = termSite(2)-1;
            end
            if randomNum ==3
                %B(termSite(1)+1, termSite(2)) = 7;
                growthSite(1) = termSite(1)+1;
                growthSite(2) = termSite(2);
            end

        end

        if (theI==-1)&&(theJ==0)

            %clockwise opposite three
            if randomNum ==1
                %B(termSite(1)+1, termSite(2)-1) = 7;
                growthSite(1) = termSite(1)+1;
                growthSite(2) = termSite(2)-1;
            end
            if randomNum ==2
                %B(termSite(1)+1, termSite(2)) = 7;
                growthSite(1) = termSite(1)+1;
                growthSite(2) = termSite(2);
            end
            if randomNum ==3
                %B(termSite(1)+1, termSite(2)+1) = 7;
                growthSite(1) = termSite(1)+1;
                growthSite(2) = termSite(2)+1;
            end

        end
        
        %detect if nutrient has been reached and make terminus and nextmins
        %body material
        if (A(growthSite(1), growthSite(2))==-10)||...
                (A(growthSite(1), growthSite(2))==-3)
            
            B(nextSite(1), nextSite(2))=5;
            B(termSite(1), termSite(2))=5;
            endLoop = 1;
            terminated=1;
            break;
        end
        
        %only make next terminus if value in cell isnt -2, 10, 3, ***5***
        %otherwise keep on looping
        if (A(growthSite(1), growthSite(2))~=-2)&&...
                (A(growthSite(1), growthSite(2))~=10)&&...
                (A(growthSite(1), growthSite(2))~=3)&&...
                (A(growthSite(1), growthSite(2))~=5)
            
            B(growthSite(1), growthSite(2))=7;
            terminated=0;
            badTerminus=0;
            endLoop=0;
            
            break
        end
        
        %handle wall collision
        if (A(growthSite(1), growthSite(2))==-2)
            B(nextSite(1), nextSite(2))=5;
            B(termSite(1), termSite(2))=5;
            badTerminus=1;
            terminated=1;
            endLoop=1;
        end
       
        %kill the loop if a bad terminus is reached
        if loopCtr>3
            B(nextSite(1), nextSite(2))=5;
            B(termSite(1), termSite(2))=5;
            badTerminus=1;
            terminated=1;
            endLoop=1;
            break
        end
        
        loopCtr = loopCtr+1;
    end
    
    
    %%make last terminus nextminus (7->6), make last nextminus body(6->5), 
    %%will need to figure out how to handle when terminus is a bud
    if endLoop ==0 && badTerminus==0
       
        %make previous nextminus body if not bud
        if B(nextSite(1), nextSite(2))==6
            B(nextSite(1), nextSite(2)) = 5;
        end
        %make last terminus nextminus
        B(termSite(1), termSite(2))=6;
    end
end

