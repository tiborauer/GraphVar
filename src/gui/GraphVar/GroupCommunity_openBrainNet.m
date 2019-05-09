function GroupCommunity_openBrainNet(~,~,handles)
global workspacePath;
global selectedNetworkID;
global drawArg2;
if exist('BrainNet_MapCfg','file')
    load(fullfile(workspacePath,'Workspace.mat'));
    
    brainIdx = find(handles.networkData.or1 == drawArg2(selectedNetworkID));
    data = handles.networkData.data(brainIdx,brainIdx);
    data2 = handles.networkData.data2(brainIdx,brainIdx);
    data(data2 > handles.networkData.alpha) = 0;
    handles.BrainStrings(brainIdx);
    
    [BrainMap] = importSpreadsheet(brainSheet);
    [~,idx] = ismember(handles.BrainStrings(brainIdx),BrainMap(:,2));
    tmp = ones(length(idx),1);
    nodes = [BrainMap(idx,4),BrainMap(idx,5),BrainMap(idx,6),num2cell(tmp*4), num2cell(tmp), BrainMap(idx,2)];
    dlmcell('tmp.node',nodes);
    dlmcell('tmp.edge',num2cell(data));
    BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv','tmp.node','tmp.edge','ConfigBrainViewer.mat');
else
    warndlg('Please install Brain Net Viewer (http://www.nitrc.org/projects/bnv/)');
end