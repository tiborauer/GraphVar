function [res] = GraphVar_GroupCommunity_Plot_HZ(handles,filesType,group_type, nperm, groups_label,idx_group_1,idx_group_2)
global workspacePath;
global InterimResultsID;
global root_path

% LOAD WORKSPACE INFO
load(fullfile(workspacePath,'Workspace.mat'));
result_path = [workspacePath filesep 'results'];

if group_type == 2
groups_label = cellfun(@num2str,groups_label,'un',0);
end

for i = 1:length(handles.vpFiles)
    [~,vpNames{i}] = fileparts(handles.vpFiles{i});
end

[~,dialogData] = GraphVar_getDialogData(handles,0,1);

if group_type ==1  && sum(dialogData.thresholds) == 0 || group_type ==2  && sum(dialogData.thresholds) == 0
    dialogData.thresholds = 0;
end

if group_type ==3
    dialogData.thresholds = 1;
end

doZh = dialogData.doZh;
doMInVIn = dialogData.doMInVIn;

for i_thr = 1:length(dialogData.thresholds)
    if group_type == 1
        grouplist = {'1'};
    else
        grouplist = {'Group 1' 'Group 2'};
    end
    tasklist = {'1'};
    
    if group_type == 3
        fileType_group3 = questdlg('Please select modularity algorithm', ...
            'Modularity', ...
            'Newman','Louvain','Louvain');
        if isempty(fileType_group3)
            return;
        end
        fileType_group3 = strcmp(fileType_group3,'Louvain'); % 1 = Louvain, 0 = Newman
        idx_group_1 = 1;
        idx_group_2 = 2;
    end
    
    cOut ={};
    q_file_values={};
    
    for g = 1:length(grouplist)
        for  t = 1:length(tasklist)
            % Load Data case all subjects (group_type ==1)
            if group_type ==1 || group_type ==2
                if group_type ==1
                    groups_label = cellstr(groups_label);
                end
                if filesType == 1
                    z_file = load([result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_modularity_group_Louvain_Z-Score_' num2str(dialogData.thresholds(i_thr)*10) '_2.mat']);
                    Z(g,t,:) = z_file.Result;
                    h_file = load([result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_modularity_group_Louvain_Diversity_Pos_' num2str(dialogData.thresholds(i_thr)*10) '_2.mat']);
                    h(g,t,:) = h_file.Result;
                    data = [squeeze(h(g,t,:)), squeeze(Z(g,t,:))];
                    c_file = load([result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_modularity_group_Louvain_Affiliation_' num2str(dialogData.thresholds(i_thr)*10) '_2.mat']);
                    C(g,t,:) = c_file.Result;
                    q_file = load([result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_modularity_group_Louvain_Q_' num2str(dialogData.thresholds(i_thr)*10) '_2.mat']);
                else
                    z_file = load([result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_modularity_group_Newman_Z-Score_' num2str(dialogData.thresholds(i_thr)*10) '_2.mat']);
                    Z(g,t,:) = z_file.Result;
                    h_file = load([result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_modularity_group_Newman_Diversity_Pos_' num2str(dialogData.thresholds(i_thr)*10) '_2.mat']);
                    h(g,t,:) = h_file.Result;
                    data = [squeeze(h(g,t,:)), squeeze(Z(g,t,:))];
                    c_file = load([result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_modularity_group_Newman_Affiliation_' num2str(dialogData.thresholds(i_thr)*10) '_2.mat']);
                    C(g,t,:) = c_file.Result;
                    q_file = load([result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_modularity_group_Newman_Q_' num2str(dialogData.thresholds(i_thr)*10) '_2.mat']);
                end
                
                if filesType == 1
                    try
                        p_value = load([result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_modularity_group_Louvain_P_value_' num2str(dialogData.thresholds(i_thr)*10) '_2.mat']);
                    catch
                    end
                else
                    try
                        p_value = load([result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_modularity_group_Newman_P_value_' num2str(dialogData.thresholds(i_thr)*10) '_2.mat']);
                    catch
                    end
                end
                
                if group_type ==2
                    cOut_path = [result_path filesep InterimResultsID filesep 'GraphVars'];
                    cOut_path_community = [result_path filesep InterimResultsID filesep 'GroupCommunity'];
                    cOut{g,1} = cOut_path;
                    q_file_values{g,1} = q_file;
                    c_file_values{g,1} = c_file;
                end
                
            end
            
            
            
            if group_type ==3
                % Load Data case 3 pre-calculated groups (group_type ==3)
                cd (result_path);
                dname = uigetdir('',['Select Folder with mat files for: ' grouplist{g}]);
                if ~ischar(dname) && dname == 0
                    return;
                end
                
                if fileType_group3 == 1
                    z_file = dir([dname filesep  '*_modularity_group_Louvain_Z-Score_*.mat']);
                    z_file = load([dname filesep z_file.name]);
                    Z(g,t,:) = z_file.Result;
                    h_file = dir([dname filesep  '*_modularity_group_Louvain_Diversity_Pos_*.mat']);
                    h_file = load([dname filesep h_file.name]);
                    h(g,t,:) = h_file.Result;
                    data = [squeeze(h(g,t,:)), squeeze(Z(g,t,:))];
                    c_file = dir([dname filesep  '*_modularity_group_Louvain_Affiliation_*.mat']);
                    c_file = load([dname filesep c_file.name]);
                    C(g,t,:) = c_file.Result;
                    q_file = dir([dname filesep  '*_modularity_group_Louvain_Q_*.mat']);
                    q_file = load([dname filesep q_file.name]);
                else
                    z_file = dir([dname filesep  '*_modularity_group_Newman_Z-Score_*.mat']);
                    z_file = load([dname filesep z_file.name]);
                    Z(g,t,:) = z_file.Result;
                    h_file = dir([dname filesep  '*_modularity_group_Newman_Diversity_Pos_*.mat']);
                    h_file = load([dname filesep h_file.name]);
                    h(g,t,:) = h_file.Result;
                    data = [squeeze(h(g,t,:)), squeeze(Z(g,t,:))];
                    c_file = dir([dname filesep  '*_modularity_group_Newman_Affiliation_*.mat']);
                    c_file = load([dname filesep c_file.name]);
                    C(g,t,:) = c_file.Result;
                    q_file = dir([dname filesep  '*_modularity_group_Newman_Q_*.mat']);
                    q_file = load([dname filesep q_file.name]);
                end
                rm = 'GroupCommunity';
                cOut_path_community = strrep(dname,rm,'');
                cOut_path = strcat(cOut_path_community, 'GraphVars');
                cOut{g,1} = cOut_path;
                q_file_values{g,1} = q_file;
                c_file_values{g,1} = c_file;
            end
            
            if group_type ==2 || group_type ==3
                if g ==1
                    hz_data_groups(:,1:2) = data;
                else
                    hz_data_groups(:,3:4) = data;
                end
            end
            
            % Colorcode
            load([root_path filesep 'src/ConfigBrainViewer_Community.mat']);
            colors = c_file.Result;
            amount = length(unique(colors));
            myColors = zeros(size(data, 1), 3);
            for col = 1:amount
                col_sum(col) = sum(colors==col);
            end
            [sorted,num] = sort(col_sum,'descend');
            sorted_color_mod = zeros(size(myColors,1),1);
            
            %num = 1:amount; % uncomment this line if you DO NOT want the communties ordered according to their sizes
            
            for c = 1:amount
                current_color = colors == num(c);
                myColors(current_color, :) = repmat(EC.nod.CMm(c,1:3), sum(current_color>0),1);
                idx = find(current_color == 1);
                sorted_color_mod(idx) = c;
            end
            
            % Plot Scatterplot
            if doZh == 1
            if group_type ==1 || group_type ==2
                figure('NumberTitle', 'off', 'Name', [groups_label{g} ' Modules Z and H plot for Thr. ' num2str(dialogData.thresholds(i_thr))]);
                plot = scatter(data(:, 1), data(:, 2), 60, myColors, 'filled');
                xlabel(['Classification Diversity h for Thr:' num2str(dialogData.thresholds(i_thr))]);
                ylabel(['Classification Consistency z for Thr:' num2str(dialogData.thresholds(i_thr))]);
                saveas(plot, [result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_Modules_GroupCommunity_' num2str(dialogData.thresholds(i_thr)),'_hz_plot.png']);
            else
                figure('NumberTitle', 'off', 'Name', ['Modules Z and H plot for Group ' grouplist{g}]);
                plot = scatter(data(:, 1), data(:, 2), 60, myColors, 'filled');
                xlabel(['Classification Diversity h for Group: ' grouplist{g}]);
                ylabel(['Classification Consistency z for Group: ' grouplist{g}]);
                saveas(plot, [dname filesep 'Modules_GroupCommunity_Group_' grouplist{g},'_hz_plot.png']);
            end
            end
            
            
            clear myColors
            
            % initiate table
            table_subj(1,1) = cellstr('Summary');
            table_subj(3,1) = cellstr(['Q: ' num2str(q_file.Result)]);
            try
                table_subj(4,1) = cellstr(['p-value: ' num2str(p_value.Result)]);
            catch
            end
            table_subj(2,1) = cellstr(['sizes: ' num2str(sorted)]);
            table_subj(1,2) = cellstr('red');
            table_subj(1,3) = cellstr('yellow');
            table_subj(1,4) = cellstr('green');
            table_subj(1,5) = cellstr('light blue');
            table_subj(1,6) = cellstr('dark blue');
            table_subj(1,7) = cellstr('pink');
            table_subj(1,8) = cellstr('dark yellow');
            table_subj(1,9) = cellstr('light green');
            table_subj(1,10) = cellstr('turquoise');
            table_subj(1,11) = cellstr('marine blue');
            table_subj(1,12) = cellstr('purple');
            table_subj(1,13) = cellstr('rose');
            table_subj(1,14) = cellstr('light yellow');
            table_subj(1,15) = cellstr('wood green');
            table_subj(1,16) = cellstr('dark turquoise');
            table_subj(1,17) = cellstr('dark purple');
            table_subj(1,18) = cellstr('brown');
            table_subj(1,19) = cellstr('dark grey');
            table_subj(1,20) = cellstr('light grey');
            table_subj(1,21) = cellstr('black');
            table_subj(1,22) = cellstr('white');
            
            % get brain areas for modules
            brain = handles.BrainMap(logical(dialogData.brainD));
            for i = 1:amount
                brain_mod_areas = colors == num(i);
                brain_print = brain(brain_mod_areas);
                table_subj(2:1+length(brain_print),i+1) = brain_print;
            end
            
            table_subj = table_subj(:,1:amount+1);
            
            
            % write all tables to .txt files
            if group_type ==1 || group_type ==2
                dlmcell([result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_Modules_GroupCommunity_' num2str(dialogData.thresholds(i_thr)) '.txt'],table_subj);
                logWnd_1 = dialog('WindowStyle', 'normal', 'Name', [groups_label{g} ' Modules in Community for Thr. ' num2str(dialogData.thresholds(i_thr))],'Resize','on');
                t = uitable(logWnd_1,'Data',table_subj,'ColumnWidth',{120},     'units','normalized', ...
                    'Position',[0.02 0.02 0.96 0.96] );
            else
                %dlmcell([dname filesep 'Modules_GroupCommunity_Group_' grouplist{g} '.txt'],table_subj);
                logWnd_1 = dialog('WindowStyle', 'normal', 'Name', ['Modules in Community for Group. ' grouplist{g}],'Resize','on');
                t = uitable(logWnd_1,'Data',table_subj,'ColumnWidth',{120},     'units','normalized', ...
                    'Position',[0.02 0.02 0.96 0.96] );
            end
            
            clear table_subj
            clear col_sum
        end
        
        % open BrainNet viewer
        if  dialogData.BrainNet_vis == 1
            if exist('BrainNet_MapCfg','file')
                load(fullfile(workspacePath,'Workspace.mat'));
                [BrainMap] = importSpreadsheet(brainSheet);
                [~,idx] = ismember(brain,BrainMap(:,3));
                tmp = ones(length(idx),1);
                nodes = [BrainMap(idx,4),BrainMap(idx,5),BrainMap(idx,6),num2cell(sorted_color_mod), num2cell(tmp), BrainMap(idx,2)];
                edges = zeros(size(brain,2));
                dlmcell('tmp.node',nodes);
                dlmcell('tmp.edge',num2cell(edges));
                EC.nod.ModularNumber = unique(colors);
                BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv','tmp.node','tmp.edge','ConfigBrainViewer_Community.mat');
                
                % save figure
                set(gcf, 'PaperPositionMode', 'manual');
                set(gcf, 'PaperUnits', 'inch');
                set(gcf,'Paperposition',[1 1 EC.img.width/EC.img.dpi EC.img.height/EC.img.dpi]);
                
                if group_type ==1 || group_type ==2
                    print(gcf,[result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_' num2str(dialogData.thresholds(i_thr)) '_Modules_GroupCommunity.' 'png'],'-dpng',['-r',num2str(EC.img.dpi)])
                else
                    print(gcf,[dname filesep 'Modules_GroupCommunity_Group_' grouplist{g} '_Community.' 'png'],'-dpng',['-r',num2str(EC.img.dpi)])
                end
                
            else
                warndlg('Please install Brain Net Viewer (http://www.nitrc.org/projects/bnv/) to visualize modularity (add path with subfolders)');
            end
        end
        
        sorted_affiliation(:,g) = sorted_color_mod;
        
        amount = length(unique(sorted_affiliation(:,g)));
        for i = 1:amount
            dummy_vec = zeros(length(sorted_affiliation(:,g)),1);
            idx = find(sorted_affiliation(:,g) == i);
            dummy_vec(idx) = 1;
            mod_vec(:,i) = dummy_vec;
        end
        
        if group_type ==1 || group_type ==2
            save([result_path filesep InterimResultsID filesep 'GroupCommunity' filesep groups_label{g} '_Binary_Affiliation_Vectors_' num2str(dialogData.thresholds(i_thr)) '.mat' ],'mod_vec');
        else
            save([result_path filesep InterimResultsID filesep 'GroupCommunity' filesep grouplist{g} '_Binary_Affiliation_Vectors_' num2str(dialogData.thresholds(i_thr)) '.mat' ],'mod_vec');
        end
        
    end
    
    
    % calculate perumtations for group difference in Q
    if group_type == 2  || group_type == 3
        if group_type == 3
            groups_label{1} = 'Group_1';
            groups_label{2} = 'Group_2';
        end
        [group1_group2_overlap_percent, group2_group1_overlap_percent] = Compare_communities(sorted_affiliation(:,1), sorted_affiliation(:,2));
        save([cOut{1,1} filesep ['Modularity_overlap_percent_' groups_label{1} '_' groups_label{2}]],'group1_group2_overlap_percent');
        save([cOut{2,1} filesep ['Modularity_overlap_percent_' groups_label{2} '_' groups_label{1}]],'group2_group1_overlap_percent');
        
        res = GroupCommunity_nonpar_Q(cOut, cOut_path_community, q_file_values, nperm, group_type, idx_group_1, idx_group_2, hz_data_groups, c_file_values, doZh, doMInVIn);
    end
    
    res = 1;
    
    
end