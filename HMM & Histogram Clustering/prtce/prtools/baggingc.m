%BAGGINGC Bootstrapping and aggregation of classifiers
% 
%    W = BAGGINGC (A,CLASSF,N,ACLASSF,T)
% 
% INPUT
%   A         Training dataset.
%   CLASSF    The base classifier (default: nmc)
%   N         Number of base classifiers to train (default: 100)
%   ACLASSF   Aggregating classifier (default: nmc), [] for no aggregation.
%   T         Tuning set on which ACLASSF is trained (default: [], meaning use A)
%
% OUTPUT
%    W        A combined classifier (if ACLASSF was given) or a stacked
%             classifier (if ACLASSF was []).
%
% DESCRIPTION
% Computation of a stabilised version of a classifier by bootstrapping and
% aggregation ('bagging'). In total N bootstrap versions of the dataset A
% are generated and used for training of the untrained classifier CLASSF.
% Aggregation is done using the combining classifier specified in CCLASSF.
% If ACLASSF is a trainable classifier it is trained by the tuning dataset
% T, if given; else A is used for training. The default aggregating classifier
% ACLASSF is MEANC. Default input classifier CLASSF is NMC.
%
% Note that the classifier combiner MEANC averages the coefficients of the
% affine linear input classifiers, e.g. W = baggingc(A,nmc); This can be
% avoided by using W = baggingc(A,nmc*classc), which will average posterior
% probability outputs.
% 
% SEE ALSO
% DATASETS, MAPPINGS, NMC, MEANC, BOOSTINGC

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: baggingc.m,v 1.5 2003/09/15 07:09:52 bob Exp $

function w = baggingc (a,clasf,n,rule,t)
	prtrace(mfilename);

	if (nargin < 5), 
		prwarning(2,'no tuning set supplied, using training set for tuning (risk of overfit)');
		t = []; 
	end
	if (nargin < 4) | isempty(rule),
		prwarning(2,'aggregating classifier not specified, assuming nmc'); 
		rule = meanc; 
	end
	if (nargin < 3) | isempty(n),
		prwarning(2,'number of repetitions not specified, assuming 100');
		n = 100; 
	end
	if (nargin < 2) | isempty(clasf),
		prwarning(2,'base classifier not specified, assuming nmc');
		clasf = nmc; 
	end
	if ((nargin < 1) | isempty(a))
		w = mapping('baggingc',{clasf,n,rule});
		return
	end

	iscomdset(a,t); % test compatibility training and tuning set
	
	% Concatenate N classifiers on bootstrap samples (100%) taken
	% from the training set.

	w = [];
	for i = 1:n
		w = [w gendat(a)*clasf]; 
	end

	% If no aggregating classifier is given, just return the N classifiers...

	if (~isempty(rule))

		% ... otherwise, train the aggregating classifier on the train or
		% tuning set.

		if (isempty(t))
			w = traincc(a,w,rule);
		else
			w = traincc(t,w,rule);
		end
	end

	w = setcost(w,a);
	
	return
