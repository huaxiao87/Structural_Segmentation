N = 30;                 % initially start with ten segments, each having a 1-component MoG:
MD = 3;                 % minimum duration of 3 frames
crit.maxiters = 1000;     % stopcriterion: max. nr. of iterations
crit.minllimpr = 1e-3;  % stopcriterion: min. likelihood improvement
reg = 1e-3;             % regularization inverse cov. matrices
% train the HMM (also obtain the viterbi-path):
[hmm,pth] = hmmtimesegment(x,N,MD,crit,reg);
% segment a new sequence:
