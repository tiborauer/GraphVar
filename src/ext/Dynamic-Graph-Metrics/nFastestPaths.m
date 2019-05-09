function [ nFastestPaths ] = ...
    nFastestPaths(contactSequence,directed)
%% Calculate the betweenness centrality of all nodes in a dynamic network.
%
% Inputs:
%       contactSequence = nEdges x 3 array of (i,j,t) tuples indicating
%           contact between nodes i,j at time t.
%       directed = 1 if network is directed, 0 if undirected.
%
% Outputs:
%       nFastestPaths = nNodes x nNodes matrix with entry ij the number of
%           fastest paths from node i to node j.
%
%
%
% Reference: Ann E. Sizemore and Danielle S. Bassett, "Dynamic Graph 
% Metrics: Tutorial, Toolbox, and Tale." Submitted. (2017)
%

adjArray = networksFromContacts(contactSequence,directed);

npoints = size(adjArray,3);
nNodes = size(adjArray,1);
durationShortestPaths = zeros(nNodes);


nPathsDurationt = sum(adjArray,3);
nFastestPathsDurationt = nPathsDurationt;
nFastestPaths = nFastestPathsDurationt;
nFastestPaths(logical(eye(nNodes))) = 1;
durationShortestPaths(find(nPathsDurationt)) = 1;
durationShortestPaths(logical(eye(nNodes))) = 1;

startingInfo = zeros(nNodes,nNodes,npoints);


% Note: we assume time steps are 1:nPoints 

for t = 2:npoints
    
    tArray = zeros(nNodes,nNodes,npoints-t+1);
    
    for p = 1:size(tArray,3)
        
        tArray(:,:,p) = adjArray(:,:,p);
        for j = p+1:p+t-1
            
            tArray(:,:,p) = tArray(:,:,p)*adjArray(:,:,j)+ (tArray(:,:,p)>0);
        end
        
        tArraySlice = tArray(:,:,p);
        startingInfoSlice = startingInfo(:,:,p);
        
        startingInfoSlice(nFastestPaths==0) = tArraySlice(nFastestPaths==0);
        startingInfo(:,:,p) = startingInfoSlice;
        
    end
    
      
    % need to update shortest path matrix
    nPathsDurationt = sum(tArray,3);
    nFastestPathsDurationt(nFastestPaths==0) = ...
        nPathsDurationt(nFastestPaths==0);
    newPathind = nFastestPathsDurationt;
    newPathind(newPathind>0) = 1;
    durationShortestPaths(nFastestPaths==0) = t*newPathind(nFastestPaths==0);
    
    % update fastest paths
    nFastestPaths(nFastestPaths==0) = ...
        nFastestPathsDurationt(nFastestPaths==0);
    
       
    
    
end



% Prepare to find path members

durationShortestPaths(~durationShortestPaths) = inf;
durationShortestPaths(logical(eye(nNodes))) = 0;
nFastestPaths(~nFastestPaths) = 1;



end

