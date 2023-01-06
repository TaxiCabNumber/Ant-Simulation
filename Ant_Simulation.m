%% cleaning stuff
clc
clear
close all
rng(11); % group 11

%load steps_60_map_1_test.mat
%% Setup
%initially define walls as empty, which will be overridden by map3_EC.mat
walls = [];

% load the map
load map1.mat
%T = 100; %% remove
%colony_pos = [20, 55];

% fixed parameters
spd = 1; % 1 unit travel per timestep

% customizable parameters
delta_b = 0.05; %delete after 20 steps
delta_r = 0.05;
r_smell = 5;
s_phi_1 = 10*pi/180; %search for pheromone
s_phi_2 = 30*pi/180; %no pheromones

% initialize the ants. 
%sol1: per ant, per time step, decay existing pheromones>add n_ants more
%pheromones
ants(n_ants) = struct();
for a = 1:n_ants %position at center of colony
    ants(a).pos = colony_pos;
    ants(a).angle = 2*pi*rand(); % radians, face random direction
    ants(a).food = 0; % if true, ant has food. else set to false
end

% initialize pheromones
% due to ComputeNewAngle not having a field for whether the ant is carrying food,
% that logic must be handled here. So the pheromones passed into CNA must
% be purely blue or red for the ant to respond only to a specific color
% number of pheromones = 
% per ant, generate a new point for each dt
pher_b_pos = zeros(n_ants, 2); % row, col
pher_b_conc = zeros(n_ants, 1); % row, col
pher_b_conc = transpose(pher_b_conc);
for i = 1:n_ants
    pher_b_pos(i,:) = ants(i).pos; % pos is (x, y) 1x2 double
    pher_b_conc(i) = 1;
    %%pher_b(i).color = 'b'; % b for blue, r for red %% not needed
end
pher_r_pos = [];
pher_r_conc = [];

%initialize colony
th = 0:pi/50:2*pi;
xunit = colony_proximity_threshold * cos(th) + colony_pos(1);
yunit = colony_proximity_threshold * sin(th) + colony_pos(2);

%% iterate over timestamps (i.e., for each timestamp...)
% preallocates struct to store each frame
M(T) = struct('cdata', [], 'colormap', []);
fig = figure(1);
fig.Visible = 'off'; % play movie instead
for t = 502:T
    clf()
    % plot colony
    plot(xunit, yunit, 'c');
    hold on    
    % plot walls (black rectangles)
    if ~isempty(walls)
        for w = 1:length(walls)
            rectangle('Position', [walls(w,1), walls(w,2), (walls(w,3)-walls(w,1)), (walls(w,4)-walls(w,2))], 'FaceColor', [0, 0, 0])
        end     
    end
    xlim([map_coordinates(1), map_coordinates(3)]); 
    ylim([map_coordinates(2), map_coordinates(4)]);
    grid on
    axis square 
    % iterate over ants (i.e., for each ant...)
    for a = 1:n_ants
        % compute the new angle
        % how does it know if it's sniffing for blue or red pheromone?
        if ants(a).food == 0
            ants(a).angle = ComputeNewAngle(ants(a).pos(1), ants(a).pos(2), ants(a).angle, pher_r_pos, pher_r_conc, r_smell, s_phi_1, s_phi_2);
        elseif ants(a).food == 1 % carrying food, smell for blue
            ants(a).angle = ComputeNewAngle(ants(a).pos(1), ants(a).pos(2), ants(a).angle, pher_b_pos, pher_b_conc, r_smell, s_phi_1, s_phi_2);
        end 
        % check movement validity and update pos and angle
        [ants(a).pos(1), ants(a).pos(2), ants(a).angle] = MovementValidationExecution(ants(a).pos(1), ants(a).pos(2), ants(a).angle, spd, map_coordinates, walls);
        % if ant is not carrying food, check the food proximity, grab food
        % if it's close by, and update food_sources before next ant
        if ants(a).food == 0 %finds food @ t= 20; indicator_food returns 1 // @ t=21, ant.food = true;
            [food_sources, indicator_food] = CheckFoodProximity(ants(a).pos(1), ants(a).pos(2), food_sources, food_proximity_threshold);
        end
        if (indicator_food == 1 && ants(a).food == 0) % ant picks up food
            ants(a).food = 1; % picks up food @ t = 20
            %disp("food picked up")
        end
        % else, check the colony proximity and drop the food if it's close
        indicator_col = CheckColonyProximity(ants(a).pos(1), ants(a).pos(2), colony_pos, colony_proximity_threshold);
        if (indicator_col == 1 && ants(a).food == 1) % ant drops food
            ants(a).food = 0;
        end
    % end iterate over ants
    end
    % update pheromones by removing zeroes
    if ~isempty(pher_b_pos)
        [pher_b_pos, pher_b_conc] = PheromonesUpdate(pher_b_pos, pher_b_conc, delta_b);
    end
    if ~isempty(pher_r_pos)
        [pher_r_pos, pher_r_conc] = PheromonesUpdate(pher_r_pos, pher_r_conc, delta_r);
    end
    % release new set of pheromones by concatenating new matrices
    pher_b_pos_new = [];
    pher_b_conc_new = [];
    pher_r_pos_new = [];
    pher_r_conc_new = [];
    for a = 1:n_ants
         if ants(a).food == false % drop blue
            pher_b_pos_new = [pher_b_pos_new; ants(a).pos]; % pos is (x, y) 1x2 double
            pher_b_conc_new = [pher_b_conc_new, 1];
        elseif ants(a).food == true % carrying food, smell for blue
            pher_r_pos_new = [pher_r_pos_new; ants(a).pos]; % pos is (x, y) 1x2 double
            pher_r_conc_new = [pher_r_conc_new, 1];
        end 
    end
    pher_b_pos = [pher_b_pos; pher_b_pos_new];
    pher_b_conc = [pher_b_conc, pher_b_conc_new];
    pher_r_pos = [pher_r_pos; pher_r_pos_new];
    pher_r_conc = [pher_r_conc, pher_r_conc_new];    
    % plot ants ("k*")
    hold on
    for a = 1:n_ants 
        plot(ants(a).pos(1), ants(a).pos(2), 'k*')
    end
    % plot pheromones and color intensity ("."), use rgb triplet * conc
    if ~isempty(pher_b_pos)
        for b = 1:length(pher_b_pos(:,1))
            blue = scatter(pher_b_pos(b,1), pher_b_pos(b,2), 'Marker', 'o', 'MarkerEdgeColor', 'b', 'MarkerEdgeAlpha', pher_b_conc(b), 'MarkerFaceColor', 'b', 'MarkerFaceAlpha', pher_b_conc(b));
            blue.SizeData = blue.SizeData/9;
        end
    end
    if ~isempty(pher_r_pos)
        for r = 1:length(pher_r_pos(:,1))
            red = scatter(pher_r_pos(r,1), pher_r_pos(r,2), 'Marker', 'o', 'MarkerEdgeColor', 'r', 'MarkerEdgeAlpha', pher_r_conc(r), 'MarkerFaceColor', 'r', 'MarkerFaceAlpha', pher_r_conc(r));
            red.SizeData = red.SizeData/9;
        end
    end
    % plot food ("mv")
    for f = 1:length(food_sources)
        plot(food_sources(f,1), food_sources(f,2), 'mv')
    end
    hold off
    drawnow
    M(t) = getframe(fig); % entire figure, not just most recent plot
% end iterate over timestamps
end
%}
fig.Visible = 'on';

%% play movie
%fig.Visible = 'on';
fps = 5; % frames per second
movie(gcf, M,1,fps) 