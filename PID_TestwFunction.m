clc; clear; close all; %clf;

%time resolution
dt = 0.001;
%final time (s)
Tf = 5;
%time vector with spacing dt
t = (0:dt:Tf);

%setpoint vector init zeros
SP = zeros(1, length(t));
%heavyside set point always turns on at 10% of Tf
SP( 1, (Tf*0.1)/(dt):length(SP)) = 1000;

%ramp set point always turns on 0 and rises to 1s
%create ramp SP function
% for i=1: length(SP)
%     if i<=(1/dt)
%         SP(i) = t(i) *1000;
%     end
%     if i>(1/dt)
%         SP(i) = 1000;
%     end    
% end

%noise magnitude
n_small = 5;
n_large = 50;
%gaussian noise vector
noise_small = n_small*randn(1, length(SP));
noise_large = n_large*randn(1, length(SP));
%add gaussian noise to SetPoint
SP_small = SP + noise_small;
SP_large = SP + noise_large;

%proportional gain
Kp1 = 0.99;
%integral gain
Ki1 = 18;
%derivative gain
Kd1 = 1e-7;

%proportional gain
Kp2 = 0.5;
%integral gain
Ki2 = .99;
%derivative gain
Kd2 = 1e-7;

%proportional gain
Kp3 = 0.8;
%integral gain
Ki3 = 15;
%derivative gain
Kd3 = 1e-7;

%transfer function of system to be controlled
H = 1;

%three cases wo noise
PV_1 = PID(SP, t, dt, Kp1, Ki1, Kd1, H);
PV_2 = PID(SP, t, dt, Kp2, Ki2, Kd2, H);
PV_3 = PID(SP, t, dt, Kp3, Ki3, Kd3, H);

%three cases w small noise
PV_1_small = PID(SP_small, t, dt, Kp1, Ki1, Kd1, H);
PV_2_small = PID(SP_small, t, dt, Kp2, Ki2, Kd2, H);
PV_3_small = PID(SP_small, t, dt, Kp3, Ki3, Kd3, H);

%three cases w large noise
PV_1_large = PID(SP_large, t, dt, Kp1, Ki1, Kd1, H);
PV_2_large = PID(SP_large, t, dt, Kp2, Ki2, Kd2, H);
PV_3_large = PID(SP_large, t, dt, Kp3, Ki3, Kd3, H);

figure(1)
subplot(3,3,1)
hold on;
plot(t, PV_1)
plot(t, SP)
title(['Underdamped PID Relief Valve', ' Kp=', num2str(Kp1)...
    , ' Ki=', num2str(Ki1), ' Kd=', num2str(Kd1)])
xlabel('Time (s)')
ylabel('Pressure (psi)')
axis( [0 Tf 0 max(PV_1)*1.1])
legend('PV', 'SP (Step)')
hold off;

subplot(3,3,4)
hold on;
plot(t, PV_2)
plot(t, SP)
title(['Overdamped PID Relief Valve', ' Kp=', num2str(Kp2)...
    , ' Ki=', num2str(Ki2), ' Kd=', num2str(Kd2)])
xlabel('Time (s)')
ylabel('Pressure (psi)')
axis( [0 Tf 0 max(PV_2)*1.1])
legend('PV', 'SP (Step)')
hold off;

subplot(3,3,7)
hold on;
plot(t, PV_3)
plot(t, SP)
title(['Critically Damped PID Relief Valve', ' Kp=', num2str(Kp3)...
    , ' Ki=', num2str(Ki3), ' Kd=', num2str(Kd3)])
xlabel('Time (s)')
ylabel('Pressure (psi)')
axis( [0 Tf 0 max(PV_3)*1.1])
legend('PV', 'SP (Step)')
hold off;

%for noisey setpoint now
subplot(3,3,2)
hold on;
plot(t, PV_1_small)
plot(t, SP_small)
title(['Underdamped w Small Noise', ' Kp=', num2str(Kp1)...
    , ' Ki=', num2str(Ki1), ' Kd=', num2str(Kd1)])
xlabel('Time (s)')
ylabel('Pressure (psi)')
axis( [0 Tf 0 max(PV_1_small)*1.1])
legend('PV', 'SP (Step)')
hold off;

subplot(3,3,5)
hold on;
plot(t, PV_2_small)
plot(t, SP_small)
title(['Overdamped w Small Noise', ' Kp=', num2str(Kp2)...
    , ' Ki=', num2str(Ki2), ' Kd=', num2str(Kd2)])
xlabel('Time (s)')
ylabel('Pressure (psi)')
axis( [0 Tf 0 max(PV_2_small)*1.1])
legend('PV', 'SP (Step)')
hold off;

subplot(3,3,8)
hold on;
plot(t, PV_3_small)
plot(t, SP_small)
title(['Critically Damped w Small Noise', ' Kp=', num2str(Kp3)...
    , ' Ki=', num2str(Ki3), ' Kd=', num2str(Kd3)])
xlabel('Time (s)')
ylabel('Pressure (psi)')
axis( [0 Tf 0 max(PV_3_small)*1.1])
legend('PV', 'SP (Step)')
hold off;

%for extra noisey setpoint now
subplot(3,3,3)
hold on;
plot(t, PV_1_large)
plot(t, SP_large)
title(['Underdamped w Large Noise', ' Kp=', num2str(Kp1)...
    , ' Ki=', num2str(Ki1), ' Kd=', num2str(Kd1)])
xlabel('Time (s)')
ylabel('Pressure (psi)')
axis( [0 Tf 0 max(PV_1_large)*1.1])
legend('PV', 'SP (Step)')
hold off;

subplot(3,3,6)
hold on;
plot(t, PV_2_large)
plot(t, SP_large)
title(['Overdamped w Large Noise', ' Kp=', num2str(Kp2)...
    , ' Ki=', num2str(Ki2), ' Kd=', num2str(Kd2)])
xlabel('Time (s)')
ylabel('Pressure (psi)')
axis( [0 Tf 0 max(PV_2_large)*1.1])
legend('PV', 'SP (Step)')
hold off;

subplot(3,3,9)
hold on;
plot(t, PV_3_large)
plot(t, SP_large)
title(['Critically Damped w Large Noise', ' Kp=', num2str(Kp3)...
    , ' Ki=', num2str(Ki3), ' Kd=', num2str(Kd3)])
xlabel('Time (s)')
ylabel('Pressure (psi)')
axis( [0 Tf 0 max(PV_3_large)*1.1])
legend('PV', 'SP (Step)')
hold off;


%this is what actually does the PID correction of the system
function PV = PID(SP, t, dt, Kp, Ki, Kd, H)
    
    %process variable init all zero except first value at 500
    PV = zeros(1, length(t));
    %error term init to zero
    ET = zeros(1, length(t));
    
    %run the PID algorithm
    for i=2: length(t)

        if SP(i)~=0

            %compute error term
            ET(i) = SP(i) - PV(i);

            %handle initial condition just proportional first time
            if i==2
                %proportional term
                P = Kp * ET(i);
                I = 0;
                D = 0;
            else
                %proportional term
                P = Kp * ET(i);

                %integral term numeric integration with spacing dt
                I = Ki * dt*trapz(ET);

                if i~=length(t)
                %derivative term rise/run
                D = Kd * (ET(i)-ET(i-1))/dt;
                end
            end

            %controller output
            U = P + I + D;

            %skip last time step
            if i~=length(t)
                %multiply by transfer function to obtain next process var value
                PV(i+1) = H * U;
            end
        end
    end

end