%KNNM K-Nearest Neighbour based density estimate
%
%   W = KNNM(A,KNN)
%
%   D = B*W
% 
% INPUT
% 	A     Dataset
%   KNN   Number of nearest neighbours	
%
% OUTPUT
%   W     Density estimate 
%
% DESCRIPTION  
% A density estimator is constructed based on the k-Nearest Neighbour rule
% using the labeled objects in A. All objects, however, are used if the
% entire dataset is unlabeled or if A is not a dataset, but a double. 
% In all cases, just single density estimator W is computed.
% Class priors in A are neglected.
% 
% The mapping W may be applied to a new dataset B using DENSITY = B*W.
%
% SEE ALSO
% DATASETS, MAPPINGS, KNNC, QDC, PARZENM, GAUSSM

% $Id: knnm.m,v 1.7 2004/02/28 21:28:54 bob Exp $

function w = knnm(a,arg2)

	prtrace(mfilename);

	if (nargin < 2)
		prwarning(2,'number of neighbours to use not specified, assuming 1');
		arg2 = 1; 
	end

	if (nargin < 1) | (isempty(a)) 		% No arguments given: return empty mapping.

		w = mapping(mfilename,arg2);
		w = setname(w,'KNN Density Estimation');

	elseif (~isa(arg2,'mapping'))			% Train a mapping.

		knn = arg2;
		
		if ~isdataset(a) | getsize(a,3) ~= 1
			w = mclassm(a,mapping(mfilename,knn),'weight');
			return
		end
		islabtype(a,'crisp');
		isvaldset(a,1);
		a = remclass(a);
		[m,k] = size(a);
		lablist = getlablist(a);
		w = mapping(mfilename,'trained',{a,knn},lablist,k,1);
		w = setname(w,'KNN Density Estimation');

	else															% Execute a trained mapping V.

		v = arg2;
		b   = v.data{1};								% B is the original training data.
		knn = v.data{2};
		iscomdset(a,b,0);
		[m,k] = size(b); 
		u = scalem(b,'variance');
		a = a*u;
		b = b*u;
		d = sqrt(distm(+a,+b));					% Calculate squared distances
		[s,J] = sort(d,2);							%   and find nearest neighbours.
		ss = s(:,knn);									% Find furthest neighbour
		ss(find(ss==0)) = realmin.^(1/k);	% Avoid zero distances
		f = knn./(m*nsphere(k)*(ss.^k)); 	% Normalize by the volume of sphere
																		%   defined by the furthest neighbour.
		f = f*prod(u.data.rot);         % Correct for scaling																

		w = setdat(a,f,v);							% proper normalisation has still to be done.

	end

return

function v = nsphere(k)

	% Volume k-dimensional sphere
	v = (2*(pi^(k/2))) / (k*gamma(k/2));
	
return
