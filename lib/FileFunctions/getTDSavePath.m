function [ path1 ] = getTDSavePath( monkey, date, task, resort )
%     This function gets the save path for the CDS, as a function of the
%     monkey, date and task (and the system you are running on):
%       Inputs:
%           Self explanatory: all strings
% 
% 
%       Outputs:
%           the path to write the CDS to 
%       
%       TODO: Add my linux partition to this
% 
    %% Get where you are
    if nargin<4
        resort= false;
    end
   path1 = [getBasicPath(monkey, date, task, resort), 'TD', filesep];
end

