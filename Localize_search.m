
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

    % Low resolution search
    tic
        lin = 0.25;
        rot = pi/8;
        [pose fit] = LaserScan_search(map, laserscan, lin, rot);
    elapsed_time1 = toc
        
    % Plot fitness function (debug)
    fig2 = figure(2);
    clf
    [~, idx] = max(fit(:));
    [ix, iy, ir] = ind2sub(size(fit), idx);
    %mesh(fit(:, :, ir))
    for i = 1:size(fit,3)
        contour(fit(:,:,i));
        hold on
    end
    contour(fit(:,:,ir));
    axis xy
    print(fig2, [output_dir '/laserscan-' num2str(datasetnum) '-fit1.png'], '-dpng', '-r200')

    % Matlab non-linear optimization toolbox
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

