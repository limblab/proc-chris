function D = td2DataHigh(td)
    %% Function to convert trial data format to DataHigh format
    % Input TDs must
    % 1. All be the same length
    % 2. Have meaningful conditions in SplitBy
    % 3. Have neural data in format (array, '_spikes')
    % 4. Be binned at 1 ms bin width.
    
    splitBy = 'target_direction'; % Conditions to split across (coloring conditions)
    array = getArrayName(td); % Automate the scraping of neural date (will need to change if you want to dimReduce non-neural data
    td(isnan([td.(splitBy)])) =[]; % Remove Trials where condition split doesn't hold
    splits = unique([td.(splitBy)]); % Find unique splits
    colors = linspecer(length(splits)); % Get number of colors equal to number of conditions
    D = []; %Placeholder
    for i = 1:length(td) % For each trial 
        trial = td(i); 
        D1.data = td(i).([array,'_spikes'])'; % Place neural data into trial structure
        D1.condition = num2str(td(i).(splitBy)); % 
        D1.epochStarts = 1;
        D1.epochColors = colors(find(splits==td(i).(splitBy)),:);
        D =[D;D1];
    end
    
end