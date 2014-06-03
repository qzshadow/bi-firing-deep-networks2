function gy = gsmoothL1(x)
mu=0.1 ;
gy = zeros(size(x)) ;
idx1 = x<-mu ;
idx2 = x>mu ;
idx3 = (x>=-mu & x<=mu)  ;
gy(idx1) = -1 ;
gy(idx2) = 1 ;
gy(idx3) = x(idx3)./mu ;
end