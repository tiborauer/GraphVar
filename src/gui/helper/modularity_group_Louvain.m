function resGroup = modularity_group_Louvain(Ci, result_path, threshold, type, doRandom, nRandom, randomFunction, groups_label, subj_agree)   
   agree = agreement(Ci);
   agree = agree ./ length(Ci);
   tau = 0;
   reps = 1000;
   [C, Q] = consensus_adapted_louvain(agree, tau, reps);
   Z = module_degree_zscore(agree, C);
   [Hpos, Hneg] = diversity_coef_sign(agree, C);
   
   resultslist = {Q, Z, agree, C, Hneg, Hpos};
   namelist = {'Q', 'Z-Score', 'Agreement_Matrix', 'Affiliation', 'Diversity_Neg', 'Diversity_Pos'};
   
   if doRandom > 0
       if ~strcmp(randomFunction, 'null_model_und_sign')
           uiwait(msgbox('Random Networks (agreement matrix) for group modularity measures are always created using "null_model_und_sign"! ','Randomization','modal'));
       end
       C_iter = cell(nRandom, 1);
       Q_iter = cell(nRandom, 1);
       subj_agree = subj_agree.Result_2;
       parfor i = 1:nRandom
           rand_iter = cell(numel(subj_agree), 1);
           for j = 1:numel(subj_agree)
               rand_iter{j} = c_null_model_und_sign(subj_agree{j}, 5);
           end
           sum_iter = sum(cat(3,rand_iter{:}),3)./length(Ci);
           [C_iter{i}, Q_iter{i}] = consensus_adapted_louvain(sum_iter, tau, reps);
           
       end
       Q_distr = cell2mat(Q_iter);
       Q_distr = sort(Q_distr);
       P = find(Q_distr<=Q);
       P = length(P)/nRandom;
       
              
       resultslist{length(resultslist)+1} = P;
       namelist{length(namelist)+1} = 'P_value';
       resultslist{length(resultslist)+1} = Q_distr;
       namelist{length(namelist)+1} = 'random_Q_distribution';
       try
       save([result_path filesep 'GraphVars' filesep groups_label '_consensus_Louvain_perm_C_' num2str(threshold*10) '_' num2str(type) '.mat'], 'C_iter', '-v7.3');
       catch
       save([result_path filesep 'GraphVars' filesep num2str(groups_label) '_consensus_Louvain_perm_C_' num2str(threshold*10) '_' num2str(type) '.mat'], 'C_iter', '-v7.3');
       end
   end
   
   for i_res = 1:length(resultslist)
       Result = resultslist{i_res};
       try
       save([result_path filesep 'GroupCommunity' filesep groups_label '_modularity_group_Louvain' '_' namelist{i_res} '_' num2str(threshold*10) '_' num2str(type) '.mat'], 'Result', '-v7.3');
       catch
       save([result_path filesep 'GroupCommunity' filesep num2str(groups_label) '_modularity_group_Louvain' '_' namelist{i_res} '_' num2str(threshold*10) '_' num2str(type) '.mat'], 'Result', '-v7.3');
       end
   end