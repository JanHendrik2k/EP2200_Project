% Stability Region for Cloud-Offloading Model 1
clc; clear; close all;

K = 10;
F0 = 45e9; % Cloud computational capability (cycles/s)
m = 15; % Number of servers in the cloud
muD = 1e-6;
muL = 0.5e-9; % Mean task complexity (Cycles/s)
F = 0.6e9; % MU computational capability (cycles/s)
R = 4e6; % Uplink rate (bits/s)


% Probability of local computation (pl) from 0 to 1 with step 0.1
pl_vals = 0.0:0.1:1;
pl2_vals = pl_vals;

%pl2_vals(pl_vals == 0) = 0.01; % Replace values where pl_vals == 0
%pl2_vals(pl_vals == 1) = 0.99; % Replace values where pl_vals == 1

% Stability Conditions
lambda_max_MU = (1/K)*((F * muL) ./ (pl2_vals));  % Execution node at MU
lambda_max_Cloud = (1/K)*((muL * F0 ) ./ ((1 - pl2_vals)));  % Execution node at Cloud
lambda_max_AP = (1/K)*((R * muD) ./ (1 - pl2_vals)); % at ap
lambda_for_2 = (1/K)*((muL * F0 + R * muD) ./ ((1 - pl2_vals)));

lambda_max_system = 1./(K*(pl2_vals*((1)/(F * muL))+(1-pl2_vals)*(1/(F0*muL))));
lambda_max_system2 = 1./(K*(pl2_vals*((1)/(F * muL))+(1-pl2_vals)*(1/(F0*muL)+1/(R*muD))));

fprintf('p_l = %.2f, lambdaMU = %.4f, lambdaCloud = %.4f, lambdaAP = %.4f\n', pl_vals, lambda_max_MU, lambda_max_Cloud, lambda_max_AP);

% Plot
figure;
hold on;
plot(pl_vals, lambda_max_MU, 'r', 'LineWidth', 1.5, 'DisplayName', 'MU Execution Node');
plot(pl_vals, lambda_max_AP, 'b', 'LineWidth', 1.5, 'DisplayName', 'Transition Execution Node');
plot(pl_vals, lambda_max_Cloud, 'g', 'LineWidth', 1.5, 'DisplayName', 'Cloud Execution Node');
hold off;

% Formatting
xlabel('Probability of Local Computation (pl)');
ylabel('Maximum Task Arrival Rate (\lambda_{max}) [tasks/s]');
title('Stability Region for Cloud-Offloading');
legend('Location', 'best');
grid on;

% Plot
figure;
hold on;
plot(pl_vals, lambda_max_system, 'g', 'LineWidth', 1.5, 'DisplayName', 'Execution Node Model 1');
plot(pl_vals, lambda_max_system2, 'b', 'LineWidth', 1.5, 'DisplayName', 'Execution Node Model 2');

hold off;

% Formatting
xlabel('Probability of Local Computation (pl)');
ylabel('Maximum Task Arrival Rate (\lambda_{max}) [tasks/s]');
title('Stability Region for entire system');
legend('Location', 'best');
grid on;