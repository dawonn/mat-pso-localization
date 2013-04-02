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
    population_size = 500;
    
    % Inital population 
    population = rand(population_size,3);
    population(:,1) = population(:,1) * (map.right - map.left) + map.left;
    population(:,2) = population(:,2) * (map.top - map.bottom) + map.bottom;
    population(:,3) = population(:,3) * 2*pi;
    
    % Population fitness
    fitness = LaserScan_fitness(population, map, laserscan);
    
    %
    % PSO GOES HERE
    %
    
    % Select the best pose estimate
    [v, i] = max(fitness);
    pose = population(i,:);
end

