function pose = LaserScan_pso (map, laserscan)
% LaserScan_search - Use a brute force search to find the best pose estimate
% INPUTS:
%   map                   (struct): Pre-processed map data
%   laserscan             (struct): Laserscan data from bag file
%   
% OUTPUTS:
%   pose      (vector): [x y r] representing the estimated location and 
%                       rotation of laser scanner in the map coordinate
%                       frame. 
    
    % Parameters
    population_size = 300;
    v_max = 0.1;
    c1    = 0.2;
    c2    = 0.1;
    w     = 1.5;
    
    % Inital particle population
    clear x
    x(:,1) = rand(population_size, 1) * (map.right - map.left) + map.left;
    x(:,2) = rand(population_size, 1) * (map.top - map.bottom) + map.bottom;
    x(:,3) = rand(population_size, 1) * 2*pi;
    
    % Inital velocities 
    clear v
    v(:,1) = v_max * (rand(size(x, 1), 1) - 0.5) * (map.right - map.left);
    v(:,2) = v_max * (rand(size(x, 1), 1) - 0.5) * (map.top - map.bottom);
    v(:,3) = v_max * (rand(size(x, 1), 1) - 0.5) * 2*pi;

    % Initial population fitness
    fitness_current = LaserScan_fitness(x, map, laserscan);
    
    % Track the best pose seen by each particle 
    local_best_fitness = fitness_current;
    local_best_x       = x;
    
    % Track the best fitness seen by the swarm
    [~, idx] = max(local_best_fitness);
    global_best = x(idx,:);
    
    
    % Loop until no better estimate is found in # ittereations
    stuck = 0;
    global_best_prev = 0;
    while stuck < 25        
        if global_best ~= global_best_prev
            global_best_prev = global_best;
            stuck = 0;
        else
            stuck = stuck + 1;
        end
        
        % Apply bounds
        v(:,1) = min(v(:,1),  (map.right - map.left  ) * v_max);
        v(:,1) = max(v(:,1), -(map.right - map.left  ) * v_max);
        v(:,2) = min(v(:,2),  (map.top   - map.bottom) * v_max);
        v(:,2) = max(v(:,2), -(map.top   - map.bottom) * v_max);
        v(:,3) = min(v(:,3),  pi * v_max);
        v(:,3) = max(v(:,3), -pi * v_max);

        % Update partcles
        x = x + v;

        % Keep rotations between 0 and 2*pi
        x(:,3) = mod(x(:,3), 2*pi);

        % Update particle fitness
        fitness_current  = LaserScan_fitness(x, map, laserscan);

        % Update the local best estimate for each particle
        fitness_better      = fitness_current > local_best_fitness;
        local_best_fitness  = local_best_fitness .* not(fitness_better) ...
                            + fitness_current    .*     fitness_better ;
        local_best_x(:,1)   = local_best_x(:,1)  .* not(fitness_better) ...
                            + x(:,1)             .*     fitness_better ;
        local_best_x(:,2)   = local_best_x(:,2)  .* not(fitness_better) ...
                            + x(:,2)             .*     fitness_better ;
        local_best_x(:,3)   = local_best_x(:,3)  .* not(fitness_better) ...
                            + x(:,3)             .*     fitness_better ;
              
        % Locate the global best estimate
        [~, idx] = max(local_best_fitness);
        global_best = local_best_x(idx,:);

        % Update Velocities
        w = w * 0.99;
        d_local  = local_best_x - x;
        d_global = bsxfun(@minus, global_best, x); 
        v = w * v + c1 * rand(size(v,1),3) .* d_local ...
                  + c2 * rand(size(v,1),3) .* d_global;
    end
        
    % Return the best pose estimate
    pose = global_best;

end

