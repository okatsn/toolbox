function tblout = tblvertcat(tbl)
arguments (Repeating)
    tbl table
end
%--------------------------------------------------------------------------
% Author(s): Sterling Baird
%
% Date: 2020-09-05
%
% Description: vertically catenate any number of tables with different
% variables, filling in dummy values where necessary.
%
% Inputs:
%  tbl - table, where each table can have a different number of rows and
%  same and/or different variables*
%
% Outputs:
%  tblout - vertically catenated table
%
% Usage:
%  tblout = tblvertcat(tbl1,tbl2);
%  tblout = tblvertcat(tbl1,tbl2,tbl3);
%
% Notes:
%  See https://www.mathworks.com/matlabcentral/answers/179290-merge-tables-with-different-dimensions
%  and https://www.mathworks.com/matlabcentral/answers/410053-outerjoin-tables-with-identical-variable-names-and-unique-non-unique-keys
%
%  *variables of the same name must also be of the same datatype.
%--------------------------------------------------------------------------
%% table properties
ntbls = length(tbl); %number of tables
nrowslist = cellfun(@height,tbl); %number of rows for each table
%% assign temporary ids going from 1 to total # rows among all tables
tableIDtmp = [0 cumsum(nrowslist)];
for n = 1:ntbls
    %variable names
    varnames = tbl{n}.Properties.VariableNames;
    %make sure tableID isn't already a variable name
    if any(strcmp('tableID',varnames))
        error(['tableID is a variable name for tbl{' int2str(n) '}, remove or rename this variable name.'])
    end
    %assign range
    tableID = tableIDtmp(n)+1:tableIDtmp(n+1);
    tbl{n}.tableID = tableID.';
end
%% catenate table pairs
%unpack first table
t1 = tbl{1};
for n = 2:ntbls
        % unpack next table
        t2 = tbl{n};
        
        %variable names
        t1names = t1.Properties.VariableNames;
        t2names = t2.Properties.VariableNames;
        
        %shared variable names
        sharednames = intersect(t1names,t2names);
        
        %catenation
        t1 = outerjoin(t1,tbl{n},'Key',['tableID',sharednames],'MergeKeys',true);
end
%remove temporary ids
tblout = removevars(t1,'tableID');
end

%% CODE GRAVEYARD
%{
            %get variable types for each
            vartypes1=varfun(@class,t1,'OutputFormat','cell');
            vartypes2=varfun(@class,t2,'OutputFormat','cell');
            
            %% find variable IDs of different types
            %struct
            structIDtmp1 = find(strcmp('struct',vartypes1));
            structIDtmp2 = find(strcmp('struct',vartypes2));
            
            %cell
            cellIDtmp1 = find(strcmp('cell',vartypes1));
            cellIDtmp2 = find(strcmp('cell',vartypes2));
            
            %% find missing variable IDs of different types
            %struct
            structID1 = union(ia1,structIDtmp1);
            structID2 = union(ia2,structIDtmp2);
            
            %cell
            cellID1 = union(ia1,cellIDtmp1);
            cellID2 = union(ia2,cellIDtmp2);


% for i = 1:n
%     strcmp('struct',varfun(@class,tbl{i},'OutputFormat','cell')
% end

%             ia1([structID1,cellID1]) = [];
%             ia2([structID2,cellID2]) = [];

if isstruct(replaceval)
    for i = ID
        varname = varnames{ID};
        sfields = fields(t(varname));
        for j = 1:length(sfields)
            sfield = sfields{j};
            sfieldtype =
            replaceval.(sfield) =

%     if any(strcmp('tableID',fieldnames(tbl{n})))
%         error(['tbl{' int2str(n) '} contains a variable name, tableID'])
%     end


%     for p = n:ntbls     
        %             %% find missing variables
        %             nrows1 = height(t1);
        %             nrows2 = height(t2);


        %             % cell tables (cell with 0x0 double inside)
        %             [celltbl1,creplaceNames1] = replacevartbl(t2,nrows1,ia1,cell(1));
        %             [celltbl2,creplaceNames2] = replacevartbl(t1,nrows2,ia2,cell(1));
        %
        %             % remove values that are represented in cell and struct tables
        %             missing1 = setdiff(missingtmp1,creplaceNames1,'stable');
        %             missing2 = setdiff(missingtmp2,creplaceNames2,'stable');
        
        %             %% splice the missing variable tables into original tables
        %             % matrices of missing elements to splice into original
        %             missingmat1 = repelem(missing,nrows1,numel(missing1));
        %             missingmat2 = repelem(missing,nrows2,numel(missing2));
        %
        %             %tables to splice into original tables
        %             missingtbl1 = array2table(missingmat1,'VariableNames',missing1);
        %             missingtbl2 = array2table(missingmat2,'VariableNames',missing2);
        %
        %             %perform the splice
        %             tbl{n} = [t1, missingtbl1, celltbl1];
        %             tbl{p} = [t2 missingtbl2, celltbl2];
%     end

%catenate all tables
% tblout = vertcat(tbl{:});


        
        %             %get variable names from t2 that are not in t1
        %             [missingtmp1,ia1] = setdiff(t2names,t1names);
        %             %get variable names from t1 that are not in t2
        %             [missingtmp2,ia2] = setdiff(t1names,t2names);


% %% Replace Variable Table
% function [replacetbl,replaceNames] = replacevartbl(t,nrows,ia,replaceval)
% %replace type
% replacetype = class(replaceval);
% 
% %% missing variable IDs and names
% %variable names
% varnames = t.Properties.VariableNames;
% 
% %variable types
% vartypes=varfun(@class,t,'OutputFormat','cell');
% 
% %variable IDs of some type
% IDtmp = find(strcmp(replacetype,vartypes));
% 
% %missing variable IDs of different types
% ID = intersect(ia,IDtmp);
% 
% %missing variable names of different types
% replaceNames = varnames(ID);
% 
% %% construct table with replacement values and names
% %table dimensions
% nvars = length(ID);
% 
% if isstruct(replaceval) && isempty(replaceval)
%     error('if type struct, cannot be empty. Instead supply struct with no fields via struct()')
% end
% 
% replacemat = repelem(replaceval,nrows,nvars);
% replacetbl = array2table(replacemat);
% replacetbl.Properties.VariableNames = replaceNames;
% 
% end


 
%  types 'cell' and 'struct' are not supported by missing. Here, cell is
%  impelemented manually, but struct is not supported. A workaround for
%  using structs in tables is to wrap them in a cell. To implement struct()
%  would require at minimum making empty structs that mimic each field so
%  that they can be vertically catenated. Starting points would be:
%  https://www.mathworks.com/matlabcentral/answers/96973-how-can-i-concatenate-or-merge-two-structures
%  https://www.mathworks.com/matlabcentral/answers/315858-how-to-combine-two-or-multiple-structs-with-different-fields
%  https://www.mathworks.com/matlabcentral/fileexchange/7842-catstruct
%}