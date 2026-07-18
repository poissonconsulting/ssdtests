# ssd_hc calculates cis in parallel with two distributions

    0.511475267792982
    

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

