%DATA2IM Convert PRTools dataset to image
%
%		IM = DATA2IM(A)
%
% INPUT
%		A     Dataset containing images
%
% OUTPUT
%		IM    X*Y*K matrix containing a set of K images of X-by-Y pixels
%
% DESCRIPTION
% An image, or a set of images stored in the objects or features of the
% dataset A are retrieved and returned as a 3D matrix IM.
%
% SEE ALSO
% DATASETS, IM2OBJ, IM2FEAT

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: data2im.m,v 1.3 2003/07/14 14:29:28 davidt Exp $

function im = data2im (a)

	prtrace(mfilename);

	isdataim(a);			% Assert that A contains image(s).

	data = +a;				% Extract data from dataset, for computational advantage.
	[m,k] = size(a); [objsize,featsize] = get(a,'objsize','featsize');

	% Reshape data into output array.

	if (isfeatim(a))	
		% A contains K images stored as features (each object is a pixel).
		im = zeros(objsize(1),objsize(2),k);
		for j = 1:k
			im(:,:,j) = reshape(data(:,j),objsize(1),objsize(2));
		end
	else							
		% A contains M images stored as objects (each feature is a pixel).
		im = zeros(featsize(1),featsize(2),m);
		for j = 1:m
			im(:,:,j) = reshape(data(j,:),featsize(1),featsize(2));
		end
	end

return
