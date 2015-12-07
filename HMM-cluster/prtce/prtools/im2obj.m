%IM2OBJ Convert Matlab images to dataset object
%
%  B = IM2OBJ(IM,A)
%
% INPUT
%  IM  X*Y image, X*Y*K array of K images, or cell-array of images
%  A   Input dataset
%
% OUTPUT
%  B   Dataset with IM added
%
% DESCRIPTION
% Add standard Matlab images, as objects, to an existing dataset A. If A is 
% not given, a new dataset is created. Images of type 'uint8' are converted
% to 'double' and divided by 256.
%
% SEE ALSO
% DATASETS, IM2FEAT, DATA2IM

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: im2obj.m,v 1.8 2003/10/09 09:31:07 bob Exp $

function a = im2obj (im,a)

	prtrace(mfilename);

	if (isa(im,'cell'))

		% If IM is a cell array of images, unpack it and recursively call IM2OBJ
		% to add each image.

		im = im(:);																	% Reshape to 1D cell array.
		if (nargin < 2)
			prwarning(4,'no dataset supplied, creating a new one');
			a = dataset([]); 
		end	
		for i = 1:length(im)
			b = feval(mfilename,im{i});
			if ~isempty(a) & any(a.objsize ~= b.objsize)
				error('Images should have equal sizes')
			end
			a = [a; feval(mfilename,im{i})];
		end
	else

		% If IM is an image or array of images, reshape it and add it in one go.

		n = size(im,3); imsize = size(im); imsize = imsize(1:2);
		% Convert to double, if necessary
		if (isa(im,'uint8'))
			prwarning(4,'image is uint8; converting to double and dividing by 256');
			im = double(im)/256; 
		end

		% Reshape images to vectors and store as objects in dataset.
		im = reshape(im,imsize(1)*imsize(2),n);
		if (nargin > 1)
			if (~isa(a,'dataset'))
				error('second argument is not a dataset'); 
			end
			if (~isempty(a) & (imsize(1)*imsize(2) ~= getfeatsize(a)))
				error('image size and dataset feature size do not match');
			end
			a = [a; im'];
		else
			a = dataset(im');
			a = setfeatsize(a,imsize);
		end

	end	

return
