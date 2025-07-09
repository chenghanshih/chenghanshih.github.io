---
authors : ["施承翰"]
title : "多種積分函數實作"
date : "2022-02-25"
summary : "使用黎曼積分法、梯形積分法、辛普森積分法及蒙地卡羅積分法來模擬程式計算積分的過程"
categories : [
    "R",
    "Mathematics",
]
tags : [
    "Simulation",
    "Intergral",
]
# series = ["Theme Demo"]
---

這裏我們將使用黎曼積分法、梯形積分法、辛普森積分法及蒙地卡羅積分法來實作他，下面是他們分別簡單的介紹。

1. **黎曼積分法**：將給定區間等分成 n 條小區間，然後計算每個小區間的函數值乘以小區間的寬度，再將這些乘積相加得到積分值。
2. **梯形積分法**：將給定區間等分成 n 條小區間，然後計算每個相鄰小區間的函數值乘以相鄰小區間的平均寬度，再將這些乘積相加得到積分值。
3. **辛普森積分法**：將給定區間等分成 n 條小區間，然後使用三點法，將相鄰小區間的函數值組合成一個曲線，再將這些曲線下面積的估計值相加得到積分值。
4. **蒙特卡羅積分法**：通過在給定區間內生成隨機數，計算這些隨機點對應函數值的平均，再乘以區間寬度，得到積分值的估計。

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

下面我們分別將他們的積分結果、誤差及函數收斂的速度存儲在一個 data.frame 中。通過這些結果，可以比較不同方法在不同情況下的性能表現。我們可以從中看出，梯形法相較黎曼和的收斂速度提升了兩倍，而辛普森更是梯形法收斂速度的四倍。

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