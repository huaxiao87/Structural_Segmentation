%NORMM Apply Minkowski-P distance normalization map
% 
%   B = A*NORMM(P)
%   B = NORMM(A,P)
% 
% INPUT
%   A  Dataset or matrix
%   P  Order of the Minkowski distance (optional; default: 1)
%
% OUTPUT
%   B  Dataset or matrix of normalized Minkowski-P distances 
%
% DESCRIPTION
% Normalizes the distances of all objects in the dataset A such that their
% Minkowski-P distances to the origin equal one. For P=1 (default), this is 
% useful for normalizing the probabilities. For 1-dimensional datasets 
% (SIZE(A,2)=1), a second feature is added before the normalization such 
% that A(:,2)=1-A(:,1).
% 
% Note that NORMM(P) or NORMM([],P) is a fixed mapping.
% 
% SEE ALSO 
% MAPPINGS, DATASETS, CLASSC

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: normm.m,v 1.10 2004/12/14 21:05:20 duin Exp $

function w = normm(a,p)

	prtrace(mfilename);

	if (nargin == 0) | (isempty(a))
		% No data, store the parameters of a fixed mapping.
		w = mapping(mfilename,'fixed',1);
		w = setname(w,'Normalization Mapping');
	elseif (nargin == 2) & (isempty(a))
		% No data, store the parameters of a fixed mapping.
		w = mapping(mfilename,'fixed',p);
		w = setname(w,'Normalization Mapping');

	elseif (nargin == 1 & (isa(a,'dataset') | length(a) > 1)) | (nargin == 2)
		% We have the case of either W = NORMM(A) or W = NORMM(A,P), 
		% hence W is now a dataset A with normalized Minkowski-P distances.
		[m,k] = size(a);

		featlist = getfeatlab(a);

		if (k == 1) 	
			
			% Normalisation of a 1-D dataset may only be used for one-class
			% classification outcomes. So we test whether this is the case as
			% good as possible and send out warnings as well
			
			a = [a 1-a];			% Add a second feature, handy for the normalization.
			k = 2;
			prwarning(4,'SIZE(A,2)=1, so the second feature 1-A(:,1) is added.');

			if size(featlist,1) < 2
				error('No two class-names found; probably a wrong dataset used.')
			else
				a = setfeatlab(a,featlist(1:2,:));
			end
		end
		
		if (nargin == 1), 
			prwarning(3,'Parameter P is not specified, 1 is assumed.');
			p = 1; 
		end

		% Compute the Minkowski-P distances to the origin.
		if (p == 1)
			dist = sum(abs(a),2);					% Simplify the computations for P=1.
		else
			dist = sum(abs(a).^p,2).^(1/p);
		end

		% For non-zero distances, scale them to 1.
		% Note that W is now a dataset with scaled Minkowski distances.
		J = find(dist ~= 0);
		w = a;
		if ~isempty(J)
			w(J,:) = +a(J,:)./repmat(dist(J,1),1,k);
		end

	elseif (nargin == 1) & isa(a,'double') & (length(a) == 1)
		% We have the case W = NORMM(P), hence W is the mapping.
		w = mapping(mfilename,'fixed',a);
		w = setname(w,'Normalization Mapping');
	else
		error('Operation undefined.')
	end
	
return;
