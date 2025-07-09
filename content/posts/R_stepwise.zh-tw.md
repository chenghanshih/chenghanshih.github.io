---
authors : ["施承翰"]
title : "基於 F-value 的 Stepwise Model Selection"
date : "2024-06-09"
summary : "以 R 語言實作基於 F-value 的 Forward 及 Backward Stepwise Model Selection，並將其製作成函數及 package"
categories : [
    "R",
    "Mathematics",
]
tags : [
    "R function",
    "Forward Stepwise",
    "Backward Stepwise",
]
# series = ["Theme Demo"]
---

## Introduction

這篇文章是修改我碩一時所製作的 R 函數，當時我們的目標是想要以Ｒ語言實作基於 F-value 的 Forward 及 Backward Stepwise Model Selection，由於近期在使用上套用至部分資料會跑出錯誤訊息，因此在這裏做簡單的版本翻修，並新增進了設置停止區間的參數及支援顯示當前進度的訊息，接下來我會簡單講解這個函數的參數及使用方法，更詳細的資訊可以參考下面的 Github 連結。

{{< github repo="hans0803/APLM" >}}

---

### fselect 變數列表

**y** : 放置被預測的變量

**data** : 放置用於預測`y`的變數

**alpha_in** : 設置 alpha 值用於判斷變數的 SLR 的 p-value 是否符合將變數放入模型的標準

**alpha_out** : 設置 alpha 值用於判斷變數在模型中的 p-value 是否符合將變數變數從模型中移出的標準

**mode** : 可以選擇`forward`或`backward`兩種

**early_break_count** : 設置當變數連續進出模型指定次數時將會中斷變數挑選，為了避免特定幾個變數輪流加入移出模型造成無法結束迴圈的情況發生

---

### fselect 函數說明

我們透過 F-value 的 Forward 及 Backward Stepwise Model Selection 來對模型進行變數挑選，不同於Ｒ內建的 aic 選模，我們嘗試提供另一種變數挑選的方法，同時在變數挑選完畢後，我們會使用 Vif test 對被選入的變數進行一次初步的共線性檢查，確保模型的變數是可以被較好的解釋的。

面對僅有300個樣本，卻有6000個變數之類的高維度數據時，Ｒ內建的 aic 選模無法處理，但 fselect 支援對變數大於資料樣本時模型時的變數初步篩選，讓面對高維度數據時可以快速的縮小變數數目利於後續的特徵工程與建模。

完整的 package 在 R 中透過以下指令下載：

```r
if(!require(devtools)) install.packages("devtools")
devtools::install_github("hans0803/APLM")
```

---

## Code

在文末附上完整的函數。

```r
fselect <- function(y, data, alpha_in=0.01, alpha_out=0.05, mode="forward", early_break_count=10){
  if(mode=="forward"){
    # start
    {
      # Set alpha, in < out
      # define in and out set to save who should in model now
      df_in  <- data.frame()
      df_out <- data
      # Get the variable num and define no ones in df_in model
      out_width <- ncol(df_out)
      in_width  <- 0
      # loop run condition
      continue <- TRUE
      break_count <- 0
      who_in  <- ''
      who_out <- ''
    }
    
    while(continue){
      # when we into the loop, set continue = FALSE
      continue <- FALSE
      # create note and check it
      {
        # Create the empty vector to save names, F-values, P-values
        C_names <- c(); F_value <- c(); P_value <- c()
        # Do i times SLR create the information data.frame "note"
        for(i in 1:out_width){
          choose_data <- as.data.frame(df_out[,i])
          if(in_width!=0){
            test_f <- cbind(df_in, choose_data)
          }else{
            test_f <- choose_data
          }
          fit <- lm(y ~ ., test_f)
          aov <- anova(fit)
          C_names[i] <- colnames(df_out[i])
          F_value[i] <- aov$`F value`[in_width+1]
          P_value[i] <- aov$`Pr(>F)`[in_width+1]
        }
        note <- data.frame(name=C_names, F_value=F_value, P_value=P_value)
        # Find whos F-value is biggest and take it P-value
        max_F <- max(note$F_value)
        max_Fvar <- which(note$F_value==max_F)[1]
        alpha_test <- as.numeric(note$P_value[max_Fvar])
        
      }
      print(alpha_test)
      # if it pass the check, add in and drop out
      {
        # Catch it in to model
        if(alpha_test <= alpha_in){
          # if the biggest F-value variable can be catch, we set countinue = TRUE
          continue <- TRUE
          # get the biggest F-value variable
          who_catch  <- note$name[max_Fvar]
          catch_var  <- which(colnames(df_out)==who_catch)
          catch_data <- as.data.frame(df_out[, catch_var])
          colnames(catch_data) <- who_catch
          # find it and add it from the df_out data.frame
          if(in_width!=0){
            df_in <- cbind(catch_data, df_in)
          }else{
            df_in <- as.data.frame(catch_data)
            colnames(df_in) <- who_catch
          }
          # find who into the df_in, and delete it from df_out
          if(out_width!=1){
            df_out[, who_catch] <- c()
          }else{
            df_out <- data.frame()
          }
          # since one variable move to df_in from df_out, change the width of df
          out_width <- out_width-1
          in_width  <- in_width +1
          cat('in:', in_width, '/ out:', out_width, ':', who_catch, '(IN) \n')
        }
      }
      who_in <- who_catch
      
      if(who_in==who_out){
        break_count <- break_count + 1
      }else{
        break_count <- 0
      }
      if(break_count > early_break_count){
        message_var <- paste("Break warning by variable in=out")
        warning(message_var)
        break
      }
      
      # stepwise part start
      # check df_in variable > 1
      if(in_width > 1){
        # delete this loop new variable
        if(in_width!=2){
          step_df <- df_in[,-1]
        }else{
          save_name <- colnames(df_in)[2]
          step_df <- as.data.frame(df_in[,-1])
          colnames(step_df) <- save_name
        }
        # create information of df_in model to "forward_note"
        forward_fit <- lm(y ~ ., step_df)
        # use another ones to anova
        forward_aov <- anova(forward_fit)
        C_names <- colnames(step_df)
        F_value <- forward_aov$`F value`[1:in_width-1] # in_width-1, since we delete this loop new variable
        P_value <- forward_aov$`Pr(>F)`[1:in_width-1] # in_width-1, since we delete this loop new variable
        forward_note <- data.frame(name=C_names, F_value=F_value, P_value=P_value)
        # Find whos F-value is smallest and take it P-value
        min_F <- min(forward_note$F_value)
        min_Fvar <- which(forward_note$F_value==min_F)[1]
        print(forward_note$name[min_Fvar])
        alpha_test <- as.numeric(forward_note$P_value[min_Fvar])
        print(alpha_test)
        
        if(alpha_test > alpha_out){
          # if the smallest F-value variable can be drop, we set countinue = TRUE
          continue <- TRUE
          # get the smallest F-value variable
          who_catch <- forward_note$name[min_Fvar]
          drop_var  <- which(colnames(df_in)==who_catch)
          drop_data <- as.data.frame(df_in[, drop_var])
          colnames(drop_data) <- who_catch
          # find it and add it to the df_out data.frame
          if(out_width!=0){
            df_out <- cbind(drop_data, df_out)
          }else{
            df_out <- drop_data
          }
          # find who into the df_out, and delete it from df_in
          df_in[, drop_var] <- c()
          # since one variable move to df_out from df_in, change the width of df
          out_width <- out_width+1
          in_width  <- in_width -1
          cat('in:', in_width, '/ out:', out_width, ':', who_catch, '(OUT) \n')
        }
      }
      who_out <- who_catch
      
      # stepwise part end
     
      # if no any variable in df_out, stop loop
      if(out_width==0){
        break
      }
    }
  }
  if(mode=="backward"){
    # start
    {
      # Set alpha, in < out
      # define in and out set to save who should in model now
      df_in  <- data
      df_out <- data.frame()
      
      save <- alpha_in
      alpha_in  <- alpha_out
      alpha_out <- save
      
      # Get the variable num and define no ones in df_in model
      out_width <- 0
      in_width  <- ncol(df_in)
      
      # loop run condition
      continue <- TRUE
      break_count <- 0
      who_in  <- ''
      who_out <- ''
    }
    
    while(continue){
      # when we into the loop, set continue = FALSE
      continue <- FALSE
      
      # create note and check it
      {
        fit <- lm(y ~ ., df_in)
        aov <- anova(fit)
        # Create the  vector to save names, F-values, P-values
        C_names <- colnames(df_in)
        F_value <- aov[-(in_width+1),4]
        P_value <- aov[-(in_width+1),5]
        note <- data.frame(name=C_names, F_value=F_value, P_value=P_value)
        # Find whos F-value is smallst and take it P-value
        min_F <- min(note$F_value)
        min_Fvar <- which(note$F_value==min_F)
        alpha_test <- as.numeric(note$P_value[min_Fvar])
      }
      
      # if it pass the check, add in and drop out
      {
        # Drop it out to model
        if(alpha_test > alpha_in){
          # if the biggest F-value variable can be catch, we set countinue = TRUE
          continue <- TRUE
          # get the biggest F-value variable
          who_catch <- note$name[min_Fvar]
          drop_var  <- which(colnames(df_in)==who_catch)
          drop_data <- as.data.frame(df_in[, drop_var])
          colnames(drop_data) <- who_catch
          # find it and add it from the df_out data.frame
          if(out_width!=0){
            df_out <- cbind(drop_data, df_out)
          }else{
            df_out <- as.data.frame(drop_data)
            colnames(df_out) <- who_catch
          }
          # find who into the df_in, and delete it from df_out
          if(in_width!=1){
            df_in[, who_catch] <- c()
          }else{
            df_in <- data.frame()
          }
          # since one variable move to df_in from df_out, change the width of df
          out_width <- out_width+1
          in_width  <- in_width -1
          cat('in:', in_width, '/ out:', out_width, ':', who_catch, '(OUT) \n')
        }
      }
      who_out <- who_catch
      
      if(who_in==who_out | in_width){
        break_count <- break_count + 1
      }else{
        break_count <- 0
      }
      if(break_count > early_break_count){
        message_var <- paste("Break warning by variable in=out")
        warning(message_var)
        break
      }
      
      # stepwise part start
      # check df_out variable > 1
      if(out_width > 1){
        # delete this loop new variable
        if(out_width!=2){
          step_df <- df_out[,-1]
        }else{
          save_name <- colnames(df_out)[2]
          step_df <- as.data.frame(df_out[,-1])
          colnames(step_df) <- save_name
        }
        # create information of df_out model to "backward_note"
        forward_fit <- lm(y ~ ., step_df)
        # use another ones to anova
        forward_aov <- anova(forward_fit)
        C_names <- colnames(step_df)
        F_value <- forward_aov$`F value`[1:out_width-1] # out_width-1, since we delete this loop new variable
        P_value <- forward_aov$`Pr(>F)`[1:out_width-1] # out_width-1, since we delete this loop new variable
        backward_note <- data.frame(name=C_names, F_value=F_value, P_value=P_value)
        # Find whos F-value is biggest and take it P-value
        max_F <- max(backward_note$F_value)
        max_Fvar <- which(backward_note$F_value==max_F)
        alpha_test <- as.numeric(backward_note$P_value[max_Fvar])
        
        if(alpha_test <= alpha_out){
          # if the biggest F-value variable can be catch, we set countinue = TRUE
          continue <- TRUE
          # get the smallest F-value variable
          who_catch  <- backward_note$name[max_Fvar]
          catch_var  <- which(colnames(df_out)==who_catch)
          catch_data <- as.data.frame(df_out[, catch_var])
          colnames(catch_data) <- who_catch
          # find it and add it to the df_in data.frame
          if(in_width!=0){
            df_in <- cbind(catch_data, df_in)
          }else{
            df_in <- catch_data
          }
          # find who into the df_in, and delete it from df_out
          df_out[, catch_var] <- NULL
          # since one variable move to df_in from df_out, change the width of df
          out_width <- out_width-1
          in_width  <- in_width +1
          cat('in:', in_width, '/ out:', out_width, ':', who_catch, '(IN) \n')
        }
      }
      who_in <- who_catch
      
      # stepwise part end
      
      # if no any variable in df_out, stop loop
      if(out_width==0){
        break
      }
    }
  }
  # vif check part
  {
    fit <- lm(y ~ ., df_in)
    vif_value <- as.data.frame(car::vif(fit))
    who_catch <- vif_value[vif_value[,1]==max(vif_value),]
    name <- rownames(vif_value)[which(vif_value[,1]==who_catch)]
    
    if(vif_value[which(vif_value[,1]==who_catch),1]>=10){
      message_vif <- paste(name, "have 'Severe' Multicollinearity problem")
      warning(message_vif)
    }else if(vif_value[which(vif_value[,1]==who_catch),1]>=5){
      message_vif <- paste(name, "maybe have Multicollinearity problem")
      warning(message_vif)
    }else{
      print("Vif test pass!")
    }
    
  }
  return(fit)
}
```