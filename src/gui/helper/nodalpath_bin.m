function D = nodalpath_bin(W)
D = distance_bin(W);
D = mean(D(D~=Inf));
