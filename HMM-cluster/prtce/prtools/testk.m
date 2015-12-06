%TESTK Error estimation of the K-NN rule
% 
% 	E = TESTK(A,K,T)
%
% INPUT
% 	A		Training dataset
% 	K 	Number of nearest neighbors (default 1)
% 	T 	Tuning dataset (default [], i.e. use leave-one-out estimate on A)
%
% OUTPUT
% 	E		Estimated error of the K-NN rule
%
% DESCRIPTION  
% Tests a dataset T on the training dataset A using the K-NN rule and
% returns the classification error E. In case no set T is provided, the
% leave-one-out error estimate on A is returned.
% 
% The advantage of using TESTK over TESTC is that it enables leave-one-out 
% error estimation.
% 
% SEE ALSO
% DATASETS, KNNC, KNN_MAP, TESTC

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: testk.m,v 1.6 2003/10/19 14:41:59 bob Exp $

function e = testk(a,knn,t)

	prtrace(mfilename);

	if (nargin < 2)	
		prwarning(2,'number of neighbours K not specified, assuming 1');
		knn = 1; 
	end

	% Calculate the KNN classifier.

	a = seldat(a);   % get labeled objects only
	w = knnc(a,knn);

	[m,k] = size(a); nlab = getnlab(a);

	if (nargin <= 2)						% Leave-one-out error estimate.

		d = knn_map([],w);				% Posterior probabilities of KNNC(A,KNN).
		[dmax,J] = max(d,[],2);		% Find the maximum.
		e = nlabcmp(J,nlab)/m;		% Calculate error: compare numerical labels.

	else												% Error estimation on tuning set T.

		[n,kt] = size(t);
		if (k ~= kt)
			error('Number of features of A and T do not match.');
		end

		d = knn_map(t,w); 				% Posterior probabilities of T*KNNC(A,KNN).
		[dmax,J] = max(d,[],2); 	% Find the maximum.
		lablist = getlablist(a);	% Calculate error: compare full labels.
		e = nlabcmp(getlab(t),lablist(J,:))/n;

	end

return
