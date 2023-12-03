%number of consensus protocol messages exchanged by the nodes in the network
m = 50;

% Initialisation
F = cell(nRobots, 1);
a = cell(nRobots, 1);

for i = 1:nRobots
    if robots(i).init_flag == true && robots(i).steps_in_range > 5
        zi = robots(i).best_tag_estimation;
        Hi = robots(i).J_h;
        j = robots(i).instance_selected;
        F{i} = Hi'*inv(Hi*MHEKFs(i,j).P*Hi')*Hi;
        a{i} = Hi'*inv(Hi*MHEKFs(i,j).P*Hi')*zi;
    else
        zi = 0;
        Hi = 0;
        F{i} = 0;
        a{i} = 0;
    end
end

for k = 1:m

    % Topology matrix: 1 if there is a link between the nodes when the robots are inside the communication range (tag_vector is true), 0 otherwise
    for i = 1:nRobots
        for j = 1:nRobots
            if i ~= j
                if tag_flag_vector(i) == true && tag_flag_vector(j) == true
                    A(i, j) = 1;
                else
                    A(i, j) = 0;
                end
            else
                A(i, j) = 0;
            end
        end
    end

    % Degree vector
    D = A * ones(nRobots, 1);

    % Maximum Degree Weighting
    FStore = F;
    aStore = a;
    for i = 1:nRobots
        for j = 1:nRobots
            if A(i, j) == 1
                F{i} = F{i} + 1/(1+max(D)).*(FStore{j} - FStore{i});
                a{i} = a{i} + 1/(1+max(D)).*(aStore{j} - aStore{i});
            end
        end
    end

end

% Final estimation
for i = 1:nRobots
    if robots(i).init_flag == true && robots(i).steps_in_range > 5
        x_est_distr = inv(F{i})*a{i}; %REVIEW: is this correct? NOPE
        % fare i conti per calcolare best tag estimation
        
        robots(i).tag_estimation_history = [robots(i).tag_estimation_history; robots(i).best_tag_estimation];

    end
end


