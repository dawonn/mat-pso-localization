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
    population_size = 500;
    
    % Init
    figure(1);
    clf
    clc
    
    % Inital particle population 
    x = rand(population_size,3);
    x(:,1) = x(:,1) * (map.right - map.left) + map.left;
    x(:,2) = x(:,2) * (map.top - map.bottom) + map.bottom;
    x(:,3) = x(:,3) * 2*pi;
        
    % Inital velocities 
    v(:,1) = (rand(size(x, 1), 1) - 0.5) * (map.right - map.left);
    v(:,2) = (rand(size(x, 1), 1) - 0.5) * (map.top - map.bottom);
    v(:,3) = (rand(size(x, 1), 1) - 0.5) * 2*pi - 2*pi;
        
    % Initial population fitness
    fitness_current = LaserScan_fitness(x, map, laserscan);
    [global_fitness, idx] = max(fitness_current);
    global_best = x(idx,:);
    
    % Animation    
    figure(1);
    set(gca,'NextPlot','replaceChildren');
	
    
    % PSO Loop  
    i = 1;
    while abs(min(v(:))) > 0.01;
        min_v = abs(min(v(:)))
        
        % Update partcles
        x_previous = x;
        x = x + v;
        
        % Apply bounds
%         x(:,1) = min(x(:,1), map.right);
%         x(:,1) = max(x(:,1), map.left);
%         x(:,2) = min(x(:,2), map.top);
%         x(:,2) = max(x(:,2), map.bottom);
         x(:,3) = mod(x(:,3) + 2*pi, 4*pi) - 2*pi;


        % Update particle fitness
        fitness_previous = fitness_current;
        fitness_current  = LaserScan_fitness(x, map, laserscan);

        % Find the local best for each particle
        fitness_better = fitness_previous < fitness_current;
        local_best = vertcat( x_previous(not(fitness_better),:), x(fitness_better,:));

        % Find and save the global best
        [val, idx] = max(fitness_current);
        if val > global_fitness 
            global_fitness = val;
            global_best = x(idx,:);
        end

        c1   = 1.3;
        c2   = 1.3;
        w    = 0.9;
            
        % Update Velocities
        d_local  = local_best - x;
        d_global = bsxfun(@minus, global_best, x);
        
        d_local(:,3)  = mod(abs(d_local (:,3) + pi), 2*pi) - pi;
        d_global(:,3) = mod(abs(d_global(:,3) + pi), 2*pi) - pi;
        
        k = exp(-i/1000);
        
        v = k * w * v + k * c1 * rand() * d_local + c2 * rand() * d_global;
        
        
        % Apply bounds
         v_max = 0.01;
         v(:,1) = min(v(:,1),  (map.right - map.left  ) * v_max);
         v(:,1) = max(v(:,1), -(map.right - map.left  ) * v_max);
         v(:,2) = min(v(:,2),  (map.top   - map.bottom) * v_max);
         v(:,2) = max(v(:,2), -(map.top   - map.bottom) * v_max);
         v(:,3) = min(v(:,3),  pi * v_max);
         v(:,3) = max(v(:,3), -pi * v_max);
         
        
        % Plot Progress  
        figure(1)
        clf
        scatter3(x(:,1), x(:,2), x(:,3));
        hold on;
        scatter3(8.0992, -0.6412, 1.5746, '*g');
        
        title(['Pose: ' num2str(global_best)]);
        axis([map.left map.right map.bottom map.top]);
        anime(i) = getframe();
        i = i + 1;
        %hold off;
               
        %waitforbuttonpress
    end
        
    % Return the best pose estimate
    pose = global_best;

    movie(anime, 10)
%end

