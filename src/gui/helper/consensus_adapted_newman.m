function [ciu, Q] = consensus_adapted_newman(d,tau,reps)

n = length(d); flg = 1;
while flg == 1
    
    flg = 0;
    dt = d.*(d >= tau).*~eye(n);
    if nnz(dt) == 0
        ciu = (1:n)';
    else
        qi = zeros(1,reps);
        ci = zeros(n,reps);
        for iter = 1:reps
            [c, q] = modularity_und(dt);
            qi(iter) = q;
            ci(:,iter) = c;
        end
        Q = mean(qi);
        ci = relabel_partitions(ci);
        ciu = unique_partitions(ci);
        nu = size(ciu,2);
        if nu > 1
            flg = 1;
            d = agreement(ci)./reps;
        end
    end
    
end

function cinew = relabel_partitions(ci)
[n,m] = size(ci);
cinew = zeros(n,m);
for i = 1:m
    c = ci(:,i);
    d = zeros(size(c));
    count = 0;
    while sum(d ~= 0) < n
        count = count + 1;
        ind = find(c,1,'first');
        tgt = c(ind);
        rep = c == tgt;
        d(rep) = count;
        c(rep) = 0;
    end
    cinew(:,i) = d;
end

function ciu = unique_partitions(ci)
ci = relabel_partitions(ci);
ciu = [];
count = 0;
c = 1:size(ci,2);
while ~isempty(ci)
    count = count + 1;
    tgt = ci(:,1);
    ciu = [ciu,tgt];                %#ok<AGROW>
    dff = sum(abs(bsxfun(@minus,ci,tgt))) == 0;
    ci(:,dff) = [];
    c(dff) = [];
end