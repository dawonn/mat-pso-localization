clf;
clc;
clear;

% Variables initialization
init_pop = 200; % Number of initial population
map_resolution = 0.050000; % Map resolution
count = 0;
distance = 0;

% Read the map
figure(1)
hold on;
map = imread('map.pgm');
map_new = map(1900:2100, 1900:2300);

% Convert the grayscale map to binary
map_b = map_new > 210;
imshow(map_new)

% Initializing population
dimension = size(map_b);

for i=1:init_pop
    % Check to see if generated point is inside the room area
    while count==0
        y(i) = randi (dimension(1));
        x(i) = randi (dimension(2));
        if map_b(y(i),x(i)) == 1
            count = 1;
        end    
    end
    count = 0;
end
for i=1:init_pop
    teta(i) = 2*pi*rand(1);
end
hold on
for i=1:init_pop
    plot(x(i),y(i),'+b')
end

% Pose Estimate
pose = [floor(dimension(1)/2) floor(dimension(2)/2) 0]; % Initial position of robot
plot(pose(2),pose(1),'*r')

% Load the laser scan data
load('matlab-laser.mat');

i=1;

laserscan = v_pioneer3at_laser__scan_ranges(i,:);
angle_min = v_pioneer3at_laser__scan_angle__min(i);
angle_max = v_pioneer3at_laser__scan_angle__max(i); 
angle_inc = v_pioneer3at_laser__scan_angle__increment(i);

angles = angle_max:-angle_inc:angle_min;

% Convert to cartesian coords
laserscan_x = round((laserscan/map_resolution) .* cos(angles - pose(3)));
laserscan_y = round((laserscan/map_resolution) .* sin(angles - pose(3)));

laserscan_x = laserscan_x + pose(1);
laserscan_y = laserscan_y + pose(2);

% Remove NaNs
laserscan_x = laserscan_x(isfinite(laserscan_x));
laserscan_y = laserscan_y(isfinite(laserscan_y));

scatter(laserscan_x, laserscan_y, '*g');
scan_numbers = size(laserscan_x);

for i=1:init_pop
    p_laserscan_x = laserscan_x + x(i);
    p_laserscan_y = laserscan_y + y(i);
    for j=1:scan_numbers(2)
    % map_new(p_laserscan_x(j),p_laserscan_y(j)) - Just for me to remember
    % The position of x and y axis ??????
    p_laserscan_x(j) = round(p_laserscan_y(j)*cos(teta(i))+p_laserscan_x(j)*sin(teta(i)));
    p_laserscan_y(j) = round(-p_laserscan_y(j)*sin(teta(i))+p_laserscan_x(j)*cos(teta(i)));
    [k l] = find(map_new==0);
    [offsetx offsetidxx]= min(abs(p_laserscan_x(j)-k));
    offsety = abs(p_laserscan_y(j)-l(offsetidxx));
    distance1 = offsetx+offsety;
    [offsety offsetidxy]= min(abs(p_laserscan_y(j)-l));
    offsetx = abs(p_laserscan_x(j)-k(offsetidxy));
    distance2 = offsetx+offsety;
    distance3 = min(distance1,distance2);
    distance = distance+distance3;
    end
    fitness(i) = distance;
    distance = 0;
end
fitness
for i=1:init_pop
   % v(i) = w
end