function [D] = shf_trial(MOV, D, fig, fig_name, varargin)
%% function [D] = shf_trial(MOV, D, fig, fig_name, varargin);
% Trial routine for Sequence Horizon Finger experiment
% called by the Subject routine (shf_subj.m)

%% Defaults
%sample = 2; % what proportion of 1000 is the sampling frequency
forceThres = 1;
goCue = 1500;
if (isempty(MOV))
    error('MOV file is empty!');
end;
%state    = MOV(:,1);
%realTime = MOV(:,2);
time     = MOV(:,3);
%sampfreq = 1000/sample;
force    = (MOV(:,4:13)); % finger force 
force    = smooth_kernel(force,4); % smoothed data
LH=[6 7 8 9 10]; %right hand column indices
RH=[1 2 3 4 5]; %left hand column indices

%%
A = fieldnames(D);
D.AllResponse   = [];
D.AllPress   = []; 
presscnt = 0; 
for i = 1:length(A)
    if length(A{i}) > 8
        if strcmp(A{i}(1:8) , 'response')
            presscnt = presscnt + 1;
            eval(['D.AllResponse = [D.AllResponse D.',A{i} , '];']);
        end
    end
end

presscnt = 0; 
for i = 1:length(A)
    if length(A{i}) > 5
        if strcmp(A{i}(1:5) , 'press') && ~strcmp(A{i}(6) , 'T')
            presscnt = presscnt + 1;
            eval(['D.AllPress = [D.AllPress D.',A{i} , '];']);
        end
    end
end

for prs = 0:presscnt - 1 
    pressName                    = ['D.pressTime' , num2str(prs)];    
    %D.AllPressIdx(:,prs + 1)     = (sampfreq/1000)* eval(pressName);
    D.AllPressTimes(:,prs + 1)   = eval(pressName);   
end
pressTimes = D.AllPressTimes;
D.IPI=diff(D.AllPressTimes);

D.AllResponse(~D.AllResponse) = NaN;
D.AllPress(~D.AllPress) = NaN;
D.AllPressTimes(~D.AllPressTimes) = NaN;
D.IPI(~D.IPI) = NaN;
 
% %%
% fNames=fieldnames(D);
% resp=[]; %which presses?
% for i=1:length(fNames)
%     if length(fNames{i})>8
%         if strcmp(fNames{i}(1:8),'response')
%             eval(['resp=[resp,D.',fNames{i},'];']);
%         end
%     end
% end
% D.numPress=sum(resp>0); %number of presses
% if D.numPress==14 %full sequence
%     pressTime=nan(1,D.numPress);
%     for press=1:D.numPress
%         pressNum=['D.pressTime',num2str(press-1)];
%         pressTime(press)=eval(pressNum); %time of press
%     end
%     D.pressTimes=pressTime;
%     D.IPI=diff(pressTime);
% else %incomplete sequence
%     pressTime=nan(1,D.numPress);
%     for press=1:D.numPress
%         pressNum=['D.pressTime',num2str(press-1)];
%         pressTime(press)=eval(pressNum); %time of press
%     end
% end

%% Display trial
if (fig>0)
    figure('Name',fig_name);
    set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
    if D.hand==1
        plot(time,force(:,LH),'LineWidth',2);
        title('Force traces for LEFT hand presses','FontSize',20);
    elseif D.hand==2
        plot(time,force(:,RH),'LineWidth',2);
        title('Force traces for RIGHT hand presses','FontSize',20);
    end
    xlabel('Time (ms)'); ylabel('Force (N)'); set(gca,'FontSize',20); %xlim([2500 4500]); ylim([-0.5 4.5]); axis square;
    hold on;
    drawline(pressTimes,'dir','vert', 'linestyle','-', 'color','r');
    drawline(goCue,'dir','vert', 'linestyle',':', 'color','g');
    drawline(forceThres,'dir','horz', 'linestyle','--', 'color','k');
    legend({'Thumb','Index','Middle','Ring','Little'},'FontSize',20)
end