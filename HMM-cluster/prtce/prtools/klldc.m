%KLLDC Linear classifier built on the KL expansion of the common covariance matrix
% 
%  W = KLLDC(A,N)
%  W = KLLDC(A,ALF)
% 
% INPUT
%  A    Dataset
%  N    Number of significant eigenvectors 
%  ALF  0 < ALF <= 1, percentage of the total variance explained (default: 0.9)
%
% OUTPUT
%  W    Linear classifier 
%
% DESCRIPTION  
% Finds the linear discriminant function W for the dataset A. This is done  
% by computing the LDC on the data projected on the first eigenvectors of
% the averaged covariance matrix of the classes.  Either first N eigenvectors
% are used or the number of eigenvectors is determined such that ALF, the 
% percentage of the total variance is explained. (Karhunen Loeve expansion)
%
%	SEE ALSO
%	MAPPINGS, DATASETS, PCLDC, KLM, FISHERM

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: klldc.m,v 1.8 2003/11/22 23:20:38 bob Exp $

function W = klldc(a,n)
	prtrace(mfilename);
	if nargin < 2
		n = [];
		prwarning(4,'number of significant eigenvectors not supplied, 0.9 variance explained');
	end
	if nargin == 0 | isempty(a)
		W = mapping('klldc',{n});
		W = setname(W,'KL Bayes-Normal-1');
		return;
	end

	islabtype(a,'crisp','soft');
	isvaldset(a,2,2); % at least 2 object per class, 2 classes

	v = klm(a,n);
	W = v*ldc(a*v);
	W = setname(W,'KL Bayes-Normal-1');
	W = setcost(W,a);
	
return
