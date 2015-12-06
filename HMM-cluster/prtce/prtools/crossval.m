%CROSSVAL Error estimation by cross validation (rotation)
% 
%   [ERR,CERR,NLAB_OUT] = CROSSVAL(DATA,CLASSF,N,1,FID)
%   [ERR,STDS]          = CROSSVAL(DATA,CLASSF,N,NREP,FID)
%
% INPUT
%   A          Input dataset
%   CLASSF     The untrained classifier to be tested.
%   N          Number of dataset divisions (default: N==number of
%              samples, leave-one-out)
%   NREP       Number of repetitions (default: 1)
%   FID        File descriptor for progress report file (default: 0)
%
% OUTPUT
%   ERR        Average test error weighted by class priors.
%   CERR       Unweighted test errors per class
%   NLAB_OUT   Assigned numeric labels
%   STDS       Standard deviation over the repetitions.
%
% DESCRIPTION
% Cross validation estimation of the error and the instability of the
% untrained classifier CLASSF using the dataset A. The set is randomly
% permutated and divided in N (almost) equally sized parts. The classifier
% is trained on N-1 parts and the remaining part is used for testing.  This
% is rotated over all parts. ERR is their weighted avarage over the class
% priors. CERR are the class error frequencies.  A and/or CLASSF may be
% cell arrays of datasets and classifiers. In that case ERR is an array
% with errors with on position ERR(i,j) the error of classifier j for
% dataset i. In this mode CERR and NLAB_OUT are returned in cell arrays.
%
% In case NREP > 1 the mean error(s) over the repetitions is returned in ERR
% and the standard deviations in the observed errors in STDS.
% 
% Progress is reported in file FID, default FID=0: no report.  Use FID=1
% for report in the command window
% 
% See also DATASETS, MAPPINGS, TESTC

% Copyright: D.M.J. Tax, R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: crossval.m,v 1.10 2004/03/11 12:03:39 duin Exp $

function [err,cerr,nlabout] = crossval(data,classf,n,nrep,fid)

	prtrace(mfilename);

	if nargin < 5, fid = []; end
	if nargin < 4, nrep = []; end
	if nargin < 3, n = []; end

	% datasets or classifiers are cell arrays
	if iscell(classf) | iscell(data)

		seed = rand('state');
		if ~iscell(classf), classf = {classf}; end
		if ~iscell(data), data = {data}; end
		if isdataset(classf{1}) & ismapping(data{1}) % correct for old order
			dd = data; data = classf; classf = dd;
		end
		numc = length(classf);
		numd = length(data);
		cerr = cell(numd,numc);
		nlab_out = cell(numd,numc);

		prprogress(fid,['\n%i-fold crossvalidation: ' ...
			     '%i classifiers, %i datasets\n'],n,numc,numd);

		e = zeros(numd,numc);

		for jc = 1:numc

			prprogress(fid,'  %s\n',getname(classf{jc}));
			for jd = 1:numd

				prprogress(fid,'    %s',getname(data{jd}));

				rand('state',seed);
				[ee,cc,nn] = feval(mfilename,data{jd},classf{jc},n,nrep,fid);
				e(jd,jc) = ee;
				cerr(jd,jc) = {cc};
				nlabout(jd,jc) = {nn};

			end
			%fprintf(fid,'\n');

		end
		if nrep > 1, cerr = cell2mat(cerr); end
			
		if nargout == 0
			fprintf('\n  %i-fold cross validation result for',n);
			disperror(data,classf,e);
		else
			err = e;
		end

	else
		
		if isempty(nrep), nrep = 1; end
		if nrep > 1
			ee = zeros(1,nrep);
			for j=1:nrep
				ee(j) = feval(mfilename,data,classf,n,1,fid);
			end
			err = mean(ee);
			cerr = std(ee);
			nlabout = [];
			return
		end

		if isdataset(classf) & ismapping(data) % correct for old order
			dd = data; data = classf; classf = dd;
		end
		isdataset(data);
		ismapping(classf); 	
		[m,k,c] = getsize(data);
		lab = getlab(data);
		if isempty(n), n = m; end

		if n > m
			warning('Number of batches too large: reset to leave-one-out')
			n = m;
		elseif n < 1
			error('Wrong size for number of batches')
		end
		if ~isuntrained(classf)
			error('Classifier should be untrained')
		end
		J = randperm(m);
		N = classsizes(data);

		% attempt to find an more equal distribution over the classes
		if all(N > n)

			K = zeros(1,m);

			for i = 1:length(N)

				L = findnlab(data(J,:),i);

				M = mod(0:N(i)-1,n)+1;

				K(L) = M;

			end

		else
			K = mod(1:m,n)+1;

		end
		nlabout = zeros(m,1);
		for i = 1:n

			OUT = find(K==i);
			JOUT=J(OUT);
			JIN = J; JIN(OUT) = [];
			w = data(JIN,:)*classf; % training
			                        % testing
			[mx,nlabout(JOUT)] = max(+(data(JOUT,:)*w),[],2);
                              % nlabout contains class assignments
			prprogress(fid,'.');
		end

		prprogress(fid,'\n');
		for j=1:c
			J = findnlab(data,j);
			f(j) = sum(nlabout(J)~=j)/length(J);
		end
		e = f*getprior(data)';
		if nargout > 0
			err  = e;
			cerr = f;
		else
			disp([num2str(n) '-fold cross validation error on ' num2str(size(data,1)) ' objects: ' num2str(e)])
		end

	end

	return