# hc multi_ci lnorm default 100

    Code
      hc_average
    Output
      # A tibble: 1 x 15
        dist    proportion   est    se   lcl   ucl    wt level est_method ci_method
        <chr>        <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <chr>      <chr>    
      1 average       0.05  1.24 0.743 0.479  3.19     1  0.95 arithmetic MACL     
      # i 5 more variables: boot_method <chr>, nboot <dbl>, pboot <dbl>,
      #   dists <list>, samples <list>

---

    Code
      hc_multi
    Output
      # A tibble: 1 x 15
        dist    proportion   est    se   lcl   ucl    wt level est_method ci_method 
        <chr>        <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <chr>      <chr>     
      1 average       0.05  1.26 0.735 0.455  3.25     1  0.95 multi      multi_free
      # i 5 more variables: boot_method <chr>, nboot <dbl>, pboot <dbl>,
      #   dists <list>, samples <I<list>>

# hp multi_ci lnorm default 100

    Code
      hp_average
    Output
      # A tibble: 1 x 15
        dist     conc    est     se     lcl    ucl    wt level est_method ci_method
        <chr>   <dbl>  <dbl>  <dbl>   <dbl>  <dbl> <dbl> <dbl> <chr>      <chr>    
      1 average     1 0.0390 0.0232 0.00738 0.0957     1  0.95 multi      MACL     
      # i 5 more variables: boot_method <chr>, nboot <dbl>, pboot <dbl>,
      #   dists <list>, samples <list>

---

    Code
      hp_multi
    Output
      # A tibble: 1 x 15
        dist     conc    est     se     lcl    ucl    wt level est_method ci_method 
        <chr>   <dbl>  <dbl>  <dbl>   <dbl>  <dbl> <dbl> <dbl> <chr>      <chr>     
      1 average     1 0.0390 0.0246 0.00347 0.0922     1  0.95 multi      multi_free
      # i 5 more variables: boot_method <chr>, nboot <dbl>, pboot <dbl>,
      #   dists <list>, samples <I<list>>

# sgompertz completely unstable!

    Code
      set.seed(94)
      ssdtools:::sgompertz(data)
    Output
      $log_location
      [1] -0.8105617
      
      $log_shape
      [1] -300.8251
      
    Code
      set.seed(99)
      ssdtools:::sgompertz(data)
    Output
      $log_location
      [1] -0.9662517
      
      $log_shape
      [1] -2.602139
      

# sgompertz with initial values still unstable!

    Code
      set.seed(94)
      ssdtools:::sgompertz(sdata)
    Output
      $log_location
      [1] -0.8105617
      
      $log_shape
      [1] -300.8251
      
    Code
      set.seed(94)
      ssdtools:::sgompertz(sdata, pars)
    Output
      $log_location
      [1] 4.078373
      
      $log_shape
      [1] -2989.932
      
    Code
      set.seed(99)
      ssdtools:::sgompertz(sdata)
    Output
      $log_location
      [1] -0.9662517
      
      $log_shape
      [1] -2.602139
      
    Code
      set.seed(99)
      ssdtools:::sgompertz(sdata, pars)
    Output
      $log_location
      [1] 3.433594
      
      $log_shape
      [1] -104.2544
      
    Code
      set.seed(100)
      ssdtools:::sgompertz(sdata, pars)
    Output
      $log_location
      [1] 3.81493
      
      $log_shape
      [1] -669.3178
      

# sgompertz cant even fit some values

    Code
      ssdtools:::sgompertz(data.frame(left = x, right = x))
    Condition
      Warning in `min()`:
      no non-missing arguments to min; returning Inf
      Error in `vglm.fitter()`:
      ! object 'eta' not found
    Code
      ssdtools:::sgompertz(data.frame(left = rep(x, 10), right = rep(x, 10)))
    Condition
      Warning in `min()`:
      no non-missing arguments to min; returning Inf
      Error in `vglm.fitter()`:
      ! object 'eta' not found
    Code
      ssdtools:::sgompertz(data.frame(left = x, right = x), pars = c(12800, 1))
    Condition
      Warning in `min()`:
      no non-missing arguments to min; returning Inf
      Error in `vglm.fitter()`:
      ! object 'eta' not found
    Code
      ssdtools:::sgompertz(data.frame(left = x / 12800, right = x / 12800))
    Condition
      Warning in `min()`:
      no non-missing arguments to min; returning Inf
      Error in `vglm.fitter()`:
      ! object 'eta' not found

# sgompertz cant even initialize lots of values

    Code
      set.seed(99)
      ssdtools:::sgompertz(data.frame(left = x, right = x))
    Condition
      Warning in `min()`:
      no non-missing arguments to min; returning Inf
      Error in `vglm.fitter()`:
      ! object 'eta' not found
    Code
      set.seed(99)
      ssd_fit_dists(data.frame(Conc = x), dists = "gompertz")
    Condition
      Warning:
      Distribution 'gompertz' failed to fit (try rescaling data): Error in checkwz(wz, M = M, trace = trace, wzepsilon = control$wzepsilon) : 
        Some elements in the working weights variable 'wz' are not finite
      .
      Error:
      ! All distributions failed to fit.
    Code
      set.seed(100)
      ssdtools:::sgompertz(data.frame(left = x, right = x))
    Condition
      Warning in `min()`:
      no non-missing arguments to min; returning Inf
      Error in `vglm.fitter()`:
      ! object 'eta' not found
    Code
      set.seed(100)
      ssd_fit_dists(data.frame(Conc = x), dists = "gompertz")
    Condition
      Warning:
      Distribution 'gompertz' failed to fit (try rescaling data): Error in optim(par, fn, gr, method = method, lower = lower, upper = upper,  : 
        L-BFGS-B needs finite values of 'fn'
      .
      Error:
      ! All distributions failed to fit.
    Code
      set.seed(131)
      ssd_fit_dists(data.frame(Conc = x), dists = "gompertz")
    Output
      Distribution 'gompertz'
        location 0.0256225
        shape 3.35465e-14
      
      Parameters estimated from 1000 rows of data.

