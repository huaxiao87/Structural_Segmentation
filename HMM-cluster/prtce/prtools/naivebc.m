%NAIVEBC Naive Bayes classifier
% 
% 	W = NAIVEBC(A,K)
% 
% INPUT	
%   A   Training dataset
%   N   Scalar number of bins (default: 10)
%
% OUTPUT
%   W   Naive Bayes classifier mapping
%
% DESCRIPTION
% Stores the naive Bayes classifier. This version divides each axis into N
% bins, counts the number of training examples for each of the classes in
% each of the bins, and classifies the object to the class that gives
% maximum posterior probability. Missing values will be put into a separate
% bin.
%
% A future version may handle discrete features properly, this one treats
% them as continuous variables.
%
% SEE ALSO
% DATASETS, MAPPINGS, UDC, QDC, PARZENC, PARZENDC

% Copyright: D.M.J. Tax, R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands
  
% $Id: naivebc.m,v 1.18 2004/02/28 21:28:54 bob Exp $

function w = naivebc(a,arg2)

	if (nargin < 2)
		prwarning (2,'number of bins not specified, assuming 10.');
		arg2 = 10; 
	end

	% No arguments given: return untrained mapping.

	if (nargin < 1) | (isempty(a))
		w = mapping(mfilename,{arg2});
		w = setname(w,'Naive Bayes');
		return
	end

	if (~ismapping(arg2))     % Second argument is not a mapping: training.

		N = arg2;
	
		islabtype(a,'crisp');
		isvaldset(a,1,2); % at least 2 object per class, 2 classes

		[m,k,c] = getsize(a); M = classsizes(a);

		% Train the mapping. First, find the scale and offset of the data 
		% and normalise (this is very non-robust, but ok...)

		offset_a = min(a); maxa = max(a); scale_a = maxa - offset_a;
		
		if(any(scale_a==0))
			prwarning (2,'one of the features has the same value for all data; scale change to realmin');
			scale_a(scale_a==0) = realmin;		
		end

		a = a - repmat(offset_a,m,1);
		a = a ./ repmat(scale_a,m,1);

		% P will contain the probability per bin per class, P0 the probability
		% per class. The highest and lowest bounds will not be used; the lowest
		% bound will be used to store the missing values.

		p  = zeros(N+1,k,c);

		% Count the number of objects for each of the classes.

		for i = 1:c

			Ic = findnlab(a,i);											% Extract one class.
			Ia = ceil(N*+(a(Ic,:)));								% Find out in which bin it falls.
			Ia(Ia<1) = 1; Ia(Ia>N) = N;							% Sanity check.

			for j=1:N
				p(j,:,i) = sum(Ia==j);								% Count for all bins.
			end

			p(N+1,:,i) = sum(~isnan(+a(Ic,:))); 	% The missing values.
			
			% Use Bayes estimators are used, like elsewhere in PRTools.
			
			p(:,:,i) = (p(:,:,i)+1) / (M(i)+N); 						% Probabilities.
			p(:,:,i) = p(:,:,i) ./ repmat(scale_a/N,N+1,1); 	% Densities.

		end

		% Save all useful data.

		pars.p0 = getprior(a); pars.p = p; pars.N = N;
		pars.offset_a = offset_a; pars.scale_a = scale_a;

		w = mapping(mfilename,'trained',pars,getlablist(a),k,c);
		w = setname(w,'Naive Bayes');
		w = setcost(w,a);

	else                      % Second argument is a mapping: testing.

		w = arg2;
		pars = getdata(w);		 	% Unpack the mapping.
		[m,k] = getsize(a); 
		c = length(pars.p0);       % Could also use size(w.labels,1)...

		% Shift and scale the test set.

		a = a - repmat(pars.offset_a,m,1);
		a = a ./ repmat(pars.scale_a,m,1);

		% Classify the test set. First find in which bins the objects fall.

		Ia = ceil(pars.N*+(a));
		Ia(Ia<1) = 1; Ia(Ia>pars.N) = pars.N;			% Sanity check.

		% Find the class probability for each object for each feature
		out = zeros(m,k,c);
		for i=1:k
			out(:,i,:) = pars.p(Ia(:,i),i,:);
		end

		% Multiply the per-feature probs.
		out = squeeze(prod(out,2));
		
		if m == 1
			out = out';
		end

		% Weight with class priors
		out = out .* repmat(pars.p0,m,1);
		
		% Done!
		w = setdat(a,out,w);

	end

return



