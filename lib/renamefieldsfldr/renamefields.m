function struct2=renamefields(struct1,oldnames,newnames,~) % ~ noerror
% renamefields  Rename field names in struct with optional noerror
%  2017-07-09  Matlab2006+  Copyright (c) 2017, W J Whiten  BSD License
%
% s2=changefields(s1,oldnames,newnames,noerror)
%  struct1  Struct to be updated
%  oldnames Cell array of old field names (or char for one name)
%  newnames Cell array of field names to replace those in s1 (or char)
%  noerror  if present no error message, ie only changes names present
%
%  struct2  Updated struct
%
% Notes:
%   Fields present in struct1 not in newnames are passed though unchanged
%   if fourth argument is present struct1 need not contain names in old 
%     names ie only old names present in struct1 are changed
%
% Examples
% s1=renamefields(struct('a',[1,2,3],'b',2),'a',{'c'})
% s1 = 
%   struct with fields:
% 
%     c: [1 2 3]
%     b: 2
%
% t2=renamefields(struct('a',{1,2},'b',{10,20}),{'a','b'},{'b','a'})
% disp(['t2(:).b   ',num2str([t2(:).b])])
% disp(['t2(:).a   ',num2str([t2(:).a])])
% t2 = 
%   1×2 struct array with fields:
%     b
%     a
% t2(:).b   1  2
% t2(:).a   10  20
% 
% t3=renamefields(struct('a',[1,2,3],'b',2),{'a' 'd'},{'c' 'dd'},true)
% t3 = 
%   struct with fields:
% 
%     c: [1 2 3]
%     b: 2

% check if no error message for missing field
if(nargin==4)
    noerror=true;
else
    noerror=false;
end

% check and adjust inputs
if(~isstruct(struct1))
    error('changefields:  First argument must be a struct')
end

if(ischar(oldnames))
    oldnames={oldnames};
end
if(ischar(newnames))
    newnames={newnames};
end

if(length(oldnames)~=length(newnames))
    error('changefields:  Number of names not equal');
end

% undo struct
names=fieldnames(struct1);
names1=names;
values=struct2cell(struct1);

%change names
for i=1:length(oldnames)
    ind=find(strcmp(oldnames{i},names));
    if(isempty(ind) && ~noerror)
        error(['changefields:  Name  ''',oldnames{i},  ...
            '''  not in struct']);
    elseif(~isempty(ind))
        names1{ind}=newnames{i};
    end
end

% create new struct
struct2=cell2struct(values,names1);

return
end
