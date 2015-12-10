%MEANCOV Estimation of the means and covariances from multiclass data
% 
%   [U,G] = MEANCOV(A,N)
% 
%	INPUT
% 	A		Dataset
%	N		Normalization to use for calculating covariances: by M, the number
%					of samples in A (N = 1) or by M-1 (default, unbiased, N = 0).
%
% OUTPUT
% 	U		Mean vectors
% 	G		Covariance matrices
%
% DESCRIPTION  
%	Computation of a set of mean vectors U and a set of covariance matrices G
%	of the C classes in the dataset A. The covariance matrices are stored as a
%	3-dimensional matrix G of the size K x K x C, the class mean vectors as a
%	labeled dataset U of the size C x K.
%
% The use of soft labels or target labels is supported.
% 
%	SEE ALSO 
%	DATASETS, GAUSS, NBAYESC, DISTMAHA

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: meancov.m,v 1.12 2004/10/12 11:49:13 dick Exp $

function [U,G] = meancov(a,n)

	prtrace(mfilename);

	% N determines whether the covariances are normalized by M (N = 1) or by 
	% M-1 (unbiased, N = 0), where M is the number of objects.

	if (nargin < 2)
		prwarning(4,'normalisation not specified, assuming by M-1');
		n = 0;
	end

	if (n ~= 1) & (n ~= 0)
		error('Second parameter should be either 0 or 1.')
	end

	if (~isa(a,'dataset'))			% A is a matrix: compute mean and covariances
		U = mean(a);							% 	in the usual way.
		G = cov(a,n);
	else
		[m,k,c] = getsize(a);

  	if (islabtype(a,'crisp'))
			
			if (c==0)
				U = mean(+a);
				G = cov(+a,n);
			else
				for i = 1:c     
					J = findnlab(a,i);
					U(i,:) = mean(a(J,:),1);
					if (nargout > 1)
						G(:,:,i) = covm(a(J,:),n);	
					end
				end
			end
			labu = getlablist(a);
  	elseif (islabtype(a,'soft'))
  		problab = gettargets(a);
			% Here we also have to be careful for unlabeled data
			if (c==0)
				prwarning(2,'The dataset has soft labels but no targets defined: using targets 1');
				U = mean(+a);
				G = cov(+a,n);
			else
				U = zeros(c,k);
				for i = 1:c

					% Calculate relative weights for the means.
					g = problab(:,i); nn = sum(g); g = g/mean(g); 

					U(i,:) = mean(a.*repmat(g,1,k));	% Weighted mean vectors	

					if (nargout > 1)

						u  = mean(a.*repmat(sqrt(g),1,k));

						% this appears to be needed to weight cov terms properly
						G(:,:,i) = covm(a.*repmat(sqrt(g),1,k),1) - U(i,:)'*U(i,:) + u'*u;

						% Re-normalise by M-1 if requested.
						if (n == 0)
							G(:,:,i) = m*G(:,:,i)/(m-1);
						end
					end
				end
			end
			labu = getlablist(a);
  	else
			% Default action.
  		U = mean(a);
  		G = covm(a,n);
		labu = [];
  	end

		% Add attributes of A to U.
		U = dataset(U,labu,'featlab',getfeatlab(a), ...
                                'featsize',getfeatsize(a));
    if (~islabtype(a,'targets')), U = setprior(U,getprior(a)); end;

	end;

return
