function [activation] = feedForwardAutoencoder(theta, info, data)

% theta: trained weights from the autoencoder
% visibleSize: the number of input units (probably 64) 
% hiddenSize: the number of hidden units (probably 25) 
% data: Our matrix containing the training data as columns.  So, data(:,i) is the i-th training example. 
  
% We first convert theta to the (W1, W2, b1, b2) matrix/vector format, so that this 
% follows the notation convention of the lecture notes. 

[W1 W2 W3 W4 b1 b2 b3 b4] = stack2param(theta, info);

%% ---------- YOUR CODE HERE --------------------------------------
%  Instructions: Compute the activation of the hidden layer for the Sparse Autoencoder.
m = size(data, 2);
z2 = W1 * data + repmat(b1,1,m);
a2 = sigmoid(z2);
z3 = W2 * a2 + repmat(b2,1,m);
a3 = sigmoid(z3);
activation = a3;
%-------------------------------------------------------------------

end

%-------------------------------------------------------------------
% Here's an implementation of the sigmoid function, which you may find useful
% in your computation of the costs and the gradients.  This inputs a (row or
% column) vector (say (z1, z2, z3)) and returns (f(z1), f(z2), f(z3)). 

function sigm = sigmoid(x)
%     sigm = 1 ./ (1 + exp(-x));
    sigm = smoothL1(x);
end
