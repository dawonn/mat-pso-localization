
function pose = LaserScan_gradiant (map, laserscan, pose)
% LaserScan_search - Use gradiant accent to find the best pose estimate
% INPUTS:
%   map       (struct): Pre-processed map data
%   laserscan (struct): Laserscan data from bag file
%   pose      (vector): Pose to start from
%
% OUTPUTS:
%   pose      (vector): [x y r] representing the estimated location and 
%                       rotation of laser scanner in the map coordinate
%                       frame. 
%   fitness   (double): Fitness of the resulting pose

   
   f = @(x) fun([x(1), x(2), x(3)], map, laserscan);
         
   pose = fminsearch(f, pose);
   
end

function score = fun(x, map, laserscan)

    score = 1 - LaserScan_fitness(x, map, laserscan);

end
