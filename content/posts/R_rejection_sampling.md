+++
authors = ["Shih Cheng Han"]
title = "Implementation of Rejection Sampling Methods"
date = "2022-03-11"
description = ""
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
Firstly, we need to define a target function `f` and specify a generation range `[a, b]`. Since we want to use `uniform(0, 1)` to generate samples that match the probability density of `f` in the `[a, b]` interval, we also need to provide the probability density function of the uniform distribution. The alpha constant is used to adjust the rejection probability to ensure that the generated samples conform to the target probability density function.

For each generated `x` value, we calculate the corresponding probability density ratio `test_x` and compare it with a random number `test_u` generated from `[0, 1]`. If `test_u` is less than or equal to `test_x`, the sample is accepted; otherwise, it is rejected.

```r
rejection_sampling <- function(f, g, alpha, a, b, n){ 
  total_n   <- 0
  accept_x  <- c()
  while(length(accept_x) < n){
    total_n <- total_n + 1
    x <- runif(1, a, b)
    test_x <- f(x) / (alpha * g(a, b)) 
    test_u <- runif(1, 0, 1) 
    if (test_u <= test_x){
      accept_x <- c(accept_x, x)
    }
  }
  return(list(c(length(accept_x), total_n), accept_x)) 
}
```

---

Next, we specify `f` in the `[-1, 1]` interval, generate 10,000 simulated data points with `alpha = pi`, and plot the results. The red line represents our target function `f`, while the gray area shows the histogram of the generated data.

```r
f <- function(x) pi/2*(sqrt(1-x^2))
unif_pdf <- function(a, b) 1/(b-a)
alpha <- pi
sampling <- rejection_sampling(f, unif_pdf, alpha, -1, 1, 10000)

area <- integrate(f, -1, 1)$value
hist(sampling[[2]], breaks = 15, probability = TRUE, 
     xlim = c(-1, 1), ylim = c(0, 0.8), xlab = "x", 
     main = paste0("Histogram of Sampling (alpha = " ,round(alpha, 2) ,")"))
curve(f(x) / area, from = -1, to = 1, 
      col = "red", lwd = 2, add = TRUE)

```
![Rplot.png](/images/R_rejection_sampling/Rplot.png)

---

Finally, let's compare the number of iterations required under different values of `alpha`. The plot below shows that after `alpha = pi`, the number of iterations required is proportional to `alpha`.

```r
alpha_vector <- c(1, pi/2, pi, 2*pi, 4*pi)
df <- data.frame()
for(alpha in alpha_vector){
  sampling <- rejection_sampling(f, unif_pdf, alpha, -1, 1, 10000)[[1]]
  df <- rbind(df, c(alpha, sampling[2]))
}
colnames(df) <- c("alpha", "iterations")
plot(df$alpha, df$iterations, type = "b", pch = 19, col = "blue",
     xlab = "Alpha", ylab = "Iterations",
     main = "Iterations vs Alpha")
```

![Rplot2.png](/images/R_rejection_sampling/Rplot2.png)

---

However, when `alpha < pi`, the generated probability density cannot cover the target function. The reason is that after calculating `f(x) / g(a, b)`, we get results in the `[-0.5, 0.5]` interval, while the maximum value of the function `f` is `pi/2`. Thus, if `alpha < pi`, the maximum value part of the function cannot be accepted, resulting in a probability density with a lower central portion and higher sides compared to the original.

![Rplot3.png](/images/R_rejection_sampling/Rplot3.png)
