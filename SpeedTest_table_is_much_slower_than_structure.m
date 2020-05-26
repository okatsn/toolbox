%% 1
sz = 25550; % e.g. total days
szr  = 50; % e.g. total 20 stations
varnames = {'a', 'b', 'c'};
t = table(randn(szr,sz),randn(szr,sz),randn(szr,sz), 'VariableNames', varnames);
colnames = t.Properties.VariableNames;
rownames = cellfun(@(x) ['St',num2str(x)],num2cell(1:szr),'UniformOutput',false);


s = struct();
for i = 1:szr
    for j = 1: length(varnames)
    s.(rownames{i}).(varnames{j}) = t{i,j};
    end
end


t.Properties.RowNames = rownames;
fprintf('iterations over all fields in a table: \n');
towrite = randn(1,sz);
tic;
for i = 1:szr
    for j = 1:numel(colnames)
%         a = t{rownames{i},colnames{j}};% to read
%         a = t(i,j);% to read
%         t{rownames{i},colnames{j}} = towrite;
        t.(colnames{j})(i,:) = towrite;
    end
    
end
toc
tbNm = 't';
fprintf('size of %s: %.3f MB\n',tbNm,whos(tbNm).bytes/1024/1024);

fprintf('iterations over all fields in a structure: \n');
tic;
for i = 1:szr
    for j = 1: length(varnames)
%         a = s.(rownames{i}).(varnames{j}); % to read
        s.(rownames{i}).(varnames{j}) = towrite;
    end
end
toc

tbNm = 's';
fprintf('size of %s: %.3f MB\n',tbNm,whos(tbNm).bytes/1024/1024);


% check if the table and structure has identical contents
for i = 1:szr
    for j = 1: length(varnames)
        if s.(rownames{i}).(varnames{j}) == t{rownames{i},colnames{j}}
        else
            error('They are incosistent');
        end
    end
end
%% 2
sz = 2555; % e.g. total days
szr  = 50; % e.g. total 20 stations
varnames = {'a', 'b', 'c','d','e'};
nov = length(varnames);

emptyrows = cell(szr,1);
vars = emptyrows;
vars(:) = {randn(1,sz)};
vararray = cell(1,nov);
vararray(:) = {vars};

t = table(vararray{:}, 'VariableNames', varnames);
colnames = t.Properties.VariableNames;
rownames = cellfun(@(x) ['St',num2str(x)],num2cell(1:szr),'UniformOutput',false);


s = struct();
for i = 1:szr
    for j = 1: nov
        s.(rownames{i}).(varnames{j}) = t{i,j};
    end
end


t.Properties.RowNames = rownames;
fprintf('iterations over all fields in a table: \n');
towrite = randn(1,sz);
tic;
for i = 1:szr
    for j = 1:numel(colnames)
%         a = t{rownames{i},colnames{j}};% to read
%         a = t(i,j);% to read
%         t{rownames{i},colnames{j}} = towrite;
        t.(colnames{j})(i,:) = {towrite};
    end
    
end
toc
tbNm = 't';
fprintf('size of %s: %.3f MB\n',tbNm,whos(tbNm).bytes/1024/1024);

fprintf('iterations over all fields in a structure: \n');
tic;
for i = 1:szr
    for j = 1: length(varnames)
%         a = s.(rownames{i}).(varnames{j}); % to read
        s.(rownames{i}).(varnames{j}) = {towrite};
    end
end
toc

tbNm = 's';
fprintf('size of %s: %.3f MB\n',tbNm,whos(tbNm).bytes/1024/1024);


% check if the table and structure has identical contents
for i = 1:szr
    for j = 1: length(varnames)
        if isequal(s.(rownames{i}).(varnames{j}) ,t{rownames{i},colnames{j}})
        else
            error('They are incosistent');
        end
    end
end


