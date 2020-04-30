function [varargout] = sec2str(varargin)
% input seconds, output e.g. 3 hr 2 min 5 sec
% speed test: 100000 runs cost 1 sec.
varargout = cell(1,nargout);
for i = 1:nargout%length(varargin)
    timeinsec = varargin{i};

    if timeinsec>=86400
        timeinday = timeinsec*1.1574e-05;
        suffix = 'day';
        str1 = sprintf('%.1f %s',timeinday,suffix);
        varargout{i} = str1;
        continue
    end

    if timeinsec<86400 && timeinsec>=3600
        suffix = 'hr';
        timeinhr = timeinsec*2.778e-04;
        str1 = sprintf('%.1f %s',timeinhr,suffix);
        varargout{i} = str1;
        continue
    end

    if timeinsec<3600 && timeinsec>=60
        suffix = 'min';
        timeinmin = timeinsec*0.0167;
        str1 = sprintf('%.1f %s',timeinmin,suffix);
        varargout{i} = str1;
        continue
    end

    if timeinsec<60
        suffix = 'sec';
        str1 = sprintf('%d %s',round(timeinsec),suffix);
        varargout{i} = str1;
        continue
    end
    
end






end

