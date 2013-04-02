
clc;
clear;

% Start up matlab 'workers' if they haven't been already
if matlabpool('size') == 0
   matlabpool
end
 
% Make output directory
output_dir = './output';
if exist(output_dir, 'dir') == 0
    mkdir(output_dir);
end

% Load the map (data from map.yaml)
map.file                = 'data/map.pgm';
map.image               = imread(map.file);
map.resolution          = 0.050000;
map.origin              = [-2.000000, -16.400000, 0.000000];
map.negate              = 0;
map.occupied_thresh     = 0.65;
map.free_thresh         = 0.196;
map                     = map_preprocess(map);

% Load the laser scan data
for datasetnum = 1:9
    laserscan = LaserScan_load(['data/laserscan-' num2str(datasetnum) '.mat']);

    % PSO Search
    tic
        lin = 0.25;
        rot = pi/8;
        [pose fit] = LaserScan_pso(map, laserscan, lin, rot);
    elapsed_time1 = toc
        
    % Matlab non-linear optimization toolbox (Optional)
    tic
    pose = LaserScan_gradiant(map, laserscan, pose);
    elapsed_time2 = toc      
    
    % Plot Final Result
    fig1 = figure(1);
    LaserScan_plot(pose, map, laserscan);
    print(fig1, [output_dir '/laserscan-' num2str(datasetnum) '.png'], '-dpng', '-r150')
    
    % Save for post-mortum debuging
    % save([output_dir '/laserscan-' num2str(datasetnum)])
end

