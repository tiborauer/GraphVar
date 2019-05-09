function Q= modularity_QOut_und(W)
   sum_q = cell(100,1);
   for iter = 1:100
       [~, q] = modularity_und(W);
       sum_q{iter} = q;
   end
   Q = mean(cell2mat(sum_q));
