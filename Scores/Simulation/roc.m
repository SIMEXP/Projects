function [false_pos, true_pos] = roc(labels, values, target)
  u_val = unique(values);
  n_val = length(u_val);

  true_pos = zeros(n_val+1, 1);
  false_pos = zeros(n_val+1, 1);
  P = sum(labels==target);
  N = sum(labels~=target);

  for v_id = 1:n_val
      thresh = u_val(v_id);
      pass_thr = values > thresh;
      TP = sum(pass_thr(labels==target));
      FP = sum(pass_thr(labels~=target));
      tpr = TP / P;
      fpr = FP / N;
      true_pos(v_id+1) = tpr;
      false_pos(v_id+1) = fpr;
  end
  true_pos(1) = 1;
  false_pos(1) = 1;
end