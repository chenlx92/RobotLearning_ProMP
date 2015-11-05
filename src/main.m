%% Eric's code with just added the CI computed with the covariacne matrix 

clc;close all;clear all; format compact;

%% Demostrations
num = 30; % # of demostrations
position = [1, 1.5 2]; 
time = [0 30 60];  
[trajT, trajX] = trajGeneration(num,position,time);

%% Basis functions
n=60; % number of basis functions
sigma = 1.5; %variance
mu = linspace(1,max(time)-1,n);

phi = zeros(n,length(trajT));
for i = 1:n 
    phi(i,:)=gaussBasis(trajT,mu(i),sigma); % one bf per row
    phi(i,:)=phi(i,:)/sum(phi(i,:));
end

%% Get weights
w = zeros(n,num);
for i = 1:num %For each demostration
    y = trajX(:,i);
    %% Least squares
    weight=pinv(phi')*y;
    w(:,i)=weight;
end

% Mean
mu_w = mean(w,2);
% Standard deviation
std_w= std(w,0,2);
% Covariance
cov_w = (w-mu_w*ones(1,num))*(w-mu_w*ones(1,num))'/num;
lamda = 10^(-9);
cov_w = (cov_w +cov_w)/2 + eye(size(cov_w))*lamda;


%% Get trajectory
mu_y = phi'*mu_w;
cov_y = (trajX-phi'*w)*(trajX-phi'*w)'/(num*n);
% lamda = 10^(-6);
% cov_y = (cov_y +cov_y)/2 + eye(size(cov_y))*lamda;

%% Confidence Intervals (95%)
upper_ci_std_w = phi'*(mu_w+1.96*std_w/sqrt(n));
lower_ci_std_w = phi'*(mu_w-1.96*std_w/sqrt(n));

% this I have no Idea about what CI is  :D
upper_ci = phi'*(mu_w+2*sqrt(diag(cov_w)));
lower_ci = phi'*(mu_w-2*sqrt(diag(cov_w)));

%% Plots

% Demostrations
plot(trajT,trajX,'k');hold on;grid on;

% Basis functions
plot(trajT,phi,'g');

% Weights
%plot(mu,w/40,'r');

% Trajectory
plot(trajT,mu_y,'r','lineWidth',2);

% CI 
plot(trajT,upper_ci,'--r','lineWidth',3);
plot(trajT,lower_ci,'--r','lineWidth',3);
plot(trajT,upper_ci_std_w,'--b','lineWidth',3);
plot(trajT,lower_ci_std_w,'--b','lineWidth',3);
title(sprintf('%d trajectories     %d basis functions',num,n))

fill_between_lines(trajT,upper_ci,lower_ci,[0 1 0],0.3)

hold off

%% 2nd plot - select a random trajectory
w_traj = mvnrnd(mu_w,cov_w)';
trajectory = phi'*w_traj;

figure(2)
plot(trajT,trajectory,'r','lineWidth',2);
hold on; grid on;
plot(trajT,upper_ci,'--r','lineWidth',3);
plot(trajT,lower_ci,'--r','lineWidth',3);
plot(trajT,upper_ci_std_w,'--b','lineWidth',3);
plot(trajT,lower_ci_std_w,'--b','lineWidth',3);
fill_between_lines(trajT,upper_ci,lower_ci,[0 1 0],0.3)
title('Random Trajectory created from the fit of the weights')

str='Y';
while((strcmp(str,'Y') || strcmp(str,'y')))
    str = input('New trajectory?[Y/N]','s')
    if strcmp(str,'Y') || strcmp(str,'y')
        w_traj = mvnrnd(mu_w,cov_w)';
        trajectory = phi'*w_traj;
        figure(2)
        plot(trajT,trajectory,'r','lineWidth',2);
    end
end
disp('_________EXIT________')

%%
% Dynamic plot
disp('SAMPLING TRAJECTORIES')

N_ITERATIONS = 100; % number of sampled trajectories

figure(3)
hold on; grid on;
plot(trajT,upper_ci,'--r','lineWidth',3);
plot(trajT,lower_ci,'--r','lineWidth',3);
plot(trajT,upper_ci_std_w,'--b','lineWidth',3);
plot(trajT,lower_ci_std_w,'--b','lineWidth',3);
fill_between_lines(trajT,upper_ci,lower_ci,[0 1 0],0.3)
title(sprintf('%d sampled trajectories',N_ITERATIONS))

for i=1:N_ITERATIONS
    i
    w_traj = mvnrnd(mu_w,cov_w)';
    trajectory = phi'*w_traj;
    figure(3)
    plot(trajT,trajectory,'r','lineWidth',2);
    pause(0.1)
end