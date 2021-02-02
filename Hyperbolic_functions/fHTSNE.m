%% use r' = exp(r) as new variable to avoid negative radius


function [Y,loss] = fHTSNE(X,lambda,varargin)
%   fHTSNE: hyperbolic t-Distributed Stochastic Neighbor Embedding.
%   Y = fHTSNE(X, lambda) returns the representation of the N by P matrix X in the
%   two dimensional space. Each row in X represents an observation. Rows
%   with NaN missing values are removed. Lambda represents the weight of
%   global loss function.


if nargin<1
    error(message('stats:tsne:TooFewInputs'));
end

paramNames = {'Algorithm',  'Distance',   'NumDimensions',  'NumPCAComponents',...
              'InitialY',   'InitialR',   'UpperRadius',    'Perplexity', 'Exaggeration',   'LearnRate', 'Momentum',...
              'Theta',      'Standardize','NumPrint',       'options',    'Verbose',...
              'Geometry'};
defaults   = {'barneshut',  'euclidean',   [],               0,...     
               [],          1,       false,      [],            4,               1,         0.2,...
               [],         false,        20,               [],            0,...
               'native'};

[algorithm, distance, ydims, numPCA, ystart, Rstart, upperRadius, perplexity, exaggeration, learnrate, momentum, theta,...
  standardize, numprint, options, verbose, geometry ] = internal.stats.parseArgs(paramNames, defaults, varargin{:});

% Input Checking
internal.stats.checkSupportedNumeric('X',X,false,false,false);
if ~ismatrix(X)
    error(message('stats:tsne:BadX'));
end
p = size(X,2);
if ~isempty(ystart)
    internal.stats.checkSupportedNumeric('InitialY',ystart,false,false,false);
    % check Inf values
    if any(isinf(ystart(:)))
        error(message('stats:tsne:InfInitialY'));
    end
    if size(X,1)~=size(ystart,1)
        error(message('stats:tsne:InputSizeMismatch'));
    end
    ystartcols = size(ystart,2);
    if ~isempty(ydims) 
        if ystartcols~=ydims
            error(message('stats:tsne:BadInitialY'));
        end
    elseif ystartcols>p
        error(message('stats:tsne:BadYdims1'));
    else
        ydims = ystartcols;
    end
else
    if isempty(ydims)
        ydims = min(p,2);
    elseif ~internal.stats.isScalarInt(ydims,1)
        error(message('stats:tsne:InvalidYdims'));
    elseif ydims>p
        error(message('stats:tsne:BadYdims2'));
    end
    ystart = 1e-4*randn(size(X,1), ydims);
end
ystart = cast(ystart,'like',X);


% Remove NaN rows, if any
haveNaN = false;
if any(any(isnan(X))) || any(any(isnan(ystart)))
   haveNaN = true;
   [~,~,X,ystart] = statremovenan(X,ystart);
   if isempty(X)
       warning(message('stats:tsne:EmptyXafterNaN'));
   else
       warning(message('stats:tsne:NaNremoved'));
   end
end

if isempty(lambda)
    lambda = 0;
end


% Hyperbolic coordinates

if strcmpi(geometry,'native')
    ystart = fSamplingNative(size(X,1),ydims,Rstart,0);
    ystart(:,1) = exp(ystart(:,1));
end

N = size(X,1);
if ~internal.stats.isScalarInt(numPCA,0)
    error(message('stats:tsne:InvalidNumPCA','NumPCAComponents'));
elseif numPCA>0 && (numPCA<ydims || numPCA>p)
    error(message('stats:tsne:BadNumPCA','NumPCAComponents'));
end

if ~(isFiniteRealNumericScalar(exaggeration) && exaggeration>=1)
    error(message('stats:tsne:BadExaggeration'));
end
if ~(isFiniteRealNumericScalar(learnrate) && learnrate>0)
    error(message('stats:tsne:BadLearnRate'));
end

if ~internal.stats.isScalarInt(numprint,1)
    error(message('stats:tsne:BadNumPrint'));
end

if ~(isFiniteRealNumericScalar(verbose) && ismember(verbose,[0 1 2]))
    error(message('stats:tsne:BadVerbose'));
end

options = statset(statset('tsne'), options);

AlgorithmNames = {'exact','barneshut'};
algorithm = internal.stats.getParamVal(algorithm,AlgorithmNames,...
    '''Algorithm''');

if ~isscalar(standardize) || (~islogical(standardize) && standardize~=0 && standardize~=1)
    error(message('stats:tsne:InvalidStandardize'));
end

if ~isempty(perplexity) 
    if ~(isFiniteRealNumericScalar(perplexity) && perplexity>0)
        error(message('stats:tsne:BadPerplexity'));
    elseif ~haveNaN && perplexity>N
        error(message('stats:tsne:LargePerplexity'));
    elseif haveNaN && perplexity>N
        error(message('stats:tsne:LargePerplexityAfterRemoveNaN'));
    end
else
    perplexity = min(ceil(N/2),30);
end

if ~(isempty(theta)|| (isFiniteRealNumericScalar(theta) && theta<=1 && theta>=0))
    error(message('stats:tsne:BadTheta'));
end
if strcmpi(algorithm,'exact') 
    if ~isempty(theta) 
        error(message('stats:tsne:InvalidTheta'));
    end
else
    if isempty(theta)
        theta = 0.5;
    end
end

% Handle empty case
if isempty(X)
    Y = zeros(N,ydims,'like',X);
    loss = cast([],'like',X);
    return;
end

% Standardize data
if standardize
    constantCols = (range(X,1)==0);
    sigmaX = std(X,0,1);
    % Avoid dividing by zero with constant columns
    sigmaX(constantCols) = 1;
    X = (X-mean(X,1))./sigmaX;
end

% Perform PCA
if numPCA>0
    if verbose > 1
        fprintf('%s\n',getString(message('stats:tsne:PerformPCA',num2str(numPCA))));
    end
    [~,X] = pca(X,'Centered',false,'Economy',false,'NumComponents',numPCA);
end

if strcmpi(algorithm,'exact')
    if verbose>1
        fprintf('%s\n',getString(message('stats:tsne:ComputeDistMat')));
    end
    if N==1
        % Only one observation
        tempDistMat = 0;
    else
        tempDistMat = pdist(X,distance);
        tempDistMat = squareform(tempDistMat);
        tempDistMat = tempDistMat.^2;
    end
    if verbose > 1
        fprintf('%s\n',getString(message('stats:tsne:ComputeProbMat')));
    end
    [probMatX,sig2] = binarySearchVariance(tempDistMat,perplexity);
    colidx = [];
    rowcnt = [];
    % Compute joint probability and set the diagnals to be 0
    probMatX(1:N+1:end) = 0;
    probMatX = (probMatX + probMatX')/(2*N);
else
    if verbose>1
        fprintf('%s\n',getString(message('stats:tsne:PerformKnnSearch')));
    end
    % Find nearest neighbors of each data point
    ns = createns(X,'distance',distance);
    k = min(N, 3 * floor(perplexity)+1);
    if k==0
        % Empty input
        knnidx = [];
        D = [];
    else
        [knnidx,D] = knnsearch(ns,X,'k',k);
        knnidx(:,1) = [];
    end
    if verbose > 1
        fprintf('%s\n',getString(message('stats:tsne:ComputeProbMat')));
    end
    D = D(:,2:end).^2;
    K = size(D,2);
    maxDensity = 0.4;
    % Compute probMatX using knn results
    if (2*K)/N<maxDensity
        % If density of matrix less than 0.4, only return N by K probMatX
        [probMatX,sig2] = binarySearchVariance(D,perplexity);
    else
        % Otherwise, return full matrix
        [probMatX,sig2] = binarySearchVariance(D,perplexity,knnidx);
    end
    % Find the nonzero elements and their indices in probMatX
    [colidx, rowcnt, probMatX] = probMatXknn(probMatX,knnidx);
end
clear tempDistMat D

if any(probMatX(:)<0 | probMatX(:)>1)
    error(message('stats:tsne:BadJointProb'));
end
probMatX = max(probMatX,realmin(class(ystart)));

if any(sig2<0)
    error(message('stats:tsne:BadVariance'));
end
% Display diagnosis message to command window
if verbose>1
    sig2 = 1./sig2;
    if isempty(sig2)
        avgSig2=[];
    else
        avgSig2 = mean(sig2);
    end
    minSig2 = min(sig2);
    maxSig2 = max(sig2);
    fprintf('%s\n',getString(message('stats:tsne:MeanVariance',num2str(avgSig2))));
    fprintf('%s\n',getString(message('stats:tsne:MinVariance',num2str(minSig2))));
    fprintf('%s\n',getString(message('stats:tsne:MaxVariance',num2str(maxSig2))));
end

% Perform t-SNE to find Y
if verbose>1
    fprintf('%s\n',getString(message('stats:tsne:PerformTSNE')));
end

[Y,loss] = tsneEmbedding(X,ystart,Rstart,upperRadius,geometry,lambda,probMatX,exaggeration,learnrate,momentum,...
    numprint,verbose,options,algorithm,theta,colidx,rowcnt);
end % tsne

% ---------------------------------------------------
% SUBFUNCTIONS 
% ---------------------------------------------------
function t = isFiniteRealNumericScalar(x)
%   T = ISSCALARINT(X) returns true if X is a finite numeric real
%   scalar value, and false otherwise.
t = isscalar(x) && isnumeric(x) && isreal(x) && isfinite(x);
end

function [condProbMatX,sig2] = binarySearchVariance(D,perplexity,varargin)
% Binary search for the sigma of the conditional probability
[N,K] = size(D);
if nargin > 2
    knnidx = varargin{:};
    condProbMatX = zeros(N);
else
     condProbMatX = zeros(N,K);
end
sig2 = ones(N,1);
H = log(perplexity);

tolBinary = 1e-5;
maxit = 100;
notConverge = false(N,1);

for i = 1:N
    a = -Inf;
    c = Inf;
    iter = 0;
    while(true)
        P_i = exp(-D(i,:)*sig2(i));
        if K==N
            P_i(i) = 0;
        end
        sum_i = max(sum(P_i),realmin(class(D)));
        P_i = P_i./sum_i;
        H_i = log(sum_i) + sig2(i)*sum(D(i,:).*P_i);
        fval = H_i - H;
        if abs(fval)< tolBinary
            break;
        end
        if fval > 0
            a = sig2(i);
            if isinf(c)
                sig2(i) = 2*sig2(i);
            else
                sig2(i) = 0.5*(sig2(i) + c);
            end
        else
            c = sig2(i);
            if isinf(a)
                sig2(i) = 0.5*sig2(i);
            else
                sig2(i) = 0.5*(a + sig2(i));
            end
        end
        iter = iter + 1;
        if iter == maxit
            notConverge(i)=true;
            break;
        end
    end
    if nargin < 3
         condProbMatX(i,:) = P_i;
    else
        % Return full matrix for 'barneshut' algorithm
        condProbMatX(i,knnidx(i,:)) = P_i;
    end
end
if any(notConverge)
    warning(message('stats:tsne:BinarySearchNotConverge'));
end
end


function [grad,probMatY,record_KL] = tsneGradient(probMatX,X,Y,geometry, lambda)
% Compute gradient of t-SNE

Y_log = Y;
Y_log(:,1) = log(Y_log(:,1)+1e-6);
% hyperbolic distances
if strcmpi(geometry,'native')
    N = size(X,1);
    Xsum = sum(X.^2,2);
    numeratorProbMatXGlobal = 1 + bsxfun(@plus,Xsum, bsxfun(@plus,Xsum', -2*(X*X'))); 
    numeratorProbMatXGlobal(1:N+1:end) = 0;
    probMatXGlobal = max(numeratorProbMatXGlobal./sum(numeratorProbMatXGlobal(:)),realmin(class(X)));

 % local Euclidean
    N = size(Y,1);
    euc_dist = fDistEuclidean(Y_log);
    numeratorProbMatY = 1./(1+euc_dist.^2);
    numeratorProbMatY(1:N+1:end) = 0;
    probMatY = max(numeratorProbMatY./sum(numeratorProbMatY(:)),realmin(class(Y)));
    euc_der = fDerivativeEuclidean(Y_log);
    euc_der(:,:,1) = euc_der(:,:,1)./Y(:,1);
    
% global hyperbolic
    hyper_dist = fDistNative(Y_log);
    numeratorProbMatYGlobal = 1+hyper_dist.^2;
    numeratorProbMatYGlobal(1:N+1:end) = 0;
    probMatYGlobal = max(numeratorProbMatYGlobal./sum(numeratorProbMatYGlobal(:)),realmin(class(Y)));

    pdiff_local =  numeratorProbMatY.*(probMatX - probMatY);
    pdiff_global = - lambda * numeratorProbMatY.*(probMatXGlobal - probMatYGlobal);
    hyper_der = fDerivativeNative(Y_log);
    hyper_der(:,:,1) = hyper_der(:,:,1)./Y(:,1);
    [l1,l2,l3] = size(hyper_der);
    grad_local = 4 * reshape(sum(pdiff_local.*euc_dist .* euc_der,2),l1,l3);
    grad_global = 4 * reshape(sum(pdiff_global.*hyper_dist .* hyper_der,2),l1,l3);
    grad = grad_local + grad_global;
    KL = probMatX.*log(probMatX./probMatY) + lambda*probMatXGlobal.*log(probMatXGlobal./probMatYGlobal);
elseif strcmpi(geometry,'euclidean')
    N = size(Y,1);
    Ysum = sum(Y.^2,2);
    numeratorProbMatY = 1 ./ (1 + bsxfun(@plus,Ysum, bsxfun(@plus,Ysum', -2*(Y*Y')))); 
    numeratorProbMatY(1:N+1:end) = 0;

    probMatY = max(numeratorProbMatY./sum(numeratorProbMatY(:)),realmin(class(Y)));
    pdiff = numeratorProbMatY.*((probMatX - probMatY));
    grad = 4 * (diag(sum(pdiff,1))-pdiff) * Y;
    KL = probMatX.*log(probMatX./probMatY);
else
    error('Geometry is neither Euclidean nor hyperbolic')
end
record_KL = sum(KL(:));
end

function [Y,loss] = tsneEmbedding(X,Y,Rstart,upperRadius,geometry,lambda,probMatX,exaggeration,...
              learnrate,momentum,numprint,verbose,options,algorithm,theta,colidx,rowcnt)

[N,Ydims] = size(Y);
% Initialization
Ychange = zeros(N,Ydims,'like',Y);
adpRatechange = ones(size(Y),'like',Y);
minRatechange = 0.01;
% momentums = [0.5 0.8];
momentumChange = 250;
exaggerationStop = 100;
titleChangeIter = ceil(exaggerationStop/numprint)*numprint;
numprintcalls = 0;
% Adaptive learning rate in reference Jacobs (1988)
k = 0.15;
phi = 0.85;

% Early exaggeration
probMatX = exaggeration * probMatX;
iter = 1;

% Check for OutputFcn
haveOutputFcn = ~isempty(options.OutputFcn);
stop = false;
if haveOutputFcn
    pval = options.OutputFcn;
    if iscell(pval) && all(cellfun(@(x) isa(x,'function_handle'),pval))
        OutputFcn = pval;
    elseif isa(pval,'function_handle')
        OutputFcn = {pval};
    elseif isempty(pval)
        OutputFcn = {};
    else
        error(message('stats:tsne:InvalidOutputFcn'))
    end
    
    optimValues = struct('iteration',[],'fval',[],'grad',[],'Y',[],...
                    'Exaggeration',exaggeration);
    stop = callOutputFcns(OutputFcn,optimValues,'init');
end
  
while (iter<=options.MaxIter && ~stop)

    if iter == exaggerationStop
        probMatX = probMatX/exaggeration;
        exaggeration = 1;
    end
    if strcmpi(algorithm,'exact')
        [grad,probMatY,record_KL] = tsneGradient(probMatX,X,Y,geometry,lambda);
        loss = record_KL;
    else
        % Compute gradient by Barnes-Hut algorithm
        ymin = min(Y,[],1);
        ymax = max(Y,[],1);
        ycenter = mean(Y,1);
        ywidth = max(ymax-ycenter,ycenter-ymin)+sqrt(eps(class(Y)));
        if isempty(colidx) || isempty(rowcnt) || isempty(probMatX)
            % Empty joint probability matrix
            grad = zeros(size(Y),'like',Y);
            loss = cast(0,'like',Y);
        else
            [attrForce,repForce,Z] = tsnebhmex(theta,Y',ycenter,ywidth,colidx,rowcnt,probMatX);
            grad = 4*(attrForce-repForce)';
            if ( rem(iter,numprint) == 0 )
                loss = tsnelossmex(Y',colidx,rowcnt,probMatX,Z);
            end
        end
    end
    if loss > 1e2
        break;
    end
    if strcmpi(geometry,'hyperbolic')
        learnrate = 1e-3;
        
        momentums = momentum * [0,0];
        k = 0.05; phi = 0.95;
    elseif strcmpi(geometry,'native')
        momentums = momentum * [1,2];
        k = 0.1; phi = 0.9;
    else
        momentums = momentum * [0,0];
    end
    % Adaptive learning rate
    opsIdx = sign(grad) ~= sign(Ychange);
    adpRatechange(opsIdx) = adpRatechange(opsIdx) + k;
    adpRatechange(~opsIdx) = adpRatechange(~opsIdx) * phi;
    adpLearnrate = learnrate .* max(minRatechange,adpRatechange);
    
    % Gradient update
    if iter < momentumChange
        Ychange = momentums(1)*Ychange - adpLearnrate.*grad;
    else
        Ychange = momentums(2)*Ychange - adpLearnrate.*grad;
    end
    
    % Update Y
    tempY = Y;
    Y = Y + Ychange;

    if strcmpi(geometry,'native')
        if upperRadius
            Y(Y(:,1)> Rstart,1) = Rstart;
        end
    end
    
    % Convergency information
    infnormg = norm(grad,Inf);
    if infnormg < options.TolFun
        if verbose >=1
            fprintf('%s\n',getString(message('stats:tsne:TerminatedNormOfGradient')));
        end
        break;
    end

    % Display convergence information
    if ( rem(iter,numprint) == 0 )
        % Perform outputfcn
        if haveOutputFcn
            % We only care about the states init, iter and done
            optimValues = struct('iteration',iter,'fval',loss,'grad',grad,'Y',Y,...
                            'Exaggeration',exaggeration);
            if iter<options.MaxIter+numprint
                stop = callOutputFcns(OutputFcn,optimValues,'iter');
            else
                stop = callOutputFcns(OutputFcn,optimValues,'done');
            end
        end
        if verbose>=1
            displayConvergenceInfo(iter,loss,infnormg,numprintcalls,exaggeration,titleChangeIter);
            numprintcalls = numprintcalls + 1;
        end
    end
    iter = iter + 1;
end

if nargout>1
    % Compute the loss of the final step
    if strcmpi(algorithm,'exact')
        entropyX = probMatX(:)'*log(probMatX(:));
        entropyY = probMatX(:)'*log(probMatY(:));
        loss = entropyX - entropyY;
    else
        if isempty(colidx) || isempty(rowcnt) || isempty(probMatX)
            % Empty joint probability matrix
            loss = 0;
        else
            loss = tsnelossmex(Y',colidx,rowcnt,probMatX,Z);
        end
    end
end
if strcmpi(geometry,'native')
    Y(:,1) = log(Y(:,1)+1e-6);
end
end


function displayConvergenceInfo(iter,loss,infnormg,numprintcalls,exaggeration,titleChangeIter)
% Helper function to display iteration convergence info.

% |==============================================|
% |   ITER   |  KL DIVERGENCE  |     NORM GRAD   |
% |          |    FUN VALUE    |                 |
% |==============================================|
% |       20 |    1.211293e-01 |    8.905909e-05 |
% |       40 |    1.211192e-01 |    2.639418e-05 |
% |       60 |    1.211093e-01 |    3.889625e-05 |
% |       80 |    1.211076e-01 |    1.954810e-04 |
% |      100 |    1.210898e-01 |    5.100216e-05 |
% |      120 |    1.210793e-01 |    1.782637e-05 |
% |      140 |    1.210700e-01 |    4.753843e-05 |
% |      160 |    1.210612e-01 |    6.728603e-05 |
% |      180 |    1.210532e-01 |    8.736254e-05 |
% 

if iter<titleChangeIter && exaggeration>1
    if rem(numprintcalls,20) == 0
        fprintf('\n');
        fprintf('|==============================================|\n');
        fprintf('|   ITER   | KL DIVERGENCE   | NORM GRAD USING |\n');
        fprintf('|          | FUN VALUE USING | EXAGGERATED DIST|\n');
        fprintf('|          | EXAGGERATED DIST| OF X            |\n');
        fprintf('|          | OF X            |                 |\n');
        fprintf('|==============================================|\n');
    end
else
    % Title change
    if exaggeration==1 && iter==titleChangeIter && rem(numprintcalls,20) ~= 0
        fprintf('\n');
        fprintf('|==============================================|\n');
        fprintf('|   ITER   |  KL DIVERGENCE  |    NORM GRAD    |\n');
        fprintf('|          |    FUN VALUE    |                 |\n');
        fprintf('|==============================================|\n');     
    end
    if rem(numprintcalls,20) == 0
        fprintf('\n');
        fprintf('|==============================================|\n');
        fprintf('|   ITER   |  KL DIVERGENCE  |    NORM GRAD    |\n');
        fprintf('|          |    FUN VALUE    |                 |\n');
        fprintf('|==============================================|\n');
    end
end

fprintf('|%9d |%16.6e |%16.6e |\n', iter,loss,infnormg);

end

function stop = callOutputFcns(outputFcn,optimValues,state)
% Call each output function
stop = false;
for i = 1:numel(outputFcn)
    stop = stop | outputFcn{i}(optimValues,state);
end
end

function [colidx, rowcnt, probvec] = probMatXknn(probMatX,knnidx)
% Find joint probability matrix of nearest neighbors
% Use sparse matrix to save memory
[N,K] = size(probMatX);
if K<N
    SProwidx = bsxfun(@times,ones(K,N),(1:N));
    SProwidx = SProwidx(:);
    knnidx = knnidx';
    knnidx = knnidx(:);
    probMatX = probMatX';
    probMatX = probMatX(:);
    S = sparse(SProwidx,knnidx,probMatX,N,N);
    P = S+S';
else
    P = probMatX + probMatX';   
end
[rowidx,colidx,probvec] = find(P);
[rowidx,sridx] = sort(rowidx);
colidx = colidx(sridx)';
probvec = probvec(sridx)'./(2*N);
rowcnt = grpstats(rowidx,rowidx,'numel')';
end
