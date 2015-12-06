%MODESEEK Clustering by mode-seeking
% 
% 	[LAB,J] = MODESEEK(D,K)
% 
% INPUT
%   D       Distance matrix or distance dataset (square)
%   K       Number of neighbours to search for local mode (default: 10)
%
% OUTPUT
%   LAB     Cluster assignments, 1..K
%   J       Indices of modal samples
%
% DESCRIPTION
% A K-NN modeseeking method is used to assign each object to its nearest mode.
%
% LITERATURE
% Cheng, Y. "Mean shift, mode Seeking, and clustering", IEEE Transactions
% on Pattern Analysis and Machine Intelligence, vol. 17, no. 8, pp. 790-799,
% 1995.
% 
% SEE ALSO
% MAPPINGS, DATASETS, KMEANS, HCLUST, KCENTRES, PROXM

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: modeseek.m,v 1.6 2003/11/24 15:25:01 pavel Exp $

function [assign,J] = modeseek (d,k)

	prtrace(mfilename);

	if (nargin < 2)
		prwarning(1,'No k supplied, assuming k = 10'); 
		k = 10;
	end

	[m,n] = size(d);
	if (m ~= n), error('distance matrix should be square'); end
	if (k < 2),  error('neighborhood size should be at least 2'); end
	if (k > n),  error('k too large for this dataset'); end

	[d,J] = sort(+d,1);		% Find neighbours.
	f = 1./d(k,:);	    	% Calculate densities.
	J(k+1:end,:) = [];  	% Just retain indices of neighbours.

	% Find indices of local modes in neighbourhood.
	[dummy,I] = max(reshape(f(J),size(J)));

	% Translate back to indices in all the data. N now contains the
	% index of the nearest neighbour in the K-neighbourhood.
	N = J(I+[0:k:k*(m-1)]);

	% Re-assign samples to the sample their nearest neighbour is assigned to.
	% Iterate until assignments don't change anymore. Samples that then point 
	% to themselves are modes; all other samples point to the closest mode.

	M = N(N);
	while (any(M~=N))
		N = M; M = N(N);
	end

	% Use renumlab to obtain assignments 1, 2, ... and the list of unique
	% assignments (the modes).

	[assign,J] = renumlab(M');

return
