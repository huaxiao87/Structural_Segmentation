%TESTC Test classifier, simple test routine
%
%   [E,F] = TESTC(A*W)
%	  [E,F] = TESTC(A,W)
%	  [E,F] = A*W*TESTC
%
% INPUT
%   A  Dataset
%   W  Trained classifier mapping
% 
% OUTPUT
%   E  Estimated error rate
%   F  Number of erroneously classified objects per class
% 
% DESCRIPTION
% An error estimate E is calculated for the classifier W using dataset A,
% by counting the number of errors. Prior probabilities in A are used to
% weight the class error contributions. Numbers of erroneously classified
% objects per class are returned in F. It is also possible to supply cell
% array of datasets {A*W}, an N x 1 cell array of datasets {A} and an N x M
% cell array of mappings {W}.
%
% For soft labelled test sets A the error contribution of a single object is
% the difference between one and the soft label value for the assigned class.
% Soft label values of test objects for other classes are not taken into
% account.
%
% EXAMPLES
% See PREX_PLOTC.
%
% SEE ALSO
% MAPPINGS, DATASETS

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: testc.m,v 1.12 2003/12/19 09:14:38 bob Exp $

function [errors,class_errors] = testc(a,w)

	prtrace(mfilename);

	if (nargin == 0) | (isempty(a))

		% No input arguments given: return mapping information.

		errs       = mapping(mfilename,'fixed');
		class_errs = [];

	elseif (nargin == 1)

		% If there's a single output argument, assume it's a (cell array of) 
		% dataset which has already been mapped by the classifier (A*W), so just
		% apply LABELD.

		if (iscell(a))

  		% If this single argument is a cell array, recursively call this
  		% function to get errors for all elements in the cell array.

			errs       = cell(size(a));
			class_errs = cell(size(a));
			for j1 = 1:size(a,1)
				for j2 = 1:size(a,2)
					[errs{j1,j2},c{j1,j2}] = feval(mfilename,a{j1,j2});
				end
			end

		else		

			% Assert that A is a dataset with the right kind of labels.
			isdataset(a); islabtype(a,'crisp','soft');

			[m,k,c] = getsize(a); p = getprior(a); labtype = getlabtype(a);

			% Find the labels.
			labout= labeld(a);

			class_errs = zeros(1,c); errs = 0;
			switch (labtype)
			 	case 'crisp'
  				% Crisp labels: count number of different labels to find error.
			  	labin = getlabels(a);
			  	for j=1:c
				  	J = findnlab(a,j);
						if (~isempty(J))
					  	class_errs(j) = nlabcmp(labin(J,:),labout(J,:));
						elseif ~isempty(a.prior)
							error('Empty class in testset found')
						end
						if isempty(a.prior)
							errs = errs + class_errs(j);
						else
					  	errs = errs + p(j) * class_errs(j) / length(J);
						end
				  end
					if isempty(a.prior)
						errs = errs / m;
					end
					
				case 'soft'
					 % Soft labels: measure errors w.r.t. the targets.
			  	targets = getlabels(a);
				  lablist = getlablist(a);
				  nlab = renumlab(labout,lablist);
				  K = (nlab-1)*m+[1:m]';
			  	for j = 1:c
					  J = findnlab(a,j);
						if (~isempty(J))
							class_errs(j) = (1-mean(targets(K(J))));
						elseif ~isempty(a.prior)
							error('Empty class in testset found')
						end
						if isempty(a.prior)
							errs = errs + class_errs(j);
						else
					  	errs = errs + p(j) * class_errs(j);
						end
				  end
					if isempty(a.prior)
						errs = errs / m;
					end

				otherwise
					error(['Wrong label type for testing classifiers: ' labtype])
			end
		end

	elseif (iscell(a)) | (iscell(w))
		
		% If there are two input arguments and either of them is a cell array,
		% recursively call this function on each of the cells.

		% Non-cell array inputs are turned into 1 x 1 cell arrays.

		if (~iscell(a)), a = {a}; end
		if (~iscell(w)), w = {w}; end

		if (min(size(a) > 1))
			error('2D cell arrays of datasets not supported')
		end

		% Check whether the number of datasets matches the number of mappings.

		if (length(a) == 1)
			a = repmat(a,size(w,1));
		elseif (min(size(w)) == 1 & length(a) ~= length(w)) | ...
			     (min(size(w))  > 1 & length(a) ~= size(w,1))
			error('Number of datasets does not match cell array size of classifiers.')
		end

		% Now recursively call this function for each combination of dataset
		% A{I} and mapping W{I,J}.

		errs = zeros(size(w)); class_errs = [];
		for i=1:size(w,1)
			for j=1:size(w,2)
				errs(i,j) = feval(mfilename,a{i}*w{i,j});
			end
		end

	else

		% Assert that the second argument is a trained mapping, and call
		% this function on the mapped data.
		ismapping(w); istrained(w);
		[errs,class_errs]= feval(mfilename,a*w);

	end

	% If there are no output arguments, display the error(s) calculated.
	% Otherwise, copy the calculated errors to the output arguments.

	if (nargout == 0) & (nargin > 0)
		if (iscell(a))
			if (nargin == 1)
				for j1 = 1:size(a,1)
					for j2 = 1:size(a,2)
						disp(['Mean classification error on ' ...
						      num2str(size(a{j1,j2},1)) ' test objects: ' num2str(errs{j1,j2})]);
					end
				end
			else
				fprintf('\n  Test results result for');
				if (size(errs,2) > 1)
					disperror(a,w(1,:),errs);
				else
					disperror(a,w,errs);
				end
			end
		else
			if (nargin == 1)
				disp(['Mean classification error on ' num2str(size(a,1)) ' test objects: ' num2str(errs)])
			else
				fprintf(' %s',getname(w,20));
				fprintf(' %5.3f',errs);
				fprintf('\n');
			end
		end
	else
		errors       = errs;
		class_errors = class_errs;
	end

return
