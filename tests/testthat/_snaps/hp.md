# ssd_hp calculates cis in parallel but one distribution

    1.45515870308144

# ssd_hp calculates cis in parallel with two distributions

    1.4500138422759
    

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

