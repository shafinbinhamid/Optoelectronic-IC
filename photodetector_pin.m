clc;
close all;
clear all;

%% Data (InGaAs photodetector FGA01)
data = dlmread('InGaAs.txt');
lambda_data = data(:,1);%in nm
resp_data = data(:,2);% responsivity data in A/W
figure
plot(lambda_data,resp_data,'Linewidth',2)
xlabel('Lambda(nm)')
ylabel('Responsivity(A/W)')
%% parameter
e = 1.6e-19; 
kb = 1.38e-23;
n = 1; %Ideality factor
T = 300; % temperature in kelvin
I0 = 25e-9; %reverse saturation current(A)
Eg = 0.784; %In0.53Ga0.47As
% L = 100e-6;
% W = 3e-6;
dia = 0.12e-3;
Area = (pi/4)*dia^2;
h = 6.626e-34;
c = 3e8;
%% Temperature Effect
T_new = 290;
I0_old = I0;
I0=((T_new^3)*exp(Eg./(kb*T_new/e)))*I0_old/((T^3)*exp(Eg/(kb*T/e))); %reverse saturation current(A)


%% Iph calculation
lambda_in = (1.57e-6)*1e9; % from laser (in nm)
Intensity = 8.2198e5;
Pout = Intensity*Area;
%Pout = 0.0012;% from laser (in W)

err = lambda_in - lambda_data;
index = find(abs(err) == min(abs(err)));
R = resp_data(index)

Iph = R*Pout

%% Output voltage
RL = 1000;

Vout = Iph*RL;

%% Calculation of current, power
Vr = 1.5;
V = -2:0.01:0.35;
I_total = -Iph + I0.*(exp(e*V/(n*kb*T))-1);
Power = (-I_total.*V);
%index = find(V == -Vr);

%% Load Line
RL = 20;
err = (-(V+Vr)/RL-I_total);
index = find(abs(err)<0.025e-2);

%% I-V Curve Plot
figure
plot(V,I_total*1e3,'Linewidth',2)
xlabel('Voltage, V(V)')
ylabel('Current,I_{total}(mA)')
grid on;
hold on
line([V(1), V(end)], [0, 0], 'Color', [0,0,0],'LineStyle','-.','linewidth',2);
plot(V,-(V+Vr)/RL*1e3);
plot(V(index),I_total(index)*1e3,'ro')

Iout = I_total(index) % in A

%% Calculation of W for PIN Photodiode

Tr = 1; %perfect AR coating(assume)
ni = 1;% internal quantum efficiency(assume)
alpha = 4e5; %absorption coeff(in m^-1)
freq = c/(lambda_in*1e-9);
W = (-1/alpha)*log(1-(R*h*freq)/(e*ni*Tr))