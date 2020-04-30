% under construction

function doit = warninginput(varargin)
doit = false;
yes_clicked = 0;
countdown = 7;
countdown_i = countdown;
exit_clicked = false;
str1 = sprintf('(Return false after %d seconds)',countdown);
if nargin<1
    str0 = 'This section only has to be done once. Press Y to return true.';
elseif nargin == 1
    str0 = varargin{1};
else
    str0 = varargin{1};
    warning('[warninginput] 2nd (and thereinafter) input arguments are ignored.')
end

hfig = figure('Name','Stopwatch',...
    'Numbertitle','off',...
    'Position',[600 500 350 150],...
    'Menubar','none',...
    'Resize','off');

Yes = uicontrol(hfig,'Style','PushButton',...
    'Position',[10 10 75 25],...
    'String','Yes (Y)',...
    'Callback',@startFcn);

uicontrol(hfig,'Style','PushButton',...
    'Position',[265 10 75 25],...
    'String','EXIT (X)',...
    'Callback',@closeRequestFcn);

uicontrol(hfig,'Style','text',...
    'Position',[10 70 330 80],...
    'BackgroundColor',[0.8 0.8 0.8],...
    'FontSize',14,'String',str0); % fixed.

DISPLAY = uicontrol(hfig,'Style','text',...
    'Position',[10 45 330 25],...
    'BackgroundColor',[0.8 0.8 0.8],...
    'FontSize',12,'String',str1); % updated realtime
drawnow;
T0 = clock;
while countdown_i >= 0
    pause(0.1);
    if ~yes_clicked && ~exit_clicked
        T1 = clock;
        timeelapsed = etime(T1,T0);
        timeleft = countdown - timeelapsed;
        if timeleft < countdown_i
            str1 = sprintf('(Return false after %.0f seconds)',timeleft);           
            set(DISPLAY,'String',str1);
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


