function mapp=Hmap(SAA,SBB)
[LC_ir, max_min_I_ir, max_gr_ir] = LCP(SAA,7);
[LC_rgb,  max_min_I_rgb, max_gr_rgb] = LCP(SBB,7);


%figure,imshow([max_min_I_ir,max_gr_ir]); figure,imshow([max_min_I_rgb,max_gr_rgb]);



alpha = 0.5;
LC_ir_our = (alpha*max_min_I_ir) + ((1-alpha)*max_gr_ir);
LC_rgb_our = (alpha*max_min_I_rgb) + ((1-alpha)*max_gr_rgb);
mapp = max(0,(LC_ir_our-LC_rgb_our)./LC_ir_our);



%fuse_High=SAA.*mapp+SBB.*(1-mapp);


%figure,imshow([LC_ir_our,LC_rgb_our,mapp,fuse_High]);