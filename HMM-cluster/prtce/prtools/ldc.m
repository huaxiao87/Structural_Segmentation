%LDC Linear Bayes Normal Classifier (BayesNormal_1)
%
%   W = LDC(A,R,S)
% 
% INPUT
%   A    Dataset
%   R,S  Regularization parameters, 0 <= R,S <= 1
%        (optional; default: no regularization, i.e. R,S = 0)
% 
% OUTPUT
%   W    Linear Bayes Normal classifier 
%
% DESCRIPTION  
% Computation of the linear classifier between the classes of the dataset A
% by assuming normal densities with equal covariance matrices. The joint
% covariance matrix is the weighted (by a priori probabilities) average of
% the class covariance matrices. R and S (0 <= R,S <= 1) are regularization
% parameters used for finding the covariance matrix G by:
%
%      G = (1-R-S)*G + R*diag(diag(G)) + S*mean(diag(G))*eye(size(G,1))
%
% The use of soft labels is supported. The classification A*W is computed
% by NORMAL_MAP.
%
% Note that A*(KLMS([],N)*NMC) performs a very similar operation by first
% pre-whitening the data in an N-dimensional space, followed by the
% nearest mean classifier. The regularization controlled by N is different
% from the above in LDC as it entirely removes small variance directions.
%
% To some extend LDC is also similar ot FISHERC

%
% EXAMPLES
% See PREX_PLOTC.
%
% REFERENCES
% 1. R.O. Duda, P.E. Hart, and D.G. Stork, Pattern classification, 2nd edition, 
% John Wiley and Sons, New York, 2001.
% 2. A. Webb, Statistical Pattern Recognition, John Wiley & Sons, New York, 2002.
% 3. C. Liu and H. Wechsler, Robust Coding Schemes for Indexing and Retrieval
% from Large Face Databases, IEEE Transactions on Image Processing, vol. 9, 
% no. 1, 2000, 132-136.

%
%  SEE ALSO
%  MAPPINGS, DATASETS, NMC, NMSC, LDC, UDC, QUADRC, NORMAL_MAP, FISHERC

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: ldc.m,v 1.15 2004/02/26 13:56:39 bob Exp $

function W = ldc(a,r,s)

	prtrace(mfilename);

	if (nargin < 3)
		prwarning(4,'Regularisation parameter S not given, assuming 0.');
		s = 0; 
	end
	if (nargin < 2)
		prwarning(4,'Regularisation parameter R not given, assuming 0.');
		r = 0;
	end

	% No input arguments: return an untrained mapping.
	if (nargin < 1) | (isempty(a))
		W = mapping(mfilename,{r,s});
		W = setname(W,'Bayes-Normal-1');
		return
	end

	islabtype(a,'crisp','soft');
	isvaldset(a,2,2); % at least 2 object per class, 2 classes

	[m,k,c] = getsize(a);
	if (c==0)
		error('Cannot train the classifier, because unlabeled data is supplied');
	end

	% Calculate mean vectors, priors and the covariance matrix G.
	[U,G] = meancov(a);
	w.mean  = +U;
	w.prior = getprior(a);
	G = reshape(sum(reshape(G,k*k,c)*w.prior',2),k,k);

	% Regularize 
	if (s > 0) | (r > 0)
 		G = (1-r-s)*G + r * diag(diag(G)) + s*mean(diag(G))*eye(size(G,1));
	end
	w.cov = G;

	W = mapping('normal_map','trained',w,getlab(U),k,c);
	W = setname(W,'Bayes-Normal-1');
	W = setcost(W,a);
	
	return
