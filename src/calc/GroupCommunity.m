%  This file is part of GraphVar.
%
%  Copyright (C) 2014
%
%  GraphVar is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  GraphVar is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with GraphVar.  If not, see <http://www.gnu.org/licenses/>.

function [res,shuffelFiles,del,groups_label,idx_group_1,idx_group_2] = GroupCommunity(thresholds,thresholdType, brain,functions,files,varargin)
global running;
global workspacePath;
load(fullfile(workspacePath,'Workspace.mat'));
[brainSheet variableSheet] =  abs_rel_correct(brainSheet,variableSheet);
[MatrixName, filePos, allTasks, doRandom, nRandom, randomFunction, randomIterations, smallworldness, ...
    randomForType, pValueField, testAgainstRandom, doShuffelRandom, nShuffelRandom,normalize,random_shuffle_calc,randomRawIter,noCorr,InterimResult, weightAdjust_Thr,DynamicGraphVar,n_multiply,n_alpha,] = ...
    getArgs(varargin,{'MatrixName','P'},'FilePos','TaskPlaner',{'DoRandom',0},'nRandom','RandomFunction','RandomIterations','Smallworldness','randomForType',{'pValueField','PValMatrix'},{'TestAgainstRandom',0},{'DoShuffelRandom',0},{'NShuffelRandom',0},{'Normalize',0},{'RandomRaw',''},{'RandomRawIter',0},{'NoCorr',0},{'InterimResult','default'},{'weightAdjust_Thr',0},{'DynamicGraphVar',''},{'n_multislice','100'},{'n_alpha','1'});

result_path = [workspacePath filesep 'results' filesep InterimResult];
% is_dyn = 1;
multislice = 0;
continueWithNeg = 0;
InterimResult_num = InterimResult;

%[BrainMap] = xlsread(brainSheet);
%BrainMap(:,1) = brain;

if(exist([workspacePath filesep 'ImportSettings.mat'],'file'))
    load([workspacePath filesep 'ImportSettings.mat']);
else
    userVar = 2;
end

if(noCorr ~=1)
    [NeoData] = importSpreadsheet(variableSheet);
    ID = NeoData(2:end,userVar);
    
    hasNumericalID = 0;
    if isscalar(ID{1})
        ID = cell2mat(ID(:));
        hasNumericalID = 1;
    end
    
    clear NeoData;
end
loc = [];

shuffelFiles = [];

if iscell(pValueField)
    pValueField = pValueField{:};
end

nSub = length(files);
if(iscell(MatrixName))
    MatrixName  = MatrixName{:};
end
emptyCells = ~cellfun(@isempty,functions);
types = 2; % everything is weigthed


allTasks.start();


%% ************************************************************************************
%% PART 2:
%% Do The Thresholding / Binarizer
if ~isempty(thresholds)
    threshTask = allTasks.getTask('Thresholds');     threshTask.start();
end

if sum(thresholds) == 0
    thresholds = 0;
end

for threshold = thresholds
    tic
    typeTask = allTasks.getTask('Types');     typeTask.start();
    
    for type = types
        validSubID = 1;
        toDel = [];
        subTask = allTasks.getTask('Thresholding Subject');     subTask.start();
        
        for i_sub=1:nSub
            % ****************************
            % Check if Subject is in Excel
            % ****************************
            if(noCorr ~=1)
                k = strfind(files{i_sub}, filesep);
                
                ID_ = files{i_sub}(k(end)+filePos(1):end-filePos(2));
                if hasNumericalID
                    ID_ = str2double(ID_);
                end
                [~,loc1] = ismember(ID_, ID);
                if loc1 > 0               % Found in Excle Sheet so valid
                    loc(validSubID) = loc1;
                    validSubID = validSubID + 1;
                else                     % Not found delete
                    toDel = [toDel i_sub];
                end
            end
            
            % ****************************
            % Load Subject, delete not requested BrainAreas
            % ****************************
            FileCont = load (files{i_sub});
            if(~isfield(FileCont,MatrixName))
                error(['The field "' MatrixName '" has not been found: ' ]);
            end
            
            if isfield(FileCont,'is_dyn')
                is_dyn = FileCont.is_dyn;
            else
                is_dyn = 0;
            end
            
            
            if(is_dyn == 1)
                n_dyn = size(FileCont.(MatrixName),2);
            else
                n_dyn = 1;
            end
            
            for i_dyn = 1:n_dyn
                
                if(iscell(MatrixName))
                    MatrixName = MatrixName{:};
                end
                
                
                if(is_dyn)
                    R = FileCont.(MatrixName){i_dyn};
                else
                    R = FileCont.(MatrixName);
                end
                
                del = find(brain==0);
                R(del,:) = [];
                R(:,del) = [];
                
                
                
                % ****************************
                % Do the Threshholding
                % ****************************
                if(thresholdType == 1 )
                    W = threshold_proportional(R,threshold);
                elseif(thresholdType == 2)
                    W = threshold_absolute(R,threshold);
                elseif(thresholdType == 3)
                    if ~isfield(FileCont,pValueField)
                        errordlg('The PValue Matrix could not be found');
                        res = 0;
                        return;
                    end
                    FileCont.(pValueField)(del,:) = []; %% Delete Brain areas
                    FileCont.(pValueField)(:,del) = [];
                    W = R;
                    W(logical(FileCont.(pValueField)>threshold)) = 0;
                    n=size(W,1);                                %number of nodes
                    W(1:n+1:end)=0;                             %clear diagonal
                elseif(thresholdType == 4)
                    W = R;
                    n=size(W,1);                                %number of nodes
                    W(1:n+1:end)=0;                             %clear diagonal
                elseif(thresholdType == 5)
                    W = SICEDense(R,threshold);
                    
                end
                
                if(type == 1)
                    W(W~=0) = 1; %binarize
                else
                    
                    if weightAdjust_Thr == 1
                        W = abs(W);
                    elseif weightAdjust_Thr == 2
                        W(W<0) = 0;
                        
                    elseif ~isempty(W(W<0)) && continueWithNeg == 0
                        button = questdlg(['The density threshold of ' num2str(threshold) ' and subsequent densities contain negative weights. Do you want to continue'], 'Found negative Values', 'Continue', 'Cancel', 'Continue');
                        if strcmpi(button, 'Cancel')
                            res = 0;
                            return;
                        else
                            continueWithNeg = 1;
                        end
                        
                    end
                end
                VPData{i_sub,i_dyn} = W;
                
                subTask.newCycle([' ' num2str(i_sub) ' of ' num2str(nSub)]);
                clear W R;
            end % end dyn
        end % END Every Subject
        
        
        
        
        %% ************************************************************************************
        %% PART 3: Radomization of already thresholded data is not done here
        %% Random data is created in the respective group_modularity function (modularity_group_Newman or Louvain) because we only randomize the agreement matrices
        %% ************************************************************************************
        
        
        %% PART 4:
        %% DO THE NETWORK/GRAPH FUNCTION (incl. random)
        %% Still in thresholds AND Type Loop
        clear Result;   % Make sure no old Result is still in memory
        functionList = {}; % Only Functions of the right Type
        
        
        % Group Modularity measures require computation of subject measures
        % Check if user wants to compute Newman group modularity
        type_mod = length(varargin); %last argument is Newman or Louvain
        type_mod = varargin{type_mod};
        gamma = varargin{end-4};
        
        % Newman: If individual measure does not exist yet, add measure
        if type_mod == 0
            functionList{length(functionList)+1} = 'modularity_cOut_und';
        end
        
        % Louvain: If individual measure does not exist yet, add measure
        if type_mod == 1
            functionList{length(functionList)+1} = 'modularity_louvain_cOut_und';
        end
        
        
        graphTask = allTasks.getTask('Graph Function');     graphTask.start();
        for i_func = 1:size(functionList,1)
            graphTask.newCycle([' ' num2str(graphTask.actCycle+1) ' of ' num2str(graphTask.cycles)]);
            
            extNSub = nSub;
            subjectTask = allTasks.getTask('Subject');    subjectTask.cycles = extNSub; subjectTask.start();
            
            for i_sub=1:nSub % For every Subject including Random
                
                %% compute regular functions
                if n_multiply ~= -1 %if the Sizemore functions are not selected
                    for i_dyn = 1:n_dyn
                        if type_mod == 1
                            try
                                [Result{i_dyn,i_sub}, Result_2{i_dyn,i_sub}] = eval([functionList{i_func} '(VPData{i_sub,i_dyn}, gamma)']);
                            catch err
                                if(GraphVarError(err))
                                    continue;
                                else
                                    rethrow(err);
                                end
                            end
                        else
                            try
                                [Result{i_dyn,i_sub}, Result_2{i_dyn,i_sub}] = eval([functionList{i_func} '(VPData{i_sub,i_dyn})']);
                            catch err
                                if(GraphVarError(err))
                                    continue;
                                else
                                    rethrow(err);
                                end
                            end
                        end
                        
                        %TO BE REVIEWED WAIT WND
                        if(~running)
                            res = 0;
                            return;
                        end
                        subjectTask.newCycle([' ' num2str(i_sub) ' of ' num2str(extNSub)]);
                        
                    end %dyn
                end % n_multiply and not sizemore function
            end % End Every Subject
        end % End Functions
        
        save([result_path filesep 'GraphVars' filesep functionList{i_func} '_' num2str(threshold*10) '_' num2str(type) '.mat'],'Result', '-v7.3')
        save([result_path filesep 'GraphVars' filesep 'agreement_matrix_' num2str(threshold*10) '_' num2str(type) '.mat'],'Result_2', '-v7.3')
        
        %vorletztes Arg == group_type
        %vorvorletzte Arg = selField
        
        group_type = varargin{end-1};
        selField = varargin{end-2};
        idx_group_1 = 1; %random preset
        idx_group_2 = 2; %random preset
        
           
        if group_type == 1
            groups_label = 'All_subjects';
            
            % Newman Group Modularity
            if type_mod == 0
                Ci = load([result_path filesep 'GraphVars' filesep 'modularity_cOut_und_' num2str(threshold*10) '_' num2str(type) '.mat']);
                subj_agree = load([result_path filesep 'GraphVars' filesep 'agreement_matrix_' num2str(threshold*10) '_' num2str(type) '.mat']);
                modularity_group_Newman(Ci.Result, result_path, threshold, type, doRandom, nRandom, randomFunction, groups_label, subj_agree)
            end
            
            % Louvain Group Modularity
            if type_mod == 1
                Ci = load([result_path filesep 'GraphVars' filesep 'modularity_louvain_cOut_und_' num2str(threshold*10) '_' num2str(type) '.mat']);
                subj_agree = load([result_path filesep 'GraphVars' filesep 'agreement_matrix_' num2str(threshold*10) '_' num2str(type) '.mat']);
                modularity_group_Louvain(Ci.Result, result_path, threshold, type, doRandom, nRandom, randomFunction, groups_label, subj_agree)
            end
        end
        
        if group_type == 2
            ImportSettings = load([workspacePath filesep 'ImportSettings.mat']);
            userVar = ImportSettings.userVar;
            NeoData = importSpreadsheet(variableSheet);
            VariablesList = NeoData(1, :);
            subjectList = NeoData(loc + 1, userVar);
            NeoData = NeoData(loc + 1, :);
            idx_group = strmatch(selField, VariablesList);
            group_var = NeoData(:,idx_group);
            
            try
            group_label = unique(group_var);
            name_group_1 = group_label{1,1};
            name_group_2 = group_label{2,1};
            idx_group_1 = strmatch(name_group_1, group_var);
            idx_group_2 =  strmatch(name_group_2, group_var);
            catch
            group_var = cell2mat(group_var);
            group_label = unique(group_var);
            name_group_1 = group_label(1,1);
            name_group_2 = group_label(2,1);
            idx_group_1 = find(group_var == name_group_1);
            idx_group_2 = find(group_var == name_group_2);
            end
            
            if type_mod == 0 % Newman Group Modularity
                Ci = load([result_path filesep 'GraphVars' filesep 'modularity_cOut_und_' num2str(threshold*10) '_' num2str(type) '.mat']);
            else % Louvain Group Modularity
                Ci = load([result_path filesep 'GraphVars' filesep 'modularity_louvain_cOut_und_' num2str(threshold*10) '_' num2str(type) '.mat']);
            end
            
            Ci_group_1 = Ci.Result(idx_group_1);
            Ci_group_2 = Ci.Result(idx_group_2);
            
            groups = {Ci_group_1, Ci_group_2};
            groups_label = {name_group_1 name_group_2};
            
            for g = 1:length(groups)
                if type_mod == 0 % Newman Group Modularity
                    modularity_group_Newman(groups{g}, result_path, threshold, type, doRandom, nRandom, randomFunction, groups_label{g})
                else             % Louvain Group Modularity
                    modularity_group_Louvain(groups{g}, result_path, threshold, type, doRandom, nRandom, randomFunction, groups_label{g})
                end
            end
            
            
        end
        
        clear Result ResultRandVar ResultS ResultMultiVar;
        typeTask.newCycle([' ' num2str(type) ' of ' num2str(2)]);
        
    end % End Type
    
    threshTask.newCycle([' ' num2str(find(thresholds == threshold)) ' of ' num2str(length(thresholds))]);
end
save([result_path filesep 'Settings.mat'],'loc')

res = 1;