---
authors : ["施承翰"]
title : "解決 Excel 寫入系統保留字元時導致的錯誤"
date : "2024-07-12"
summary : "我們將在這篇文章中說明及解決在使用 R 寫入文本大數據至 Excel 時遇到的檔案損毀問題"
categories : [
    "programming",
]
tags : [
    "r",
    "data-processing",
]

---

## 遇到的問題

最近我在透過 R 寫入 Excel 數據時，由於資料中意外含有系統保留字元時會導致檔案無法正常讀取，造成檔案損毀的發生，因此衍生出了這篇文章，在這裡我們透過篩選出造成異常狀況的字元並移除它來避免這一結果。

如要複現錯誤訊息可以透過下面的程式碼產生與我遇到一樣問題的 Excel：

``` r
library(openxlsx)
write.xlsx("\uffff", "test.xlsx")
```

但須注意該字串本身無法被作為變量命名至變數中，但可以透過讀取 csv 等檔案來寫入。

---

## 程式碼解說

接著我為了解決問題而編寫了下面的程式碼，透過下面的程式可以將輸入的字串轉換為沒有問題的字串。

程式碼的運作邏輯大致可以拆解成下面的步驟：

1. 定義要剔除範圍的字元，並將他們編寫成一個檢索函數

2. 初始化一個空的字符向量用於儲存後續處理的字串

3. 透過逐個字符轉換為字符向量來檢查字串，並將不需剔除的字元保留下來

4. 將被轉換的字符向量轉換為修正後的字符串並回傳


```r
remove_reserved_characters <- function(input_string) {

  is_reserved <- function(codepoint) {
    return(
      (codepoint >= 0x0001 && codepoint <= 0x001F) ||
        (codepoint == 0x007F) ||
        (codepoint >= 0x0080 && codepoint <= 0x009F) ||
        (codepoint >= 0xD800 && codepoint <= 0xDFFF) ||
        (codepoint >= 0xFDD0 && codepoint <= 0xFDEF) ||
        (codepoint >= 0xE000 && codepoint <= 0xF8FF) ||
        (codepoint >= 0xF0000 && codepoint <= 0xFFFFD) ||
        (codepoint >= 0x100000 && codepoint <= 0x10FFFD) ||
        (codepoint == 0xFFFF)
    )
  }
  
  result <- integer()
  
  chars <- strsplit(input_string, NULL)[[1]]
  valid_chars <- sapply(chars, function(char) {
    codepoint <- utf8ToInt(char)
    if (length(codepoint) == 1 && !is.na(codepoint) && !is_reserved(codepoint)) {
      return(char)
    } else {
      return(NA)
    }
  })

  cleaned_string <- paste(valid_chars[!is.na(valid_chars)], collapse = "")
  return(cleaned_string)
}
```

---

## 程式碼應用

在宣告上面的函數後，我們可以透過下面的程式碼來清除 data.frame 中目標欄位的問題字元：

``` r
d <- read.csv("/Users/hans/Downloads/textcsvdata.csv")

test <- sapply(d$content, remove_reserved_characters, USE.NAMES = FALSE)

write.xlsx(d, "test.xlsx")
```

同時，若是運算環境有餘裕可以開啟平行運算，在 R 中我們使用 parallel package 來達到這個效果，可以將上面的程式碼替換成下面的模塊，透過平行運算可以大幅度得縮短運算時間。

``` r
library(parallel)
library(doParallel)

d <- read.csv("/Users/hans/Downloads/textcsvdata.csv")

cl <- makeCluster(detectCores() - 1)

registerDoParallel(cl)

test <- foreach(x = d$content, .combine = c, .packages = c('parallel')) %dopar% remove_reserved_characters(x)

stopCluster(cl)

write.xlsx(d, "test.xlsx")
```