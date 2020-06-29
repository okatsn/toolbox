function [C,outside_thr_ind,inside_thr_ind,varargout] = split1dArrayByThreshold(Y_i,thr)
% split the input time series Yi by a certain threshold thr.
% output arguments 1 to 3:
%     [C,outside_thr_ind,inside_thr_ind] = split1dArrayByThreshold(Y_i,thr)
%         - 'inside_thr': Y<thr, or Y>thr(1) && Y<thr(2)
%         - 'outside_thr': Y>thr, or Y<thr(1) && Y>thr(2)
%         - outside_thr_segments: the segments satisfying the 'outside_thr' criterion.
%             - outside_thr_segments = C(outside_thr_ind);
%         - inside_thr_segments: the segments satisfying the 'inside_thr' criterion.
%             - inside_thr_segments = C(inside_thr_ind);
% 
% output arguments 4:
%     [~,~,~,durations] = split1dArrayByThreshold(Y_i,thr)
%         - durations_Y_outside = durations(outside_thr_ind);
%         - durations_Y_inside = durations(inside_thr_ind);
% 
% output arguments 5 to 6:
%     [~,~,~,~,Y_outside_ind,Y_inside_ind] = split1dArrayByThreshold(Y_i,thr)
%         - Y_outside = Yi(Y_outside_ind);
%         - Y_inside = Yi(Y_inside_ind);
%     try this:
%         O = EulerSDE_a(D,r,100);
%         [~,~,~,~,Youtind,Yinind] = split1dArrayByThreshold(O.Y,[-1,1]);
%         figure; plot(O.X(Youtind),O.Y(Youtind),'*'); hold on; plot(O.X(Yinind),O.Y(Yinind),'o')
    
    
Y = Y_i(:); % to make sure Y is N by 1.
Y2 = Y;

lenthr = length(thr);
if lenthr == 1
    Y2(Y2<thr) = NaN;
elseif lenthr
    thr = sort(thr); 
    Y2(Y>thr(1) & Y<thr(2)) = NaN;
else
    error('thr must be scalar or 2-element vector.');
end

id_nan = isnan(Y2);
notNaN = ~id_nan;
sizeY_dim2 = size(Y,2);
id_nansplit = diff(id_nan); % indicates the midpoints that separate NaN and non-NaN elements.
id_cross = adjMultiply(Y2) < 0; % indicates the midpoints where Y(i)*Y(i - 1) are negative.
% ... that is, Y transits from positive to negative, or vice versa.
id_bothOutside = adjAND(notNaN); % indicates the midpoints where both Y(i) and Y(i - 1) are not NaN.
% ... that is, Y(i) and Y(i - 1) are outside thr.
id_nonansplit = and(id_cross, id_bothOutside);
id_split = or(id_nansplit,id_nonansplit);
id_split_ext = [1;id_split;1];
edges = find(id_split_ext); % the edges/boundaries for segments.
id_nonansplit_ext = [0;id_nonansplit;0];
edges2 = sort([edges; find(id_nonansplit_ext)]);
durations = diff(edges2); % the duration/numel of each segment.
C = mat2cell(Y,durations(:),sizeY_dim2);
lenC = length(durations);

firstseg = C{1};
if isnan(Y2(1)) || isempty(firstseg) % all is faster than any
    % NaN and non-NaN segments should occur in turn.
    % Hence if firstseg is all nan, then 1:2:end indicates the inside_thr
    % segments.
    outside_thr_ind = 2:2:lenC;
    inside_thr_ind = 1:2:lenC;
else % first segment is not nan or empty
    outside_thr_ind = 1:2:lenC;
    inside_thr_ind = 2:2:lenC;
end

if nargout > 3 % 4th output argument
    varargout{1} = durations;
    
    if nargout > 4 % 5th argument
        id1s = csum(durations);
        id0s = [1;id1s(1:end - 1)+1];
        Y_outside_ind = julialikerange(id0s(outside_thr_ind),id1s(outside_thr_ind));
        varargout{2} = Y_outside_ind;
        if nargout > 5 % 6th argument
            Y_inside_ind = julialikerange(id0s(inside_thr_ind),id1s(inside_thr_ind));
            varargout{3} = Y_inside_ind;
        end
        
    end
end

% https://www.mathworks.com/matlabcentral/answers/335333-split-array-into-separate-arrays-at-row-with-nans
%% test example

% M = [NaN;NaN;0;2;NaN;NaN;NaN;4;6;NaN;NaN;8;9;10;NaN;NaN];
% M = [0;2;NaN;4;6;NaN;NaN;8;9;10;NaN;NaN];
% M = [0;2;NaN;4;6;NaN;NaN;8];
% M = [0;2;4;6;8];
%  id_nan = isnan(M);
%  diff_id_nan = diff(id_nan);
%  B = [1;diff_id_nan;1];
%  id_y = find(B);
%  id_z = diff(id_y);
%  C = mat2cell(M,id_z(:),size(M,2));

end

