function metric = get_metric(varargin)
y_test         = varargin{1};
eval_metric    = varargin{end-1};
num_bootstraps = varargin{end};

% this is a really efficient way to bootstrap...
if num_bootstraps > 1
    bs = randi(length(y_test),length(y_test),num_bootstraps);
else
    bs = 1:length(y_test);
end

y_fit = varargin{2};
if nargin == 4 % normal metric
    switch lower(eval_metric)
        case 'pr2'
            metric = compute_pseudo_R2(y_test(bs),y_fit(bs),mean(y_test));
        case 'vaf'
            metric = compute_vaf(y_test(bs),y_fit(bs));
        case 'r2'
            metric = compute_r2(y_test(bs),y_fit(bs));
    end
elseif nargin == 5 % relative metric
    y_fit2 = varargin{3};
    switch lower(eval_metric)
        case 'pr2'
            metric = compute_rel_pseudo_R2(y_test(bs),y_fit(bs),y_fit2(bs));
        case 'vaf'
            error('VAF not yet implemented for relative metrics');
        case 'r2'
            error('R2 not yet implemented for relative metrics');
        case 'r'
            error('r not yet implemented for relative metrics');
    end
end
% no need to repeat
if num_bootstraps > 1
    metric = prctile(metric,[2.5,97.5]);
    metric = [mean(metric) - std(metric); mean(metric) + std(metric)];
end