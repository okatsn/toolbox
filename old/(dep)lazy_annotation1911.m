%  lazy_annotation(gcf_,'String','a,b,c;d,e,f','do','part_labels')
%  The dimentions have to be consistent.
%  e.g. lazy_annotation(gcf_,'String','a,b,c; ,d,e','do','part_labels')
function [a] = lazy_annotation(gcf_,varargin)
expected_do = {'simple','part_labels','part_labels(align)'};
valid_do = @(x) any(validatestring(x,expected_do));

p = inputParser;
addRequired(p,'gcf');
addParameter(p,'String','please add parameter "String" ');
addParameter(p,'do','simple');     
addParameter(p,'dim',[0,0,0.5,0.5]);     
addParameter(p,'shapeType','textbox');     
addParameter(p,'FontSize',15);     
addParameter(p,'Shift',[0 0]);
parse(p,gcf_,varargin{:});
rslt = p.Results; 
gcf_ = rslt.gcf; 
dim = rslt.dim; 
shapeType = rslt.shapeType;
string_ = rslt.String;
task = rslt.do;
FontSize_1 = rslt.FontSize;  shift = rslt.Shift;


switch task
    case 'simple'
        annotation(gcf_,shapeType,dim,'String',string_);
    case {'part_labels','part_labels(align)'}
        fprintf('shift of part-label (from top-left corner): [%.2f %.2f]',shift(1),shift(2));
% gcf_= gcf; shapeType = 'textbox';string_ = 'a,b,c;d,e,f'; % for TEST
        rows = strsplit(string_,';'); % split string by ';'
        % rows will be e.g. 1กั2 cell array: {{'a,b,c'},{'d,e,f'}}
        tmp = regexp(rows(:),'[^,|;]*','match');
        % tmp will be e.g. 2กั1 cell array:    {{1กั3 cell};{1กั3 cell}}
        part_labels = vertcat(tmp{:});
        % part_labels will be e.g.   2กั3 cell array { {'a'},{'b'},{'c'}; {'d'},{'e'},{'f'} }
        [nrows,ncols] = size(part_labels);

        ax = gcf_.Children.findobj('-regexp', 'Type', 'axes');
        iters = numel(ax);
        x0y0 = NaN(iters,2); % list of upper-left corner positions of axes.       
        for i = 1:iters
%             x0y0(i,1) = ax(i).Position(1);
%             x0y0(i,2) = ax(i).Position(2)+ax(i).Position(4);
            x0y0(i,1) = ax(i).OuterPosition(1);
            x0y0(i,2) = ax(i).OuterPosition(2)+ax(i).OuterPosition(4);
        end
        up_left = sortrows(x0y0,2,'descend'); % sort by y_starts.
        C = mat2cell(up_left,[ncols ncols],[2]); % [xstart ystart] has dimension [2].
        % e.g.: C{1} will be xystart of {(a), (b) ,(c)}, but not in the order of (a), (b) ,(c).
        % e.g.: C{2} will be xystart of {(d), (e) ,(f)}, but not in the order of (d), (e) ,(f).

        xy_start = [];
        C_sum = zeros(ncols,2); % [xstart ystart] has dimension [2].
        for i = 1:nrows
            C_sorted{i} = sortrows(C{i});  % sort by x_starts.
            y_avg(i) = mean(C_sorted{i}(:,2)); % (:,2) for y_starts
            C_sum = C_sum + C_sorted{i};    
            tmp2_1 = reshape(C_sorted{i}',1,nrows*ncols);
            xy_start = [xy_start ; tmp2_1];
        end
        x_avg = C_sum(:,1)/nrows; % (:,1) for x_starts
%         y_avg = y_avg';        x_avg = x_avg'; % just for easy reading.
        if any(regexp(task,'align'))
            xy_start = [];
            for i = 1:nrows
                C_sorted{i}(:,1) = x_avg;
                C_sorted{i}(:,2) = y_avg(i);
                tmp2_1 = reshape(C_sorted{i}',1,nrows*ncols);
                xy_start = [xy_start ; tmp2_1];
            end
        end      
%         assignin('base','up_left',up_left); % For debug
        xparts = ones(1,nrows); yparts = 2*ones(1,ncols);
        C2 = mat2cell(xy_start,xparts,yparts); % [xstart ystart] has dimension [2].
        
        labels = cell(nrows,1); 

        for i = numel(C2)
%             labels{i} = regexp(rows{i},'[^,|;]*','match'); % find something that is not comma or not ';'.
%             endcols = k+numel(labels{i})-1;
%             up_left_i = sortrows(up_left(k:endcols, :),1);
%             ystart(i) = mean(up_left_i(:,2));
%             x_avg = [up_left_i]
%             ncols(i) = numel(labels{i});
            
%             if i==2
%             assignin('base','up_left_2',up_left_i); % For debug
%             assignin('base','labels_2',labels{i}); % For debug
%             end
%             
%             if i==1
%             assignin('base','up_left_1',up_left_i); % For debug
%             assignin('base','labels_1',labels{i}); % For debug
%             end

            
%             for j = 1:ncols(i)
%                 tag_to = up_left_i(j,:) + shift;
%                 dim{i}{j} = [tag_to, 0.08 0.1];
%                 assignin('base','dim',dim); % For debug           
%                 annotation(gcf_,shapeType,dim,'String',labels{i}{j},'LineStyle','none',...
%                     'FontSize',FontSize_1,'HorizontalAlignment','left','VerticalAlignment','bottom',...
%                     'Tag','part_label'); 
            end
            k = k + ncols;
        end
        assignin('base','up_left_sorted',up_left_i); % For debug
        
        
        
        for i = 1:nrows
            for j = 1:ncols(i)
                    annotation(gcf_,shapeType,dim,'String',labels{i}{j},'LineStyle','none',...
                    'FontSize',FontSize_1,'HorizontalAlignment','left','VerticalAlignment','bottom',...
                    'Tag','part_label'); 
                
            end
        end
        

                % 'Tag','part_label' allows findall(gcf,'Tag','part_label'); 
                % otherwise, annotation cannot be obtained
        
        
        
        
        
              
end
end

