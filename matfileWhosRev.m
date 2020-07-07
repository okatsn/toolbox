function [target_S] = matfileWhosRev(target_S,table0,fieldnames2assign,varargin)
% Load information from the table that created from matfileWhos, and
% re-assign them into the fields of a structure/matfile
% target_S: the target structure or matfile.
% table0: the table that was created from matfileWhos
% fieldnames2assign: a cell array containing some field names in table0.
%
%
% How to use:
%     [target_S] = matfileWhosRev(target_S,table0,fieldnames2assign);
%     
%     overwrite_field = true;
%     [target_S] = matfileWhosRev(target_S,table0,fieldnames2assign,overwrite_field)
% 
% Real Example: 
%     mtf_ts = matfile(targets.fullpath{i},'Writable',true);
%     infotable = mtf_ts.original_information;
%     mtf_ts.original_information = [];   
%     mtf_ts = matfileWhosRev(mtf_ts,infotable,{'D','r','dt','StartPoint','constantForce','FrictionType'});

if nargin>3
    overwrite_field = varargin{1};
else 
    overwrite_field = false;
end

TF_array = ismember(fieldnames2assign,fieldnames(target_S));

for i = 1:length(fieldnames2assign)
    fnm = fieldnames2assign{i};
    fieldexist = TF_array(i);
    
    if ~fieldexist || overwrite_field
        target_S.(fnm) = table0{'value',fnm}{1};
    else
        warning("field name '%s' already existed in the input structure. Hence skipped",fnm);        
    end
end
end

