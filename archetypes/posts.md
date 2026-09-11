---
authors : ["Hank Shih"]
title : "{{ replace .Name "-" " " | title }}"
date : "{{ .Date | dateFormat "2006-01-02" }}"
summary : "在這裡寫下文章的摘要說明"
categories : [
    "程式設計",  # 可選：資料科學、程式設計、資料庫、網站開發、數學統計
]
tags : [
    "R語言",     # 可選：R語言、Python、SQL、MongoDB、Flask、統計模擬、資料視覺化、正則表達式、數值計算、機器學習
]
series : [""]
draft : false
---

## 介紹

在這裡撰寫你的文章內容...

## 主要內容

### 子標題

更多內容...

```python
# 範例程式碼
def example():
    print("Hello, World!")
```

## 結論

文章的結論... 