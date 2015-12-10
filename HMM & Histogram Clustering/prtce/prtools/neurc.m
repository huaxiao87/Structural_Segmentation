%NEURC Automatic neural network classifier
% 
% 	W = NEURC (A,UNITS)
%
% INPUT
%   A     Dataset
%   UNITS Array indicating number of units in each hidden layer (default: [5])
%
% OUTPUT
%   W     Trained feed-forward neural network mapping
%
% DESCRIPTION
% Automatically trained feed-forward neural network classifier with
% lenght(UNITS) hidden layers of UNITS(I) units in layer I. Training, by LMNC,
% is stopped when the performance on an artificially generated tuning set of 
% 1000 samples per class (based on k-nearest neighbour interpolation) does not 
% improve anymore. In future versions UNITS might be optimized automatically
% as well. For the time being it is set to 0.2 time the size of the smallest
% class in A.
%
% NEURC always tries three random initialisations, with fixed random seed, 
% and returns the best result according to the tuning set. This is done in 
% order to obtain a reproducable result.
%
% Uses the Mathworks' neural network toolbox.
% 
% SEE ALSO
% MAPPINGS, DATASETS, LMNC, BPXNC, GENDATK

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: neurc.m,v 1.10 2003/12/28 17:32:21 bob Exp $

function argout = neurc (a,argin)

	prtrace(mfilename);

	mapname = 'Automatic Neural Classifier';
	n_attempts = 3;							% Try three different random initialisations.

	if (nargin < 2)
    prwarning(1,'no network architecture specified, assuming one hidden');
		argin = []; 
	end
	if (nargin < 1) | (isempty(a))
		w = mapping(mfilename,argin);
		argout = setname(w,mapname);
		return
	end

	[m,k] = size(a);
	if isempty(argin)
		cs = classsizes(a);
		argin = ceil(0.2*min(cs));
	end
	
	if (~ismapping(argin)) 
		
		islabtype(a,'crisp');
		isvaldset(a,1,2); % at least 1 object per class, 2 classes

		% Second parameter is not a mapping: train a network.
		units = argin;

		% Reproducability: always use same seeds. 
		rand('seed',1); randn('seed',1); opt_err = inf; opt_mapping = [];

		% Try a number of random initialisations.
		for attempt = 1:n_attempts
			prwarning(4,'training with initialisation %d of %d',attempt,n_attempts);
			t = gendatk(a,1000,2,1); 			% Create tuning set based on training set.
			w = lmnc(a,units,inf,[],t);		% Find LMNC mapping.
			e = t*w*testc;								% Calculate classification error.
			if (e < opt_err)							 
				% If this is the best of the three repetitions, store it.
				opt_mapping = w; opt_err = e;	
			end
		end

		% Output is best network found.
		argout = setname(opt_mapping,mapname);

	else 

		% Second parameter is a mapping: execute.
		w = argin;													

		data = getdata(w); 

		if (length(data) > 1)
	    % "Old" neural network - network is second parameter: unpack.
  	  data = getdata(w); weights = data{1};
    	pars = data{2}; numlayers = length(pars);

	    output = a;                       % Output of first layer: dataset.
  	  for j = 1:numlayers-1
    	  % Number of inputs (n_in) and outputs (n_out) of neurons in layer J.
      	n_in = pars(j); n_out = pars(j+1);

	      % Calculate output of layer J+1. Note that WEIGHTS contains both
  	    % weights (multiplied by previous layer's OUTPUT) and biases
    	  % (multiplied by ONES).

      	this_weights = reshape(weights(1:(n_in+1)*n_out),n_in+1,n_out);
	      output = sigm([output,ones(m,1)]*this_weights);

  	    % Remove weights of this layer.
    	  weights(1:(n_in+1)*n_out) = [];
	    end
		else
			% "New" neural network: unpack and simulate using the toolbox.
			net = data{1};
			output = sim(net,+a')';
		end;

		% 2-class case, therefore 1 output: 2nd output is 1-1st output.
		if (size(output,2) == 1)
			output = [output (1-output)]; 
		end

		% Output is mapped dataset.
		argout = setdat(a,output,w);
	
	end

return
	
