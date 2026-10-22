# ssd_fit_dists computable = TRUE allows for fits without standard errors

    Code
      fits <- ssd_fit_dists(data, right = "Other", rescale = FALSE, at_boundary_ok = FALSE)
    Condition
      Warning:
      Distribution 'lnorm_lnorm' failed to converge (try rescaling data): Iteration limit maxit reach (try increasing the maximum number of iterations in control).

