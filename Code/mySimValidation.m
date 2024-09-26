function mySimValidation(AP_number, STA_number, grid_value, sim)

if ~(strcmp(sim, '20metros-8STAs') || strcmp(sim, '20metros-16STAs') || strcmp(sim, '30metros-16STAs'))
    error('Simulation is not in the list of allowed ones')
end

if AP_number~=4
    error('AP_number must be equal to 4')
end

switch sim
    case '20metros-8STAs'
        if STA_number ~= 8 
            error('STA_number must be equal 8');
        elseif grid_value ~= 40
            error('grid_value must be equal 40');
        end
    case '20metros-16STAs'
        if STA_number ~= 16 
            error('STA_number must be equal 16');
        elseif grid_value ~= 40
            error('grid_value must be equal 40');
        end
    case '30metros-16STAs'
        if STA_number ~= 16 
            error('STA_number must be equal 8');
        elseif grid_value ~= 60
            error('grid_value must be equal 40');
        end
end
