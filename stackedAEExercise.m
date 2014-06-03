%% CS294A/CS294W Stacked Autoencoder Exercise

%  Instructions
%  ------------
% 
%  This file contains code that helps you get started on the
%  sstacked autoencoder exercise. You will need to complete code in
%  stackedAECost.m
%  You will also need to have implemented sparseAutoencoderCost.m and 
%  softmaxCost.m from previous exercises. You will need the initializeParameters.m
%  loadMNISTImages.m, and loadMNISTLabels.m files from previous exercises.
%  
%  For the purpose of completing the assignment, you do not need to
%  change the code in this file. 
%
%%======================================================================
%% STEP 0: Here we provide the relevant parameters values that will
%  allow your sparse autoencoder to get good filters; you do not need to 
%  change the parameters below.
clc; clear all; close all;


inputSize = 28 * 28;
numClasses = 10;
hiddenSizeL1 = 500;    % Layer 1 Hidden Size
hiddenSizeL2 = 300;    % Layer 2 Hidden Size
sparsityParam = 0.1;   % desired average activation of the hidden units.
                       % (This was denoted by the Greek alphabet rho, which looks like a lower-case "p",
		               %  in the lecture notes). 
lambda = 3e-3;         % weight decay parameter       
beta = 0;              % weight of sparsity penalty term       

%%======================================================================
%% STEP 1: Load data from the MNIST database
%
%  This loads our training data from the MNIST database files.

% Load MNIST database files
% trainData = loadMNISTImages('train-images-idx3-ubyte');
% trainLabels = loadMNISTLabels('train-labels-idx1-ubyte');

load mnist_rot_bg_img.mat

trainData = traindata';
trainLabels = trainlabels';

trainLabels(trainLabels == 0) = 10; % Remap 0 to 10 since our labels need to start from 1

%%======================================================================
%% STEP 2: Train the first sparse autoencoder
%  This trains the first sparse autoencoder on the unlabelled STL training
%  images.
%  If you've correctly implemented sparseAutoencoderCost.m, you don't need
%  to change anything here.


%  Randomly initialize the parameters
% sae1Theta = initializeParameters(hiddenSizeL1, inputSize);

[Theta, info] = initialize(hiddenSizeL1, hiddenSizeL2, inputSize);

% trainData = trainData(:,1:10);
% % 
% % [cost, grad] = sparseAutoencoderCost(sae1Theta, inputSize, hiddenSizeL1, lambda, ...
% %                                      sparsityParam, beta, trainData);
% [cost, grad] = sparseAutoencoderC(Theta,info,inputSize,hiddenSizeL1,hiddenSizeL2,lambda,sparsityParam,beta,trainData);
% 
% numgrad = computeNumericalGradient( @(x) sparseAutoencoderC(x,info,inputSize,hiddenSizeL1, ...
%                                                   hiddenSizeL2,lambda,sparsityParam, ...
%                                                   beta,trainData), Theta);
% % Use this to visually compare the gradients side by side
% disp([numgrad grad]); 
% % 
% % Compare numerically computed gradients with the ones obtained from backpropagation
% diff = norm(numgrad-grad)/norm(numgrad+grad);
% disp(diff); % Should be small. In our implementation, these values are
%             % usually less than 1e-9.
% 
%             % When you got this working, Congratulations!!! 
% pause;



%  Use minFunc to minimize the function
% addpath minFunc/
% options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost
%                           % function. Generally, for minFunc to work, you
%                           % need a function pointer with two outputs: the
%                           % function value and the gradient. In our problem,
%                           % sparseAutoencoderCost.m satisfies this.
% options.maxIter = 400;	  % Maximum number of iterations of L-BFGS to run 
% options.display = 'on';
% 
% 
% [OptTheta, cost] = minFunc(  @(p) sparseAutoencoderC(p,info,inputSize,hiddenSizeL1, ...
%                                                   hiddenSizeL2,lambda,sparsityParam, ...
%                                                   beta,trainData),Theta,options);
%                                
% save 'OptTheta.mat' OptTheta                               

load OptTheta;







% -------------------------------------------------------------------------


%%======================================================================
%% STEP 3: Train the softmax classifier
%  This trains the sparse autoencoder on the second autoencoder features.
%  If you've correctly implemented softmaxCost.m, you don't need
%  to change anything here.

[sae2Features] = feedForwardAutoencoder(OptTheta, info, trainData);

%  Randomly initialize the parameters
saeSoftmaxTheta = 0.005 * randn(hiddenSizeL2 * numClasses, 1);


%% ---------------------- YOUR CODE HERE  ---------------------------------
%  Instructions: Train the softmax classifier, the classifier takes in
%                input of dimension "hiddenSizeL2" corresponding to the
%                hidden layer size of the 2nd layer.
%
%                You should store the optimal parameters in saeSoftmaxOptTheta 
%
%  NOTE: If you used softmaxTrain to complete this part of the exercise,
%        set saeSoftmaxOptTheta = softmaxModel.optTheta(:);


options.maxIter = 100;
softmaxModel = softmaxTrain(hiddenSizeL2, numClasses, lambda, ...
                            sae2Features, trainLabels, options);


saeSoftmaxOptTheta = softmaxModel.optTheta(:);

save 'saesoftmaxOptTheta.mat' saeSoftmaxOptTheta;

%load saeSoftmaxOptTheta;

% -------------------------------------------------------------------------



%%======================================================================
%% STEP 5: Finetune softmax model

% Implement the stackedAECost to give the combined cost of the whole model
% then run this cell.

% Initialize the stack using the parameters learned
stack = cell(2,1);

[W1 W2 W3 W4 b1 b2 b3 b4] = stack2param(OptTheta, info);

%第一层自动编码机的w1，b1
stack{1}.w = W1;
stack{1}.b = b1;
%第二层自动编码机的w2，b2
stack{2}.w = W2;
stack{2}.b = b2;

% Initialize the parameters for the deep model
[stackparams, netconfig] = stack2params(stack);
stackedAETheta = [ saeSoftmaxOptTheta ; stackparams ];

%% ---------------------- YOUR CODE HERE  ---------------------------------
%  Instructions: Train the deep network, hidden size here refers to the '
%                dimension of the input to the classifier, which corresponds 
%                to "hiddenSizeL2".
%
%

DEBUG = false;

if DEBUG
    lambda = 0;
    hiddenSizeL2 = 2;
    trainData = trainData(:,1:10);
    trainLabels = trainLabels(1:10);
    netconfig.layersizes = {};
    netconfig.layersizes = [netconfig.layersizes;2];
    netconfig.layersizes = [netconfig.layersizes;2];
    stackedAETheta = stackedAETheta(1:1596);
end

[cost, grad] = stackedAECost(stackedAETheta, inputSize, hiddenSizeL2, ...
                                              numClasses, netconfig, ...
                                              lambda, trainData, trainLabels);


if DEBUG
%     numGrad = computeNumericalGradient( @(x) stackedAECost(x, numClasses, ...
%                                     inputSize, lambda, trainData, trainLabels), stackedAETheta);
    numGrad = computeNumericalGradient( @(x) stackedAECost(x, inputSize, hiddenSizeL2, ...
                                              numClasses, netconfig, lambda, ...
                                              trainData, trainLabels), stackedAETheta);
                                
    % Use this to visually compare the gradients side by side
    disp([numGrad grad]); 

    % Compare numerically computed gradients with those computed analytically
    diff = norm(numGrad-grad)/norm(numGrad+grad);
    disp(diff); 
    % The difference should be small. 
    % In our implementation, these values are usually less than 1e-7.

    % When your gradients are correct, congratulations!
end

%!!!!!!!!!!!!!这个步骤非常重要，否则识别率只有%91！
%lambda = 1e-4;

lambda = 1e-3;

addpath minFunc/
options.Method = 'lbfgs'; 
options.maxIter = 1200;	 
options.display = 'on';

[stackedAEOptTheta, cost] = minFunc( @(p) stackedAECost(p, inputSize, hiddenSizeL2, ...
                                              numClasses, netconfig, lambda, ...
                                              trainData, trainLabels), stackedAETheta, options);
                                          
save 'stackedAEOptTheta.mat' stackedAEOptTheta;

load stackedAEOptTheta;

% -------------------------------------------------------------------------



%%======================================================================
%% STEP 6: Test 
%  Instructions: You will need to complete the code in stackedAEPredict.m
%                before running this part of the code
%

% Get labelled test images
% Note that we apply the same kind of preprocessing as the training set
% testData = loadMNISTImages('t10k-images-idx3-ubyte');
% testLabels = loadMNISTLabels('t10k-labels-idx1-ubyte');

testData = testdata';
testLabels = testlabels';

testLabels(testLabels == 0) = 10; % Remap 0 to 10

[pred] = stackedAEPredict(stackedAETheta, inputSize, hiddenSizeL2, ...
                          numClasses, netconfig, testData);

acc = mean(testLabels(:) == pred(:));
fprintf('Before Finetuning Test Accuracy: %0.3f%%\n', acc * 100);

[pred] = stackedAEPredict(stackedAEOptTheta, inputSize, hiddenSizeL2, ...
                          numClasses, netconfig, testData);

acc = mean(testLabels(:) == pred(:));
fprintf('After Finetuning Test Accuracy: %0.3f%%\n', acc * 100);

% Accuracy is the proportion of correctly classified images
% The results for our implementation were:
%
% Before Finetuning Test Accuracy: 87.7%
% After Finetuning Test Accuracy:  97.6%
%
% If your values are too low (accuracy less than 95%), you should check 
% your code for errors, and make sure you are training on the 
% entire data set of 60000 28x28 training images 
% (unless you modified the loading code, this should be the case)
