function [food_sources, indicator] = CheckFoodProximity(x, y, food_sources, food_proximity_threshold)
%{

functionality:
    compute the distance between the ant location and all food sources.
    find the nearest food source.
    if the distance is less than a threshold, remove that source from the
    foods list, and return 1. else, return 0.

outputs:
    food_sources: the (probably) modified list of food sources.
    indicator: 1, if the ant is near a food source, and 0 else.

inputs:
    x: the x of ant
    y: the y of ant
    food_sources: the list of food sources
    food_proximity_threshold: the threshold to determine proximity

%}

% your code here...
%{
new_fs = zeros(length(food_sources)-1,2);
distances = sqrt((x - food_sources(1,:)).^2 + (y - food_sources(2,:)).^2);
[min_value, min_index] = min(distances);
if min_value  < food_proximity_threshold
    indicator = 1;
    for i = 1:length(food_sources)
        % skip recording that entry from food as ant takes it up
        if i ~= min_index
            new_fs = [new_fs; food_sources(i,:)]; %retain food source as new row
        end
    end
    food_sources = new_fs;
else
        indicator = 0; %retain food source as new row
        food_sources = food_sources;
end
%}
new_fs = [];
indicator = 0; % by default it is not near food
for j = 1:length(food_sources)  
    if sqrt((x - food_sources(j,1)).^2 + (y - food_sources(j,2)).^2) < food_proximity_threshold
        indicator = 1;
        % skip recording that entry from food as ant takes it up
    else
        new_fs = [new_fs; food_sources(j,:)]; %retain food source as new row
    end
end
food_sources = new_fs;

end