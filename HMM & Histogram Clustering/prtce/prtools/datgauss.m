%DATGAUSS Apply Gaussian filter on images in a dataset 
%
%  B = DATGAUSS(A,SIGMA)
%
% INPUT
%  A        Dataset containing images
%  SIGMA    Standard deviation of Gaussian filter (default 1)
%
% OUTPUT
%  B       Dataset with filtered images
%
% DESCRIPTION
% All images stored as objects (rows) or as features (columns) of dataset A
% are filtered with a Gaussian filter with standard deviation SIGMA and 
% stored in dataset B. SIGMA may be a vector with standard deviations for
% each image in A. Image borders are mirrored before filtering.
%
% SEE ALSO
% DATASETS, DATAIM, IM2OBJ, IM2FEAT, DATUNIF, DATFILT

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: datgauss.m,v 1.6 2003/10/17 13:04:36 bob Exp $

function a = datgauss(a,sigma)

	prtrace(mfilename);

	% Convert dataset to image or image array.
 	im = data2im(a); [imheight,imwidth,nim] = size(im);
	
	% Check arguments.
	if (nargin < 2)
		prwarning(4,'sigma not specified, assuming 1');
		sigma = 1;
	else
		sigma = sigma(:);
		if (length(sigma) ~= 1) & (length(sigma) ~= nim)
			error('incorrect mumber of standard deviations specified')
		end
	end

	% Create filter(s): 1D Gaussian.
	bordersize = ceil(2*sigma); filtersize = 2*bordersize + 1;	
	filter = exp(-repmat((([1:filtersize] - bordersize - 1).^2),length(sigma),1) ...
								./repmat((2.*sigma.*sigma),1,filtersize));		% Gaussian(s).
	filter = filter ./ repmat(sum(filter,2),1,filtersize);			% Normalize.

	% Replicate filter if just a single SIGMA was specified.
	if (length(sigma) == 1)
		bordersize = repmat(bordersize,nim,1);
		sigma      = repmat(sigma,nim,1);
		filter     = repmat(filter,nim,1);
	end

  % Process all images...
	for i = 1:nim
		out = bord(im(:,:,i),NaN,bordersize(i));           % Add mirrored border.
		out = conv2(filter(i,:),filter(i,:),out,'same');   % Convolve with filter.
		im(:,:,i) = resize(out,bordersize(i),imheight,imwidth);
																								% Crop back to original size.
	end

  % Place filtered images back in dataset.
	if (isfeatim(a))
		a = setdata(a,im2feat(im),getfeatlab(a));
	else
		a = setdata(a,im2obj(im),getfeatlab(a));
	end

return
