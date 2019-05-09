function D = charpath_W__normalized_pos(W)
    W=( W.*(W>0));
    E=find(W); W(E)=1./W(E);        %invert weights
    W=W./max(abs(W(:)));    %scale by maximal weight
    D = distance_wei(W);
    D = charpath(D);
