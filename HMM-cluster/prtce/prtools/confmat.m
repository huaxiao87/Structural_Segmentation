%CONFMAT Construct confusion matrix
% 
%  [C,NE,LABLIST] = CONFMAT(LAB1,LAB2,METHOD)
%
% INPUT
%  LAB1        Set of labels
%  LAB2        Set of labels
%  METHOD      'count' (default) to count number of co-occurences in
%					LAB1 and LAB2, 'disagreement' to count relative
%					non-co-occurrence.
%
% OUTPUT
%  C           Confusion matrix
%  NE          Total number of errors
%  LABLIST     Unique labels in LAB1 and LAB2
%
% DESCRIPTION
% Constructs a confusion matrix C between two sets of labels LAB1 
% (corresponding to the rows in C) and LAB2 (the columns in C). The order of 
% the rows and columns is returned in LABLIST. NE is the total number of 
% errors (sum of non-diagonal elements in C).
%
% When METHOD = 'count' (default), co-occurences in LAB1 and LAB2 are counted 
% and returned in C. When METHOD = 'disagreement', the relative disagreement 
% is returned in NE, and is split over all combinations of labels in C
% (such that the rows sum to 1).
%
%   [C,NE,LABLIST] = CONFMAT(D,METHOD)
%
% If D is a classification result D = A*W, the labels LAB1 and LAB2 are 
% internally retrieved by CONFMAT before computing the confusion matrix.
%
% When no output argument is specified, the confusion matrix is displayed.
%
% EXAMPLE
% Typical use of CONFMAT is the comparison of true and and estimated labels
% of a testset A by application to a trained classifier W: 
% LAB1 = GETLABELS(A); LAB2 = A*W*LABELD.
% More examples can be found in PREX_CONFMAT, PREX_MATCHLAB.
% 
% SEE ALSO
% MAPPINGS, DATASETS, GETLABELS, LABELD

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: confmat.m,v 1.6 2003/12/19 09:13:45 bob Exp $

function [C,ne,lablist] = confmat (arg1,arg2,arg3)

	prtrace(mfilename);

	% Check arguments.

	if (nargin == 3)
		lab1 = arg1; lab2 = arg2; method = arg3;
	elseif (nargin == 2)
		if (isdataset(arg1))
			lab1 = getlabels(arg1); lab2 = arg1*labeld; method = arg2;
		else
			lab1 = arg1; lab2 = arg2; method = 'count';
			prwarning(4,'no method supplied, assuming count');
		end
	elseif (nargin == 1)
		if (isdataset(arg1))
			lab1 = getlabels(arg1); lab2 = arg1*labeld; method = 'count';
		else
			error('two labellists or one dataset should be supplied')
		end
	end

	% Renumber LAB1 and LAB2 and find number of unique labels.

	m = size(lab1,1); [nlab1,nlab2,lablist] = renumlab(lab1,lab2);
	n = max([nlab1;nlab2]); 

	% Construct matrix of co-occurences (confusion matrix).

	C = zeros(n,n);
	for i = 1:n
		K = find(nlab1==i);
		if (isempty(K))
			C(i,:) = zeros(1,n);
		else
			for j = 1:n
				C(i,j) = length(find(nlab2(K)==j));
			end
		end
	end
	
	% Calculate number of errors ('count') or disagreement ('disagreement').

	switch (method)
		case 'count'								
			ne = sum(sum(C)) - sum(diag(C));       % Diagonal entries are correctly
                                                % classified, so all off-diagonal
                                                % entries denote wrong ones.
		case 'disagreement'
			ne = (sum(sum(C)) - sum(diag(C)))/m;   % Relative sum of off-diagonal 
                                                % entries.
			D = repmat(sum(C,2),1,2);               % Disagreement = 1 - 
			C = ones(n,n)-C./D;                    % relative co-occurence.
		otherwise
			error('unknown method');
	end

    % If no output argument is specified, pretty-print C.

	if (nargout == 0)

		% Make sure labels are stored in LABC as matrix of characters, 
      % max. 6 per label.

		labc = strlab(lablist);
		if (size(labc,2) > 6), labc = labc(:,1:6); end
		if (size(labc,2) < 5), labc = [labc repmat(' ',n,ceil((5-size(labc,2))/2))]; end

		fprintf('\n         | Estimated Labels\n')
		fprintf('   True  |');
		fprintf('\n  Labels |')
		for j = 1:n, fprintf('%7s',labc(j,:)); end
		fprintf('|')
		fprintf(' Totals')
		fprintf('\n  ');
		fprintf('-------|%s',repmat('-',1,7*n))
		fprintf('|-------')
		fprintf('\n');
	
		for j = 1:n
			fprintf('  %-7s|',labc(j,:));
			switch (method)
				case 'count'
					fprintf('%5i  ',C(j,:)');
					fprintf('|')
					fprintf('%5i',sum(C(j,:)));
				case 'disagreement'
					fprintf(' %5.3f ',C(j,:)');
					fprintf('|')
					fprintf(' %5.3f ',sum(C(j,:)));
			end
			fprintf('\n');
		end

		fprintf('  -------|%s',repmat('-',1,7*n))
		fprintf('|-------')
		fprintf('\n  Totals |');

		switch (method)
			case 'count'
				fprintf('%5i  ',sum(C));
				fprintf('|')
				fprintf('%5i',sum(C(:)));
			case 'disagreement'
				fprintf(' %5.3f ',sum(C));
				fprintf('|')
				fprintf(' %5.3f ',sum(C(:)));
		end
		fprintf('\n\n')
	end

return
