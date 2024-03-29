# #‘ \cite{This function is copied from the fdapace package}

GetSmoothedMeanCurve <- function (y, t, obsGrid, regGrid, optns){
  
  # For the case of binned data one may use a weighted mean response for each time-point.
  # This is not currently implemented. \hat{y}_i = \sum_i w_i y_i where w_i are the
  # same points for common t_is so we have: \hat{y}_i = n_t w_i \bar{y}

  userMu = optns$userMu;
  methodBwMu = optns$methodBwMu;
  npoly = 1
  nder = 0 
  userBwMu = optns$userBwMu; 
  kernel = optns$kernel
 
  # If the user provided a mean function use it
  if ( is.list(userMu) && (length(userMu$mu) == length(userMu$t))){
    
    buff <- .Machine$double.eps * max(abs(obsGrid)) * 10
    rangeUser <- range(optns$userMu$t)
    rangeObs <- range(obsGrid)
    if( rangeUser[1] > rangeObs[1] + buff || 
        rangeUser[2] < rangeObs[2] - buff   ) {
      stop('The range defined by the user provided mean does not cover the support of the data.')
    }

    mu = stats::spline(userMu$t, userMu$mu, xout= obsGrid)$y;
    muDense = stats::spline(obsGrid,mu, xout=regGrid)$y;
    bw_mu = NULL;
 
 # otherwise if the user provided a mean bandwidth use it to estimate the mean function (below)
  } else {
    if (userBwMu > 0){
      bw_mu = userBwMu;
    #otherwise estimate the mean bandwith via the method selected to estimnate the mean function (below)
    } else {
      if( any(methodBwMu == c('GCV','GMeanAndGCV') )){
        # get the bandwidth using GCV
        bw_mu =  unlist(GCVLwls1D1(yy = y, tt = t, kernel = kernel, npoly = npoly, nder = nder, dataType = optns$dataType) )[1]    
        if ( 0 == length(bw_mu)){ 
          stop('The data is too sparse to estimate a mean function. Get more data!\n')
         }
         # Uncomment to ensure MATLAB compatibility (AdjustBW1 is removed (3-Jun-16); check older versions.)
         # bw_mu = AdjustBW1(kernel=kernel,bopt=bw_mu,npoly=npoly,dataType=optns$dataType,nder=nder)
         # get the geometric mean between the minimum bandwidth and GCV bandwidth to estimnate the mean function (below)         
         if ( methodBwMu == 'GMeanAndGCV') {
           minbw = Minb( unlist(t),2)
           bw_mu = sqrt(minbw*bw_mu);
        } 
      } else {
        # get the bandwidth using CV to estimnate the mean function (below)
        bw_mu = CVLwls1D(y, t, kernel= kernel, npoly=npoly, nder=nder, dataType= optns$dataType, kFolds = optns$kFoldMuCov, 
                         useBW1SE = optns$useBW1SE); 
      }
    }
    # Get the mean function using the bandwith estimated above:
    xin = unlist(t);    
    yin = unlist(y)[order(xin)];
    xin = sort(xin);    
    win = rep(1, length(xin));
    mu = fdapace::Lwls1D(bw_mu, kernel_type = kernel, npoly = npoly, nder = nder, xin = xin, yin= yin, xout = obsGrid, win = win)
    muDense = fdapace::Lwls1D(bw_mu, kernel_type = kernel, npoly = npoly, nder = nder, xin = xin, yin= yin, xout = regGrid, win = win)
  }  
  
  result <- list( 'mu' = mu, 'muDense'= muDense, 'bw_mu' = bw_mu);
  class(result) <- "SMC"
  return(result)
}


