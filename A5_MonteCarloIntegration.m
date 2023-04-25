clc; clear; close all;

%%%parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%number of discrete points in x
N = 10000;

%%x vectors and dx's and totalArea for each equation
x1 = linspace(0, 10, N);
dx1 = 10/N;
totalArea1 = 100*10;

x2 = linspace(0, 90, N);
dx2 = 90/N;
totalArea2 = 90*20;

x3 = linspace(0, 4, N);
dx3 = 4/N;
totalArea3 = 4*4;

x4 = linspace(0, 10, N);
dx4 = 10/N;
totalArea4 = 10;

%create random number vectors for each eqn
y1_rand = rand(1, N) * 100;

y2_rand = rand(1, N) * 20;

y3_rand = rand(1, N) * 4;

y4_rand = rand(1, N); 




%create functions
y1 = x1.^2;          %%integrate from 0 to 10
y2 = tand(x2);       %%integrate from 0 to 90 degrees
y3 = sqrt(16-x3.^2);  %%integrate from 0 to 4
y4 = abs(sin(x4.^2).*cos(5.*x4));


%%plot%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)

subplot(2,2,1)
hold on;
plot(x1, y1)

%stores number of pts on or under curve
underCurve = 0;
%change color for each dot based on under vs over
for i=1: N
    if y1_rand(i) <= y1(i)
        plot(x1(i), y1_rand(i), 'b.')
        underCurve = underCurve + 1;
    else
        plot(x1(i), y1_rand(i), 'r.')
    end
end
%find proportion of pts under curve
fracUnder = underCurve/N;
%calculate area under curve by multiplying total area by number of pts
area = fracUnder*totalArea1;

%analytical integral solution
analyt = (10^3)/3;

error1 = abs((area-analyt)/analyt)*100;

title(['y = x^2 MCintegral= ',num2str(area), ' err%= ', num2str(error1)])
xlabel('x')
ylabel('y')
axis( [0 10 0 max(y1)*1.1])
hold off;

subplot(2,2,2)
hold on;

%stores number of pts on or under curve
underCurve = 0;
%change color for each dot based on under vs over
for i=1: N-318
    if y2_rand(i) <= y2(i)
        plot(x2(i), y2_rand(i), 'b.')
        underCurve = underCurve + 1;
    else
        plot(x2(i), y2_rand(i), 'r.')
    end       
end
%find proportion of pts under curve
fracUnder = underCurve/N;
%calculate area under curve by multiplying total area by number of pts
area = fracUnder*totalArea2;

%analytical integral solution
%analyt = 6.908;
analyt = trapz(y2(:, 1:9682))*dx2;

%percent error
error2 = abs((area-analyt)/analyt)*100;

plot(x2, y2)

title(['y = tan(\theta) MCintegral= ',num2str(area), ' err%= ', ...
    num2str(error2),' max capped at y=20'])
xlabel('\theta (deg)')
ylabel('y')
axis( [0 90 0 20])
hold off;

subplot(2,2,3)
hold on;
%stores number of pts on or under curve
underCurve = 0;
%change color for each dot based on under vs over
for i=1: N
    if y3_rand(i) <= y3(i)
        plot(x3(i), y3_rand(i), 'b.')
        underCurve = underCurve + 1;
    else
        plot(x3(i), y3_rand(i), 'r.')
    end
end
%find proportion of pts under curve
fracUnder = underCurve/N;
%calculate area under curve by multiplying total area by number of pts
area = fracUnder*totalArea3;

%analytical integral solution
analyt = 4*pi;

%percent error
error3 = abs((area-analyt)/analyt)*100;

plot(x3, y3)

title(['y = sqrt(16-x^2) MCintegral= ',num2str(area), ' err%= ', num2str(error3)])
xlabel('x')
ylabel('y')
axis( [0 4 0 max(y3)*1.1])
hold off;

subplot(2,2,4)
hold on;
%stores number of pts on or under curve
underCurve = 0;
%change color for each dot based on under vs over
for i=1: N
    if y4_rand(i) <= y4(i)
        plot(x4(i), y4_rand(i), 'b.')
        underCurve = underCurve + 1;
    else
        plot(x4(i), y4_rand(i), 'r.')
    end
end
%find proportion of pts under curve
fracUnder = underCurve/N;
%calculate area under curve by multiplying total area by number of pts
area = fracUnder*totalArea4;

%analytical integral solution
analyt = trapz(y4)*dx4;

%percent error
error4 = abs((area-analyt)/analyt)*100;

plot(x4, y4)

title(['y = abs(sin(x^2)cos(5x)) MCintegral= ',num2str(area), ' err%= ', num2str(error4)])
xlabel('x')
ylabel('y')
axis( [0 10 0 max(y4)*1.1])
hold off;

