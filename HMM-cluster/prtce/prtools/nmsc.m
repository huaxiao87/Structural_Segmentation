%NMSC Nearest Mean Scaled Classifier
% 
% 	W = NMSC(A)
% 
% INPUT
%   A   Trainign dataset
%
% OUTPUT
%   W   Nearest Mean Scaled Classifier mapping
%
% DESCRIPTION
% Computation of the linear discriminant for the classes in the dataset A
% assuming zero covariances and equal class variances. The use of soft
% labels is supported.
% 
% SEE ALSO
% DATASETS, MAPPINGS, NMC, LDC ,FISHERC, QDC, UDC 

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: nmsc.m,v 1.6 2003/11/22 23:19:27 bob Exp $

function w = nmsc(a)

	prtrace(mfilename);

	% No input arguments: return an untrained mapping.

	if (nargin < 1) | (isempty(a))
		w = mapping(mfilename);
		w = setname(w,'Scaled Nearest Mean');
		return
	end

	islabtype(a,'crisp','soft');
	isvaldset(a,1,2); % at least 1 object per class, 2 classes

	[m,k,c] = getsize(a); p = getprior(a); 
	[U,GG] = meancov(a);
	
	% All class covariance matrices are assumed to be diagonal. They are scaled
	% by the priors, unlike the standard nearest mean classifier (NMC).

	G = zeros(c,k);
	for j = 1:c
		G(j,:) = diag(GG(:,:,j))';
	end
	G = diag(p*G);

	% The two-class case is special, as it can be conveniently stored as an
	% affine mapping.

	if (c == 2)
		ua = +U(1,:); ub = +U(2,:);
		G = inv(G); R = G*(ua - ub)';
		offset = (ub*G*ub' - ua*G*ua')/2 + log(p(1)/p(2));
		w = affine(R,offset,a,getlablist(a)); 
		w = cnormc(w,a);
	else
		pars.mean = +U; pars.cov = G; pars.prior = p;
		w = mapping('normal_map','trained',pars,getlab(U),k,c);
	end

	w = setname(w,'Scaled Nearest Mean');
	w = setcost(w,a);

return
