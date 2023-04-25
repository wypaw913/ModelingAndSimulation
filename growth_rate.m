clc; clf; clear; close all;

%%%%Define initial conditions and parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%number of iterations in time
N = 500;

%initial population
x_initial = 0.3; 

%growth rate constant
r = 2.9;

%vector to hold pop values
X_Vect = zeros(N+1, 1);

%time vector
time = linspace(0, N, N+1);

%%%%iterate growth rate projection%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%handle initial condition
X_Vect(2) = x_initial;
x_current = x_initial;
for i=3: size(X_Vect)
    
    %run growth rate algo
    x_next = r * x_current * (1 - x_current);
    
    %Add to output population vector
    X_Vect(i) = x_next;
    
    %update current population
    x_current = x_next;
end


subplot(2, 3, 1)
plot(time, X_Vect)
title(['Pop vs Time, r = ', num2str(r), ', branch= ', num2str(branch_detect(X_Vect))])
ylabel("Frac. Pop.")
xlabel("Time Iters.")
ylim([0,1])

r=3;
%handle initial condition
X_Vect(2) = x_initial;
x_current = x_initial;
for i=3: size(X_Vect)
    
    %run growth rate algo
    x_next = r * x_current * (1 - x_current);
    
    %Add to output population vector
    X_Vect(i) = x_next;
    
    %update current population
    x_current = x_next;
end


subplot(2, 3, 2)
plot(time, X_Vect)
title(['Pop vs Time, r = ', num2str(r), ', branch= ', num2str(branch_detect(X_Vect))])
ylabel("Frac. Pop.")
xlabel("Time Iters.")
ylim([0,1])

r=3.5;
%handle initial condition
X_Vect(2) = x_initial;
x_current = x_initial;
for i=3: size(X_Vect)
    
    %run growth rate algo
    x_next = r * x_current * (1 - x_current);
    
    %Add to output population vector
    X_Vect(i) = x_next;
    
    %update current population
    x_current = x_next;
end


subplot(2, 3, 3)
plot(time, X_Vect)
title(['Pop vs Time, r = ', num2str(r), ', branch= ', num2str(branch_detect(X_Vect))])
ylabel("Frac. Pop.")
xlabel("Time Iters.")
ylim([0,1])

r=3.55;
%handle initial condition
X_Vect(2) = x_initial;
x_current = x_initial;
for i=3: size(X_Vect)
    
    %run growth rate algo
    x_next = r * x_current * (1 - x_current);
    
    %Add to output population vector
    X_Vect(i) = x_next;
    
    %update current population
    x_current = x_next;
end


subplot(2, 3, 4)
plot(time, X_Vect)
title(['Pop vs Time, r = ', num2str(r), ', branch= ', num2str(branch_detect(X_Vect))])
ylabel("Frac. Pop.")
xlabel("Time Iters.")
ylim([0,1])

r=3.565;
%handle initial condition
X_Vect(2) = x_initial;
x_current = x_initial;
for i=3: size(X_Vect)
    
    %run growth rate algo
    x_next = r * x_current * (1 - x_current);
    
    %Add to output population vector
    X_Vect(i) = x_next;
    
    %update current population
    x_current = x_next;
end


subplot(2, 3, 5)
plot(time, X_Vect)
title(['Pop vs Time, r = ', num2str(r), ', branch= ', num2str(branch_detect(X_Vect))])
ylabel("Frac. Pop.")
xlabel("Time Iters.")
ylim([0,1])

r = 3.7;
%handle initial condition
X_Vect(2) = x_initial;
x_current = x_initial;
for i=3: size(X_Vect)
    
    %run growth rate algo
    x_next = r * x_current * (1 - x_current);
    
    %Add to output population vector
    X_Vect(i) = x_next;
    
    %update current population
    x_current = x_next;
end


subplot(2, 3, 6)
plot(time, X_Vect)
title(['Pop vs Time, r = ', num2str(r), ', branch>>', num2str(branch_detect(X_Vect))])
ylabel("Frac. Pop.")
xlabel("Time Iters.")
ylim([0,1])


%to detect patterns above 2^6 branches
 function branch = branch_detect(V)
     
     %check for all same value to the 4th decimal place
     if round(V(length(V)), 4) == round(V(length(V)-1), 4)
        branch = 1; 
        return
     end
     
     %find patterns of 2^n repeating sets 
     %number of loops makes downstream code extremely costly
     for n=1: 7
        
        %equates values rounded to the 4th decimal place
        if round(V(length(V)), 4) == round(V(length(V)-(2^n)), 4)
               branch = 2^n;
               return
        end
     end
     %default max branches for when things get crazy
     branch = 2^8;

 end
