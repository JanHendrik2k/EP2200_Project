% Parameters
K_values = [5, 15, 25];  % Number of mobile users
p_l_values = 0:0.1:1;  % Probability of local execution
lambda_val = 1;  % Task arrival rate (tasks/sec)

K = 10;
F0 = 45e9; % Cloud computational capability (cycles/s)
m = 15; % Number of servers in the cloud
mu_D = 1e-6;
mu_L = 0.5e-9; % Mean task complexity (Cycles/s)
F = 0.6e9; % MU computational capability (cycles/s)
R = 4e6; % Uplink rate (bits/s)


% Preallocate storage for results
T_i_model1 = zeros(length(K_values), length(p_l_values));
T_i_model2 = zeros(length(K_values), length(p_l_values));

% Initialize arrays to store results
N = zeros(length(K_values), length(p_l_values)); % Mean number of tasks (Model 1)
N2 = zeros(length(K_values), length(p_l_values)); % Mean number of tasks (Model 2)
T = zeros(length(K_values), length(p_l_values)); % Mean system time (Model 1)
T2 = zeros(length(K_values), length(p_l_values)); % Mean system time (Model 2)

% Compute mean time for each K and pl
for j = 1:length(K_values)
    K = K_values(j);

    for i = 1:length(p_l_values)
        p_l = p_l_values(i);
        % Compute NMU (Mean number of tasks in MU)
        N_MU = (lambda_val * p_l) / (F * mu_L - lambda_val * p_l);
        
        % Compute a_cloud (Average task number in cloud server)
        lambda_cloud = K * lambda_val * (1 - p_l);
        mu_cloud = (F0 * mu_L) / m;
        a_cloud = lambda_cloud / mu_cloud;
        
        
        % Compute Dm(a_cloud) using Erlang-C formula
        roh = lambda_cloud / (F0 * mu_L); % Traffic intensity
        k = 0:m-1;  % Create an array from 0 to m-1
        summ = sum((a_cloud).^k ./ factorial(k));
        
        Dm_a_cloud = ((a_cloud)^m/(factorial(m)*(1-(a_cloud/m))))/(summ + (((a_cloud)^m / (factorial(m)) / (1 - (a_cloud/m)))));
        
        %library used to test if my own implementation is correct
        %Dm_a_cloud = erlangc(m,a_cloud); 

        Dm_a_cloud_comp = Dm_a_cloud *(lambda_cloud / (m * mu_cloud - lambda_cloud));

        % Compute Nq,cloud (Mean number of tasks in queue)
        Nq_cloud = Dm_a_cloud * (a_cloud / (m - a_cloud));
        
        % Compute Ns,cloud (Mean number of tasks in cloud servers)
        Ns_cloud = a_cloud;
        
        % Compute Ncloud (Mean number of tasks in cloud)
        Ncloud = (Ns_cloud + Nq_cloud)/K;
        
        % Compute total mean number of tasks in the system
        N(j, i) = (N_MU + Ncloud);


        N_TM = (lambda_val * (1 - p_l)) / (R * mu_D - lambda_val * (1 - p_l));
        N2(j, i) = (N(j,i) + (N_TM));
 
        T(j, i) = N(j, i) / lambda_val;
        T2(j, i) = N2(j, i) / lambda_val;

          % Compute mean system time
        if (F * mu_L - lambda_val * p_l) <= 0
            T(j, i) = NaN; % System becomes unstable
            N(j, i) = NaN;
            T2(j, i) = NaN; % System becomes unstable
            N2(j, i) = NaN;
            continue;
        end
           
    fprintf('p_l = %.2f, roh = %.4f, rohMU = %.4f, N = %.4f, T = %.4f\n', p_l, roh, (F * mu_L - lambda_val * p_l) ,N(j, i), T(j, i));

    end
end

% Plot results
figure;
hold on;
colors = ['r', 'g', 'b'];  % Different colors for different K values

for i = 1:length(K_values)
    plot(p_l_values, T(i, :), ['-' colors(i)], 'LineWidth', 2);
    plot(p_l_values, T2(i, :), ['--' colors(i)], 'LineWidth', 2);
end

% Labels and legend
xlabel('Probability of Local Execution (p_l)');
ylabel('T̄_i generated by MU i (in sec)');
title('Mean Task Time vs. Probability of Local Execution');
legend('Model 1, K=5', 'Model 2, K=5', 'Model 1, K=15', 'Model 2, K=15', 'Model 1, K=25', 'Model 2, K=25');
grid on;
hold off;