clc;clear;close all;format compact;

%% Load files (specify Ndemos)
trajpath = '../experiments/narrow_passage_box';
addpath(trajpath);
trajname = 'test';  
Ndemos = 20;   
[demoY,Nt, dof, x, mw, Sw] = loadTrajectory(trajpath, trajname, Ndemos, 'Cartesian');


%% Distributions
Nf=size(mw,1)/dof;  % # of basis functions
C=(0:1:Nf-1)/Nf;    % Centers
D=0.025;            % Amplitud

PHI = obtainPhi(Nf,Nt,dof,C,D);

% Get weights
demos = reshape(demoY,Nt*dof,Ndemos);
w = pinv(PHI')*demos;

% Mean
mu_w = mean(w,2);

% Standard deviation
std_w = std(w,0,2);

% Covariance
cov_w = (w-mu_w*ones(1,Ndemos))*(w-mu_w*ones(1,Ndemos))'/Ndemos;

%Mean Trajectory
mu_y = PHI'*mu_w; 
Mean_Traj = reshape(mu_y,Nt,dof);



% Confidence intervals
std_y = reshape(2*real(sqrt(diag(PHI'*cov_w*PHI))),Nt,dof);
u_ci = Mean_Traj + std_y;
l_ci = Mean_Traj - std_y;

% Sample trajectories
Sampled_Traj = sampleTrajectories(5,mu_w,cov_w,PHI,Nt,dof);

%% Via Points
T = round([0.9,0.9,0.9]'*Nt);
Y = [0.40,0.1,-0.22]';
via_point_var = 0.0001*eye(size(Y,2));

for k=1:3
    k=2
    t = T(k);
    y = Y(k);

    mu_w_vp = mu_w + cov_w*PHI(:,t)*inv(via_point_var + PHI(:,t)'*cov_w*PHI(:,t))*(y-PHI(:,t)' * mu_w);
    cov_w_vp = cov_w - cov_w*PHI(:,t)*inv(via_point_var + PHI(:,t)'*cov_w*PHI(:,t)) * PHI(:,t)'*cov_w;

    mu_y_vp = PHI'*mu_w_vp; 
    
    interval = (Nt*(k-1)+1):1:(Nt*k);
    
    mean_vp(:,k) = mu_y_vp(interval');
    std_vp = 2*real(sqrt(diag(PHI'*cov_w_vp*PHI)));
    
    u_ci_vp(:,k) = mu_y_vp(interval')+std_vp(interval');
    l_ci_vp(:,k) = mu_y_vp(interval')-std_vp(interval');
    
    figure(k);hold on
    plot(x',mu_y_vp(interval'),'g','lineWidth',2)
    plot(t/Nt,y,'bX','markerSize',10,'lineWidth',2)
end

%% Plots
figure(1); hold on;
xmin = [0]; xmax = [1];
ymin = [0.2,-0.6,-0.4]; ymax = [0.8,0.6,0];
DOF = {'x[m]','y[m]','z[m]'};

for k=1:3
    figure(k);hold on;grid on;
    plot(x',Mean_Traj(:,k),'r','lineWidth',2)
    plot(x',u_ci(:,k),'r')
    for i=1:Ndemos
        plot(x',demoY(:,k,i),'b','lineWidth',1)
    end
    fill_between_lines(x',u_ci(:,k),l_ci(:,k),[1 0 0],0.2)
    plot(x',l_ci(:,k),'r')
    plot(x',Mean_Traj(:,k),'r','lineWidth',2)
    plot(x',u_ci(:,k),'r')
%     legend('mean','mean VP','CI','CI VP','demos','location','BestOutside');
%     axis([xmin, xmax, ymin(k), ymax(k)]);
    xlabel('time [0-1]');ylabel(DOF(k))
end

for k=1:3
    figure(k+3);hold on;grid on;
    plot(x',Mean_Traj(:,k),'r','lineWidth',2)
    plot(x',mean_vp(:,k),'g','lineWidth',2)
    plot(x',u_ci(:,k),'r')
    plot(x',u_ci_vp(:,k),'g')
    fill_between_lines(x',u_ci(:,k),l_ci(:,k),[1 0 0],0.2)
    fill_between_lines(x',u_ci_vp(:,k),l_ci_vp(:,k),[0 1 0],0.2)
    plot(x',l_ci(:,k),'r')
    plot(x',l_ci_vp(:,k),'g')
    plot(x',Mean_Traj(:,k),'r','lineWidth',2)
    plot(x',mean_vp(:,k),'g','lineWidth',2)
    plot(x',u_ci(:,k),'r')
    plot(x',u_ci_vp(:,k),'g')
%     legend('mean','mean VP','CI','CI VP','demos','location','BestOutside');
%     axis([xmin, xmax, ymin(k), ymax(k)]);
    xlabel('time [0-1]');ylabel(DOF(k))
    plot(T(k)/Nt,Y(k),'bX','markerSize',10,'lineWidth',2)
end

rmpath(trajpath);
