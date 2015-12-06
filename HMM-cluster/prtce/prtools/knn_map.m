%KNN_MAP Map a dataset on a K-NN classifier
%
%   F = KNN_MAP(A,W)
% 
% INPUT
%   A  Dataset
%   W  k-NN classifier trained by KNNC
%
% OUTPUT
%   F  Posterior probabilities
%
% DESCRIPTION  
% Maps the dataset A by the K-NN classifier W on the [0,1] interval for 
% each of the classes that W is trained on. The posterior probabilities, 
% stored in F, sum in a row-wise way to one. This routine is called 
% automatically to determine A*W if W is trained by KNNC.
%
% Warning: Class prior probabilities in the dataset A are neglected.
%
% SEE ALSO
% MAPPINGS, DATASETS, KNNC, TESTK

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: knn_map.m,v 1.6 2003/10/20 07:06:49 dick Exp $

function F = knn_map(T,W)
	prtrace(mfilename);

	% Get the training data and parameters from the mapping:
	data = getdata(W);
	a = data{1};
	knn = data{2};
	[m,k,c] = getsize(a);
	nlab = getnlab(a);

	% If there is no test set, then the leave-one-out is done on the
	% training set (see TESTK).
	if isempty(T) 
		T = a;
		loo = 1;
	else
		loo = 0;
	end
	[mt,kt] = size(T);
	if (kt ~= k), error('Wrong feature size'); end

	r = classsizes(a);
	[num,n] = prmem(mt,m);				% Check the available memory. 
	F = ones(mt,c);
	D = ones(mt,c);

	% Loop in batches. 
	for i = 0:num-1									
		if (i == num-1)
			nn = mt - num*n + n;
		else
			nn = n;
		end
		range = [i*n+1:i*n+nn];
		if loo,
			DD = +distm(a,a(range,:));
			% Set distances to itself at INF to find later the nearest
			% neighbors more easily
			DD(i*n+1:m+1:i*n+nn*m) = inf*ones(1,nn); 
		else
			DD = distm(a,T(range,:));
		end
		[DD,L] = sort(DD);     		
	
		L = reshape(nlab(L),size(L));				% Find labels.


		% Find label frequencies.
		for j = 1:c													
			F(range,j) = sum(L(1:knn,:)==j,1)';
		end
		K = max(F(range,:)');
		for j = 1:c
			K = min(K,r(j));
			J = reshape(find(L==j),r(j),nn);	% Find the distances between 
			J = J(K+[0:nn-1]*r(j));						% that neighbor and other objects.
			D(range,j) = DD(J)';							% Number for all classes.
		end

		% Estimate posterior probabilities
		if (knn > 2)												% Use Bayes estimators on frequencies.
			F(range,:) = (F(range,:)+1)/(knn+c);
		else																% Use distances.
			F(range,:) = sigm(log(sum(D(range,:),2)*ones(1,c)./ ...
									 (D(range,:)+realmin) - 1 + realmin));
		end
		% Normalize the probabilities.
		F(range,:) = F(range,:) ./ (sum(F(range,:),2)*ones(1,c));
	end

	if (isdataset(T))
		F = setdata(T,F,getlabels(W));
	end;

return;

