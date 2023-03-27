%========================================================================
% LCP, Version 1.0
% Copyright(c) 2020 A.Elliethy, M.Awad
% All Rights Reserved.
%
%----------------------------------------------------------------------
% Permission to use, copy, or modify this software and its documentation
% for educational and research purposes only and without fee is hereby
% granted, provided that this copyright notice and the original authors'
% names appear on all copies and supporting documentation. This program
% shall not be used, rewritten, or adapted as the basis of a commercial
% software or hardware product without first obtaining permission of the
% authors. The authors make no representations about the suitability of
% this software for any purpose. It is provided "as is" without express
% or implied warranty.
%
% The software code is provided "as is" with ABSOLUTELY NO WARRANTY
% expressed or implied. Use at your own risk.
%----------------------------------------------------------------------
%
% This is an implementation of the local contrast estimation of an image.
% Please refer to the following paper:
%
% M. Awad, A. Elliethy, and H. A. Aly, “Adaptive near-infrared and visible
% fusion for fast image enhancement,” IEEE Trans. Comp. Imaging, pp.1–11,
% Nov. 2019.
%
% Kindly report any suggestions or corrections to the author emails.
%
%========================================================================

function [LC, min_gr, max_gr,max_min_I] = LCP(I,N)

    max_fun = @(x) max(x(:));
    min_fun = @(x) min(x(:));
    max_min_fun = @(x) (max(x(:)) - min(x(:)));
    [height, width, ~] = size(I);
    padSize = floor(N/2); 
    imJ = padarray(I, [padSize padSize], 0);
    [Gr_I,Gdir] = imgradient(imJ,'CentralDifference');
    max_gr = nlfilter(abs(Gr_I),[N N],max_fun);
    min_gr = nlfilter(abs(Gr_I),[N N],min_fun);
    max_min_I = nlfilter(imJ,[N N],max_min_fun);
    LC = max_gr./(max_min_I+0.1);
    LC = imcrop(LC,[padSize+1 padSize+1 width-1 height-1]);
    max_min_I = imcrop(max_min_I,[padSize+1 padSize+1 width-1 height-1]);
    max_gr = imcrop(max_gr,[padSize+1 padSize+1 width-1 height-1]);
    min_gr = imcrop(min_gr,[padSize+1 padSize+1 width-1 height-1]);

end

