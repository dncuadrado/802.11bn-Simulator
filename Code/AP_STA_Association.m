function association = AP_STA_Association(AP_number, STA_number, scenario_type)
% % Association process. STAs are associated independently of the distance to their corresponding AP.
% Returns a cell array with the list of STAs by AP

switch scenario_type
    case 'grid'
        STAs_per_AP = STA_number/AP_number;
        association = cell(AP_number,1);

        for i = 1:AP_number
            association{i} = (((i-1)*STAs_per_AP+1):(STAs_per_AP*i))';
        end
end




end