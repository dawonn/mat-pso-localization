function [ laserscan ] = LaserScan_load(file)
%LOAD_LASERSCAN Summary of this function goes here
%   Detailed explanation goes here

    load(file); 
    i=1;        
    laserscan.file      = file;
    laserscan.ranges    = v_Pioneer3AT_laserscan_ranges(i,:);
    laserscan.angle_min = v_Pioneer3AT_laserscan_angle__min(i);
    laserscan.angle_max = v_Pioneer3AT_laserscan_angle__max(i);
    laserscan.angle_inc = v_Pioneer3AT_laserscan_angle__increment(i);
    laserscan.range_min = v_Pioneer3AT_laserscan_range__min(i);
    laserscan.range_max = v_Pioneer3AT_laserscan_range__max(i);
    
    laserscan.translate = @(pose) translate(pose, laserscan);
end

function [x y] = translate(pose, laserscan)
    % Convert laser ranges to map coordinate frame
    angles = laserscan.angle_min:laserscan.angle_inc:laserscan.angle_max;
    x = pose(1) + laserscan.ranges .* cos(angles + pose(3));
    y = pose(2) + laserscan.ranges .* sin(angles + pose(3));
    
    % Remove NaNs
    idx = isfinite(x);
    x = x(idx);
    y = y(idx);   
end