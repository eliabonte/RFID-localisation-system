phase_measured = robot(i).phaseMeasured(tag_position, lambda , sigma_phi);
% phase_history(k,1) = phase_measured; #TODO: check if this part is used somewhere different from euristic weighing algorithm

% Prediction and Correction EKF
for l = 1:nM
    MHEKFs(i,l).EKF_predict(odometry_estimation, d);
    MHEKFs(i,l).EKF_correct(K, sigma_phi, phase_measured);
end


for l = 1:nM
    weights_vec(l) = MHEKFs(i,l).weight;
end

for l = 1:nM
    MHEKFs(i,l).weight = MHEKFs(i,l).weight/sum(robots(i).weights_vec);
end

for l = 1:nM
    robots(i).weights_vec(l) = MHEKFs(i,l).weight;
end

%weights_sum(k) = sum(weights_vec); %vector used to check if the weights' sum is always zero at every step
%weights_history(:,k) = weights_vec;

% Correction of non-positive range estimation and range estimation too low
for l = 1:nM
    if MHEKFs(i,l).x(1) < 10^-6
        number_states = length( MHEKFs(i,l).state_history);
        MHEKFs(i,l).x(1) = max([abs(MHEKFs(i,l).state_history(max(1,number_states-5),1)),10^-6]); % I choose the range of 5 steps before
        MHEKFs(i,l).x(2) = MHEKFs(i,l).state_history(max(1,number_states-5),2) + pi;
    end
    MHEKFs(i,l).x(2) = atan2(sin(MHEKFs(i,l).x(2)),cos(MHEKFs(i,l).x(2)));
end


% saving the state
for l = 1:nM
    MHEKFs(i,l).state_history = [MHEKFs(i,l).state_history; MHEKFs(i,l).x];
end

% Weighing Step
[max_value,instance_selected] = max(robots(i).weights_vec);

rho_est = MHEKFs(i, robots(i).instance_selected).x(1);
beta_est = MHEKFs(i, robots(i).instance_selected).x(2);

%best_state_estimate = [rho_est,beta_est];

robots(i).best_tag_estimation(1) = robots(i).x_est(1) + rho_est*cos(robots(i).x_est(3) - beta_est);
robots(i).best_tag_estimation(2) = robots(i).x_est(2) + rho_est*sin(robots(i).x_est(3) - beta_est);

robots(i).tag_estimation_history = [tag_estimation_history; robots(i).best_tag_estimation(1), robots(i).best_tag_estimation(2)];
