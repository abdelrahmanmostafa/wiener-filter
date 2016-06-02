clc;
clear all;
close all;

% ---------------------------Wiener Filter--------------------------------% 
 A = 1; % signal amplitude
 f = 500; % signal frequency in Hz
 fs = 8000; % sampling frequency in Hz
 t = 0: 1/fs : 0.1; % time samples
 t = t(1:100);
 
 % empty arrays to hold all the signals
 X = [];
 Y = [];
 Noise = [];
 % repeat 10 times 
 for i = 1:10
 %% Generate the sinusoidal signal
 random_phase = -pi + (pi-(-pi)) * rand(1,1);
 x = A *sin(2 * pi * f * t + random_phase);
 %% Generate gaussian noise
 noise = normrnd(0,0.5,[1,100]);
 %% Add noise to signal
 y = x + noise;
 X = [X; x];
 Y = [Y; y];
 Noise = [Noise; noise];
 % plot x signal
 figure('Name',strcat('x',num2str(i)),'NumberTitle','off')  , plot(t,x) , ylabel(['x',num2str(i)]),xlabel('time'); 
 end
%% Calculate Covaraince Matrix
M = size(X,1);  % M measurments (10)
N = size(X,2);  % N random variables (100)  
v1 = [];
v2 = [];
v3 = [];

for i = 1 : N
    n   = Noise(:,i) - mean(Noise(:,i));
    x   = X(:,i) - mean(X(:,i));
    y   = Y(:,i) - mean(Y(:,i));
    v1 = [ v1 ; n'];
    v2 = [ v2 ; x'];
    v3 = [ v3 ; y'];
end
CN = (v1 * v1') / (M-1); % noise covaraince
CX = (v2 * v2') / (M-1); % X covaraince
CY = (v3 * v3') / (M-1); % Y covaraince
CXY= (v2 * v3') / (M-1); % cross covaraince between X,Y
%% display covariance matrices as images  
figure('Name','CN','NumberTitle','off') ; imagesc(CN);
figure('Name','CX','NumberTitle','off') ; imagesc(CX);
figure('Name','CY','NumberTitle','off') ; imagesc(CY);
figure('Name','CXY','NumberTitle','off') ; imagesc(CXY);
% 
%% Generate Test signal
random_phase = -pi + (pi-(-pi)) * rand(1,1);
x11 = A*sin(2*pi*f*t + random_phase);
figure('Name',strcat('x',num2str(11)),'NumberTitle','off'),plot(t,x11), ylabel(['x', num2str(11)]),xlabel('time');
noise = normrnd(0,0.5,[1,100]);
y11 = x11 + noise; 

%% Calculate A matrix 
A = CXY * inv(CY);
%% Calculate b matrix
mx = mean(X,1)';
my = mean(Y,1)';
b = mx-A*my;
%% Calculate estimated signal 
x11Estimated = (A * y11' + b)';
%% normalize xEstimated
x11Estimated = max(x11)* (x11Estimated) / (max(x11Estimated));
%% Calculate error
error = norm(x11 - x11Estimated);
fprintf('Error = %f',error);
%% plot x11 , xEstimated , y11
figure('Name','Estimated signal vs original signal','NumberTitle','off') , plot(t, x11Estimated); 
hold on , plot(t, x11,'r'), title ('Estimated signal vs original signal'),
plot(t, y11,'g'),xlabel('time'),
legend('x11','Estimated x11','y11');

