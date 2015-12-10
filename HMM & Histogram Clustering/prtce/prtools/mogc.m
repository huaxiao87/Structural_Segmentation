%MOGC Mixture of Gaussian classifier
%
%   W = MOGC(A,N)
%   W = A*MOGC([],N);
%
%	INPUT
%    A   Dataset
%    N   Number of mixtures (optional; default 2)
%	OUTPUT
%
% DESCRIPTION
% For each class j in A a density estimate is made by GAUSSM, using N(j)
% mixtures. Using the class prior probabilities they are combined into
% a single classifier W. If N is a scalar, this number is applied to each
% class.
%
% EXAMPLES
% PREX_DENSITY
%
% SEE ALSO
% DATASETS, MAPPINGS, QDC, PLOTM, TESTC

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: mogc.m,v 1.9 2004/02/28 21:28:54 bob Exp $

function w = mogc(a,n);

	prtrace(mfilename);

	if nargin < 2, n = 2; end
	if nargin < 1 | isempty(a)
		w = mapping(mfilename,n);
		w = setname(w,'MoG Classifier');
		return
	end
	
	islabtype(a,'crisp','soft');
	isvaldset(a,n,2); % at least n objects per class, 2 classes
	
	% Initialize all the parameters:
	a = dataset(a);
	[m,k,c] = getsize(a);
	p = getprior(a);
	if length(n) == 1
		n = repmat(n,1,c);
	end
	if length(n) ~= c
		error('Numbers of components does not match number of classes')
	end
	w = [];
	d.mean = zeros(sum(n),k);
	d.cov = zeros(k,k,sum(n));
	d.prior = zeros(1,sum(n));
	d.nlab = zeros(1,sum(n));

	if(any(classsizes(a)<n))
		error('One or more class sizes too small for desired number of components')
	end

	% Estimate a MOG for each of the classes:
	w = [];
	n1 = 1;
	for j=1:c
		n2 = n1 + n(j) - 1;
		b = seldat(a,j);
		v = gaussm(b,n(j));
		d.mean(n1:n2,:) = v.data.mean;
		d.cov(:,:,n1:n2)= v.data.cov;
		d.prior(n1:n2)  = v.data.prior*p(j);
		d.nlab(n1:n2)   = j;
		n1 = n2+1;
	end
	
	w = mapping('normal_map','trained',d,getlablist(a),k,c);
	w = setname(w,'MoG Classifier');
	w = setcost(w,a);
	
return;
