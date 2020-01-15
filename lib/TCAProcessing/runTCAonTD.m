function tca = runTCAonTD(td, params)
firstDim = 'time';
secondDim = 'neurons';
thirdDim = 'trials';
array = 'cuneate';
num_comps = 4;
if nargin > 1, assignParams(who,params); end % overwrite defaults

plotParams.Modetitles = {firstDim, secondDim, thirdDim};
plotParams.Plottype = {'bar', 'line', 'scatter'};
plotParams.SplitBy = 'bumpDir';
td = removeBadNeurons(td); 
spikes = [array, '_spikes'];
tensorIn = cat(3, td.(spikes));
tensorIn = permute(tensorIn, [2, 1, 3]);
tca = cp_als(tensor(tensorIn), num_comps);
viz_ktensor_td(tca,td, plotParams)
end
