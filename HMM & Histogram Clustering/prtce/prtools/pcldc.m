%PCLDC Linear classifier using PC expansion on the joint data.
% 
% 	W = PCLDC(A,N)
% 	W = PCLDC(A,ALF)
%
% INPUT
%  A    Dataset
%  N    Number of eigenvectors
%  ALF  Total explained variance (default: ALF = 0.9)
%
% OUTPUT
%  W    Mapping
% 
% DESCRIPTION
% Finds the linear discriminant function W for the dataset A 
% computing the LDC on a projection of the data on the first N  
% eigenvectors of the total dataset (Principle Component Analysis).
% 
% When ALF is supplied the number of eigenvalues is chosen such that at 
% least a part ALF of the total variance is explained. 
% 
% SEE ALSO
% MAPPINGS, DATASETS, KLLDC, KLM, FISHERM

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: pcldc.m,v 1.7 2003/11/22 23:20:38 bob Exp $

function W = pcldc(a,n)

		prtrace(mfilename);

	if nargin < 2, n = []; end
	if nargin == 0 | isempty(a)
		W = mapping('pcldc',{n});
		W = setname(W,'PC Bayes-Normal-1');
		return;
	end

	islabtype(a,'crisp','soft');
	isvaldset(a,2,2); % at least 2 object per class, 2 classes

	% Make a sequential classifier combining PCA and LDC:
	v = pca(a,n);
	W = v*ldc(a*v);
	W = setname(W,'PC Bayes-Normal-1');
	W = setcost(W,a);

return
