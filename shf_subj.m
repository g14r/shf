function S = shf_subj(snum, sid, fig, block, trial)
%% function S = shf_subj(subj, fig, block, trial)
% Subject routine for SequenceRepetition experiment 3
%
% Example calls:
%               S=shf_subj(1,'CG1');         % which subj
%               S=shf_subj(1,'CG1',0);       % which subj, with/without plot
%               S=shf_subj(1,'CG1',0,3);     % which subj, with/without plot, which block, all trials
%               S=shf_subj(1,'CG1',1,7,5);   % which subj, with/without plot, which block, and which trial in this block
%
%%
if nargin<3
    fig=0; %don't produce a plot
end
%%
pathToData='/Volumes/MotorControl/data/SeqEye2/SEp/data'; %path to data
pathToAnalize='/Users/giacomo/Documents/data/SeqHorizonFinger/shf/analyze'; %path to data
datafilename=fullfile(pathToData,sprintf('SEp_%s.dat',sid)); %input (from server)
outfilename=fullfile(pathToAnalize,sprintf('shf_s%02d.mat',snum)); %output (locally)
%%
S=[]; %preallocate an empty output structure
D=dload(datafilename); %load dataset for this subj
if (nargin<4)
    trials=1:numel(D.TN); %analyze all trials for all blocks
    block=-1; %initialize block count variable
else
    if (nargin<5)
        trials=find(D.BN==block & D.TN==1):find(D.BN==block & D.TN==numel(unique(D.TN))); %analyze all trials for this block
    else
        trials=find(D.BN==block & D.TN==trial); %analyze this trial of this block
    end
end
%%
for t=trials
    if ~exist('MOV','var') || (D.BN(t)~=block)
        block=D.BN(t); %update block number within the loop 
        MOV=movload(fullfile(pathToData,sprintf('SEp_%s_%02d.mov',sid,block))); %load MOV file for this block
    end
    fprintf(1,'\nsubnum: %02d   subid: %s   block: %02d   trial: %02d\n\n',snum,sid,block,D.TN(t));
    fig_name=sprintf('shf_%02d_b%02d_t%02d',snum,block,D.TN(t));
    T=shf_trial(MOV{D.TN(t)},getrow(D,t),fig,fig_name);
    S=addstruct(S,T,'row','force');
end
%%
if (nargin<4)
    save(outfilename,'-struct','S');
end