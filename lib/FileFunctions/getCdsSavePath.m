function [ path1 ] = getCdsSavePath( monkey, date, task )
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
    
    path1 = [getBasicPath(monkey, date, task), 'CDS',filesep];
end

