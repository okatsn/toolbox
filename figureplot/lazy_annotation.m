function [ax_simple] = lazy_annotation(gcf_,text_,varargin)
% lazy_annotation(gcf,'(a),(b);(c),(d)','do','part_labels','FontSize',16);
%  The dimentions have to be consistent.
%  e.g. lazy_annotation(gcf_,'String','a,b,c; ,d,e','do','part_labels')
% lazy_annotation(gcf,'Rc = 2','Position',[0.6,0.9]); % auto fit textbox to the text
% lazy_annotation(gcf,'Rc = 2','Position',[0.6,0.9 0.4 0.1]); % custom textbox width = 0.4; height = 0.1;
expected_do = {'simple','part_labels','part_labels_align'};
dftOpt = {'FitBoxToText','on','LineStyle','none'};
valid_do = @(x) any(validatestring(x,expected_do));

% [Results,varargin] = inputParser2(varargin,{'latex'});

p = inputParser;
addRequired(p,'gcf');
% addParameter(p,'String','please add parameter "String" ');
addParameter(p,'do','simple',valid_do);     
addParameter(p,'Position',[0.5,0.5]);     
addParameter(p,'shapeType','textbox');     
addParameter(p,'Options',dftOpt);
addParameter(p,'FontSize',10);     
addParameter(p,'Shift',[0 0]);
parse(p,gcf_,varargin{:});
rslt = p.Results; 
gcf_ = rslt.gcf; 
dim = rslt.Position; 
shapeType = rslt.shapeType;
% text_ = rslt.String;
task = rslt.do;
FontSize_1 = rslt.FontSize;  shift = rslt.Shift;
boxWidth = 0.1;
boxHeight = 0.05;

Length_dim = length(dim);
switch Length_dim
    case 2 % assign only the position. width and height of textbox will automatically fit the text.
        dim = [dim,0.05,0.05];
    case 4 % if input dimension is 4, then FitBoxToText should be off or the customized dimension will be reset.
        [~,findatlocb] = ismember({'FitBoxToText'},dftOpt);
        % dftOpt  must be cell arrays of character vectors. If there is a number then it fail. 
        % This is why Options = [dftOpt,rslt.Options]; have to be after this.
        dftOpt(findatlocb+1) = {'off'};

    otherwise
end

dftOpt = [dftOpt,{'FontSize',FontSize_1}];
Options = [dftOpt,rslt.Options];

% if Results.latex
%     Options = [Options,{'interpreter','latex'}];
% end

switch task
    case 'simple'
        ax_simple = annotation(gcf_,shapeType,dim,'String',text_,Options{:});
    case {'part_labels','part_labels_align'}
        fprintf('shift of part-label (from top-left corner): [%.2f %.2f]\n',shift(1),shift(2));
% gcf_= gcf; shapeType = 'textbox';string_ = 'a,b,c;d,e,f'; % for TEST
        rows = strsplit(text_,';'); % split string by ';'
        % rows will be e.g. 1¡Ñ2 cell array: {{'a,b,c'},{'d,e,f'}}
        tmp = regexp(rows(:),'[^,|;]*','match');
        % tmp will be e.g. 2¡Ñ1 cell array:    {{1¡Ñ3 cell};{1¡Ñ3 cell}}
        part_labels = vertcat(tmp{:});
        % part_labels will be e.g.   2¡Ñ3 cell array { {'a'},{'b'},{'c'}; {'d'},{'e'},{'f'} }
        [nrows,ncols] = size(part_labels);

        ax = gcf_.Children.findobj('-regexp', 'Type', 'axes');
        iters = numel(ax);
        x0y0 = NaN(iters,2); % list of upper-left corner positions of axes.       
        for i = 1:iters
%             x0y0(i,1) = ax(i).Position(1);
%             x0y0(i,2) = ax(i).Position(2)+ax(i).Position(4);
            x0y0(i,1) = max([ax(i).OuterPosition(1),0]);
            x0y0(i,2) = max([ax(i).OuterPosition(2)+ax(i).OuterPosition(4),0]);
        end
        up_left = sortrows(x0y0,2,'descend'); % sort by y_starts.
        C = mat2cell(up_left,[ncols*ones(1,nrows)],[2]); % [xstart ystart] has dimension [2].
        % e.g.: C{1} will be xystart of {(a), (b) ,(c)}, but not in the order of (a), (b) ,(c).
        % e.g.: C{2} will be xystart of {(d), (e) ,(f)}, but not in the order of (d), (e) ,(f).

        xy_start = [];
        C_sum = zeros(ncols,2); % [xstart ystart] has dimension [2].
        for i = 1:nrows
            C_sorted{i} = sortrows(C{i});  % sort by x_starts.
            y_avg(i) = mean(C_sorted{i}(:,2)); % (:,2) for y_starts
            C_sum = C_sum + C_sorted{i};    
            tmp2_1 = reshape(C_sorted{i}',1,2*ncols);
            xy_start = [xy_start ; tmp2_1];
        end
        x_avg = C_sum(:,1)/nrows; % (:,1) for x_starts
%         y_avg = y_avg';        x_avg = x_avg'; % just for easy reading.
        if any(regexp(task,'align'))
            xy_start = [];
            for i = 1:nrows
                C_sorted{i}(:,1) = x_avg;
                C_sorted{i}(:,2) = y_avg(i);
                tmp2_1 = reshape(C_sorted{i}',1,2*ncols);
                xy_start = [xy_start ; tmp2_1];
            end
        end      

        xparts = ones(1,nrows); yparts = 2*ones(1,ncols);
        C2 = mat2cell(xy_start,xparts,yparts); % [xstart ystart] has dimension [2].
%         assignin('base','C2',C2); % For debug
        
        NC2 = numel(C2);
        if size(shift,1) == 1
            shift = repmat(shift,NC2,1);
        end

        for i = 1:NC2
            dim = [C2{i}+shift(i,:), boxWidth, boxHeight];
            dim(2) = min(1-boxHeight,dim(2)); % to avoid
            
            ax_simple(i) = annotation(gcf_,shapeType,dim,'String',part_labels{i},'LineStyle','none',...
                'FontSize',FontSize_1,'HorizontalAlignment','left','VerticalAlignment','bottom',...
                'Tag','part_label'); 
                % 'Tag','part_label' allows findall(gcf,'Tag','part_label'); 
                % otherwise, annotation cannot be obtained

        end
        
                  
end
end
