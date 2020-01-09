function [mean1, ci] = getMeanTD(td, params)
signal =[];
if nargin > 1, assignParams(who,params); end % overwrite defaults
  sig = cat(1, td.(signal));
  mean1 = mean(sig);
  ci = bootci(1000, @mean, sig);
end