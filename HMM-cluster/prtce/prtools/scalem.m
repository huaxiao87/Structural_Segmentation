%SCALEM Compute scaling map
% 
%   W = SCALEM(A,T)
%
% INPUT
%   A  Dataset
%   T  Type of scaling (optional; default: the mean of A is shifted to the origin)
%
% OUTPUT
%   W  Scaling mapping
%
% DESCRIPTION
% Computes a scaling map W, whose type depends on the parameter T:
%
% []          - The mean of A is shifted to the origin.
% 'variance'  - The mean of A is shifted to the origin and the total variances 
%               of all features are scaled to 1. This is computed for the
%               data as given in A, neglecting class priors.
% 'c-variance'- The mean of A  is shifted to the origin and the average class 
%               variances (within-scatter) are normalized. Class priors are taken
%               into account.
% 'domain'    - The domain for all features in the dataset A is set to [0,1].
% '2-sigma'   - For each feature f, the 2-sigma interval, [f-2*std(f),f+2*std(f)] 
%               is rescaled to [0,1]. Values outside this domain are clipped.
%               Class priors are taken into account.
% 
% The map W may be applied to a new dataset B by B*W.
% 
% SEE ALSO
% MAPPING, DATASET

% Copyright: R.P.W. Duin, r.p.w.duin@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: scalem.m,v 1.7 2004/10/14 06:22:30 davidt Exp $

function W = scalem(a,t)
	prtrace(mfilename);

	if nargin < 2, 
		prwarning(4,'No mapping type specified. The mean of A is shifted to the origin.');
		t = 'empty'; 
	end

	% No data, return an untrained mapping.
	if (nargin < 1) | isempty(a)
		W = mapping('scalem',{t});
		W = setname(W,'Scaling Mapping');
		return;
	end

	[a,c,lablist,p] = cdats(a);
	[m,k] = size(a);
	
	switch t
	case 'empty'
		u = meancov(a);
		u =p*(+u);
		s = ones(1,k);
		clip = 0;

	case 'variance'
		[u,G] = meancov(+a);
		s = sqrt(diag(G))';
		clip = 0;

	case 'c-variance'
		r = classsizes(a);
		U = meancov(a);
		u = p*(+U);
		s = zeros(1,k);
		for j=1:c
			s = s + p(j)*var(+seldat(a,j)-repmat(+U(j,:),r(j),1));
		end
		s = sqrt(s);
		clip = 0;

	case 'domain'
		mx = max(a,[],1)+eps;
		mn = min(a,[],1)-eps;
		u = mn;
		s = (mx - mn)*(1+eps);
		clip = 0;

	case '2-sigma'
		U = meancov(a);
		u = p*(+U);
		s = zeros(1,k);
		for j=1:c
			s = s + p(j)*var(+seldat(a,j));
		end
		s = sqrt(s);
		s = 4*s;
		u = u-0.5*s;
		clip = 1;

	otherwise
		error('Unknown option')
	end

	J = find(s==0);
	s(J) = ones(size(J)); 				% No scaling for zero variances.

	W = cmapm({u,s,clip},'scale');	
	W.size_out = a.featsize;

return;
