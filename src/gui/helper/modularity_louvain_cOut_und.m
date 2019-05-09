function [C,agree] = modularity_louvain_cOut_und(W,gamma)
   sum_c = cell(1000,1);
   for iter = 1:1000
       [ci, ~] = community_louvain(W,gamma);
       sum_c{iter} = ci;
   end
   agree = agreement(sum_c);
   tau = 0;
   reps = 70;
   C = consensus_und(agree, tau, reps);
