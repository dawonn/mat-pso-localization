%function pose = LaserScan_pso (map, laserscan)
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
    population_size = 200;
    c1   = 2.3;
    c2   = c1;
    w    = 10;
    
    % Inital particle population
    x(:,1) = rand(population_size, 1) * (map.right - map.left) + map.left;
    x(:,2) = rand(population_size, 1) * (map.top - map.bottom) + map.bottom;
    x(:,3) = rand(population_size, 1) * 2*pi;
        
    % Inital velocities 
    v(:,1) = (rand(size(x, 1), 1) - 0.5) * (map.right - map.left);
    v(:,2) = (rand(size(x, 1), 1) - 0.5) * (map.top - map.bottom);
    v(:,3) = (rand(size(x, 1), 1) - 0.5) * 2*pi - 2*pi;
        
    % Initial population fitness
    fitness_current = LaserScan_fitness(x, map, laserscan);
    
    % Track the best pose seen by each particle 
    local_best_fitness = fitness_current;
    local_best_x       = x;
    
    % Track the best fitness seen by the swarm
    [global_fitness, idx] = max(local_best_fitness);
    global_best = x(idx,:);
    
    % PSO Loop  
    i = 1;
    
    % Loop untill no better estimate is found in # ittereations
    stuck = 0;
    global_best_prev = 0;
    while stuck < 15        
        if global_best ~= global_best_prev
            global_best_prev = global_best;
            stuck = 0;
        else
            stuck = stuck + 1;
        end
        
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
                            + x(:,1)             .*     fitness_better ;
        local_best_x(:,3)   = local_best_x(:,3)  .* not(fitness_better) ...
                            + x(:,1)             .*     fitness_better ;

        % Locate the global best estimate
        [global_fitness, idx] = max(local_best_fitness);
        global_best = local_best_x(idx,:);
            
        % Update Velocities
        d_local  = local_best_x - x;
        d_global = bsxfun(@minus, global_best, x);
                
        w = w * 0.99;
        
        v = w * v + c1 * rand() * d_local + c2 * rand() * d_global;
        
        phi = c1 + c2;
        k = 2 / (1 - phi - sqrt(phi^2 - 4*phi));
        v = k * v;
        
        % Apply bounds
        v_max = 0.1;
        v(:,1) = min(v(:,1),  (map.right - map.left  ) * v_max);
        v(:,1) = max(v(:,1), -(map.right - map.left  ) * v_max);
        v(:,2) = min(v(:,2),  (map.top   - map.bottom) * v_max);
        v(:,2) = max(v(:,2), -(map.top   - map.bottom) * v_max);
        v(:,3) = min(v(:,3),  pi * v_max);
        v(:,3) = max(v(:,3), -pi * v_max);
         
        
%         % Plot Progress  
%         figure(1)
%         clf
%         scatter3(x(:,1), x(:,2), x(:,3));
%         hold on;
%         scatter3(8.0992, -0.6412, 1.5746, '*g');
%         
%         title(['Pose: ' num2str(global_best)]);
%         axis([map.left map.right map.bottom map.top 0 2*pi]);
%         anime(i) = getframe();
%         i = i + 1;
               
        %waitforbuttonpress
    end
        
    % Return the best pose estimate
    pose = global_best;

    %movie(anime, 1, 30)
%end

