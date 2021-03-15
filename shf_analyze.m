function [varargout] = shf_analyze(what, varargin)
%% function [varargout] = shf_analyze(what, varargin)
% Sequence Horizon Finger experiment: analysis of behavioral data
%
% usage|example calls:
%
%                       shf_analyze('all_subj');                                %pre-analysis: run the subject routine for all_subj
%                       shf_analyze('all_subj', 1, 'CG1'});                     %pre-analysis: run the subject routine for selected subjects
%                       [all_data] = shf_analyze('all_data');                   %pre-analysis: create .mat file containing data from subjects in subj
%                       [D] = shf_analyze('horizon_MT');
%                       [D] = shf_analyze('horizon_RT');
%                       [D] = shf_analyze('horizon_ACC');
%                       [D] = shf_analyze('horizon_IPI');
%                       [D] = shf_analyze('exp_model_MT', 'thres',99, 'sim',0, 'analysis','split_half');
%                       [D] = shf_analyze('plot_exp_model_MT', 'thres',99, 'sim',0, 'analysis','split_half');
%                       [D] = shf_analyze('error_analysis');
%                       [D] = shf_analyze('percept_control');
%                       [D] = shf_analyze('fixation_strategy');
%
% --
% gariani@uwo.ca - 2020.04.09

%% paths
%pathToData = '/Volumes/MotorControl/data/SeqEye2/SEp/data';
pathToData = '/Users/giacomo/Documents/data/SeqHorizonFinger/shf';
pathToAnalyze = '/Users/giacomo/Documents/data/SeqHorizonFinger/shf/analyze';
if ~exist(pathToAnalyze, 'dir'); mkdir(pathToAnalyze); end % if it doesn't exist already, create analyze folder

%% globals
subj = {
    's01', ...'s02', ...
    's03', 's04', 's05', 's06', 's07', 's08', ...
    's09', 's10', 's11', 's12', 's13', 's14', 's15', ...
    };
subid = {
    'CG1', ...'HB1', ...
    'AT1', 'SR1', 'NL1', 'CB1', 'JT1', 'YM1', ...
    'DW1', 'IB1', 'MZ1', 'CC1', 'RA1', 'DK1', 'JM1', ...
    };
% incomplete subj: 'AS1', 'JJ1'
% high-error subj: 's02_HB1' (>25% on avg)
ns = numel(subj);
subvec = zeros(1,ns);
for i = 1:ns; subvec(1,i) = str2double(subj{i}(2:3)); end

% colors
cbs_red = [213 94 0]/255;
cbs_blue = [0 114 178]/255;
cbs_yellow = [240 228 66]/255;
cbs_pink = [204 121 167]/255;
cbs_green = [0 158 115]/255;
blue = [49,130,189]/255;
lightblue = [158,202,225]/255;
red = [222,45,38]/255;
lightred = [252,146,114]/255;
green = [49,163,84]/255;
lightgreen = [161,217,155]/255;
orange = [253,141,60]/255;
yellow = [254,196,79]/255;
lightyellow = [255,237,160]/255;
purple = [117,107,177]/255;
lightpurple = [188,189,220]/255;
darkgray = [50,50,50]/255;
gray2 = [100,100,100]/255;
gray = [150,150,150]/255;
lightgray = [200,200,200]/255;
silver = [220,220,220]/255;
black = [0,0,0]/255;
white = [255,255,255]/255;

% plot defaults
fs = 24; % default font size for all figures
lw = 4;  % default line width for all figures
ms = 6; % default marker size for all figures

% styles
style.reset;
style.custom({blue,lightblue,red,lightred,orange,yellow,lightyellow,purple,lightpurple,darkgray,gray,gray2,lightgray,green,lightgreen,black,silver,white,...
    cbs_red,cbs_yellow,cbs_blue,cbs_green,cbs_pink});
lrnsty = style.custom({red, blue}, 'markerfill',{red, blue}, 'markersize',ms, 'linewidth',lw);%, 'errorbars','shade');
lightsty = style.custom({lightgray}, 'markertype','none', 'linewidth',1.5);
allsubsty = style.custom({lightgray}, 'markertype','none', 'errorbars','none', 'linewidth',1.5);
allsubsty2 = style.custom({silver}, 'linewidth',1, 'sizedata',100, 'markertype','none');
alldaysty = style.custom({red, lightred, lightgray, lightblue, blue}, 'linewidth',1, 'errorbars','shade', 'sizedata',100);
%darksty = style.custom({gray}, 'markertype','none', 'linewidth',2);
%grsty = style.custom({lightgray}, 'markerfill',{lightgray}, 'markersize',ms, 'linewidth',lw, 'linestyle','-', 'errorbars','shade');
%dgsty = style.custom({gray2}, 'markerfill',{gray2}, 'markersize',ms, 'linewidth',lw, 'linestyle','-', 'errorbars','shade');
bksty2 = style.custom({black}, 'markerfill',{black}, 'markertype','o', 'markersize',ms, 'linewidth',lw, 'linestyle','-', 'errorbars','plusminus', 'sizedata',200);
bksty = style.custom({black}, 'markerfill',{black}, 'markertype','o', 'markersize',ms, 'linewidth',lw, 'linestyle','-', 'errorbars','plusminus');

plansty = style.custom({purple, green, orange}, 'markerfill',{purple, green, orange}, 'markersize',ms, 'linewidth',lw);
planstylight = style.custom({lightpurple, lightgreen, yellow}, 'markerfill',{lightblue, lightgreen, lightyellow}, 'markersize',ms, 'linewidth',2);
plansty0 = style.custom({purple}, 'markerfill',{purple}, 'markersize',ms, 'linewidth',lw, 'errorbars','plusminus');
plansty1 = style.custom({green}, 'markerfill',{green}, 'markersize',ms, 'linewidth',lw, 'errorbars','shade');
plansty2 = style.custom({orange}, 'markerfill',{orange}, 'markersize',ms, 'linewidth',lw, 'errorbars','shade');
horsty = style.custom({darkgray, gray2, gray, lightgray}, 'markerfill',{darkgray, gray2, gray, lightgray}, 'markersize',ms, 'linewidth',lw, 'errorbars','shade');

% plansty = style.custom({lightgray, gray, black}, 'markerfill',{lightgray, gray, black}, 'markersize',ms, 'linewidth',lw);
% planstylight = style.custom({lightgray, lightgray, lightgray}, 'markerfill',{lightgray, lightgray, lightgray}, 'markersize',ms, 'linewidth',2);
% plansty2 = style.custom({black}, 'markerfill',{black}, 'markersize',ms, 'linewidth',lw, 'errorbars','shade');
% plansty1 = style.custom({gray}, 'markerfill',{gray}, 'markersize',ms, 'linewidth',lw, 'errorbars','shade');
% plansty0 = style.custom({lightgray}, 'markerfill',{lightgray}, 'markersize',ms, 'linewidth',lw, 'errorbars','plusminus');
% horsty = style.custom({darkgray, gray2, gray, lightgray}, 'markerfill',{darkgray, gray2, gray, lightgray}, 'markersize',ms, 'linewidth',lw);%, 'errorbars','shade');

d5sty = style.custom({blue}, 'markerfill',{blue}, 'markersize',ms, 'linewidth',lw, 'linestyle','-', 'errorbars','shade');
d5box = style.custom({lightblue}, 'markertype','none', 'linewidth',1.5, 'errorbars','none');
d1sty = style.custom({red}, 'markerfill',{red}, 'markersize',ms, 'linewidth',lw, 'linestyle','-', 'errorbars','shade');
d1box = style.custom({lightred}, 'markertype','none', 'linewidth',1.5, 'errorbars','none');
daysty = style.custom({red, blue}, 'markerfill',{red, blue}, 'markersize',ms, 'linewidth',lw, 'errorbars','shade');
diffsty = style.custom({black}, 'markerfill',{black}, 'markersize',ms, 'linewidth',lw, 'linestyle','-', 'errorbars','shade');
diffbox = style.custom({lightgray}, 'markerfill',{lightgray}, 'markersize',ms, 'linewidth',2, 'linestyle','-', 'errorbars','shade');

% d5sty = style.custom({darkgray}, 'markerfill',{darkgray}, 'markersize',ms, 'linewidth',lw, 'linestyle','-', 'errorbars','shade');
% d5box = style.custom({lightgray}, 'markertype','none', 'linewidth',2);
% d1sty = style.custom({gray}, 'markerfill',{gray}, 'markersize',ms, 'linewidth',lw, 'linestyle','-', 'errorbars','shade');
% d1box = style.custom({lightgray}, 'markertype','none', 'linewidth',2);
% daysty = style.custom({gray, darkgray}, 'markerfill',{gray, darkgray}, 'markersize',ms, 'linewidth',lw, 'errorbars','shade');
% diffsty = style.custom({black}, 'markerfill',{black}, 'markersize',ms, 'linewidth',lw, 'linestyle','-', 'errorbars','shade');
% diffbox = style.custom({lightgray}, 'markerfill',{lightgray}, 'markersize',ms, 'linewidth',2, 'linestyle','-', 'errorbars','shade');

% legends
lrnleg = {'Day 1', 'Day 5'};
planleg = {'S-R mapping', 'Preplanning','Online planning'};
horleg = {'W = 1', 'W = 2', 'W = 3', 'W = 4+'};

%% types of analysis
switch (what)
    case 'all_subj' % pre-analysis: run the subject routine for all_subj
        if nargin>1; subvec = varargin{1}; subid = varargin{2}; end
        for s = 1:ns
            shf_subj(subvec(s), subid{s}, 0); % run shf_subj.m routine (without plot)
        end
        
    case 'all_data' % pre-analysis: create .mat file containing data from all subjects
        all_data = [];
        for s = 1:ns
            fprintf('\n%s\n\n', subj{s});
            D = load(fullfile(pathToAnalyze, sprintf('shf_%s.mat', subj{s}))); % load data structure for each subject
            
            %-------------------------------------------------------------------------------------------------------------------------------------
            % remove extra fields
            fdn = fieldnames(D);
            D = rmfield(D, fdn([4,61:65,67]));
            
            %-------------------------------------------------------------------------------------------------------------------------------------
            % add info about subject numbers, RT, days, IPI numbers, and bad presses
            D.IPInum = repmat(1:13, numel(D.TN),1);
            D.SN(1:numel(D.TN), 1) = subvec(s);
            D.RT = D.AllPressTimes(:,1)-1500;
            BlPerDay = {1:11, 12:22, 23:33, 34:44, 45:55};
            D.Day = zeros(size(D.BN));
            for d = 1:length(BlPerDay)
                D.Day(ismember(D.BN , BlPerDay{d})) = d;
            end
            D.badPress = D.AllPress ~= D.AllResponse;
            
            %-------------------------------------------------------------------------------------------------------------------------------------
            % keep random sequences only (remove chunks and structured sequences)
            D = getrow(D, D.seqNumb==0);
            
            %-------------------------------------------------------------------------------------------------------------------------------------
            % append data structures from each subject
            all_data = addstruct(all_data, D);
        end
        save( fullfile( pathToAnalyze, 'shf_all_data.mat'), '-struct', 'all_data'); % save all_data.mat file
        varargout = {all_data};
        
    case 'horizon_MT' % MT vs horizon
        if nargin>1 % load single subj data
            subj = varargin{1};
            D = load( fullfile(pathToData, sprintf('shf_%s.mat', subj)));
        else % load group data
            D = load( fullfile(pathToAnalyze, 'shf_all_data.mat'));
        end
        
        % pool days
        D.Day(D.Day==2) = 3;
        D.Day(D.Day==3) = 3;
        D.Day(D.Day==4) = 3;
        
        % open multi-panel figure
        figure('Name', 'Horizon MT'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
        
        % ------------------------------------------------------------------------------------------------------
        % summarize data
        T = tapply(D, {'SN', 'Horizon'}, ...
            {D.MT, 'nanmean', 'name', 'MT'}, ...
            'subset',D.isError==0);
        T = normData(T, {'MT'});
        % plot data
        subplot(2,2,1);
        plt.box(T.Horizon, T.normMT/1000, 'style',lightsty);
        %plt.line(T.Horizon, T.MT/1000, 'split',T.SN, 'style',allsubsty, 'leg','none');
        hold on;
        plt.line(T.Horizon, T.normMT/1000, 'plotfcn','nanmean', 'style',bksty); axis square;
        xlabel('Viewing window (W)'); ylabel('Movement time (s)'); set(gca,'fontsize',fs); ylim([3 8]);
        % stats
        T.ANOVA = anovaMixed(T.MT, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 1:13));
        T.ANOVA = anovaMixed(T.MT, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 2:13));
        T.ANOVA = anovaMixed(T.MT, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 3:13));
        T.ANOVA = anovaMixed(T.MT, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 4:13));
        
        TT = tapply(D, {'SN'}, ...
            {D.MT, 'nanmean', 'name', 'MT2', 'subset',D.Horizon == 2}, ...
            {D.MT, 'nanmean', 'name', 'MT313', 'subset',D.Horizon > 2}, ...
            {D.MT, 'nanmean', 'name', 'MT3', 'subset',D.Horizon == 3}, ...
            {D.MT, 'nanmean', 'name', 'MT413', 'subset',D.Horizon > 3}, ...
            {D.MT, 'nanmean', 'name', 'MT4', 'subset',D.Horizon == 4}, ...
            {D.MT, 'nanmean', 'name', 'MT513', 'subset',D.Horizon > 4});
        ttest(TT.MT2, TT.MT313, 2, 'paired');
        ttest(TT.MT3, TT.MT413, 2, 'paired');
        ttest(TT.MT4, TT.MT513, 2, 'paired');
        
        % ------------------------------------------------------------------------------------------------------
        % summarize data
        T2 = tapply(D, {'SN', 'Horizon', 'Day'}, ...
            {D.MT, 'nanmean', 'name', 'MT'});
        % stats
        T.ANOVA = anovaMixed(T2.MT, T2.SN,'within', [T2.Horizon T2.Day], {'Horizon', 'Day'}, 'subset',T2.Day~=3);
        T = tapply(D, {'SN', 'Horizon'}, ...
            {D.MT, 'nanmean', 'name', 'MT'}, ...
            {D.MT, 'nanmean', 'name', 'MTd1', 'subset',D.Day==1}, ...
            {D.MT, 'nanmean', 'name', 'MTd5', 'subset',D.Day==5});
        T = normData(T, {'MTd1', 'MTd5', 'MT'});
        % plot data
        subplot(222); %hold on;
        %plt.line(T2.Horizon, T2.MT/1000, 'split',T2.Day, 'style',daysty, 'leg',lrnleg, 'plotfcn','nanmean', 'subset',T2.Day~=3);
        %keyboard; cla;
        plt.box(T.Horizon, T.normMTd1/1000, 'style',d1box, 'leg','skip');
        %plt.line(T.Horizon, T.MTd1/1000, 'split',T.SN, 'style',d1box, 'leg','skip');
        hold on;
        plt.box(T.Horizon, T.normMTd5/1000, 'style',d5box, 'leg','skip');
        %plt.line(T.Horizon, T.MTd5/1000, 'split',T.SN, 'style',d5box, 'leg','skip');
        hold on;
        [T.x1,T.y1]=plt.line(T.Horizon, T.normMTd1/1000, 'style',d1sty);
        hold on;
        [T.x5,T.y5]=plt.line(T.Horizon, T.normMTd5/1000, 'style',d5sty);
        ylabel('MT (s)'); set(gca,'fontsize',fs); axis square; ylim([3 8]);
        
        % ------------------------------------------------------------------------------------------------------
        % summarize data
        T = tapply(D, {'SN', 'Horizon'}, ...
            {D.MT, 'nanmean', 'name', 'MT'}, ...
            {D.MT, 'nanmean', 'name', 'MTd1', 'subset',ismember(D.Day,1)}, ...
            {D.MT, 'nanmean', 'name', 'MTd5', 'subset',ismember(D.Day,5)});
        % plot data
%         subplot(223);
%         %plt.line(T.Horizon, (nanplus(T.normMTd1,-T.normMTd5)./T.normMT)*100, 'split',T.SN, 'style',allsubsty, 'leg','none');
%         plt.line(T.Horizon, (nanplus(T.normMTd1,-T.normMTd5)), 'split',T.SN, 'style',allsubsty, 'leg','none');
%         hold on;
%         %plt.line(T.Horizon, (nanplus(T.normMTd1,-T.normMTd5)./T.normMT)*100, 'plotfcn','nanmean', 'style',diffsty);
%         plt.line(T.Horizon, (nanplus(T.normMTd1,-T.normMTd5)), 'plotfcn','nanmean', 'style',diffsty);
%         xlabel('Viewing window (W)'); ylabel('MT difference (% of avg MT)'); set(gca,'fontsize',fs); axis square;
%         drawline(0, 'dir','horz', 'linestyle','-.');
%         %ylim([-15 65]);
        subplot(223);
        plt.box(T.Horizon, (nanplus(T.MTd1,-T.MTd5)./T.MT)*100, 'style',diffbox, 'plotall',0);
        hold on;
        plt.line(T.Horizon, (nanplus(T.MTd1,-T.MTd5)./T.MT)*100, 'plotfcn','nanmean', 'style',diffsty);
        xlabel('Viewing window (W)'); ylabel('MT difference (% of avg MT)'); set(gca,'fontsize',fs); axis square;
        drawline(0, 'dir','horz', 'linestyle','-.'); ylim([-15 60]);
        % stats
        T3 = tapply(D, {'SN'}, ...
            {D.MT, 'nanmean', 'name', 'MTd1', 'subset',ismember(D.Day,1) & D.Horizon==1}, ...
            {D.MT, 'nanmean', 'name', 'MTd5', 'subset',ismember(D.Day,5) & D.Horizon==1});
        ttest(T3.MTd1, T3.MTd5, 1, 'paired');
        % day 1|2
        T.ANOVA = anovaMixed(T.MTd1, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 1:13));
        T.ANOVA = anovaMixed(T.MTd1, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 2:13));
        T.ANOVA = anovaMixed(T.MTd1, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 3:13));
        % day 4|5
        T.ANOVA = anovaMixed(T.MTd5, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 1:13));
        T.ANOVA = anovaMixed(T.MTd5, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 2:13));
        T.ANOVA = anovaMixed(T.MTd5, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 3:13));
        T.ANOVA = anovaMixed(T.MTd5, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 4:13));
        T.ANOVA = anovaMixed(T.MTd5, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 5:13));
        % day 12-45
        ttest((nanplus(T.MTd1(T.Horizon==1),-T.MTd5(T.Horizon==1))./T.MT(T.Horizon==1))*100, (nanplus(T.MTd1(T.Horizon==2),-T.MTd5(T.Horizon==2))./T.MT(T.Horizon==2))*100, 2, 'paired');
        ttest((nanplus(T.MTd1(T.Horizon==2),-T.MTd5(T.Horizon==2))./T.MT(T.Horizon==2))*100, (nanplus(T.MTd1(T.Horizon==3),-T.MTd5(T.Horizon==3))./T.MT(T.Horizon==3))*100, 2, 'paired');
        ttest((nanplus(T.MTd1(T.Horizon==3),-T.MTd5(T.Horizon==3))./T.MT(T.Horizon==3))*100, (nanplus(T.MTd1(T.Horizon==4),-T.MTd5(T.Horizon==4))./T.MT(T.Horizon==4))*100, 2, 'paired');
        T.ANOVA = anovaMixed((nanplus(T.MTd1,-T.MTd5)./T.MT)*100, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 1:13));
        T.ANOVA = anovaMixed((nanplus(T.MTd1,-T.MTd5)./T.MT)*100, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 2:13));
        T.ANOVA = anovaMixed((nanplus(T.MTd1,-T.MTd5)./T.MT)*100, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 3:13));
        
        % out
        varargout = {T}; %return main structure
        
    case 'horizon_RT' % RT vs horizon
        if nargin>1 % load single subj data
            subj = varargin{1};
            D = load( fullfile(pathToData, sprintf('shf_%s.mat', subj)));
        else % load group data
            D = load( fullfile(pathToAnalyze, 'shf_all_data.mat'));
        end
        
        % pool days
        D.Day(D.Day==2) = 3;
        D.Day(D.Day==3) = 3;
        D.Day(D.Day==4) = 3;
        
        % open multi-panel figure
        figure('Name', 'Horizon RT'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
        
        % ------------------------------------------------------------------------------------------------------
        % summarize data
        T = tapply(D, {'SN', 'Horizon'}, ...
            {D.RT, 'nanmean', 'name', 'RT', ...
            'subset',D.isError==0});
        T = normData(T, {'RT'});
        % plot data
        subplot(2,2,1);
        plt.box(T.Horizon, T.normRT, 'style',lightsty);
        hold on;
        plt.line(T.Horizon, T.normRT, 'plotfcn','nanmean', 'style',bksty); axis square;
        ylabel('Reaction time (ms)'); set(gca,'fontsize',fs); ylim([350 950]);
        %stats
        T.ANOVA = anovaMixed(T.RT, T.SN,'within', [T.Horizon], {'Horizon'}, 'subset',ismember(T.Horizon, 1:13));
        
        % ------------------------------------------------------------------------------------------------------
        % summarize data
        T2 = tapply(D, {'SN', 'Horizon', 'Day'}, ...
            {D.RT, 'nanmean', 'name', 'RT'});
        % stats
        T.ANOVA = anovaMixed(T2.RT, T2.SN,'within', [T2.Horizon T2.Day], {'Horizon', 'Day'}, 'subset',T2.Day~=3);
        T = tapply(D, {'SN', 'Horizon'}, ...
            {D.RT, 'nanmean', 'name', 'RTd1', 'subset',D.Day==1}, ...
            {D.RT, 'nanmean', 'name', 'RTd5', 'subset',D.Day==5});
        T = normData(T, {'RTd1', 'RTd5'});
        % plot data
        subplot(223);
        plt.line(T2.Horizon, T2.RT, 'split',T2.Day, 'style',daysty, 'leg',lrnleg, 'plotfcn','nanmean', 'subset',T2.Day~=3, 'leglocation','Southeast');
        keyboard; cla;
        plt.box(T.Horizon, T.normRTd1, 'style',d1box);
        hold on;
        plt.box(T.Horizon, T.normRTd5, 'style',d5box);
        hold on;
        plt.line(T.Horizon, T.normRTd1, 'style',d1sty);
        hold on;
        plt.line(T.Horizon, T.normRTd5, 'style',d5sty);
        xlabel('Viewing window (W)'); ylabel('Reaction time (ms)'); set(gca,'fontsize',fs); axis square; ylim([350 950]);
        
        %         % ------------------------------------------------------------------------------------------------------
        %         % summarize data
        %         T = tapply(D, {'SN', 'Horizon'}, ...
        %             {D.RT, 'nanmean', 'name', 'RT'}, ...
        %             {D.RT, 'nanmean', 'name', 'RTd1', 'subset',ismember(D.Day,1)}, ...
        %             {D.RT, 'nanmean', 'name', 'RTd5', 'subset',ismember(D.Day,5)});
        %         T = normData(T, {'RT', 'RTd1', 'RTd5'});
        %         % plot data
        %         subplot(224);
        %         plt.box(T.Horizon, (nanplus(T.RTd1,-T.RTd5)./T.RT)*100, 'style',lightsty);
        %         hold on;
        %         plt.line(T.Horizon, (nanplus(T.RTd1,-T.RTd5)./T.RT)*100, 'plotfcn','nanmean', 'style',bksty);
        %         xlabel('Viewing window (W)'); ylabel('RT difference (% of avg RT)'); set(gca,'fontsize',fs); axis square;
        %         drawline(0, 'dir','horz', 'linestyle','--'); ylim([-40 45]);
        
        % out
        varargout = {T}; %return main structure
        
    case 'horizon_ACC' % ACC vs horizon
        if nargin>1 % load single subj data
            subj = varargin{1};
            D = load( fullfile(pathToData, sprintf('shf_%s.mat', subj)));
        else % load group data
            D = load( fullfile(pathToAnalyze, 'shf_all_data.mat'));
        end
        
        % pool days
        D.Day(D.Day==2) = 3;
        D.Day(D.Day==3) = 3;
        D.Day(D.Day==4) = 3;
        
        % open multi-panel figure
        %figure('Name', 'Horizon ACC'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
        
        % ------------------------------------------------------------------------------------------------------
        % create summary tables for ACC
        T = tapply(D,{'SN', 'Horizon'},...
            ...{(1-D.isError)*100,'nanmean', 'name','ACC'});
            {(1-D.badPress)*100,'nanmean', 'name','ACC'});
        T.ACC = mean(T.ACC,2);
        T = normData(T, {'ACC'}, 'sub');
        
        % make sure that you have one value per subject for each condition
        % pivottable(T.SN, T.Horizon, T.ACC, 'numel');
        
        % plot data
        subplot(2,2,3);
        plt.box(T.Horizon, T.ACC, 'style',lightsty);
        hold on;
        plt.line(T.Horizon, T.ACC, 'plotfcn','nanmean', 'style',bksty); axis square;
        xlabel('Viewing window (W)'); ylabel('Accuracy (%)'); set(gca,'fontsize',fs); %ylim([50 120]);
        % stats
        T.ANOVA = anovaMixed(T.ACC, T.SN,'within', [T.Horizon], {'Horizon'});
        
        % ------------------------------------------------------------------------------------------------------
        % summarize data
        T2 = tapply(D, {'SN', 'Horizon', 'Day'}, ...
            ...{(1-D.isError)*100, 'nanmean', 'name', 'ACC'},...
            {(1-D.badPress)*100, 'nanmean', 'name', 'ACC'},...
            'subset',D.Day~=3);
        T2.ACC = mean(T2.ACC,2);
        % stats
        T.ANOVA = anovaMixed(T2.ACC, T2.SN,'within', [T2.Horizon T2.Day], {'Horizon', 'Day'});
        T = tapply(D, {'SN', 'Horizon'}, ...
            ...{(1-D.isError)*100, 'nanmean', 'name', 'ACCd1', 'subset',D.Day==1}, ...
            ...{(1-D.isError)*100, 'nanmean', 'name', 'ACCd5', 'subset',D.Day==5});
            {(1-D.badPress)*100, 'nanmean', 'name', 'ACCd1', 'subset',D.Day==1}, ...
            {(1-D.badPress)*100, 'nanmean', 'name', 'ACCd5', 'subset',D.Day==5});
        T.ACCd1 = mean(T.ACCd1,2); T.ACCd5 = mean(T.ACCd5,2);
        T = normData(T, {'ACCd1', 'ACCd5'});
        % plot data
        subplot(224);
        plt.line(T2.Horizon, T2.ACC, 'split',T2.Day, 'style',daysty, 'leg',lrnleg, 'plotfcn','nanmean', 'subset',T2.Day~=3);
        keyboard; cla;
        plt.box(T.Horizon, T.ACCd1, 'style',d1box);
        hold on;
        plt.box(T.Horizon, T.ACCd5, 'style',d5box);
        hold on;
        plt.line(T.Horizon, T.ACCd1, 'style',d1sty);
        hold on;
        plt.line(T.Horizon, T.ACCd5, 'style',d5sty);
        ylabel('ACC (%)'); set(gca,'fontsize',fs); axis square; %ylim([50 120]);
        
        %         % ------------------------------------------------------------------------------------------------------
        %         % summarize data
        %         T = tapply(D, {'SN', 'Horizon'}, ...
        %             {(1-D.isError)*100, 'nanmean', 'name', 'ACC'}, ...
        %             {(1-D.isError)*100, 'nanmean', 'name', 'ACCd1', 'subset',ismember(D.Day,1)}, ...
        %             {(1-D.isError)*100, 'nanmean', 'name', 'ACCd5', 'subset',ismember(D.Day,5)});
        %         T = normData(T, {'ACC', 'ACCd1', 'ACCd5'});
        %         % plot data
        %         subplot(224);
        %         plt.box(T.Horizon, (nanplus(T.ACCd1,-T.ACCd5)./T.ACC)*100, 'style',lightsty);
        %         hold on;
        %         plt.line(T.Horizon, (nanplus(T.ACCd1,-T.ACCd5)./T.ACC)*100, 'plotfcn','nanmean', 'style',bksty);
        %         xlabel('Viewing window (W)'); ylabel('ACC difference (% of avg ACC)'); set(gca,'fontsize',fs); axis square;
        %         drawline(0, 'dir','horz', 'linestyle','--'); %ylim([-40 40]);
        
        % out
        varargout = {T}; %return main structure
        
    case 'horizon_IPI' % IPI vs horizon
        if nargin>1 % load single subj data
            subj = varargin{1};
            D = load( fullfile(pathToData, sprintf('shf_%s.mat', subj)));
        else % load group data
            D = load( fullfile(pathToAnalyze, 'shf_all_data.mat'));
        end
        
        % pool days
        D.Day(D.Day==2) = 3;
        D.Day(D.Day==3) = 3;
        D.Day(D.Day==4) = 3;
        
        % open multi-panel figure
        figure('Name', 'Horizon IPI'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
        
        % ------------------------------------------------------------------------------------------------------
        % create summary table for IPI profile
        for t = 1:length(D.TN)
            IPI.TN(t,:)         = D.TN(t,:) * ones(1,13);
            IPI.BN(t,:)         = D.BN(t,:) * ones(1,13);
            IPI.SN(t,:)         = D.SN(t,:) * ones(1,13);
            IPI.Horizon(t,:)    = D.Horizon(t,:)    * ones(1,13);
            IPI.Day(t,:)        = D.Day(t,:)        * ones(1,13);
            IPI.IPInum(t,:)     = D.IPInum(t,:);
            IPI.IPI(t,:)        = D.IPI(t,:);
            IPI.badIPI(t,:)     = D.badPress(t,1:13);
            IPI.isError(t,:)    = D.isError(t,:)    * ones(1,13);
        end
        % reshape IPI table and put a cap on Horizon limit
        IPI.TN          = reshape(IPI.TN, numel(IPI.TN), 1);
        IPI.BN          = reshape(IPI.BN, numel(IPI.BN), 1);
        IPI.SN          = reshape(IPI.SN, numel(IPI.SN), 1);
        IPI.Horizon     = reshape(IPI.Horizon, numel(IPI.Horizon), 1);
        IPI.Day         = reshape(IPI.Day, numel(IPI.Day), 1);
        IPI.IPInum      = reshape(IPI.IPInum, numel(IPI.IPInum), 1);
        IPI.IPI         = reshape(IPI.IPI, numel(IPI.IPI), 1);
        IPI.badIPI      = reshape(IPI.badIPI, numel(IPI.badIPI), 1);
        IPI.isError     = reshape(IPI.isError, numel(IPI.isError), 1);
        %%%
        %fullHor = IPI.Horizon;
        IPI.Horizon(IPI.Horizon >= 4) = 4;
        %%%
        % summarize data
        T = tapply(IPI, {'SN', 'IPInum', 'Horizon'},...
            {IPI.IPI, 'nanmean', 'name', 'IPI'}, ...
            'subset',IPI.badIPI==0); %'subset',IPI.isError==0);
        T = normData(T, {'IPI'});
        % plot data
        subplot(2,2,[1,2]);
        plt.line([T.IPInum], T.normIPI, 'split',T.Horizon, 'style',horsty, 'leg',horleg, 'leglocation','South'); axis square;
        xlabel('Transition number'); ylabel('Inter-press interval (ms)'); set(gca,'fontsize',fs); ylim([150 650]);
        % stats
        T.ANOVA = anovaMixed(T.IPI, T.SN,'within', [T.IPInum, T.Horizon], {'IPInum', 'Horizon'});
        
        T = tapply(IPI, {'SN', 'IPInum'},...
            {IPI.IPI, 'nanmean', 'name', 'IPI'}, ...
            'subset',IPI.badIPI==0); %'subset',IPI.isError==0);
        T.ANOVA = anovaMixed(T.IPI, T.SN,'within', [T.IPInum], {'IPInum'});
        
        T = tapply(IPI, {'SN'},...
            {IPI.IPI, 'nanmean', 'name', 'IPI1', 'subset',IPI.IPInum==1}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI212', 'subset',ismember(IPI.IPInum, 2:12)}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI13', 'subset',IPI.IPInum==13}, ...
            'subset',IPI.badIPI==0); %'subset',IPI.isError==0);
        ttest(T.IPI1 , T.IPI212, 2, 'paired');
        ttest(T.IPI13, T.IPI212, 2, 'paired');
        
        T = tapply(IPI, {'SN'},...
            {IPI.IPI, 'nanmean', 'name', 'IPI212_W1', 'subset',ismember(IPI.IPInum, 2:12) & IPI.Horizon==1}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI212_W213', 'subset',ismember(IPI.IPInum, 2:12) & IPI.Horizon>1}, ...
            'subset',IPI.badIPI==0); %'subset',IPI.isError==0);
        ttest(T.IPI212_W1, T.IPI212_W213, 2, 'paired');
        
        T = tapply(IPI, {'SN'},...
            {IPI.IPI, 'nanmean', 'name', 'IPI512_W1', 'subset',ismember(IPI.IPInum, 5:12) & IPI.Horizon==1}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI512_W2', 'subset',ismember(IPI.IPInum, 5:12) & IPI.Horizon==2}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI512_W3', 'subset',ismember(IPI.IPInum, 5:12) & IPI.Horizon==3}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI512_W4', 'subset',ismember(IPI.IPInum, 5:12) & IPI.Horizon==4}, ...
            'subset',IPI.badIPI==0); %'subset',IPI.isError==0);
        ttest(T.IPI512_W1, T.IPI512_W2, 2, 'paired');
        ttest(T.IPI512_W2, T.IPI512_W3, 2, 'paired');
        ttest(T.IPI512_W3, T.IPI512_W4, 2, 'paired');
        
        
        % ------------------------------------------------------------------------------------------------------
        % summarize data
        T = tapply(IPI, {'SN', 'IPInum', 'Horizon', 'Day'}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI'}, ...
            'subset',IPI.badIPI==0 & IPI.Day~=3);
        T = normData(T, {'IPI'});
        % plot data
        subplot(2,2,3);
        plt.line([T.Horizon T.IPInum], T.normIPI, 'split',T.Day, 'style',daysty, 'leg',lrnleg, 'leglocation','Northeast');
        xlabel('Transition number'); ylabel('IPI (ms)'); set(gca,'fontsize',fs); ylim([150 650]);
        xtl = repmat({'1','','','','','6','','','','','11','',''},1,numel(unique(T.Horizon))); xticklabels(xtl);
        % stats
        T = tapply(IPI, {'SN', 'Day'}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI'}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI13', 'subset',ismember(IPI.IPInum, 1:3)}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI14', 'subset',ismember(IPI.IPInum, 1:4)}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI412', 'subset',ismember(IPI.IPInum, 4:12)}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI512', 'subset',ismember(IPI.IPInum, 5:12)}, ...
            'subset',IPI.badIPI==0 & IPI.Day~=3);
        T.ANOVA = anovaMixed(T.IPI, T.SN,'within', [T.Day], {'Day'});
        T.ANOVA = anovaMixed(T.IPI13, T.SN,'within', [T.Day], {'Day'});
        T.ANOVA = anovaMixed(T.IPI14, T.SN,'within', [T.Day], {'Day'});
        T.ANOVA = anovaMixed(T.IPI412, T.SN,'within', [T.Day], {'Day'});
        T.ANOVA = anovaMixed(T.IPI512, T.SN,'within', [T.Day], {'Day'});
        
        T = tapply(IPI, {'SN', 'Horizon', 'Day'}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI'}, ...
            'subset',IPI.badIPI==0 & IPI.Day~=3);
        T.ANOVA = anovaMixed(T.IPI, T.SN,'within', [T.Horizon, T.Day], {'Horizon', 'Day'});
        
        % ------------------------------------------------------------------------------------------------------
        % summarize data
        %%%
        %         IPI.Horizon = fullHor;
        %         IPI.Horizon(IPI.Horizon >= 6) = 6;
        %%%
        IPI.plan = zeros(numel(IPI.IPInum),1); % IPI.plan --> 0 = S-R mapping | 1 = preplan | 2 = online plan (default)
        for iw = 2:numel(unique(IPI.Horizon))
            IPI.plan(IPI.Horizon==iw & ismember(IPI.IPInum, 1:iw-1)) = 1; % preplanning
            IPI.plan(IPI.Horizon==iw & ismember(IPI.IPInum, iw:end)) = 2; % online planning
        end
        T = tapply(IPI, {'SN', 'plan', 'Horizon'}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI'},..., 'subset',IPI.Day==1 | IPI.Day==5}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPId1', 'subset',IPI.Day==1}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPId5', 'subset',IPI.Day==5}, ...
            'subset',IPI.badIPI==0);% & IPI.IPInum<13);
        T = normData(T, {'IPI', 'IPId1', 'IPId5'});
        % plot data
        subplot(2,2,4);
        plt.line([T.Horizon], ((T.normIPId1-T.normIPId5)./T.normIPI)*100, 'split',T.plan, 'style',plansty, 'leg',planleg, 'leglocation','Southeast'); axis square;
        keyboard; cla;
        xcb = plt.box([T.Horizon], ((T.normIPId1-T.normIPId5)./T.normIPI)*100, 'split',T.plan, 'style',planstylight, 'leg','skip', 'linscale',0, 'plotall',0, 'gapwidth',[1.5 0.3], 'boxwidth',0.6); axis square;
        xc0 = xcb(1); xc1 = xcb(2:2:end); xc2 = xcb(3:2:end); xc = repmat([xc0, xc1, xc2, ]',ns,1);
        hold on;
        plt.line(xc, ((T.normIPId1-T.normIPId5)./T.normIPI)*100, 'plotfcn','nanmean', 'split',T.plan, 'style',plansty0, 'leg','skip', 'leglocation','North', 'subset',T.plan==0);
        hold on;
        plt.line(xc, ((T.normIPId1-T.normIPId5)./T.normIPI)*100, 'plotfcn','nanmean', 'split',T.plan, 'style',plansty1, 'leg','skip', 'leglocation','North', 'subset',T.plan==1);
        hold on;
        plt.line(xc, ((T.normIPId1-T.normIPId5)./T.normIPI)*100, 'plotfcn','nanmean', 'split',T.plan, 'style',plansty2, 'leg','skip', 'leglocation','North', 'subset',T.plan==2); axis square;
        xlabel('Viewing window (W)'); ylabel('IPI difference (% of avg IPI)'); set(gca,'fontsize',fs); ylim([-35 75]); %ylim([-10 50]);
        drawline(0, 'dir','horz', 'linestyle','-.','linewidth',1.5);
        xticks(xcb); xticklabels({'1','','2  ','','3  ','','4+ '});
        % stats
        ttest((nanplus(T.IPId1(T.plan==0 & T.Horizon==1),-T.IPId5(T.plan==0 & T.Horizon==1))./T.IPI(T.plan==0 & T.Horizon==1))*100, 0, 2, 'onesample');
        %         ttest((nanplus(T.IPId1(T.plan==1 & T.Horizon==2),-T.IPId5(T.plan==1 & T.Horizon==2))./T.IPI(T.plan==1 & T.Horizon==2))*100, 0, 1, 'onesample');
        %         ttest((nanplus(T.IPId1(T.plan==1 & T.Horizon==3),-T.IPId5(T.plan==1 & T.Horizon==3))./T.IPI(T.plan==1 & T.Horizon==3))*100, 0, 1, 'onesample');
        %         ttest((nanplus(T.IPId1(T.plan==1 & T.Horizon==4),-T.IPId5(T.plan==1 & T.Horizon==4))./T.IPI(T.plan==1 & T.Horizon==4))*100, 0, 1, 'onesample');
        %         ttest((nanplus(T.IPId1(T.plan==2 & T.Horizon==2),-T.IPId5(T.plan==2 & T.Horizon==2))./T.IPI(T.plan==2 & T.Horizon==2))*100, 0, 1, 'onesample');
        %         ttest((nanplus(T.IPId1(T.plan==2 & T.Horizon==3),-T.IPId5(T.plan==2 & T.Horizon==3))./T.IPI(T.plan==2 & T.Horizon==3))*100, 0, 1, 'onesample');
        %         ttest((nanplus(T.IPId1(T.plan==2 & T.Horizon==4),-T.IPId5(T.plan==2 & T.Horizon==4))./T.IPI(T.plan==2 & T.Horizon==4))*100, 0, 1, 'onesample');
        %
        %         ttest((nanplus(T.IPId1(T.plan==1 & T.Horizon==2),-T.IPId5(T.plan==1 & T.Horizon==2))./T.IPI(T.plan==1 & T.Horizon==2))*100, (nanplus(T.IPId1(T.plan==2 & T.Horizon==2),-T.IPId5(T.plan==2 & T.Horizon==2))./T.IPI(T.plan==2 & T.Horizon==2))*100, 2, 'paired');
        %         ttest((nanplus(T.IPId1(T.plan==1 & T.Horizon==3),-T.IPId5(T.plan==1 & T.Horizon==3))./T.IPI(T.plan==1 & T.Horizon==3))*100, (nanplus(T.IPId1(T.plan==2 & T.Horizon==3),-T.IPId5(T.plan==2 & T.Horizon==3))./T.IPI(T.plan==2 & T.Horizon==3))*100, 2, 'paired');
        %         ttest((nanplus(T.IPId1(T.plan==1 & T.Horizon==4),-T.IPId5(T.plan==1 & T.Horizon==4))./T.IPI(T.plan==1 & T.Horizon==4))*100, (nanplus(T.IPId1(T.plan==2 & T.Horizon==4),-T.IPId5(T.plan==2 & T.Horizon==4))./T.IPI(T.plan==2 & T.Horizon==4))*100, 2, 'paired');
        %
        %
        %         T = tapply(IPI, {'SN'}, ...
        %             {IPI.IPI, 'nanmean', 'name', 'IPI'},...
        %             {IPI.IPI, 'nanmean', 'name', 'IPId1', 'subset',IPI.Day==1}, ...
        %             {IPI.IPI, 'nanmean', 'name', 'IPId5', 'subset',IPI.Day==5}, ...
        %             'subset',IPI.badIPI==0 & IPI.plan>0);
        %         ttest((nanplus(T.IPId1,-T.IPId5)./T.IPI)*100, 0, 1, 'onesample');
        %
        %         T = tapply(IPI, {'SN', 'plan', 'Horizon'}, ...
        %             {IPI.IPI, 'nanmean', 'name', 'IPI'},..., 'subset',IPI.Day==1 | IPI.Day==5}, ...
        %             {IPI.IPI, 'nanmean', 'name', 'IPId1', 'subset',IPI.Day==1}, ...
        %             {IPI.IPI, 'nanmean', 'name', 'IPId5', 'subset',IPI.Day==5}, ...
        %             'subset',IPI.badIPI==0 & IPI.plan>0);
        %         T.ANOVA = anovaMixed(((T.IPId1-T.IPId5)./T.IPI)*100, T.SN,'within', [T.Horizon, T.plan], {'Horizon', 'Plan'});
        
        T = tapply(IPI, {'SN', 'plan'}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI'},..., 'subset',IPI.Day==1 | IPI.Day==5}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPId1', 'subset',IPI.Day==1}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPId5', 'subset',IPI.Day==5}, ...
            'subset',IPI.badIPI==0 & IPI.plan~=1);
        ttest(((T.IPId1(T.plan==2)-T.IPId5(T.plan==2))./T.IPI(T.plan==2))*100, ((T.IPId1(T.plan==0)-T.IPId5(T.plan==0))./T.IPI(T.plan==0))*100, 2, 'paired');
        
        T = tapply(IPI, {'SN', 'plan'}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI'},..., 'subset',IPI.Day==1 | IPI.Day==5}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPId1', 'subset',IPI.Day==1}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPId5', 'subset',IPI.Day==5}, ...
            'subset',IPI.badIPI==0 & IPI.plan~=2);
        ttest(((T.IPId1(T.plan==1)-T.IPId5(T.plan==1))./T.IPI(T.plan==1))*100, ((T.IPId1(T.plan==0)-T.IPId5(T.plan==0))./T.IPI(T.plan==0))*100, 2, 'paired');
        
        % open multi-panel figure
        figure('Name', 'Horizon IPI'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
        
        T = tapply(IPI, {'SN', 'plan'}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPI'},...
            {IPI.IPI, 'nanmean', 'name', 'IPId1', 'subset',IPI.Day==1}, ...
            {IPI.IPI, 'nanmean', 'name', 'IPId5', 'subset',IPI.Day==5}, ...
            'subset',IPI.badIPI==0);% & IPI.Horizon>1);
        %subplot(2,2,1);
        %plt.scatter( (T.IPId1(T.plan==1)-T.IPId5(T.plan==1)) - (T.IPId1(T.plan==0)-T.IPId5(T.plan==0)), (T.IPId1(T.plan==2)-T.IPId5(T.plan==2)) - (T.IPId1(T.plan==0)-T.IPId5(T.plan==0)), 'style',bksty2, 'label',T.SN(T.plan==1));
        [~,T.b,~,T.p]=plt.scatter( (T.IPId1(T.plan==1)-T.IPId5(T.plan==1)), (T.IPId1(T.plan==2)-T.IPId5(T.plan==2)), 'style',bksty2, 'label',T.SN(T.plan==1));
        xlabel('Preplanning gains minus S-R mapping gains (IPI difference D1-D5)'); ylabel('Online planning gains minus S-R mapping gains (IPI difference D1-D5)'); set(gca,'fontsize',fs);
        axis image;
        xlim([-50 300])
        ylim([-50 300])
        %ylim([-35 75]); %ylim([-10 50]);
        drawline(0, 'dir','horz', 'linestyle','--', 'linewidth',1.5);
        drawline(0, 'dir','vert', 'linestyle','--', 'linewidth',1.5);
        
        %         subplot(2,2,2);
        %         plt.scatter(T.IPId1(T.plan==0)-T.IPId5(T.plan==0), T.IPId1(T.plan==2)-T.IPId5(T.plan==2), 'style',bksty, 'label',T.SN(T.plan==2));
        %         xlabel('S-R mapping gains (IPI difference D1-D5)'); ylabel('Online planning gains (IPI difference D1-D5)'); set(gca,'fontsize',fs);
        %         axis image
        %         %ylim([-35 75]); %ylim([-10 50]);
        %         drawline(0, 'dir','horz', 'linestyle','--','linewidth',1.5);
        %         drawline(0, 'dir','vert', 'linestyle','--','linewidth',1.5);
        %
        %         subplot(2,2,4);
        %         plt.scatter(T.IPId1(T.plan==0)-T.IPId5(T.plan==0), T.IPId1(T.plan==1)-T.IPId5(T.plan==1), 'style',bksty, 'label',T.SN(T.plan==1));
        %         xlabel('S-R mapping gains (IPI difference D1-D5)'); ylabel('Preplanning gains (IPI difference D1-D5)'); set(gca,'fontsize',fs);
        %         axis image
        %         %ylim([-35 75]); %ylim([-10 50]);
        %         drawline(0, 'dir','horz', 'linestyle','--','linewidth',1.5);
        %         drawline(0, 'dir','vert', 'linestyle','--','linewidth',1.5);
        
        % out
        varargout = {T}; %return main structure
        
    case 'exp_model_MT' % MT exp fit
        sn = subvec;
        sim = 0; % choose whether to use simulated random data (1) or not (0)
        thres = 99;
        analysis = 'split_half';
        vararginoptions(varargin, {'sn', 'thres', 'sim', 'analysis'});
        
        switch (sim)
            case 1 % simulate data for control analysis
                nSim = 100;
                init_params = [6000, 0.8, 3000]; % initial parameters for the exp model
                fcn = @(init_params,x)(init_params(1) * exp(-init_params(2)*(x-1)) + init_params(3)); % define exp function model
                % load data
                ds = load( fullfile(pathToAnalyze, 'shf_all_data.mat')); % load group data
                theta = zeros(ns,3); res = zeros(9,ns); pred_ys = zeros(ns,9);
                for s = 1:ns
                    % select data
                    D = getrow(ds, ds.SN==subvec(s));
                    % summarize data
                    [ys,xs,~]=pivottable(D.Horizon, D.SN, D.MT, 'nanmean');
                    % fit data to exp model
                    [theta(s,:),res(:,s),~,~,~] = nlinfit(xs,ys,fcn,init_params); % fit data to the model
                    pred_ys(s,:) = theta(s,1) * exp(-theta(s,2)*(xs'-1)) + theta(s,3); % calculate predicted curve
                end
                res = reshape(res,[],1);
                est_noise = sqrt( sum(res.^2)/(ns*numel(xs)-ns*3) );
                
                S.SN = [];
                S.day = [];
                S.a = [];
                S.b = [];
                S.c = [];
                S.h = [];
                T = [];
                D2 = [];
                for s = 1:ns
                    % select predicted function for each subj
                    pred_y = (pred_ys(s,:))';
                    %pred_y = (mean(pred_ys))';
                    for d = 1:nSim
                        % add noise estimated from sum of squares
                        noisy_y = pred_y + est_noise * randn(length(pred_y),1);
                        %noisy_y = pred_y + 100 * randn(length(pred_y),1);
                        fit_params = nlinfit(xs,noisy_y,fcn,init_params); % fit data to the model
                        horizon = -log(1-thres/100) / fit_params(2) + 1; % find the "effective" planning horizon given the thres (101% of asymptote)
                        
                        % save MT simulation data in output structure
                        D1.SN  = ones(numel(noisy_y),1) * subvec(s);
                        D1.Day = ones(numel(noisy_y),1) * d;
                        D1.MT = noisy_y;
                        D1.Horizon = xs;
                        D2 = addstruct(D2, D1);
                        
                        % save fit params and horizon in output structure
                        S.SN    = subvec(s);
                        S.day   = d;
                        S.a     = fit_params(1); % initial value of the exp (minus the asymptote)
                        S.b     = fit_params(2); % slope (rate of change) of the exp
                        S.c     = fit_params(3); % asymptote of the exp
                        S.h     = horizon;
                        T = addstruct(T, S);
                    end
                end
                T.D = D2;
                
                %                 % define exponential model on the basis of avg group data
                %                 ds = load( fullfile(pathToAnalyze, 'shf_all_data.mat')); % load group data
                %                 [x0,y0]=plt.line(ds.Horizon,ds.MT, 'style',bksty); % plot group data (mean)
                %                 init_params = [7000, 0.8, 4000]; % initial parameters for the exp model
                %                 fcn = @(init_params,x0)(init_params(1) * exp(-init_params(2)*(x0-1)) + init_params(3)); % define exp function model
                %                 fit_params = nlinfit(x0,y0',fcn,init_params); % fit data to the model
                %                 horizon = -log(1-thres/100) / fit_params(2) + 1; % find the "effective" planning horizon given the thres (101% of asymptote)
                %                 %pred_x=[1:8,13]; % set resolution on the x-axis (viewing window levels)
                %                 pred_y0 = fit_params(1) * exp(-fit_params(2)*(x0'-1)) + fit_params(3); % calculate predicted function
                %                 hold on; plot(x0', pred_y0, 'color','r', 'linewidth',1); ylim([3000 8000]); % plot predicted function
                %                 drawline(fit_params(3) + fit_params(3)*0.01, 'dir','horz', 'linestyle',':') % add thres line
                %                 drawline(horizon, 'dir','vert', 'linestyle',':') % add horizon line
                %                 xlabel('Viewing window (W)'); ylabel('Movement time (ms)'); set(gca,'fontsize',fs); axis square;
                %                 close;
                %
                %                 % generate random dataset (with gaussian noise) around avg
                %                 % exponential model separately for different days and repeat
                %                 % model fit to get new randomly generated planning horizons
                %                 T.day = [];
                %                 T.SN = []; T.a = []; T.b = []; T.c = []; T.h = []; T.D = [];
                %                 for d = 1:numel(unique(ds.Day))
                %                     for s = 1 : ns
                %                         %noisy_y = pred_y0 + 300 * randn(1, length(pred_y0));
                %                         noisy_y = pred_y0 + (2.8.*randn(1, length(pred_y0))*100);
                %                         figure; [x,y]=plt.line(x0,noisy_y', 'style',bksty); % get data
                %
                %                         D.SN  = ones(numel(y),1) * subvec(s);
                %                         D.Day = ones(numel(y),1) * d;
                %                         D.MT = y';
                %                         D.Horizon = x;
                %
                %                         fit_params = nlinfit(x,y',fcn,init_params); % fit data to the model
                %                         horizon = -log(1-thres/100) / fit_params(2) + 1; % find the "effective" planning horizon given the thres (101% of asymptote)
                %                         pred_y = fit_params(1) * exp(-fit_params(2)*(x0'-1)) + fit_params(3);
                %
                %                         % plot single subject (optional)
                %                         hold on; plot(x0',pred_y, 'color','r', 'linewidth',1); ylim([3000 8000])
                %                         drawline(fit_params(3) + fit_params(3)*0.01, 'dir','horz', 'linestyle',':')
                %                         drawline(horizon, 'dir','vert', 'linestyle',':')
                %                         xlabel('Viewing window (W)'); ylabel('Movement time (ms)'); set(gca,'fontsize',fs); axis square;
                %                         close;
                %
                %                         % save fit params and horizon in output structure
                %                         T.SN = [T.SN; subvec(s)];
                %                         T.day = [T.day; d];
                %                         T.a = [T.a; fit_params(1)]; % initial value of the exp
                %                         T.b = [T.b; fit_params(2)]; % slope (rate of change) of the exp
                %                         T.c = [T.c; fit_params(3)]; % asymptote of the exp
                %                         T.h = [T.h; horizon];
                %                         T.D = addstruct(T.D, D);
                %                     end
                %                 end
                
                % save outputs
                save( fullfile( pathToAnalyze, sprintf('shf_exp_model_sim_thres_%dpct.mat',thres)), '-struct', 'T');
                % out
                varargout = {T}; %return main structure
            case 0 % load actual data
                if numel(sn)==1 % load single subj data
                    D = load( fullfile(pathToData, sprintf('shf_%s.mat', sn)));
                else % load group data
                    D = load( fullfile(pathToAnalyze, 'shf_all_data.mat'));
                end
                switch analysis
                    case 'across_days'
                        % across days
                        S.SN = [];
                        S.a = []; S.b = []; S.c = []; S.h = [];
                        figure('Name', 'Exp model of MT results'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
                        subplot(2,2,1)
                        for s = 1 : ns
                            ds = getrow(D, D.SN == subvec(s) & D.isError==0); % select subj
                            [x,y]=plt.line(ds.Horizon,ds.MT, 'style',bksty); close; % get data
                            init_params = [y(1), 1, y(end)]; % initial parameters for the exp model
                            %init_params = [6000, 0.8, 3000]; % initial parameters for the exp model
                            fcn = @(init_params,x)(init_params(1) * exp(-init_params(2)*(x-1)) + init_params(3)); % exp function model
                            fit_params = nlinfit(x,y',fcn,init_params); % fit data to the model
                            horizon = -log(1-thres/100) / fit_params(2) + 1; % find the "effective" planning horizon given the thres (101% of asymptote)
                            
                            % plot single subject (optional)
                            pred_x=1:.01:13;
                            pred_y = fit_params(1) * exp(-fit_params(2)*(pred_x-1)) + fit_params(3);
                            hold on; plot(pred_x,pred_y, 'color','m', 'linewidth',2); ylim([3000 8000])
                            drawline(fit_params(3) + fit_params(3)*0.01, 'dir','horz', 'linestyle',':')
                            drawline(horizon, 'dir','vert', 'linestyle',':')
                            xlabel('Viewing window (W)'); ylabel('Movement time (ms)'); set(gca,'fontsize',fs); axis square;
                            
                            % save fit params and horizon in output structure
                            S.SN = [S.SN; subvec(s)];
                            S.a = [S.a; fit_params(1)]; % initial value of the exp
                            S.b = [S.b; fit_params(2)]; % slope (rate of change) of the exp
                            S.c = [S.c; fit_params(3)]; % asymptote of the exp
                            S.h = [S.h; horizon];
                        end
                        % save outputs
                        save( fullfile( pathToAnalyze, sprintf('shf_exp_model_fit_thres_%dpct_across_days.mat',thres)), '-struct', 'S');
                        % out
                        varargout = {S}; %return main structure
                    case 'within_days'
                        % separately for different days
                        T.SN = []; T.day = [];
                        T.a = []; T.b = []; T.c = []; T.h = [];
                        for d = 1:numel(unique(D.Day))
                            figure('Name', 'Exp model of MT results'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
                            subplot(2,2,1)
                            for s = 1 : ns
                                ds = getrow(D, D.SN == subvec(s) & D.Day == d & D.isError==0); % select subj / day
                                [x,y]=plt.line(ds.Horizon,ds.MT, 'style',bksty); close; % get data
                                init_params = [y(1), 1, y(end)]; % initial parameters for the exp model
                                %init_params = [6000, 0.8, 3000]; % initial parameters for the exp model
                                fcn = @(init_params,x)(init_params(1) * exp(-init_params(2)*(x-1)) + init_params(3)); % exp function model
                                fit_params = nlinfit(x,y',fcn,init_params); % fit data to the model
                                horizon = -log(1-thres/100) / fit_params(2) + 1; % find the "effective" planning horizon given the thres (101% of asymptote)
                                
                                % plot single subject (optional)
                                pred_x=1:.01:13;
                                pred_y = fit_params(1) * exp(-fit_params(2)*(pred_x-1)) + fit_params(3);
                                hold on; plot(pred_x,pred_y, 'color','r', 'linewidth',1); ylim([3000 8000])
                                drawline(fit_params(3) + fit_params(3)*0.01, 'dir','horz', 'linestyle',':')
                                drawline(horizon, 'dir','vert', 'linestyle',':')
                                xlabel('Viewing window (W)'); ylabel('Movement time (ms)'); set(gca,'fontsize',fs); axis square;
                                
                                % save fit params and horizon in output structure
                                T.SN = [T.SN; subvec(s)];
                                T.day = [T.day; d];
                                T.a = [T.a; fit_params(1)]; % initial value of the exp
                                T.b = [T.b; fit_params(2)]; % slope (rate of change) of the exp
                                T.c = [T.c; fit_params(3)]; % asymptote of the exp
                                T.h = [T.h; horizon];
                            end
                        end
                        % save outputs
                        save( fullfile( pathToAnalyze, sprintf('shf_exp_model_fit_thres_%dpct.mat',thres)), '-struct', 'T');
                        % out
                        varargout = {S,T}; %return main structure
                    case 'split_half'
                        % separately for different days
                        T.SN = []; T.day = [];
                        T.a = []; T.b = []; T.c = []; T.h = [];
                        for d = 1:numel(unique(D.Day))
                            %figure('Name', 'Exp model of MT results'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
                            %subplot(2,2,1)
                            for s = 1 : ns
                                % split-half selection criteria: estimate
                                % on data from odd runs, and even runs also
                                % but for W<=5 only
                                subset = mod(D.BN,2)==1 | (mod(D.BN,2)==0 & D.Horizon<=5);
                                ds = getrow(D, D.SN == subvec(s) & D.Day == d & D.isError==0 & subset); % select subj / day
                                [x,y]=plt.line(ds.Horizon,ds.MT, 'style',bksty); % get data
                                init_params = [y(1), 1, y(end)]; % initial parameters for the exp model
                                %init_params = [max(y), 0.8, min(y)]; % initial parameters for the exp model
                                %init_params = [6000, 0.8, 3000]; % initial parameters for the exp model
                                fcn = @(init_params,x)(init_params(1) * exp(-init_params(2)*(x-1)) + init_params(3)); % exp function model
                                fit_params = nlinfit(x,y',fcn,init_params); % fit data to the model
                                horizon = -log(1-thres/100) / fit_params(2) + 1; % find the "effective" planning horizon given the thres (101% of asymptote)
                                
                                % plot single subject (optional)
                                pred_x=1:.01:13;
                                pred_y = fit_params(1) * exp(-fit_params(2)*(pred_x-1)) + fit_params(3);
                                hold on; plot(pred_x,pred_y, 'color','r', 'linewidth',1); %ylim([3000 8000])
                                drawline(fit_params(3) + fit_params(3)*0.01, 'dir','horz', 'linestyle',':')
                                drawline(horizon, 'dir','vert', 'linestyle',':')
                                xlabel('Viewing window (W)'); ylabel('Movement time (ms)'); set(gca,'fontsize',fs); axis square;
                                close;
                                
                                % save fit params and horizon in output structure
                                T.SN = [T.SN; subvec(s)];
                                T.day = [T.day; d];
                                T.a = [T.a; fit_params(1)]; % initial value of the exp
                                T.b = [T.b; fit_params(2)]; % slope (rate of change) of the exp
                                T.c = [T.c; fit_params(3)]; % asymptote of the exp
                                T.h = [T.h; horizon];
                            end
                        end
                        % save outputs
                        save( fullfile( pathToAnalyze, sprintf('shf_exp_model_fit_thres_%dpct_sh.mat',thres)), '-struct', 'T');
                        % out
                        varargout = {T}; %return main structure
                    otherwise
                        fprintf(1, 'No such case!');
                end
            otherwise
                fprintf(1, 'No such case!');
        end
        
    case 'plot_exp_model_MT' % plot results from MT exp fit
        sim = 0; % choose whether to use simulated random data (1) or not (0)
        thres = 99;
        analysis = 'split_half';
        vararginoptions(varargin, {'thres', 'sim', 'analysis'});
        
        switch (sim)
            case 1 % use simulated data for plotting
                % separately for different days
                T = load( fullfile(pathToAnalyze, sprintf('shf_exp_model_sim_thres_%dpct.mat', thres)));
                D = T.D; T = rmfield(T, 'D');
                
                % normalize data
                T = normData(T, {'a','b','c','h'});
                
                % plot results
                % open multi-panel figure
                figure('Name', 'Exp model of MT results'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
                
                subplot(1,2,1);
                plt.line(T.day, T.h, 'split',T.SN, 'style',allsubsty, 'leg','skip');
                hold on
                plt.line(T.day, T.normh, 'style',bksty);
                drawline(1, 'dir','horz', 'linestyle','--');
                xlabel('Day of practice'); ylabel('Effective planning horizon (# of digits)'); set(gca,'fontsize',fs);
                
                subplot(1,2,2);
                [~,~,~,~]=plt.scatter(T.day, T.h, 'split',T.SN, 'leg','skip');
                drawline(1, 'dir','horz', 'linestyle','--');
                xlabel('Day of practice'); ylabel('Effective planning horizon (# of digits)'); set(gca,'fontsize',fs);
                
                % open multi-panel figure
                figure('Name', 'Exp model of MT results'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
                
                T4 = tapply(D, {'SN', 'Day'}, ...
                    {D.MT, 'nanmean', 'name', 'MT'}, ...
                    'subset', D.Horizon>5);
                T5 = tapply(T, {'SN', 'day'}, ...
                    {T.h, 'nanmean', 'name', 'h'});
                T4.h = T5.h;
                %[~,T.b2,~,T.p2]=plt.scatter(T4.h, T4.MT, 'split', T4.Day, 'leg','skip');
                [~,T.b2,~,T.p2]=plt.scatter(T4.h, T4.MT, 'split', T4.SN, 'leg','skip');
                %[~,T.b2,~,T.p2]=plt.scatter(T4.h, T4.MT);
                xlabel('Mean effective planning horizon (#of digits)'); ylabel('Mean MT for W > 5 (ms)'); set(gca,'fontsize',fs);
                
                % out
                varargout = {T}; %return main structure
            case 0 % use actual data for plotting
                switch analysis
                    case 'within_days'
                        % separately for different days
                        T = load( fullfile(pathToAnalyze, sprintf('shf_exp_model_fit_thres_%dpct.mat', thres)));
                        
                        % normalize data
                        T = normData(T, {'a','b','c','h'});
                        
                        % plot results
                        % open multi-panel figure
                        figure('Name', 'Exp model of MT results'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
                        
                        subplot(2,2,1);
%                         plt.line(T.day, T.h, 'split',T.SN, 'style',allsubsty, 'leg','none');
%                         hold on
                        
                        [~,T.b,~,~]=plt.scatter(T.day, T.h, 'split',[T.day], 'style',alldaysty, 'leg','none');
                        hold on;
                        [~,T.b,~,~]=plt.scatter(T.day, T.h, 'split',T.SN, 'style',allsubsty2, 'leg','none');
                        
                        hold on
                        plt.line(T.day, T.normh, 'style',diffsty);
                        %ylim([2.4 4.2]);
                        %ylim([2 5.5]);
                        ylim([0.5 6.5]);
                        drawline(1, 'dir','horz', 'linestyle','--');
                        xlabel('Day of practice'); ylabel('Effective planning horizon (# of digits)'); set(gca,'fontsize',fs);
                        %axis square;
                        
%                         T1 = tapply(T, {'SN'}, ...
%                             {T.h, 'nanmean', 'name', 'h'});
%                         subplot(1,2,2);
%                         [~,T1.b,~,T1.p]=plt.scatter(T.b(2,:)', T1.h, 'style',allsubsty2, 'sizedata',200);
                        
                        %                         subplot(1,2,2);
                        %                         %         plt.line(T.day, T.h, 'split',T.SN);
                        %                         %         hold on
                        %                         [~,b,~,~]=plt.scatter(T.day, T.h, 'split',T.SN, 'style',allsubsty2);
                        %                         %plt.scatter(T.day, T.h, 'split',T.SN);
                        %                         ylim([0.5 6.5]);
                        %                         drawline(1, 'dir','horz', 'linestyle','--');
                        %                         xlabel('Day of practice'); ylabel('Effective planning horizon (# of digits)'); set(gca,'fontsize',fs);
                        
                        %stats
                        ttest(T.h(T.day==5), T.h(T.day==1), 2, 'paired');
                        signtest(T.b(2,:));
                        
                        %                         % open multi-panel figure
                        %                         figure('Name', 'Exp model of MT results'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
                        %
                        %                         % load group data
                        %                         D = load( fullfile(pathToAnalyze, 'shf_all_data.mat'));
                        %
                        %                         T4 = tapply(D, {'SN', 'Day'}, ...
                        %                             {D.MT, 'nanmean', 'name', 'MT'}, ...
                        %                             'subset',D.isError==0 & D.Horizon>5);
                        %                         T5 = tapply(T, {'SN', 'day'}, ...
                        %                             {T.h, 'nanmean', 'name', 'h'});
                        %                         T4.h = T5.h;
                        %                         %subplot(1,2,1);
                        %                         [~,T.b2,~,T.p2]=plt.scatter(T4.h, T4.MT, 'split',T4.Day, 'style',alldaysty, 'leg',{'D1','D2','D3','D4','D5'});
                        %                         %[~,T.b2,~,T.p2]=plt.scatter(T4.h, T4.MT, 'flip',1);
                        %                         xlabel('Mean effective planning horizon (#of digits)'); ylabel('Mean MT for W > 5 (ms)'); set(gca,'fontsize',fs);
                        %
                        % out
                        varargout = {T}; %return main structure
                    case 'split_half'
                        % separately for different days
                        T = load( fullfile(pathToAnalyze, sprintf('shf_exp_model_fit_thres_%dpct_sh.mat', thres)));
                        
                        % normalize data
                        T = normData(T, {'a','b','c','h'});
                        
                        %                         % plot results
                        %                         % open multi-panel figure
                        %                         figure('Name', 'Exp model of MT results'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
                        %
                        %                         subplot(1,2,1);
                        %                         %plt.line(T.day, T.normh, 'split',T.SN, 'style',allsubsty, 'leg','skip');
                        %                         %plt.line(T.day, T.h, 'split',T.SN, 'style',allsubsty, 'leg','skip');
                        %                         plt.scatter(T.day, T.h, 'split',T.SN, 'style',allsubsty2, 'leg','skip');
                        %                         hold on
                        %                         %plt.line(T.day, T.normh, 'style',bksty);
                        %                         plt.line(T.day, T.h, 'style',bksty);
                        %                         ylim([0.5 6.5]);
                        %                         drawline(1, 'dir','horz', 'linestyle','--');
                        %                         xlabel('Day of practice'); ylabel('Effective planning horizon (# of digits)'); set(gca,'fontsize',fs);
                        %
                        %                         subplot(1,2,2);
                        %                         [~,b,~,~]=plt.scatter(T.day, T.h, 'split',T.SN, 'style',allsubsty2);
                        %                         ylim([0.5 6.5]);
                        %                         drawline(1, 'dir','horz', 'linestyle','--');
                        %                         xlabel('Day of practice'); ylabel('Effective planning horizon (# of digits)'); set(gca,'fontsize',fs);
                        %
                        %                         %stats
                        %                         ttest(T.h(T.day==5), T.h(T.day==1), 2, 'paired');
                        %                         signtest(b(2,:));
                        
                        % open multi-panel figure
                        %figure('Name', 'Exp model of MT results'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
                        
                        % load group data
                        D = load( fullfile(pathToAnalyze, 'shf_all_data.mat'));
                        
                        % select left-out part of MT data: even runs only,
                        % and MT for W>5 only
                        T4 = tapply(D, {'SN', 'Day'}, ...
                            {D.MT, 'nanmean', 'name', 'MT'}, ...
                            'subset',D.isError==0 & D.Horizon>5 & mod(D.BN,2)==0);
                        T5 = tapply(T, {'SN', 'day'}, ...
                            {T.h, 'nanmean', 'name', 'h'});
                        T4.h = T5.h;
                        subplot(2,2,3);
                        [~,T.b2,~,T.p2]=plt.scatter(T4.h, T4.MT/1000, 'split', T4.Day, 'style',alldaysty, 'leg',{'1','2','3','4','5'});
                        xlabel('Planning horizon'); ylabel('Mean MT for W > 5 (s)'); set(gca,'fontsize',fs);
                        xticks(1:6); ylim([1.5 8.5]);
                        %axis square;
                        
                        % out
                        varargout = {T}; %return main structure
                    otherwise
                        fprintf(1, 'No such case!');
                end
                
            otherwise
                fprintf(1, 'No such case!');
        end
        
    case 'error_analysis' % analysis of error trials (press monitoring + anticipation)
        if nargin>1 % load single subj data
            subj = varargin{1};
            D = load( fullfile(pathToData, sprintf('shf_%s.mat', subj)));
        else % load group data
            D = load( fullfile(pathToAnalyze, 'shf_all_data.mat'));
        end
        
        % ------------------------------------------------------------------------------------------------------
        % create summary table for IPI profile and flag anticipations annd
        % correct presses that followed an error
        flag = 0;
        for t = 1:length(D.TN)
            for p = 1 : size(D.IPI,2)
                IPI.TN(t,p)         = D.TN(t,1);
                IPI.BN(t,p)         = D.BN(t,1);
                IPI.SN(t,p)         = D.SN(t,1);
                IPI.Horizon(t,p)    = D.Horizon(t,1);
                IPI.Day(t,p)        = D.Day(t,1);
                IPI.IPInum(t,p)     = D.IPInum(t,p);
                IPI.IPI(t,p)        = D.IPI(t,p);
                IPI.badIPI(t,p)     = D.badPress(t,p);
                if D.badPress(t,p) == 1 && D.AllResponse(t,p) == D.AllPress(t,p+1)
                    IPI.anticipErr(t,p) = 1;
                else
                    IPI.anticipErr(t,p) = 0;
                end
                if flag == 1
                    IPI.postErr(t,p) = 1;
                else
                    IPI.postErr(t,p) = 0;
                end
                if D.badPress(t,p) == 1 && D.badPress(t,p+1) == 0
                    flag = 1;
                else
                    flag = 0;
                end
                IPI.isError(t,p)    = D.isError(t,1);
            end
        end
        % reshape IPI table and put a cap on Horizon limit
        IPI.TN          = reshape(IPI.TN, numel(IPI.TN), 1);
        IPI.BN          = reshape(IPI.BN, numel(IPI.BN), 1);
        IPI.SN          = reshape(IPI.SN, numel(IPI.SN), 1);
        IPI.Horizon     = reshape(IPI.Horizon, numel(IPI.Horizon), 1);
        IPI.Day         = reshape(IPI.Day, numel(IPI.Day), 1);
        IPI.IPInum      = reshape(IPI.IPInum, numel(IPI.IPInum), 1);
        IPI.IPI         = reshape(IPI.IPI, numel(IPI.IPI), 1);
        IPI.badIPI      = reshape(IPI.badIPI, numel(IPI.badIPI), 1);
        IPI.anticipErr  = reshape(IPI.anticipErr, numel(IPI.anticipErr), 1);
        IPI.postErr     = reshape(IPI.postErr, numel(IPI.postErr), 1);
        IPI.isError     = reshape(IPI.isError, numel(IPI.isError), 1);
        %IPI.Horizon(IPI.Horizon >= 4) = 4;
        
        % ------------------------------------------------------------------------------------------------------
        % open multi-panel figure
        figure('Name', 'Horizon MT'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
        
        % summarize data
        T = tapply(IPI, {'SN', 'postErr', 'Horizon'},...
            {IPI.IPI, 'nanmean', 'name', 'IPI'},...
            'subset',IPI.badIPI == 0);
        T = normData(T, {'IPI'});
        % plot data
        subplot(2,2,1);
        plt.line(T.Horizon, T.normIPI, 'split',T.postErr, 'style',lrnsty, 'leg',{'N-1 correct', 'N-1 error'});
        xlabel('Viewing window (W)'); ylabel('IPI (ms)'); set(gca,'fontsize',fs);
        ylim([250 600]);
        axis square;
        
        % summarize data
        T = tapply(IPI, {'SN', 'postErr', 'IPInum'},...
            {IPI.IPI, 'nanmean', 'name', 'IPI'},...
            'subset',IPI.badIPI == 0);
        T = normData(T, {'IPI'});
        % plot data
        subplot(2,2,2);
        plt.line(T.IPInum, T.normIPI, 'split',T.postErr, 'style',lrnsty, 'leg',{'N-1 correct', 'N-1 error'});
        xlabel('Transition number'); ylabel('IPI (ms)'); set(gca,'fontsize',fs);
        ylim([250 600]);
        axis square;
        
        % summarize data
        T = tapply(IPI, {'SN', 'Horizon'},...
            {IPI.anticipErr, 'nanmean', 'name', 'anti'},...
            'subset',IPI.badIPI == 1);
        % plot data
        subplot(2,2,3);
        plt.box(T.Horizon, T.anti*100, 'style',bksty); hold on
        plt.scatter(T.Horizon, T.anti*100, 'regression','none');
        plt.line(T.Horizon, T.anti*100, 'style',d1sty);
        xlabel('Viewing window (W)'); ylabel('Anticipation errors (%)'); set(gca,'fontsize',fs);
        ylim([-10 110]); drawline(25, 'dir','horz', 'linestyle','--');
        axis square;
        
        % summarize data
        T = tapply(IPI, {'SN', 'Day'},...
            {IPI.anticipErr, 'nanmean', 'name', 'anti'},...
            'subset',IPI.badIPI == 1);
        % plot data
        subplot(2,2,4);
        plt.box(T.Day, T.anti*100, 'style',bksty); hold on
        plt.scatter(T.Day, T.anti*100, 'regression','none');
        plt.line(T.Day, T.anti*100, 'style',d1sty);
        xlabel('Days'); ylabel('Anticipation errors (%)'); set(gca,'fontsize',fs);
        ylim([-10 110]); drawline(25, 'dir','horz', 'linestyle','--');
        axis square;
        
%         % ------------------------------------------------------------------------------------------------------
%         % open multi-panel figure
%         figure('Name', 'All subjs (part 1)'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
%         for s = 1:7
%             T = getrow(IPI, IPI.SN==subvec(s) & ismember(IPI.IPInum, 3:11) & IPI.Horizon>3);
%             
%             subplot(3,7,s);
%             plt.hist(T.IPI(T.badIPI==0)); title(sprintf('SUB %02d', subvec(s)));
%             ylabel('Correct trials'); set(gca,'fontsize',fs);
%             subplot(3,7,7+s);
%             plt.hist(T.IPI(T.badIPI==1 & T.anticipErr==0));
%             ylabel('Error trials'); set(gca,'fontsize',fs);
%             subplot(3,7,14+s);
%             plt.hist(T.IPI(T.badIPI==1 & T.anticipErr==1));
%             xlabel('IPI distribution (ms)'); ylabel('Anticipation trials'); set(gca,'fontsize',fs);
%             plt.match('x');
%         end
%         
%         figure('Name', 'All subjs (part 2)'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
%         for s = 8:14
%             T = getrow(IPI, IPI.SN==subvec(s) & ismember(IPI.IPInum, 3:11) & IPI.Horizon>3);
%             
%             subplot(3,7,(s-7));
%             plt.hist(T.IPI(T.badIPI==0)); title(sprintf('SUB %02d', subvec(s)));
%             ylabel('Correct trials'); set(gca,'fontsize',fs);
%             subplot(3,7,7+(s-7));
%             plt.hist(T.IPI(T.badIPI==1 & T.anticipErr==0));
%             ylabel('Error trials'); set(gca,'fontsize',fs);
%             subplot(3,7,14+(s-7));
%             plt.hist(T.IPI(T.badIPI==1 & T.anticipErr==1));
%             xlabel('IPI distribution (ms)'); ylabel('Anticipation trials'); set(gca,'fontsize',fs);
%             plt.match('x');
%         end
        
        % stats
        
        % out
        varargout = {T}; %return main structure
        
    case 'percept_control' % analysis of perceptual control exp (peripheral vision)
        
        % subjects
        sid = {'ls', 'ga', 'jd'};
        
        % load data
        D = [];
        for s = 1:numel(sid)
            fn = fullfile(pathToData, sprintf('SEp_%s.dat', sid{s}));
            S = dload(fn);
            S = trial_routine(S);
            S.SN = ones(numel(S.TN),size(S.pressNum,2)) * s;
            D = addstruct(D, S);
        end
        
        % reshape data
        P.SN = reshape(D.SN, numel(D.SN),1);
        P.isCorrect = reshape(D.isCorrect, numel(D.isCorrect),1);
        P.pressNum = reshape(D.pressNum, numel(D.pressNum),1);
        
        % summarize data
        T = tapply(P, {'SN', 'pressNum'},...
            {P.isCorrect, 'nanmean', 'name', 'pCorrect'});
        
        % plot data
        figure('Name', 'percept control'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
        plt.line(T.pressNum, T.pCorrect, 'split',T.SN, 'style',allsubsty);
        hold on
        plt.line(T.pressNum, T.pCorrect, 'style',bksty);
        xlabel('Distance from fixation (cm)'); ylabel('p(Correct press)');
        dist = round(linspace(0,13.5,14),1); xticklabels(dist); set(gca,'fontsize',fs);
        ylim([0.1 1.05]);
        drawline(0.2, 'dir','horz', 'linestyle','--');
        axis square;
        
        % stats
        
        % out
        varargout = {T}; %return main structure
        
    case 'fixation_strategy' % analysis of eye movements to investigate changes in fixation strategies with learning
        % load group data
        ds = load( fullfile(pathToData, 'se2_eyeInfo.mat'));
        eyeinfo = ds.eyeinfo;
        eyeinfo = getrow(eyeinfo, eyeinfo.seqNumb==0); % select random sequences only
        D.SN = eyeinfo.TN;
        D.BN = eyeinfo.BN;
        D.SN = eyeinfo.sn;
        D.day = eyeinfo.day;
        D.horizon = eyeinfo.Horizon;
        D.PB = eyeinfo.PB; % preview benefit: how far ahead is the eye position with respect to current digit, at the time of current press
        D.pressNum = eyeinfo.prsnumb;
        D.RT = eyeinfo.RT;
        D.IPI1 = eyeinfo.initIPI;
        D.IPI13 = eyeinfo.finlIPI;
        
        D.horizon(D.horizon>4) = 4;
        
        %T = tapply(D, {'SN', 'day', 'horizon', 'pressNum'}, {'PB', 'nanmean'}, 'subset',ismember(D.day,[1,5]) & ismember(D.pressNum,3:12));
        T = tapply(D, {'SN', 'day', 'horizon', 'pressNum'}, {'PB', 'nanmean'}, 'subset',ismember(D.day,[1,5]));
        T = normData(T, {'PB'});
        
        % plot
        figure('Name', 'Fixation strategy'); set(gcf, 'Units','normalized', 'Position',[0.1,0.1,0.8,0.8], 'Resize','off', 'Renderer','painters');
        plt.line([T.horizon T.pressNum], T.normPB, 'split',T.day, 'style',daysty, 'leg',lrnleg);
        ylabel('Eye position relative to current press');
        xlabel('Press number'); ylim([-1 2]);
        drawline(0, 'dir','horz', 'linestyle','-.', 'linewidth',1); set(gca,'fontsize',fs);
        
        % stats
        %T2 = tapply(D, {'SN', 'day', 'horizon'}, {'PB', 'nanmean'}, 'subset',ismember(D.day,[1,5]) & ismember(D.pressNum,3:12));
        T2 = tapply(D, {'SN', 'day', 'horizon'}, {'PB', 'nanmean'}, 'subset',ismember(D.day,[1,5]));
        T.ANOVA = anovaMixed(T2.PB, T2.SN,'within', [T2.horizon,T2.day],{'Horizon','Day'});
        
        % out
        varargout = {T}; %return main structure
        
    otherwise
        error('no such case!')
end
end

% function [fit_params]=fit_exp_model(x,y,init_params)
% fcn=@(params)loss_fcn(y,exp_model(params,x));
% fit_params=fminsearch(fcn,init_params);
% end
%
% function [y_pred]=exp_model(params,x)
% a=params(1); % initial value / starting point
% r=params(2); % decay rate
% c=params(3); % asymptote / plateau
% y_pred = a * exp(-r*(x-1)) + c;
%
% y = c + .05*a
% end
%
% function [loss]=loss_fcn(y,y_pred)
% n=numel(y);
% loss = sum((y - y_pred).^2) / n;
% end

function T = trial_routine(ds)

T = [];
for t = 1:numel(ds.TN)
    D = getrow(ds, t);
    A = fieldnames(D);
    
    % group all cues
    D.AllPress   = []; % what should have been pressed
    presscnt = 0;
    for i = 1:length(A)
        if length(A{i}) > 5
            if strcmp(A{i}(1:5) , 'press') && ~strcmp(A{i}(6) , 'T')
                presscnt = presscnt + 1;
                eval(['D.AllPress = [D.AllPress D.',A{i} , '];']);
            end
        end
    end
    D.pressNum = 1:numel(D.AllPress);
    
    % group all responses
    D.AllResponse   = []; % what was actually pressed
    presscnt = 0;
    for i = 1:length(A)
        if length(A{i}) > 8
            if strcmp(A{i}(1:8) , 'response')
                presscnt = presscnt + 1;
                eval(['D.AllResponse = [D.AllResponse D.',A{i} , '];']);
            end
        end
    end
    
    % look for involuntary eye movements (flagged by repetitions of number 2)
    resp = double(D.AllResponse==2);
    c = 0; idx = zeros(1);
    for rr = 1:numel(resp)-1
        if resp(rr)==1 && resp(rr)==resp(rr+1)
            c = c+1;
            idx(c) = rr;
        end
    end
    
    % look for correct presses and deal with missing data (no response)
    D.AllResponse(D.AllResponse==0) = 3; % if random guessing or stopped guessing, keep same resp number 3
    D.isCorrect = double(D.AllPress==D.AllResponse);
    if c>2
        D.isCorrect(1:end) = NaN; % if eye moved, considet missing response for whole trial
    end
    
    % concatenate each trial
    T = addstruct(T,D);
end

end
