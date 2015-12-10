%PARZENM Estimate Parzen densities
%
%	  W = PARZENM(A,H)
%   W = A*PARZENM([],H)
%   [W,H] = PARZENM(A)
%
%	  D = B*W
%
% INPUT
%   A  Input dataset
%   H  Smoothing parameters (scalar, vector)
%
% OUTPUT
%   W  output mapping
%
% DESCRIPTION
% A Parzen distribution is estimated for the labeled objects in A. Unlabeled
% objects are neglected, unless A is entirely unlabeled or double. Then all
% objects are used. If A is a multi-class dataset the densities are estimated
% class by class and then weighted and combined according their prior
% probabilities. In all cases, just single density estimator W is computed.
% 
% The mapping W may be applied to a new dataset B using DENSITY = B*W.
%
% The smoothing parameter H is estimated by PARZENML and returned if not 
% supplied. It can be a scalar or a vector with as many components as A has 
% features.
%
% SEE ALSO
% DATASETS, MAPPINGS, KNNM, GAUSSM, PARZENML, PARZENDC, KNNM

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: parzenm.m,v 1.7 2004/08/16 15:36:43 dick Exp $

function w = parzenm(a,h)
	
	prtrace(mfilename);

	if (nargin < 2)
		prwarning(4,'smoothing parameter not specified, will optimize by leave-one-out ML');
		h = []; 
	end

	% No input arguments specified: return an untrained mapping.

	if (nargin < 1 | isempty(a))
		w = mapping(mfilename,h); 
		w = setname(w,'Parzen Density Estimation');
		return; 
	end

	if (~isdataset(a) | getsize(a,3) ~= 1)
		w = mclassm(a,mapping(mfilename,h),'weight');
		return
	end

	lablist = getlablist(a);
	[m,k] = size(a);
		
	% Scale A such that its mean is shifted to the origin and 
	% the variances of all features are scaled to 1. 
	ws = scalem(a,'variance');
	b = a*ws;  

	% SCALE is basically [1/mean(A) 1/STD(A)] based on the properties of SCALEM.
	scale = ws.data.rot;				
	if (size(scale,1) ~= 1) % formally ws.data.rot stores a rotation matrix 
		scale = diag(scale)'; % extract the diagonal if it does,
	end                     % otherwise we already have the diagonal
	if isempty(h)
		h = repmat(parzenml(b),1,k)./scale;
	end
	w = mapping('parzen_map','trained',{a,h},lablist,k,1);
	w = setname(w,'Parzen Density Estimation');

return
