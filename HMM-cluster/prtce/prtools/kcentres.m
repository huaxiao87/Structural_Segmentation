%KCENTRES Finds K center objects from a distance matrix
% 
%  [LAB,J,DM] = KCENTRES(D,K,N,FID)
% 
% INPUT
%   D    Distance matrix between, e.g. M objects (may be a dataset)
%   K    Number of center objects to be found (optional; default: 1)
%   N    Number of trials starting from a random initialization
%        (optional; default: 1)
%   FID  File ID to write progress to (default [], see PRPROGRESS)
%
% OUTPUT
%   LAB  Integer labels: each object is assigned to its nearest center
%   J    Indices of the center objects
%   DM   A list of distances corresponding to J: for each center from 
%        J, the maximum distance of the objects assigned to this center  	
%
% DESCRIPTION  
% Finds K center objects from a symmetric distance matrix D. The center 
% objects are chosen from all M objects such that the maximum of the 
% distances over all objects to the nearest center is minimized. For K > 1,
% the results depend on a random initialization. The procedure is repeated 
% N times and the best result is returned. 
% 
% SEE ALSO
% HCLUST, KMEANS, EMCLUST, MODESEEK, PRPROGRESS

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: kcentres.m,v 1.10 2003/11/23 22:32:13 bob Exp $

function [labels,Jopt,dm] = kcentres(d,k,n,fid)

	prtrace(mfilename);
	
	if nargin < 4, fid = []; end

	if (nargin < 3) | isempty(n)
      n = 1;
      prwarning(4,'Number of trials not supplied, assuming one.');
   end

	if (nargin < 2) | isempty(k)
      k = 1;
      prwarning(4,'Number of centers not supplied, assuming one.');
   end
	
	if(isdataset(d))
		d = +d;
		prwarning(4,'Distance matrix is convert to double.');
	end

	[m,m2] = size(d);
	if ( ~issym(d,1e-12) | any(diag(d) > 1e-14) )
		error('Distance matrix should be symmetric and have zero diagonal')
	end

% checking for a zero diagonal 
	t = eye(m) == 1;	
	if(~all(d(t)==0))
		error('Distance matrix should have a zero diagonal.')
	end

	if (k == 1)
		dmax = max(d);
		[dm,Jopt] = min(dmax);
		labels = repmat(1,m,1);
		return;
	end

	% We are here only if K (> 1) centers are to be found.
	% Loop over number of trials.
	dmax = max(max(d));
	dopt = inf;
	for tri = 1:n                       
		M = randperm(m); M = M(1:k);		% Random initializations
	 	J = zeros(1,k); 					    	% Center objects to be found.

		prprogress(fid,'\nkcentres, attempt %i\n',tri)
		% Iterate until J == M. See below.
		while 1,
			[dm,I] = min(d(M,:));

			% Find K centers. 
			for i = 1:k                   
				JJ = find(I==i); 
				if (isempty(JJ))
%JJ can be empty if two or more objects are in the same position of feature space in dataset
					J(i) = 0;									
				else
						% Find objects closest to the object M(i)
					[dummy,j,dm] = kcentres(d(JJ,JJ),1,1);
					J(i) = JJ(j);
				end
			end

			J(find(J==0)) = [];
			k = length(J);
			prprogress(fid,'  Relative maximum cluster radius: %8.5f\n',max(min(d(J,:)))/dmax)
			if (length(M) == k) & (all(M == J))
				% K centers are found.
				[dmin,labs] = min(d(J,:));
				dmin = max(dmin);
				break;
			end
			M = J;
		end
		prprogress(fid,'kcentres finished\n')
		% Store the optimal centers in JOPT.
		
		if (dmin <= dopt)
			dopt = dmin;
			labels = labs';
			Jopt = J;
		end
	end

	% Determine the best centers over the N trials.
	dm = zeros(1,k);   
	for i=1:k
		L = find(labels==i);
		dm(i) = max(d(Jopt(i),L));
	end

return;
