function [ state_equnce ] = getStateSequence( X , stateNum)
% training the HMM and using Viterbi algorithm to decode the state sequence
%   X        feature sequence
%   stateNum number of states

% Initialize the HMM
initHmm      = hmminit(stateNum,X);

% train the model
model        = hmmem(X,initHmm);

% using Viterbi algorithm to decode the state sequnce
state_equnce = hmmviterbi(X,model);
end

