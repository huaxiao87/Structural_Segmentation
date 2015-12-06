%LOGLC Logistic Linear Classifier
% 
%   W = LOGLC(A)
% 
% INPUT
%   A   Dataset
%
% OUTPUT
%   W   Logistic linear classifier 
%
% DESCRIPTION  
% Computation of the linear classifier for the dataset A by maximizing the
% likelihood criterion using the logistic (sigmoid) function.
% 
% REFERENCES
% A. Webb, Statistical Pattern Recognition, John Wiley & Sons, New York, 2002.
%
%  SEE ALSO 
%  MAPPINGS, DATASETS, LDC, FISHERC

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: loglc.m,v 1.9 2003/11/22 23:20:39 bob Exp $

function W = loglc(a)

	prtrace(mfilename);

	% No input data, return an untrained classifier.
	if (nargin == 0) | (isempty(a))
		W = mapping(mfilename); 
		W = setname(W,'Logistic Classifier');
		return
	end

	islabtype(a,'crisp');
	isvaldset(a,1,2); % at least 2 object per class, 2 classes

	[m,k,c] = getsize(a);
	nlab = getnlab(a);
	prior = getprior(a);
	if (c > 2)
		% Compute C classifiers: each class against all others.	
		W = mclassc(a,mapping(mfilename));	
	else
		v = scalem(a,'variance');
		a = a*v;
		accuracy = 0.0001;		% An accuracy for the ML loop.
		x = [+a,ones(m,1)];
		% A standard trick to set the labels to +1 for the first class
		% (NLAB=1) and to -1 for the second one (NLAB=2). Then, each 
		% object vector is multiplied by its new label +/-1.
		x(find(nlab==2),:) = -x(find(nlab==2),:);

		alf = sum(nlab==2)/sum(nlab==1);
		weights = zeros(1,k+1);
		% Maximize the likelihood L to find WEIGHTS
		L = -inf; Lnew = -realmax;
		while (abs(Lnew - L) > accuracy)
			pax = ones(m,1) ./ (1 + exp(-x*weights'));	% Estimate of P(class +1|x).
			pbx = 1 - pax;                          		% Estimate of P(class -1|x).
			L = Lnew; Lnew = sum(log(pax+realmin));     % Update likelihood.	
			p2x = sqrt(pax.*pbx); 
			y = x .* p2x(:,ones(1,k+1));
			weights = pbx' * x * pinv(y'*y) + weights;
		end

		% Define LOGLC by an affine (linear) mapping based 
		% on the [K x 1] matrix R and the offset w0.
		w0 = weights(k+1) + log(alf*prior(1)/prior(2));
		R  = weights(1:k)';
		W  = v*affine(R,w0,a,getlablist(a)); 
		W  = setout_conv(W,1);
	end
	W = setname(W,'Logistic Classifier');

	return
