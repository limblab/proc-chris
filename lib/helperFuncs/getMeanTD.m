function mean1 = getMeanTD(td, params)
signal =[];
if nargin > 1, assignParams(who,params); end % overwrite defaults
  sig = cat(1, td.(signal));
  mean1 = mean(sig);
end