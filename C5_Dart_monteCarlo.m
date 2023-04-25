clc; clear; close all; 

%Dart toss into a rectangular area probablility of landing in an annulus

%%Parameters
lengthSquare = 8;
Inner_radiusCircle = 2;
Outer_radiusCircle = 3;

maxTrials = 2000;

%%deterministic approach
areaSquare = lengthSquare^2;
areaAnnulus = pi*(Outer_radiusCircle^2-Inner_radiusCircle^2);

probHit = areaAnnulus/areaSquare;

fprintf('D probability = %1.4f/n', probHit);

%%Monte Carlo approach

hitCNTR = 0;
for count = 1: maxTrials
    x = lengthSquare*(1-2*rand)/2;
    y = lengthSquare*(1-2*rand)/2;
    
    trialRadius = sqrt(x^2+y^2);
    
    in_out = 0;
    
    if trialRadius <= Inner_radiusCircle & trialRadius <= ...
            Outer_radiusCircle
        hitCNTR = hitCNTR+1;
        in_out = 1;
    end
    
    myData(count, 1) = x;
    myData(count, 2) = y;
    myData(count, 3) = in_out;
end

MC_hitProb = hitCNTR/maxTrials;

fprintf('MC probability = %1.4f/n', MC_hitProb);

%%output
figure(1)
axis square

if maxTrials <= 1000
    blueSym = 'bo';
    redSym = 'ro';
else
    blueSym = 'b.';
    redSym = 'r.';
end


hold on;
for count = 1: maxTrials
    if myData(count, 3) == 1
        plot(myData(count,1), myData(count,2), blueSym);
    else
        plot(myData(count,1), myData(count,2), redSym);
    end
end

hold off;

      