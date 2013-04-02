function [ map ] = map_preprocess( map )

    % Translate pixels to meters (anonomous functions)
    map.x_from_pixel = @(x)   x * map.resolution  + map.origin(1);
    map.y_from_pixel = @(y) -(y * map.resolution  + map.origin(2));
    
    % Translate meters to pixels (anonomous functions)
    map.pixel_from_x = @(x) ( x - map.origin(1)) / map.resolution;
    map.pixel_from_y = @(y) (-y - map.origin(2)) / map.resolution;

    map.x_axis = map.x_from_pixel(1:size(map.image, 2)); % Yes it's correct...
    map.y_axis = map.y_from_pixel(1:size(map.image, 1)); % Yes it's correct...
    
    % Binarize the Image
    map.bin  = map.image < 128;
   
    % Find the Region Of Interest
    map = find_roi(map);    
    
    % Calculate the chamfer distance
    map.dist = bwdist(map.bin) * map.resolution;
end


function map = find_roi(map)
% Find the map in the image
    for i = 1:size(map.bin,1)
        if ~isempty(find(map.bin(i,:), 1))
            map.top = map.y_from_pixel(i - 1);
            break
        end
    end
    for i = size(map.bin,1):-1:map.top
        if ~isempty(find(map.bin(i,:), 1))
            map.bottom = map.y_from_pixel(i + 1);
            break
        end
    end
    for i = 1:size(map.bin,2)
        if ~isempty(find(map.bin(:,i), 1))
            map.left = map.x_from_pixel(i - 1);
            break
        end
    end
    for i = size(map.bin,2):-1:map.left
        if ~isempty(find(map.bin(:,i), 1))
            map.right = map.x_from_pixel(i + 1);
            break
        end
    end
end