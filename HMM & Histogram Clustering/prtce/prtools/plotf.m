%PLOTF Plot feature distribution
% 
%   h = PLOTF(A)
% 
% Produces 1-D density plots for all the features in dataset A. The 
% densities are estimated using PARZENML.
% 
% See also DATASETS, PARZENML

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: plotf.m,v 1.4 2003/08/18 13:02:29 pavel Exp $

function h_out = plotf(a)

	prtrace(mfilename);
	
	[m,k,c] = getsize(a);

	% Define the color for each of the classes:
	if c == 2
		map = [0 0 1; 1 0 0];
	else
		map = hsv(c);
	end

	% Make subplots for each feature, so a grid of p x q subplots is
	% defined
	h = [];
	if k > 3
		p = ceil(k/2); q = 2;
	else
		p = k; q = 1;
	end

	% Get the feature names
	feats = getfeatlab(a,'string');
	if size(feats,2) == 1
		feats = [repmat('Feature ',size(feats,1),1) feats];
	end

	% Make the plot for each of the features:
	for j = 1:k
		b = a(:,j);
		s = zeros(1,c);
		d = zeros(121,c);
		bb = [-0.10:0.01:1.10]' * (max(b)-min(b)) + min(b);
		ex = 0;
		% Make a density estimate of each of the classes:
		for i = 1:c
			I = findnlab(a,i);
			D = +distm(bb,b(I));
			s(i) = parzenml(b(I));
			% Compute the density function
			d(:,i) = sum(exp(-D/(s(i).^2)),2)./(length(I)*s(i));;
		end
		% Create the subplots with the correct sizes:
		subplot(p,q,j)
		plot(bb,zeros(size(bb)),'w.');
		hold on
		h = [];
		% Scatter the data and plot the density functions for each of the
		% classes:
		for i = 1:c
			I = findnlab(a,i);
			hh = plot(b(I),zeros(size(b(I))),'x',bb,+d(:,i));
			set(hh,'color',map(i,:));
			h = [h;hh];
		end
		%legend(h,getlablist(a)); does not work properly
		title([getname(a) ': ' feats(j,:)]);
		hold off
	end

	% The last details to take care of:
	if k == 1, title(''); end
	if nargout > 1
		h_out = h;
	end

	return
