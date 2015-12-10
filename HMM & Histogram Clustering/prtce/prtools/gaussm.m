%GAUSSM Mixture of Gaussians density estimate
%
%	 W = GAUSSM(A,K)
%  W = A*GAUSS([],K);
%
% INPUT
%	  A	  Dataset
%   K   Number of Gaussians to use (default: 1)
%
% OUTPUT
%	  W   Mixture of Gaussians density estimate
%
% DESCRIPTION
% Estimation of a PDF for the dataset A by a Mixture of Gaussians
% procedure. Use is made of EMCLUST(A,QDC,K). Unlabeled objects are
% neglected, unless A is entirely unlabeled or double. Then all objects
% are used. If A is a multi-class dataset the densities are estimated
% class by class and then weighted and combined according their prior
% probabilities. In all cases, just single density estimator W is computed.
% 
% The mapping W may be applied to a new dataset B using DENSITY = B*W.
%
% SEE ALSO
% DATASETS, MAPPINGS, QDC, MOGC, PLOTM, TESTC

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: gaussm.m,v 1.6 2003/10/20 07:01:32 bob Exp $

function w = gaussm(a,n)

	prtrace(mfilename)

  if (nargin < 2)
		prwarning (2,'number of Gaussians not specified, assuming 1.');
		n = 1; 
	end

	% No arguments specified: return an empty mapping.

	if (nargin < 1) | (isempty(a))
		w = mapping(mfilename,n);
		w = setname(w,'Mixture of Gaussians');
		return
	end
	
	if (~isdataset(a) | getsize(a,3) ~= 1)
		w = mclassm(a,mapping(mfilename,n),'weight');
		return
	end

	lablist = getlablist(a);
	[m,k] = size(a);
	
	if n == 1
		p = getprior(a);
		[U,G] = meancov(a);
		res.mean = +U;
		res.cov  = G;
		res.prior= 1;
	else
		[e,v] = emclust(a,qdc,n);	
		ncomp = size(v.data.mean,1);			
		while (ncomp ~= n)   % repeat until exactly n componednts are found
	 		[e,v] = emclust(a,qdc,n);				
 			ncomp = size(v.data.mean,1);
  	end
  	res.mean = v.data.mean;
  	res.cov  = v.data.cov;
  	res.prior= v.data.prior;
		res.nlab = ones(n,1); % defines that all Gaussian components have to be
		                      % combined into a single class.
	end
	w = mapping('normal_map','trained',res,lablist,k,1);
	w = setname(w,'Mixture of Gaussians');

return
