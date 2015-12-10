%FFNC Feed-forward neural net classifier back-end 
% 
% 	[W,HIST] = FFNC (ALG,A,UNITS,ITER,W_INI,T,FID)
%
% INPUT
% 	ALG   Training algorithm: 'bpxnc' for back-propagation (default), 'lmnc' 
%         for Levenberg-Marquardt
% 	A     Training dataset
% 	UNITS Array indicating number of units in each hidden layer (default: [5])
% 	ITER  Number of iterations to train (default: inf)
% 	W_INI Weight initialisation network mapping (default: [], meaning 
%         initialisation by Matlab's neural network toolbox)
% 	T     Tuning set (default: [], meaning use A)
%   FID   File ID to write progress to (default [], see PRPROGRESS)
%
% OUTPUT
% 	W     Trained feed-forward neural network mapping
% 	HIST  Progress report (see below)
%
% DESCRIPTION 
% This function should not be called directly, but through one of its 
% front-ends, BPXNC or LMNC. Uses the Mathworks' Neural Network toolbox.
% 
% SEE ALSO
% MAPPINGS, DATASETS, BPXNC, LMNC, NEURC, RNNC, RBNC, PRPROGRESS

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: ffnc.m,v 1.14 2004/04/28 07:45:06 duin Exp $

function [w,hist] = ffnc(alg,a,units,max_iter,w_ini,t,fid)

	prtrace(mfilename);

	% Settings for the different training algorithms.
	
	if exist('nnet') ~= 7
		error('Neural network toolbox not found')
	end

	if (strcmp(alg,'bpxnc'))
		mapname = 'BP Neural Classf';	
	elseif (strcmp(alg,'lmnc'))
		mapname = 'LM Neural Classf';
	else
		error('illegal training algorithm specified');
	end;

	% Check arguments

	if (nargin < 7), fid = []; end;
	if (nargin < 6) | (isempty(t))
		prwarning(2,'no tuning set supplied, using training set for tuning (risk of overfit)');
		if (nargin < 2), t = []; else, t = a; end;
	end
	if (nargin < 5) | (isempty(w_ini))
		prwarning(3,'no initialisation supplied, using Nguyen-Widrow random initialisation');
		w_ini = []; 
	end
	if (nargin < 4) | (isempty(max_iter))
		prwarning(3,'no maximum number of iterations supplied, assuming infinite');
		max_iter = inf; 
	end
	if (nargin < 3) | (isempty(units))
		prwarning(1,'no network architecture specified, assuming one hidden layer of 5 units');
		units = 5; 
	end
	if (nargin < 2) | (isempty(a))
		w = mapping(alg,{units,max_iter,w_ini,t,fid});
		w = setname(w,mapname);
		hist = [];
		return
	end

	% Training target values.

	prwarning (4, 'using training targets 0.9/0.1');
	target_high	= 0.9;
	target_low	= 0.1;

	% Check whether the dataset is valid.

	islabtype(a,'crisp');
	isvaldset(a,1,2); 							% At least 1 object per class, 2 classes
	iscomdset(a,t);   							% Check whether training and tuning set match
	
	[m,k,c] = getsize(a); lablist = getlablist(a); 

	% Standard training parameters.

	disp_freq   = inf; 
	err_goal 		= 0.02/m;						% Mean-squared error goal, stop if reached
	trnsf_fn	  = 'logsig';					% Transfer function
  perf_fn     = 'mse';            % Performance function

	% Settings for the different training algorithms.

	tp.show   = disp_freq;
	tp.time   = inf;
	tp.goal   = err_goal;
	if (strcmp(alg,'bpxnc'))
		trnalg 					= 'traingdx'; 
		lrnalg 					= 'learngdm';
		burnin       		= 500;			% Never stop training before this many iters
		tp.epochs    		= min(50,max_iter); 	% Iteration unit
		tp.lr        		= 0.01;			% BP, initial value for adaptive learning rate
		tp.lr_inc    		= 1.05;			% BP, multiplier for increasing learning rate
		tp.lr_dec    		= 0.7;			% BP, multiplier for decreasing learning rate
		tp.mc        		= 0.95;			% BP, momentum
		tp.max_perf_inc = 1.04;			% BP, error ratio
		tp.min_grad  		= 1e-6;			% BP, minimum performance gradient
		tp.max_fail  		= 5;				% BP, maximum validation failures
	elseif (strcmp(alg,'lmnc'))
		trnalg 					= 'trainlm';  
		lrnalg 					= 'learngdm';
		burnin       		= 50;				% Never stop training before this many iters
		tp.epochs 	 		= min(1,max_iter); 		% Iteration unit
		tp.mem_reduc 		= 1;				% Trade-off between memory & speed
		tp.max_fail  		= 1; 				% LM, maximum validation failures
		tp.min_grad  		= 1e-6;			% LM, minimum gradient, stop if reached
		tp.mu  	    		= 0.001;		% LM, initial value for adaptive learning rate
		tp.mu_inc    		= 10;				% LM, multiplier for increasing learning rate
		tp.mu_dec    		= 0.1;			% LM, multiplier for decreasing learning rate
		tp.mu_max    		= 1e10;			% LM, maximum learning rate
	end;
	
	% Scale each feature to the range [0,1].
	prwarning(3,'scaling such that training set features have range [0,1]');
	ws = scalem(a,'domain'); a_scaled = a*ws; t_scaled = t*ws;

	% Set number of network outputs: 1 for 2 classes, c for c > 2 classes.
	if (c == 2), cout = 1; else, cout = c; end

	% Create target matrix: row C contains a high value at position C,
	% the correct class, and a low one for the incorrect ones (place coding).
	if (cout > 1)
    target = target_low * ones(c,c) + (target_high - target_low) * eye(c);
	else
		target = [target_high; target_low];
	end

	% Create the target arrays for both datasets.
	target_a = target(getnlab(a),:)';
	target_t = target(getnlab(t),:)';

	% Create the network layout: K inputs, N(:) hidden units, COUT outputs.
	numlayers = length(units)+1; numunits = [k,units(:)',cout];
	transfer_fn = cellstr(char(ones(numlayers,1)*trnsf_fn));

	% Create network and set training parameters. The network is initialised
	% by the Nguyen-Widrow rule by default.

	net = newff(ones(numunits(1),1)*[0 1],numunits(2:end),...
							transfer_fn,trnalg,lrnalg,perf_fn);
	net.trainParam = tp;

	% If an initial network is specified, use its weights and biases.

	if (~isempty(w_ini))
		% Use given initialisation.
		[data,lab,type_w] = get(w_ini,'data','labels','mapping_file');
		if (strcmp(type_w,'sequential'))
			a_scaled = a*data{1}; t_scaled = t*data{1}; ws = data{1};
			[data,lab,type_w] = get(data{2},'data','labels','mapping_file');
		end

		% Check whether the mapping's dimensions are the same as the network's.
		[kw,cw] = size(w_ini); net_ini = data{1};
		if (~strcmp(type_w,'neurc')) | (kw ~= k) | (cw ~= c) | ...
				(net.numInputs  ~= net_ini.numInputs) | ...
				(net.numLayers  ~= net_ini.numLayers) | ...
				(net.numOutputs ~= net_ini.numOutputs) | ...
				any(net.biasConnect ~= net_ini.biasConnect) | ...
				any(net.inputConnect ~= net_ini.inputConnect) | ...
				any(net.outputConnect ~= net_ini.outputConnect)
			error('incorrect size initialisation network supplied')
		end
		% Check whether the initialisation network was trained on the same data.
		[dummy1,nlab,dummy2] = renumlab(lablist,lab);
		if (max(nlab) > c)
			error('initialisation network should be trained on same classes')
		end
		net.IW = net_ini.IW; net.LW = net_ini.LW; net.b = net_ini.b;
	end

	% Initialize loop 

	opt_err = inf; opt_iter = inf; opt_net = net; 
	iter = 0; this_iter = 1; hist = []; 
	
	% Loop while:
	% - training has not gone on for longer than 50 iterations or 2 times the 
	%   number of iterations for which the error was minimal, and
	% - the number of iterations does not exceed the maximum
	% - the actual training function still performed some iterations
  
	prprogress(fid,'ffnn:  Feed-Forward Neural Net\n');				
  while ((iter <= 2*opt_iter) | (iter < burnin)) & ...
				(iter < max_iter) & (this_iter > 0) & (opt_err > 0)

		% Call TRAIN, from Matlab's NN toolbox.

		prwarning(4,'[%d] calling NNETs train', iter);
		[net,tr] = train(net,+a_scaled',target_a);
		this_iter = length(tr.epoch)-1; iter = iter + this_iter;

		% Copy current learning rate as the one to start with for the next time.
		if (strcmp(alg,'bpxnc'))
			net.trainParam.lr = tr.lr(end);
		else
			net.trainParam.mu = tr.mu(end);
		end;

		% Map train and tuning set.
  	w = mapping('neurc','trained',{net},lablist,k,c);
  	w = setname(w,mapname); 
	
		% Calculate mean squared errors (MSE).
  	out_a = a_scaled*w; out_t = t_scaled*w; 
		mse_a = mean(mean(((out_a(:,1:cout))-target_a').^2,1));
		mse_t = mean(mean(((out_t(:,1:cout))-target_t').^2,1));

		% Calculate classification errors.
		e_a = testc(a_scaled,w); e_t = testc(t_scaled,w);	

		% If this error is minimal, store the iteration number and weights.
  	if (e_t < opt_err)
			prprogress(fid,'                --  minimum error %3.3f found, storing network  --\n', e_t);
  		opt_err = e_t; opt_iter = iter; opt_net = net; 
  	end

		w1 = cell2mat(net.IW); w1 = w1(:);
		w2 = cell2mat(net.LW); w2 = w2(:);
  	hist = [hist; iter e_a e_t mse_a mse_t ...
						mean([w1; w2].^2)];

  	prprogress(fid,'  epochs:%5i  ea: %3.3f  et: %3.3f  msea: %3.3f  mset: %3.3f mean-w^2: %3.3f min_error: %3.3f\n', ...
						hist(end,:), opt_err);
  end
  prprogress(fid,'ffnn finished\n');				

	% Create mapping.

  w = ws*mapping('neurc','trained',{opt_net},lablist,k,c);
  w = setname(w,mapname);
	w = setcost(w,a);

return