function y = smoothL1(x)
mu=0.1 ;
y = zeros(size(x)) ;
idx1 = x<-mu ;
idx2 = x>mu ;
idx3 = (x>=-mu & x<=mu)  ;
y(idx1) = -x(idx1) - mu/2 ;
y(idx2) = x(idx2) - mu/2 ;
y(idx3) = x(idx3).^2/(2*mu) ;
end