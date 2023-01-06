function [x_new, y_new, angle] = MovementValidationExecution(x, y, angle, speed, allowed, forbidden)
%{
    - compute the new ant position.
    - if the new position is valid, return the new position. else, keep the
    current position, and only change the angle by 180 degrees.
outputs:
    x_new: new x of ant
    y_new: new y of ant
    angle: new angle of ant
inputs:
    x: the x of ant
    y: the y of ant
    angle: ant current angle
    speed: ant speed
    allowed: a matrix of N rows and 4 columns, containing lower left and 
        upper right points of the map %
    forbidden: a matrix of N rows and 4 columns, containing lower left and 
        upper right points of the walls
%}
xt = x + speed* cos(angle);
yt = y + speed* sin(angle);
angle_cur = angle;
%map bounds == allowed; if outside map bounds
if xt < allowed(1) || yt < allowed(2) || xt > allowed(3) || yt > allowed(4)
    angle = angle_cur + pi; % turn around if hit bound
    if angle > 2*pi % over 360 deg
        angle = angle - 2*pi; %
    end
    x_new = x;
    y_new = y;
    return % leave position untouched, just update angle
end
%wall bounds == forbidden; if inside forbidden (walls)
if ~isempty(forbidden)
    for i = 1:length(forbidden) % per pair of coordinates, check if future step is inside wall
        if xt > forbidden(i,1) && xt < forbidden(i,3) && yt > forbidden(i,2) && yt < forbidden(i,4)
            angle = angle_cur + pi;
            if angle > 2*pi % over 360 deg
                angle = angle - 2*pi; %
            end
            x_new = x;
            y_new = y;
            return 
        end
    end
end
% new location is valid, update xy, keep same angle
x_new = xt;
y_new = yt;
angle = angle_cur;
end







