function [indicator] = CheckColonyProximity(x, y, colony_pos, colony_proximity_threshold)
%{
CheckColonyProximity returns true/false for whether the colony is close 
enough for an ant to put down the food.

outputs:
    indicator: true (logical 1) if the ant is close the colony, and 
               false (logical 0) if it's not.

inputs:
                             x: the x coordinate of the ant
                             y: the y coordinate of the ant
                    colony_pos: The (x, y) of the colony center (a 1-by-2 
                                array)
    colony_proximity_threshold: The range to determine whether an ant is
                                close to colony enough to put down the food
%}

% Compute the distance from the ant to the colony
distance = sqrt((x-colony_pos(1))^2 + (y-colony_pos(2))^2);
% If the distance is within the proximity threshold
if distance < colony_proximity_threshold
    indicator = 1;
else 
    indicator = 0;
end
%   Return true (logical 1) for the indicator
% Else
%   Return false (logical 0) for the indicator
end