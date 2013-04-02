
function [pose fit] = LaserScan_search (map, laserscan, search_resolution_lin, search_resolution_rot, roi)
% LaserScan_search - Use a brute force search to find the best pose estimate
% INPUTS:
%   map                   (struct): Pre-processed map data
%   laserscan             (struct): Laserscan data from bag file
%   search_resolution_lin (double): Linear space resolution      [meters]
%   search_resolution_lin (double): Rotational space resolution  [radians]
%   roi                   (strcut): Contrain seach space
%
% OUTPUTS:
%   pose      (vector): [x y r] representing the estimated location and 
%                       rotation of laser scanner in the map coordinate
%                       frame. 
%   fitness   (double): Fitness of the resulting pose

    % Input parameter defaults
    if nargin < 3
        search_resolution_lin = 0.01;
    else
        if map.resolution > search_resolution_lin
            fprintf('Map resolution limit: %6.3f \n', map.resolution)
            search_resolution_lin = map.resolution;
        end
    end
    if nargin < 4
        search_resolution_rot = pi/180;
    else
        search_resolution_rot = abs(search_resolution_rot);
    end
    if nargin < 5
        roi.left   = map.left; 
        roi.right  = map.right; 
        roi.top    = map.top; 
        roi.bottom = map.bottom; 
        roi.minrot = 0;
        roi.maxrot = 2*pi;
    end
    
    % Pose estimate search space
    x_axis = roi.left   : search_resolution_lin : roi.right;
    y_axis = roi.bottom : search_resolution_lin : roi.top;
    r_axis = roi.minrot : search_resolution_rot : roi.maxrot;
    
    % Search loop
    fit = zeros(length(x_axis), length(y_axis), length(r_axis));
    for ix = 1:size(fit,1);    
        for iy = 1:size(fit,2)       
            for ir = 1:size(fit,3)     
            	fit(ix, iy, ir) = LaserScan_fitness([x_axis(ix) y_axis(iy) r_axis(ir)], map, laserscan);
            end
        end     
        fprintf('%5.2f%% \n', ix * 100 / size(fit,1)) % Progress indicator 
    end
       
    % Find best result
    [~, idx] = max(fit(:));
    [ix, iy, ir] = ind2sub(size(fit), idx);
    pose = [x_axis(ix) y_axis(iy) r_axis(ir)];
end

