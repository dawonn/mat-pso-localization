function score = LaserScan_fitness(pose, map, laserscan)

    score = zeros(size(pose,1),1);
    
    for i = 1:size(pose,1)       
        % Convert laser ranges to map coordinate frame
        [x y] = laserscan.translate(pose(i,:));

        % Find any 'hits' outside the map
        idx = (x > map.left & x < map.right) & (y > map.bottom & y < map.top);

        % Find the pixel at each laser hit
        q_x = round(map.pixel_from_x(x));
        q_y = round(map.pixel_from_y(y));

        % Gather the distances from each hit to the nearest object
        map_ind = sub2ind(size(map.dist), q_y(idx), q_x(idx) );
        z = map.dist(map_ind);

        % Score the Result
        a = sum(z);
        % b = sqrt((map.right - map.left)^2 + (map.top - map. bottom)^2);    
        % c = length(z);
        % d = length(laserscan.ranges);
        e = length(idx(not(idx)));
        
        score(i) = 1 / (a + e);
    end
end