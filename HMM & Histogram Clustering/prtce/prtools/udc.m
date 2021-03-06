%UDC Uncorrelated normal based quadratic Bayes classifier (BayesNormal_U)
% 
%  W = UDC(A)
% 
% INPUT
%  A  input dataset
%
% OUTPUT
%  W   output mapping
%
% DESCRIPTION
% Computation a quadratic classifier between the classes in the 
% dataset A assuming normal densities with uncorrelated features.
%
% The use of probabilistic labels is supported.  The classification A*W is
% computed by normal_map.
% 
% EXAMPLES
% PREX_DENSITY
%
% SEE ALSO
% MAPPINGS, DATASETS, NMC, NMSC, LDC, QDC, QUADRC, NORMAL_MAP

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: udc.m,v 1.6 2003/11/22 23:19:27 bob Exp $

function W = udc(a)

	prtrace(mfilename);
	
	if nargin == 0
		W = mapping(mfilename);
		W = setname(W,'Bayes-Normal-U');
		return
	end

	islabtype(a,'crisp','soft');
	isvaldset(a,2,2); % at least 2 objects per class, 2 classes
	[m,k,c] = getsize(a);

	[U,G] = meancov(a); %computing mean and covariance matrix
	p = getprior(a);
	for j = 1:c
		G(:,:,j) = diag(diag(G(:,:,j)));
	end
	w.mean = +U;
	w.cov = G;
	w.prior = getprior(a);
	W = mapping('normal_map','trained',w,getlab(U),k,c);
	W = setname(W,'Bayes-Normal-U');
	W = setcost(W,a);

return

