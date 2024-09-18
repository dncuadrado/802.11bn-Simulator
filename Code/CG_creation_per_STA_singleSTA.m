function CGs_STAs = CG_creation_per_STA_singleSTA(AP_number, STA_number, association)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Creating a 2D matrix with all posible single AP-STA pair per group 
    CGs_STAs = zeros(STA_number,AP_number);

    for k = 1:AP_number
        CGs_STAs([association{k}],k) = [association{k}];
    end



end