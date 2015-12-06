%CLEVALF Classifier evaluation (feature size curve)
% 
%   E = CLEVALF(A,CLASSF,FEATSIZES,LEARNSIZE,N,T,FID)
% 
% INPUT
%   A          Training dataset.
%   CLASSF     The untrained classifier to be tested.
%   FEATSIZES  Vector of feature sizes (default: all sizes)
%   LEARNSIZE  Number of objects/fraction of training set size
%   N          Number of repetitions (default: 1)
%   T          Independent test dataset (optional)
%   FID        File descriptor for progress report file (default: 0)
%
% OUTPUT
%   E          Structure with results
%              See PLOTR for a description
%
% DESCRIPTION
% Generates at random for all feature sizes stored in FEATSIZES training
% sets of the given LEARNSIZE out of the dataset A.  See GENDAT for the
% interpretation of LEARNSIZE.  These are used for training the untrained
% classifier CLASSF.  The result is tested by all unused ojects of A, or,
% if given, by the test dataset T. This is repeated N times.  If LEARNSIZE
% is not given or empty, the training set is bootstrapped.  Default
% FEATSIZES: all feature sizes.  The mean erors are stored in E. The
% observed standard deviations are stored in S.
% 
% This function uses the rand random generator and thereby reproduces only
% if its seed is saved and reset.

% Progress is reported in file FID, default FID=0: no report.

% Use FID=1 for report in the command windo
% 
% See also MAPPINGS, DATASETS, CLEVAL, CLEVALB, TESTC, PLOTR, PRPROGRESS

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: clevalf.m,v 1.7 2004/02/16 08:56:46 bob Exp $

function e = clevalf(a,classf,featsizes,learnsize,n,T,fid)
	
	prtrace(mfilename);
	
	[m,k] = size(a);
	if nargin < 7, fid = 0; end;
	if nargin < 6, T = []; end
	if nargin < 5, n = 1; end;
	if nargin < 4, learnsize = []; end
	if nargin < 3 | isempty(featsizes), featsizes = [1:k]; end
	
	if isdataset(classf) & ismapping(a) % correct for old order
		dd = a; a = classf; classf = {dd};
	end
	if isdataset(classf) & iscell(a) & ismapping(a{1}) % correct for old order
		dd = a; a = classf; classf = dd;
	end
	
	if ~iscell(classf), classf = {classf}; end
	isdataset(a);
	ismapping(classf{1});

	if ~isempty(T), isdataset(T); end

	[m,k,c] = getsize(a);
	featsizes(find(featsizes > k)) = [];
	featsizes = featsizes(:)';

	if length(learnsize) > 1
		error('Learnsize should be scalar')
	end
	
	r = length(classf(:));
	e.error = zeros(r,length(featsizes));
	e.std   = zeros(r,length(featsizes));
	e.xvalues = featsizes;
	e.n = n;
	datname = getname(a);
	if ~isempty(datname)
		e.title = ['Learning curve computed on ' getname(a)];
	end
	e.xlabel= 'Feature size';
	if n > 1
		e.ylabel= ['Averaged error (' num2str(n) ' experiments)'];
	else
		e.ylabel = 'Error';
	end

	if featsizes(end)/featsizes(1) > 20
		e.plot = 'semilogx';
	end
	e.names = [];


	prprogress(fid,['\nclevalf: classifier evaluation (feature curve): \n' ...
		     '    %i classifiers, %i repetitions, %i featuresizes ['],r,n,length(featsizes));

	fprintf(fid,' %i ',featsizes)

	fprintf(fid,']\n  ');

	e1 = zeros(n,length(featsizes));
	seed = rand('state');

	% loop over all classifiers
	
	for q = 1:r
		isuntrained(classf{q});
		name = getname(classf{q});

		prprogress(fid,'classifier: %s\n  ',name);
		e.names = char(e.names,name);
		e1 = zeros(n,length(featsizes));
		rand('state',seed);  % take care that classifiers use same training set
		seed2 = seed;
		
		for i = 1:n
			if isempty(T)
				[b,T] = gendat(a,learnsize);
			else
				b = gendat(a,learnsize);
			end
			for j=1:length(featsizes)
				f = featsizes(j);
				e1(i,j) = T(:,1:f)*(b(:,1:f)*classf{q})*testc;
				prprogress(fid,'.');
			end

			prprogress(fid,'\n  ');
		end
		e.error(q,:) = mean(e1,1);
		if n == 1
			e.std(q,:) = zeros(1,size(e.std,2));
		else
			e.std(q,:) = std(e1)/sqrt(n);
		end
	end
	prprogress(fid,'\b\bclevalf finished\n')

	e.names(1,:) = [];
	
	return
	
