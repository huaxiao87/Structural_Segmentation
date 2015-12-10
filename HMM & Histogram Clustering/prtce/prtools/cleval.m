%CLEVAL Classifier evaluation (learning curve)
%
%   E = CLEVAL(A,CLASSF,TRAINSIZES,NREPS,T,FID)
%
% INPUT
%   A           Training dataset
%   CLASSF      Classifier to evaluate
%   TRAINSIZES  Vector of class sizes, used to generate subsets of A
%               (default [2,3,5,7,10,15,20,30,50,70,100])
%   NREPS       Number of repetitions (default 1)
%   T           Tuning dataset (default [], use remaining samples in A)
%   FID         File ID to write progress to (default [], see PRPROGRESS)
%
% OUTPUT
%   E           Error structure (see PLOTR)
%
% DESCRIPTION
% Generates at random, for all class sizes defined in TRAINSIZES, training
% sets out of the dataset A and uses these for training the untrained
% classifier CLASSF. CLASSF may also be a cell array of untrained
% classifiers; in this case the routine will be run for all of them. The
% resulting trained classifiers are tested on all objects in A. This
% procedure is then repeated NREPS times.
%
% Training set generation is done "with replacement" and such that for each
% run the larger training sets include the smaller ones and that for all
% classifiers the same training sets are used.
%
% If CLASSF is fully deterministic, this function uses the RAND random
% generator and thereby reproduces if its seed is reset (see RAND).
% If CLASSF uses RANDN, its seed may have to be set as well.
%
% Use FID = 1 to report progress to the command window.
%
% SEE ALSO
% MAPPINGS, DATASETS, CLEVALB, TESTC, PLOTR, PRPROGRESS
% Examples in PREX_CLEVAL

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function e = cleval(a,classf,learnsizes,nreps,t,fid)

	prtrace(mfilename);

  if (nargin < 6)
    fid = [];
  end;
  if (nargin < 5)
    prwarning(2,'no tuning set T supplied, using remaining samples in A');
    t = [];
  end;
  if (nargin < 4)
    prwarning(2,'number of repetitions not specified, assuming NREPS = 1');
    nreps = 1;
  end;
  if (nargin < 3)
    prwarning(2,'vector of training set class sizes not specified, assuming [2,3,5,7,10,15,20,30,50,70,100]');
    learnsizes = [2,3,5,7,10,15,20,30,50,70,100];
  end;

  % Correct for old argument order.

  if (isdataset(classf)) & (ismapping(a))
    tmp = a; a = classf; classf = {tmp};
  end
  if (isdataset(classf)) & (iscell(a)) & (ismapping(a{1}))
    tmp = a; a = classf; classf = tmp;
  end
  if ~iscell(classf), classf = {classf}; end

  % Assert that all is right.
  isdataset(a); ismapping(classf{1}); if (~isempty(t)), isdataset(t); end

  % Remove requested class sizes that are larger than the size of the
  % smallest class.

  mc = classsizes(a); [m,k,c] = getsize(a);
  toolarge = find(learnsizes >= min(mc));
  if (~isempty(toolarge))
    prwarning(2,['training set class sizes ' num2str(learnsizes(toolarge)) ...
                 ' larger than the minimal class size in A; removed them']);
    learnsizes(toolarge) = [];
  end
  learnsizes = learnsizes(:)';

  % Fill the error structure.

  nw = length(classf(:));
  datname = getname(a);

  e.n       = nreps;
  e.error   = zeros(nw,length(learnsizes));
  e.std     = zeros(nw,length(learnsizes));
  e.xvalues = learnsizes(:)';
  e.names   = [];
  if (nreps > 1)
    e.ylabel= ['Averaged error (' num2str(nreps) ' experiments)'];
  elseif (nreps == 1)
    e.ylabel = 'Error';
  else
    error('Number of repetitions NREPS should be >= 1.');
  end;
  if (~isempty(datname))
    e.title = ['Bootstrapped learning curve on ' datname];
  end
  if (learnsizes(end)/learnsizes(1) > 20)
    e.plot = 'semilogx';        % If range too large, use a log-plot for X.
  end

  % Report progress.

  prprogress(fid,['\ncleval: classifier evaluation (learning curve): \n' ...
      '    %i classifiers, %i repetitions, %i learnsizes ['],nw,nreps,length(learnsizes));
  prprogress(fid,' %i ',learnsizes)
  prprogress(fid,']\n  ');

  % Store the seed, to reset the random generator later for different
  % classifiers.

	seed = rand('state');

  % Loop over all classifiers (with index WI).

  for wi = 1:nw

    if (~isuntrained(classf{wi}))
      error('Classifiers should be untrained.')
    end
    name = getname(classf{wi});
    prprogress(fid,'classifier: %s\n  ',name); e.names = char(e.names,name);

    % E1 will contain the error estimates.

    e1 = zeros(nreps,length(learnsizes));

    % Take care that classifiers use same training set.

    rand('state',seed); seed2 = seed;

		% For NREPS repetitions...

		for i = 1:nreps
	
      % Store the randomly permuted indices of samples of class CI to use in
      % this training set in JR(CI,:).

			JR = zeros(c,max(learnsizes));
			for ci = 1:c

				JC = findnlab(a,ci);

        % Necessary for reproducable training sets: set the seed and store
        % it after generation, so that next time we will use the previous one.
				rand('state',seed2);

				JD = JC(randperm(mc(ci)));
				JR(ci,:) = JD(1:max(learnsizes))';
				seed2 = rand('state'); 
			end

			li = 0;										% Index of training set.
			for j = learnsizes
				li = li + 1;

        % J will contain the indices for this training set.

        J = [];
        for ci = 1:c
          J = [J;JR(ci,1:j)'];
        end;

				w = a(J,:)*classf{wi}; 					% Use right classifier.

				if (isempty(t))
  				Jt = ones(m,1);
					Jt(J) = zeros(size(J));
					Jt = find(Jt); 								% Don't use training set for testing.
					e1(i,li) = testc(a(Jt,:),w);
				else
					e1(i,li) = testc(t,w);
				end

				prprogress(fid,'.');

			end

			prprogress(fid,'\n  ');

		end

    % Calculate average error and standard deviation for this classifier
    % (or set the latter to zero if there's been just 1 repetition).

		e.error(wi,:) = mean(e1,1);
		if (nreps == 1)
			e.std(wi,:) = zeros(1,size(e.std,2));
		else
			e.std(wi,:) = std(e1)/sqrt(nreps);
		end
	end
	prprogress(fid,'\b\bcleval finished\n')

	% The first element is the empty string [], remove it.
	e.names(1,:) = [];

return

