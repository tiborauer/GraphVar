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

%% Community Structure Callback
function GraphVar_GroupCommunity_Callback(hObject, eventdata, handles,group_type)
global workspacePath;
global inter
global running;
global InterimResultsID;

GraphVar_enable_disable(handles,'Off');

if group_type ==1 || group_type ==2
    fileType = questdlg('Please select modularity algorithm. Resolution only applies to Louvain.', ...
        'Modularity', ...
        'Newman','Louvain','Louvain');
    if isempty(fileType)
        return;
    end
    filesType = strcmp(fileType,'Louvain'); % 1 = Louvain, 0 = Newman
    selField = {'na'};
    if group_type ==2
        load(fullfile(workspacePath,'Workspace.mat'));
        [~, variableSheet] =  abs_rel_correct(brainSheet,variableSheet);
        
        if(exist([workspacePath filesep 'ImportSettings.mat'],'file'))
            load([workspacePath filesep 'ImportSettings.mat']);
        else
            userVar = 2;
        end
        
        [NeoData] = importSpreadsheet(variableSheet);
        names = NeoData(1,:);
        clear NeoData;
        names(userVar) = [];
        [selection,ok] = listdlg('PromptString','Select within ID field','ListString',names,'SelectionMode','single');
        if(ok)
            selField = names(selection);
        else
            return;
        end
        
        if iscell(selField)
            selField = [selField{:}];
        end
    end
    
    
    if group_type == 2
        nperm = inputdlg({'Number of permutations for group statistic (non-parametric p-value)'},'Permutation based difference between groups',1,{'1000'});
        nperm = str2double(nperm);
        if isnan(nperm)
            nperm = 1;
        end
        if isempty(nperm)
            nperm = 1;
        end
    end
    
    
    [res,allTasks,del,groups_label,idx_group_1,idx_group_2] = GraphVar_calc_GroupCommunity(handles,filesType,group_type,selField,1);
    if(res)
        if group_type == 2
        [res] = GraphVar_GroupCommunity_Plot_HZ(handles,filesType, group_type, nperm, groups_label,idx_group_1,idx_group_2);
        else
        [res] = GraphVar_GroupCommunity_Plot_HZ(handles,filesType, group_type, 1, groups_label,idx_group_1,idx_group_2);    
        end
    end
end


if group_type ==3
    filesType = 0;
    nperm = inputdlg({'Number of permutations for group statistic (non-parametric p-value)'},'Permutation based difference between groups',1,{'1000'});
    nperm = str2double(nperm);
    if isnan(nperm)
        nperm = 1000;
    end
    if isempty(nperm)
        nperm = 1;
    end
    
   GraphVar_GroupCommunity_Plot_HZ(handles,filesType, group_type, nperm);
end

if(~running)
    GraphVar_enable_disable(handles,'On');
    return;
end

multiWaitbar('CloseAll');
GraphVar_enable_disable(handles,'On');
