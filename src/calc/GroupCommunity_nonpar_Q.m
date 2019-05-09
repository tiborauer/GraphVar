function [res] = GroupCommunity_nonpar_Q(cOut_path, cOut_path_community, q_file_values, nperm, group_type, idx_group_1, idx_group_2, hz_data_groups, c_file_values, doZh, doMInVIn)
global InterimResultsID;

%% Load Data
if group_type == 2
    COut_file_G1 = dir([cOut_path{1,1} filesep  '*_cOut_*.mat']);
    All = load([cOut_path{1,1} filesep COut_file_G1.name]);
    c_fl.Result = All.Result(idx_group_1);
    p_fl.Result = All.Result(idx_group_2);
else
    COut_file_G1 = dir([cOut_path{1,1} filesep  '*_cOut_*.mat']);
    c_fl = load([cOut_path{1,1} filesep COut_file_G1.name]);
    COut_file_G2 = dir([cOut_path{2,1} filesep  '*_cOut_*.mat']);
    p_fl = load([cOut_path{2,1} filesep COut_file_G2.name]);
end

% Number of Permutations
nperm = nperm;

%% Calculate Q, C, Z, h for group permutation
group_ci = horzcat(c_fl.Result, p_fl.Result);
col = size(group_ci,2);
for j = 1:nperm
    disp(['Permutation number: ' num2str(j)]);
    shuffle = randsample(1:col,col,false);
    group_ci_perm = group_ci(:,shuffle);
    group_1_perm = group_ci_perm(:,1:size(c_fl.Result,2));
    group_2_perm = group_ci_perm(:,1+size(c_fl.Result,2):end);
    [Q_group_1_perm(1,j), C_group_1_perm(:,j), Z_group_1_perm(:,j), h_group_1_perm(:,j)]  = QCZh_perm_group(group_1_perm, doZh);
    [Q_group_2_perm(1,j), C_group_2_perm(:,j), Z_group_2_perm(:,j), h_group_2_perm(:,j)]  = QCZh_perm_group(group_2_perm, doZh);
    
    if doMInVIn ==1
        [VIn_group_perm(1,j), MIn_group_perm(1,j)] = partition_distance(C_group_1_perm(:,j), C_group_2_perm(:,j));
    end
end


%% Calculate Q for shuffled Ci Vectors
% group_1_perm = shuffleCi(c_fl.Result, nperm, 'Group 1');
% group_2_perm = shuffleCi(p_fl.Result, nperm, 'Group 2');


%% Save permuted results
save([cOut_path{1,1} filesep 'group_1_perm_Q'],'Q_group_1_perm');
save([cOut_path{2,1} filesep 'group_2_perm_Q'],'Q_group_2_perm');
save([cOut_path{1,1} filesep 'group_1_perm_C'],'C_group_1_perm');
save([cOut_path{2,1} filesep 'group_2_perm_C'],'C_group_2_perm');

if doZh == 1
    save([cOut_path{1,1} filesep 'group_1_perm_Z'],'Z_group_1_perm');
    save([cOut_path{2,1} filesep 'group_2_perm_Z'],'Z_group_2_perm');
    save([cOut_path{1,1} filesep 'group_1_perm_h'],'h_group_1_perm');
    save([cOut_path{2,1} filesep 'group_2_perm_h'],'h_group_2_perm');
end



%% Calculate Q, Z, h distribution and determine non-par p-value
delta_q = abs(Q_group_2_perm - Q_group_1_perm);
final_delta_q = abs(delta_q);
final_delta_q = sort(final_delta_q);

group_1_actual  = q_file_values{1,1};
group_2_actual  = q_file_values{2,1};
group12_delta = abs(group_2_actual.Result - group_1_actual.Result);
q_final_delta = abs(group12_delta);

P = find(final_delta_q>=q_final_delta);
P_Q = length(P)/nperm;

save([cOut_path{1,1} filesep 'actual_delta_Q'],'q_final_delta');
save([cOut_path{1,1} filesep 'distr_delta_Q_group_perm'],'final_delta_q');
save([cOut_path{1,1} filesep 'P_Q'],'P_Q');

% Plot Q distribution
figure('NumberTitle', 'off', 'Name', ['Permutation distribution for difference in Q. with actual Q-diff of ' num2str(q_final_delta)]);
hist(final_delta_q)
line([q_final_delta, q_final_delta], ylim, 'LineWidth', 2, 'Color', 'r')
xlabel(['Difference in Q (permutation) with non-par p-value of true difference p = ' num2str(P_Q)]);
ylabel('Number of occurences');

if doZh == 1
    delta_Z = abs(Z_group_2_perm - Z_group_1_perm);
    final_delta_Z = abs(delta_Z);
    final_delta_Z = sort(final_delta_Z,2);
    
    delta_h = abs(h_group_2_perm - h_group_1_perm);
    final_delta_h = abs(delta_h);
    final_delta_h = sort(final_delta_h,2);
    
    group_1_actual_Z  = hz_data_groups(:,2);
    group_2_actual_Z  = hz_data_groups(:,4);
    group12_delta_Z = abs(group_2_actual_Z - group_1_actual_Z);
    Z_final_delta = abs(group12_delta_Z);
    
    group_1_actual_h  = hz_data_groups(:,1);
    group_2_actual_h  = hz_data_groups(:,3);
    group12_delta_h = abs(group_2_actual_h - group_1_actual_h);
    h_final_delta = abs(group12_delta_h);
    
    for d = 1:size(final_delta_Z,1)
        P_Z_pre(1,:) = find(final_delta_Z(d,:)>=Z_final_delta(d,1));
        P_h_pre(1,:) = find(final_delta_h(d,:)>=h_final_delta(d,1));
        P_Z(d,:) = size(P_Z_pre(1,:),2)/nperm;
        P_h(d,:) = size(P_h_pre(1,:),2)/nperm;
        clear P_Z_pre
        clear P_h_pre
    end
    
    idx_Z = find(P_Z <= 0.05)
    idx_h = find(P_h <= 0.05)
    
    
    save([cOut_path{1,1} filesep 'actual_delta_Z'],'Z_final_delta');
    save([cOut_path{1,1} filesep 'actual_delta_h'],'h_final_delta');
    save([cOut_path{1,1} filesep 'distr_delta_Z_group_perm'],'final_delta_Z');
    save([cOut_path{1,1} filesep 'distr_delta_h_group_perm'],'final_delta_h');
    save([cOut_path{1,1} filesep 'P_Z'],'P_Z');
    save([cOut_path{1,1} filesep 'P_h'],'P_h');
    
end


%% Calculate partition distance VIn, MIn distribution and determine non-par p-value
if doMInVIn == 1
    
    C_group_1_actual  = c_file_values{1,1};
    C_group_2_actual  = c_file_values{2,1};
    [VIn, MIn] = partition_distance(C_group_1_actual.Result, C_group_2_actual.Result);
    
    final_VIn_group_perm = abs(VIn_group_perm);
    final_VIn_group_perm = sort(final_VIn_group_perm);
    P_VIn = find(final_VIn_group_perm>=VIn);
    P_VIn = length(P_VIn)/nperm;
    
    final_MIn_group_perm = abs(MIn_group_perm);
    final_MIn_group_perm = sort(final_MIn_group_perm);
    P_MIn = find(final_MIn_group_perm<=MIn);
    P_MIn = length(P_MIn)/nperm;
    
    save([cOut_path{1,1} filesep 'actual_MIn'],'MIn');
    save([cOut_path{1,1} filesep 'actual_VIn'],'VIn');
    save([cOut_path{1,1} filesep 'distr_VIn_group_perm'],'final_VIn_group_perm');
    save([cOut_path{1,1} filesep 'distr_MIn_group_perm'],'final_MIn_group_perm');
    save([cOut_path{1,1} filesep 'P_MIn'],'P_MIn');
    save([cOut_path{1,1} filesep 'P_VIn'],'P_VIn');
    
    % Plot VIn distribution
    figure('NumberTitle', 'off', 'Name', ['Permutation distribution of VIn with actual VIn of ' num2str(VIn)]);
    hist(final_VIn_group_perm)
    line([VIn, VIn], ylim, 'LineWidth', 2, 'Color', 'r')
    xlabel(['Difference in VIn (permutation) with non-par p-value of p = ' num2str(P_VIn)]);
    ylabel('Number of occurences');
    
    figure('NumberTitle', 'off', 'Name', ['Permutation distribution of MIn with actual VIn of ' num2str(MIn)]);
    hist(final_MIn_group_perm)
    line([MIn, MIn], ylim, 'LineWidth', 2, 'Color', 'r')
    xlabel(['Difference in MIn (permutation) with non-par p-value of p = ' num2str(P_MIn)]);
    ylabel('Number of occurences');
    
end



%% Q-C-Z-h-function for permuted groups
    function [Q, C, Z, Hpos] = QCZh_perm_group(Ci,doZh)
        nSubj = length(Ci);
        agree = agreement(Ci);
        agree = agree ./ nSubj;
        tau = 0;
        reps = 100;
        [C, Q] = consensus_adapted_louvain(agree, tau, reps);
        
        if doZh == 1
            Z = module_degree_zscore(agree, C);
            [Hpos, Hneg] = diversity_coef_sign(agree, C);
        else
            Z = 0;
            Hpos = 0;
        end
        
    end

%% Shuffle Ci Vector
% function Q = shuffleCi(Ci, nperm, progress)
%     nSubj = length(Ci);
%     Q = NaN(nperm,1);
%     for i = 1:nperm
%         fprintf('%s Permutation: %d \n', progress, i);
%         shuffled = cellfun(@(x) x(randperm(length(x))), Ci, 'UniformOutput', 0);
%         agree = agreement(shuffled);
%         Q(i) = calcQ(agree, nSubj);
%     end
%
% end

res = 1;
end
