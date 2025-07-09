+++
authors = ["Shih Cheng Han"]
title = "Implementation of Various Integration Methods"
date = "2022-02-25"
description = "Guide to implementing various integration methods"
categories = [
    "R",
    "Mathematics",
]
tags = [
    "R Coding",
    "Integrate",
]
# series = ["Theme Demo"]
+++

Here we will implement the Riemann integration method, the trapezoidal integration method, the Simpson integration method, and the Monte Carlo integration method. Below are brief descriptions of each:

1. **Riemann Integration Method**: Divide the given interval into n small intervals, then calculate the product of the function values in each small interval multiplied by the width of the interval, and finally add up these products to obtain the integral value.
   
2. **Trapezoidal Integration Method**: Divide the given interval into n small intervals, then calculate the product of the average width of adjacent small intervals multiplied by the function values in each adjacent interval, and finally add up these products to obtain the integral value.

3. **Simpson Integration Method**: Divide the given interval into n small intervals, then use the three-point method to combine the function values in each adjacent interval into a curve, and finally add up the estimated areas under these curves to obtain the integral value.

4. **Monte Carlo Integration Method**: By generating random numbers within the given interval, calculate the average of the function values corresponding to these random points, then multiply by the interval width to obtain an estimate of the integral value.

```r
my_integrate <- function(Fun, lower, upper, n=10, digit=15, method="rect"){
  options(digits = digit)
  if(method == "rect"){
    sum(sapply(1:n, function(x, Fun) Fun(x*(upper-lower)/n+lower)*(1/n), Fun))
  }else if(method == "tri"){
    sum(sapply(1:n, function(x, fx, dx) (fx[x]+fx[x+1])*dx/2,
               sapply(seq(lower, upper, (upper-lower)/n), Fun),
               (upper-lower)/n))
  }else if(method == "simp"){
    dx <- (upper-lower)/n; x <- seq(lower, upper, dx)
    odd <- seq(length(x)-2, 2, by=-2); even <- seq(length(x)-1, 2, by=-2)
    sum(c(Fun(x[1]), Fun(x[n+1]),
      sapply(x[odd], function(x, Fun) 2*Fun(x), Fun),
      sapply(x[even], function(x, Fun) 4*Fun(x), Fun)))*dx/3
  }else if(method == "mtca"){
    mean(Fun(runif(n, min = lower, max = upper)))*(upper-lower)
  }
}
```

Below, we will store their integration results, errors, and the convergence speed of functions in a data frame. Through these results, we can compare the performance of different methods under different conditions. We can observe that the trapezoidal method improves convergence speed by two times compared to the Riemann method, and Simpson's method improves convergence speed by four times compared to the trapezoidal method.

```r
I <- 0.746824132812427 # Curect Anwser

f <- function(x) exp(-x^2) # Target Function 
Inputs  <- sapply(2:9, function(x) 2**x) # Given Inputs from 4 to 512
Methods <- c("rect", "tri", "simp", "mtca") # Integrate Methods

result_df <- data.frame() # I save all results by empty Dataframe 
first <- TRUE # We can't cbind empty dataframe in first loop, so I set this
for(Method in Methods){ # loop by Methods
  results <- sapply(Inputs, 
                    function(x) my_integrate(f, 0, 1, x, 15, Method))
  if(first==FALSE){
    result_df <- cbind(result_df, results)
  }else{
    result_df <- results
    first <- FALSE
  }
}
rownames(result_df) <- Inputs
colnames(result_df) <- Methods

error_df <- result_df-I # error for results
ratio_df <- t(sapply(1:(length(Inputs)-1), # ratio for results
                     function(x) error_df[x+1,]/error_df[x,]))

rm(f, first, I, Inputs, Method, Methods, results)
```