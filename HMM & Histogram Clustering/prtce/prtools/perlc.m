% PERLC - Train a linear perceptron classifier
% 
%   W = PERLC(A)
%   W = PERLC(A,MAXITER,ETA,W0)
%
% INPUT
%   A        Training dataset
%   MAXITER  Maximum number of iterations (default 100)
%   ETA      Learning rate (default 0.1)
%   W_INI    Initial weights, as affine mapping, e.g W_INI = NMC(A)
%            (default: random initialisation)
%
% OUTPUT
%   W        Linear perceptron classifier mapping
%
% DESCRIPTION
% Outputs a perceptron W trained on dataset A using learning rate ETA for a
% maximum of MAXITER iterations (or until convergence). 
%
% SEE ALSO
% DATASETS, MAPPINGS, NMC, FISHERC, BPXNC, LMNC

% Copyright: D. de Ridder, R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: perlc.m,v 1.7 2003/11/22 23:20:59 bob Exp $

function w = perlc (a, maxiter, eta, w_ini)

	prtrace(mfilename);

	if (nargin < 4)
		prwarning(3,'No initial weights W_INI supplied, using random initialization');
		w_ini = []; 
	end
	if (nargin < 3)
		prwarning(3,'Learning rate ETA not specified, assuming 0.1');
		eta = 0.1;     
	end
	if (nargin < 2)
		prwarning(3,'Maximum number of iterations not specified, assuming 100');
		maxiter = 100; 
	end
	if (nargin < 1) | (isempty(a))
		w = mapping(mfilename,{maxiter,eta,w_ini});
		w = setname(w,'Linear Perceptron');
		return
	end
  	
	% Unpack the dataset.
	islabtype(a,'crisp');
	isvaldset(a,1,2); % at least 1 object per class, 2 classes
	[m,k,c] = getsize(a); 
	nlab = getnlab(a);

	% PERLC is basically a 2-class classifier. More classes are
	% handled by mclassc.
	
	if c == 2   % two-class classifier

		% Add a column of 1's for the bias term.
		Y = [+a ones(m,1)]; 

		% Initialise the WEIGHTS with a small random uniform distribution,
		% or with the specified affine mapping.
		if isempty(w_ini)
			weights = 0.02*(rand(k+1,c)-0.5);
		else
			isaffine(w_ini);
			weights = [w_ini.data.rot;w_ini.data.offset];
		end

		converged = 0; iter = 0;
		while (~converged)

			% Find the maximum output for each sample.
			[dummy,ind] = max((Y*weights)');

			% Update only incorrectly classified samples.
			changed = 0;
			for i = 1:m
				if (ind(i) ~= nlab(i))
					weights(:,nlab(i)) = weights(:,nlab(i)) + eta*Y(i,:)';
					weights(:,ind(i))  = weights(:,ind(i))  - eta*Y(i,:)';
					changed = 1;
				end;
			end;

			% Continue until things stay the same or until MAXITER iterations.
			iter = iter+1;
			converged = (~changed | iter >= maxiter);

		end

		% Build the classifier
		w = affine(weights(1:k,:),weights(k+1,:),a);
		w = cnormc(w,a);
	
	else   % multi-class classifier:
		
		w = mclassc(a,mapping(mfilename,{maxiter,eta,w_ini}));
		
	end	
		
return
