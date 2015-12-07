%IM2FEAT Convert Matlab images to dataset feature
%
%   B = IM2FEAT(IM,A)
%
% INPUT
%   IM    X*Y image, X*Y*K array of K images, or cell-array of images
%   A     Input dataset
%
% OUTPUT
%   B     Dataset with IM added
%
% DESCRIPTION
% Add standard Matlab images, as features, to an existing dataset A. If A is
% not given, a new dataset is created. Images of type 'uint8' are converted
% to 'double' and divided by 256.
%
% SEE ALSO
% DATASETS, IM2OBJ, DATA2IM

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: im2feat.m,v 1.4 2003/08/18 15:49:39 dick Exp $

function a = im2feat (im,a)

	prtrace(mfilename);

	if (isa(im,'cell'))

		% If IM is a cell array of images, unpack it and recursively call IM2FEAT
		% to add each image.

		im = im(:);
		if (nargin < 2)
			a = dataset([]);
		end
		for i = 1:length(im)
			a = [a feval(mfilename,im{i})];
		end
	else

		% If IM is an image or array of images, reshape it and add it in one go.

		n = size(im,3); imsize = size(im); imsize = imsize(1:2);

		% Convert to double, if necessary
		if (isa(im,'uint8'))
			prwarning(4,'Image is uint8; converting to double and dividing by 256');
			im = double(im)/256;
		end

		% Reshape images to vectors and store as features in dataset.
		im = reshape(im,imsize(1)*imsize(2),n);
		if (nargin > 1)
			if (~isa(a,'dataset'))
				error('Second argument is not a dataset')
			end
			if (imsize(1)*imsize(2) ~= getobjsize(a))
				error('Image size and dataset object size do not match')
			end
			a = [a im];
		else
			a = dataset(im);
			a = setobjsize(a,imsize);
		end
	end

return
