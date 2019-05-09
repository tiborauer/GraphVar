function [BL_FU2_overlap_percent, FU2_BL_overlap_percent] = Compare_communities(partition_BL, partition_FU2)

amount_BL = length(unique(partition_BL));
amount_FU2 = length(unique(partition_FU2));

for c = 1:amount_BL
    current_module = partition_BL == c;
    BL_idx{:,c} = find(current_module == 1);
end

for c = 1:amount_FU2
    current_module = partition_FU2 == c;
    FU2_idx{:,c} = find(current_module == 1);
end

for bl = 1:size(BL_idx,2)
    mod = BL_idx{1,bl};
    
    for fu = 1:size(FU2_idx,2)
        mod2 = FU2_idx{1,fu};
        
        overlap = intersect(mod,mod2);
        BL_FU2_nodes_overlap{bl,fu} = overlap;
        BL_FU2_overlap_percent(bl,fu) = length(overlap)/length(mod);
    end
end

for bl = 1:size(FU2_idx,2)
    mod = FU2_idx{1,bl};
    
    for fu = 1:size(BL_idx,2)
        mod2 = BL_idx{1,fu};
        
        overlap = intersect(mod,mod2);
        FU2_BL_nodes_overlap{fu,bl} = overlap;
        FU2_BL_overlap_percent(fu,bl) = length(overlap)/length(mod);
    end
end



for bl = 1:size(BL_idx,2)
    
    for fu = 1:size(FU2_idx,2)
        
        mod1 = intersect(BL_idx{1,bl}, FU2_idx{1,fu}); %die Nodes, die in beiden sind (AND)
        mod2 = [BL_idx{1,bl}; FU2_idx{1,fu}];
        mod2 = unique(mod2); %hier nun alle Nodes, die in einem der beiden sind (OR)
        
        overlap = intersect(mod1,mod2);
        Together_nodes_overlap{bl,fu} = overlap;
        Together_overlap_percent(bl,fu) = length(overlap)/length(mod2);
    end
end

% recoded_affiliation_FU2 = zeros (length(partition_FU2),1);

% for t = 1:size(Together_overlap_percent,2)
%     max_table = max(Together_overlap_percent(:,t));
%     [row, column] = find(Together_overlap_percent == max_table);
% 
%     
%     recoded_affiliation_FU2(FU2_idx{1,t}) = row;
%     
%     
% end

end
