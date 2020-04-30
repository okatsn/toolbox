% under construction

function doit = warninginput(varargin)

default_message = ["This section only has to be done once. Press Y to return true.";...
                    "If no action return false "];
validstrchar = @(x) ischar(x)||isstring(x);
p = inputParser;
addParameter(p,'Message',default_message,validstrchar);
addParameter(p,'LeftButtonText','Yes (Return true)'); % if LeftButton clicked, doit will be true. Otherwise, false.
addParameter(p,'RightButtonText','Exit (Return false)');
addParameter(p,'FontSize',14);
addParameter(p,'CountDown',7);
parse(p,varargin{:});
prs = p.Results;
leftbuttontext = prs.LeftButtonText;
rightbuttontext = prs.RightButtonText;
doit = false;
yes_clicked = 0;
countdown = prs.CountDown;
countdown_i = countdown;
exit_clicked = false;

numelmsg = numel(prs.Message);
if numelmsg == 1 || ischar(prs.Message)
    mainstr = prs.Message;
    substr_pre = 'Retrun false';
else
    mainstr = strcat(prs.Message{1:numelmsg-1});
    substr_pre = prs.Message(end);    
end

substrfmt = '(%s after %.0f seconds)';
substr = sprintf(substrfmt,substr_pre,countdown);
msgfontsize = prs.FontSize;
% if nargin<1
%     str0 = 'This section only has to be done once. Press Y to return true.';
% elseif nargin == 1
%     str0 = varargin{1};
% else
%     str0 = varargin{1};
%     warning('[warninginput] 2nd (and thereinafter) input arguments are ignored.')
% end
windowwidth = 500;

hfig = figure('Name','Stopwatch',...
    'Numbertitle','off',...
    'Position',[600 500 windowwidth 150],...
    'Menubar','none',...
    'Resize','off');

Yes = uicontrol(hfig,'Style','PushButton',...
    'Position',[10, 10, windowwidth/2-15, 25],...
    'String',leftbuttontext,...
    'Callback',@startFcn);

uicontrol(hfig,'Style','PushButton',...
    'Position',[windowwidth/2+10, 10, windowwidth/2-15, 25],...
    'String',rightbuttontext,...
    'Callback',@closeRequestFcn);

uicontrol(hfig,'Style','text',...
    'Position',[10, 70, windowwidth-20, 80],...
    'BackgroundColor',[0.8 0.8 0.8],...
    'FontSize',msgfontsize,'String',mainstr); % fixed.

DISPLAY = uicontrol(hfig,'Style','text',...
    'Position',[10, 45, windowwidth-20, 25],...
    'BackgroundColor',[0.8 0.8 0.8],...
    'FontSize',12,'String',substr); % updated realtime
drawnow;
T0 = clock;
while countdown_i >= 0
    pause(0.1);
    if ~yes_clicked && ~exit_clicked
        T1 = clock;
        timeelapsed = etime(T1,T0);
        timeleft = countdown - timeelapsed;
        if timeleft < countdown_i
            substr = sprintf(substrfmt,substr_pre,timeleft);           
            set(DISPLAY,'String',substr);
            drawnow;
            countdown_i = countdown_i - 1;
        end

    else % if either button is clicked.
        return
    end
end
% if no button clicked

if ~yes_clicked && ~exit_clicked % no click until the end
    % to avoid error when you click exit at the last moment 
    % (in this case, it will close the figure and hence shouldn't be closed again)
    close(hfig); 
end
% htimer = timer;
% htimer.TimerFcn = @timerFcn;
% htimer.ExecutionMode = 'fixedRate';  
% htimer.Period = 0.1;
% % the Period property specifies the amount of time between executions; has no effect under 'singleShot'
% start(htimer);
% disp('after start function');

%   function timerFcn(varargin)
%       if ~clicked
%             T1 = clock;
%             timeelapsed = etime(T1,T0);
%             timeleft = countdown - timeelapsed;
%             if timeleft < countdown_i
%                 str1 = sprintf('(Return false after %.0f seconds)',timeleft);           
%                 set(DISPLAY,'String',str1);
%                 countdown_i = countdown_i - 1;
%             end
%             if countdown_i < 0
%                 closeRequestFcn;
%             end
% 
%       else % if clicked.
%             closeRequestFcn;
%       end
%     end


    function startFcn(varargin)
        % Start the Stopwatch
        doit = true;
        yes_clicked = 1;
        DISPLAY.String = 'Return True';
        pause(1);
        close(hfig);
    end

    function closeRequestFcn(varargin)
        % Stop the Timer
%         stop(htimer)
%         delete(htimer)
        

        % Close the Figure Window
%         closereq; % delete the current figure
        close(hfig);
        exit_clicked = true;
%         return % return is useless in callback function?
    end

end


