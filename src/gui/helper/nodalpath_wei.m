function D = nodalpath_wei(W)
E=find(W); W(E)=1./W(E);        %invert weights
D = distance_wei(W);
D = mean(D(D~=Inf));
