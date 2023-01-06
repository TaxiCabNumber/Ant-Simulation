function [pheromone, concentration] = PheromonesUpdate(pheromone, concentration, decay)
%{
   - reduce all concentrations by decay, and only keep the pheromones with
   - positive concentration.
outputs:
    pheromone: list of all modified pheromones
    concentration: list of all new pheromone concentrations
inputs:
    pheromone: list of all pheromones
    concentration: list of all pheromone concentrations
    decay: the concentration decay value
%}
% independent of ants
pher_out = [];
conc_out = [];
for i=1:length(pheromone(:,1))
    concentration(i) = concentration(i) - decay; %
    if concentration(i) > 0
        pher_out = [pher_out; pheromone(i,:)]; %nth row used, all columns % modify to accept structs
        conc_out = [conc_out, concentration(i)];
    end
end
% remove all expired pheromones positions
pheromone = pher_out;
% update corresponding concentration of surviving pheromones
concentration = conc_out;
end