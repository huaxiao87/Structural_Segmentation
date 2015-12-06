%KMEANS k-means clustering
%
%   [LABELS,A] = KMEANS(A,K,MAXIT,INIT,FID)
%
% INPUT
%  A       Matrix or dataset
%  K       Number of clusters to find (optional; default: 2)
%  MAXIT   maximum number of iterations (optional; default: 50)
%  INIT    Labels for initialisation, or
%          'rand'     : take at random K objects as initial means, or
%          'kcentres' : use KCENTRES for initialisation (default)
%  FID     File ID to write progress to (default [], see PRPROGRESS)
%
% OUTPUT
%  LABELS  Cluster assignments, 1..K
%  A       Dataset with original data and labels ASSIGN
% 
% DESCRIPTION
% K-means clustering of data vectors in A. 
%
% SEE ALSO
% DATASETS, HCLUST, KCENTRES, MODESEEK, EMCLUST, PRPROGRESS

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: kmeans.m,v 1.11 2003/12/19 09:13:45 bob Exp $

function [assign,a] = kmeans(a,kmax,maxit,init,fid)

	prtrace(mfilename);

	n_ini = 100;				% Maximum size of subset to use for initialisation.

	if (nargin < 2) | isempty(kmax)
		kmax = 2; 
		prwarning(3,'No K supplied, assuming K = 2.');
	end
	if nargin < 3 | isempty(maxit)
		maxit = 50;
	end
	if nargin < 4 | isempty(init)
		init = 'kcentres';
	end
	if nargin < 5
		fid = [];
	end
	
	% Create dataset with all equal labels and no priors.
	a = dataset(a);
	islabtype(a,'crisp');
	m = size(a,1); 
  a=set(a,'labels',ones(m,1),'lablist',[1:kmax]','prior',[]); % for speed

	prprogress(fid,'\nkmeans clustering procedure\n')
	% Initialise by performing KCENTRES on...
	if (size(init,1) == 1) & strcmp(init,'kcentres') & (m > n_ini) 
		prwarning(1,'Initializing by performing KCENTRES on subset of %d samples.', n_ini);
		b = +gendat(a,n_ini); % ... a random subset of A.
		d = +distm(b);
		assign = kcentres(d,kmax,[],fid);
		w = nmc(dataset(b,assign)); % Initial partition W and assignments ASSIGN.
	elseif (size(init,1) == 1) & strcmp(init,'kcentres')
		prwarning(1,'Initializing by performing KCENTRES on training set.');
		d = +distm(a);    % ... the entire set A.
		assign = kcentres(d,kmax,[],fid);
		w = nmc(dataset(a,assign)); % mapping trained on the complete dataset
	elseif (size(init,1) == 1) & strcmp(init,'rand')
		prwarning(1,'Initializing by randomly selected objects');
		R = randperm(m);
		w = nmc(dataset(a(R(1:kmax),:),[1:kmax]')); % mapping trained on kmax random samples
	elseif (size(init,1) == m)
		assign = renumlab(init);
		kmax = max(assign);
		prwarning(1,'Initializing by given labels, k = %i',kmax);
		w = nmc(dataset(a,assign));
	else
		error('Wrong initialisation supplied')
	end
	assign = labeld(a*w);					

	tmp_assign = zeros(m,1); % Allocate temporary array.

	% Main loop, while assignments change
	it=1; % number of iterations
	ndif = 1;
	while (it<maxit) & (ndif > 0)
		tmp_assign = assign;     % Remember previous assignments.
		a = setnlab(a,assign);	
		w = a * nmc;   % Re-partition the space by assigning samples to nearest mean.
		assign = a * w * labeld;  % Re-calculate assignments.
		it = it+1; % increase the iteration counter
		ndif = sum(tmp_assign ~= assign);
		prprogress(fid,'  iter: %i changes: %i\n',it,ndif);
	end
	
	if it>=maxit
		prwarning(1,['No convergence reached before the maximum number of %d iterations passed. ' ...
			'The last result was returned.'], maxit);
	end
	prprogress(fid,'kmeans finished\n')
	
return;
