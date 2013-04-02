function LaserScan_plot(pose, map, laserscan)
    
    clf    
    hold on;
    
    % Display map image
    imagesc(map.x_axis, map.y_axis, map.image)
    set(gca,'YDir','normal')
    axis([map.left map.right map.bottom map.top]) 
    axis equal
    
    % Display meter-spaced grid
    set(gca,'XTick', round(map.left):round(map.right))
    set(gca,'YTick', round(map.bottom):round(map.top))
    set(gca, 'layer', 'top');
    grid on;
  
    colormap(bone);
    
    % Display a meter-spaced grid    
    grid on;
    
    % Plot the pose location
    plot( pose(1), pose(2), '.g', 'MarkerSize', 20)
    plot( pose(1), pose(2), 'Og', 'MarkerSize', 40, 'LineWidth', 2)
    line([pose(1)  pose(1) + 0.5 * cos(pose(3))],  ...
         [pose(2)  pose(2) + 0.5 * sin(pose(3))],    ...
         'Color','green',                   ...
         'LineWidth', 2)
     
    % Convert laser ranges to map coordinate frame
    [x y] = laserscan.translate(pose);
    plot(x, y, 'rO')
    
    % Display pose and pose fitness in title
    title(['Pose: [' num2str(pose, '%4.2f ') '] Score: ' num2str(LaserScan_fitness(pose, map, laserscan)) ]); 
end



