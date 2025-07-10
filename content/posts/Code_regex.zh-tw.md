---
authors : ["施承翰"]
title : "使用正則表達式在 R 語言中挖掘文本資訊"
date : "2024-06-19"
summary : "關於正則表達式在資料處理中的用法及示例"
categories : [
    "programming",
]
tags : [
    "r",
    "regex",
    "text-mining",
]
series : ["Regex"]

---

正則表達式（Regular Expressions，簡稱 regex）是一種強大的文本處理工具，允許開發者以高度靈活和效率的方式搜索、替換、分析和操作文本數據。在資料科學領域，正則表達式提供了一種解析大規模數據集、清洗數據和提取有價值信息的有效方法。

正則表達式是用於描述字符串匹配模式的語言。它們主要用於字符串搜尋和替換操作，支持一些特定的語法規則，讓用戶能夠定義一個或多個匹配的規則。在資料科學中，正則表達式尤其重要，它們可以快速地從大量的文本數據中提取有用的信息，進而被廣泛地運用在許多程式語言中，並在不同的地方扮演著不同的角色，例如從日誌文件中提取日期和時間信息，或從社交媒體數據中識別和提取特定的話題標籤，甚至我們日常所使用的密碼設置時的大小寫識別等。若是沒有程式編譯環境，也可以透過[regex101](https://regex101.com)這個網站來進行正則表達式的練習。

本篇文章會簡單說明關於正則表達式的語法及應用，並且再以 R 做簡單的程式上使用的舉例。

## 基本搜索

首先對於 R 的字串處理我們需要載入 `stringr` 這個 package，它是一個對於在 R 環境中進行文字探勘十分重要的套件。

```r
install.packages("stringr")
library(stringr)
```

---

### `?`

在這個符號前的字符代表可有可無的意思，以下面為例，若我們想在句子中抓取包含 use 的詞，我們可以透過在 d 後面加入 `?` 來使 use 的變體 used。

```r
sentence <- "use a used variable name is illegal."
str_extract_all(sentence, "used?")

# [[1]]
# [1] "use"  "used"
```

---

### `*`

若是我們在搜索條件中加入這個條件，則代表在搜尋字串時需同時滿足三個條件才會被匡列成搜索對象：

1. 在搜索時除了不能出現其他字符外， * 前的字符只需「不需出現」、「出現一次」或「出現多次」其中之一即可。
    
2. 滿足前後字符的條件。
    
以下面的例子來說，我們可以看到不論 b 出現多少次，都能正確的被正則表達式切割並抓取滿足條件之部分。但若是中間是 d，則因爲我們規定 a 和 c 中間只能出現零到多個 b，並不能出現其他字符，因此該字串不會被搜索。

```r
sentence <- c("acd, abc, abbbbbcddddc, adc, addddddc")
str_extract_all(sentence, "ab*c")

# [[1]]
# [1] "ac"       "abc"      "abbbbbc"
```

---

### `+`

與上面不同的是，若我們希望 * 前的字符最少需出現一次，則我們可以使用 + 來做搜尋。下面是一個簡單的例子，我們可以看到在下面相較於上面的搜尋結果而言，'acd' 因為中間沒有 b 而沒有被抓取出。

```r
sentence <- c("acd, abc, abbbbbcddddc, adc, addddddc")
str_extract_all(sentence, "ab+c")

# [[1]]
# [1] "abc"     "abbbbbc"
```

---


### `()`

若是我們想在正則表達式中組合條件，我們可以使用 () 來達成需求，首先我們先來看到關於合併檢索的部分，下面是一個將 ab 組合後搜尋的例子，我們可以得到滿足大於等於出現一次 ab 條件的字符串。

```r
sentence <- c("acd, ababc, abbbc, abababbbcddddc, adc, adadddddc")
str_extract_all(sentence, "(ab)+")

# [[1]]
# [1] "abab"   "ab"     "ababab"
```

接著我們也可以透過加入 | 來執行搜索中「或」的操作，例如當我們想要得到大於等於出現一次 ab 或 ad 條件的字符串時可以進行下面的操作。

```r
sentence <- c("acd, ababc, abbbc, abababbbcddddc, adc, adadddddc")
str_extract_all(sentence, "(ab|ad)+")

# [[1]]
# [1] "abab"   "ab"     "ababab" "ad"     "adad"
```

---

### `{}`

在這裡若是我們想定義字符中出現的精確次數，我們可以透過加入 {} 及數字來做搜索。下面是一個簡單的範例。

```r
sentence <- c("acd, abbc, abbbc, abbbbbcddddc, adc, addddddc")
str_extract_all(sentence, "ab{2}c")

# [[1]]
# [1] "abbc"
```

而若是我們希望有一個搜索的範圍，我們可以在 {} 中加入區間來做範圍搜索。若我們想從段落中擷取出現 0~3 次 b 的字串，則簡單的範例如下。

```r
sentence <- c("acd, abbc, abbbc, abbbbbcddddc, adc, addddddc")
str_extract_all(sentence, "ab{0,3}c")

# [[1]]
# [1] "ac"    "abbc"  "abbbc"
```

同時我們希望指定一個搜索的方向，我們也可以在 {} 中只放入範圍的上界或下界來做搜索。若我們想從段落中擷取出現大於等於 3 次 b 的字串，我們可以進行如下的操作。

```r
sentence <- c("acd, abbc, abbbc, abbbbbcddddc, adc, addddddc")
str_extract_all(sentence, "ab{3,}c")

# [[1]]
# [1] "abbbc"   "abbbbbc"
```

---

### `[]`

若是我們想要搜索滿足特定字符條件的字串，我們可以使用 [] 來篩選字符，其中 `a-z` 與 `A-Z` 分別為代表大小寫字母的字符串，而 `0-9` 是代表數字的字符串。下面是我們的範例演示。

```r
sentence <- "abc, tiger, aabbcc, dog, 1234678, abc123456, ABCDEFG"
str_extract_all(sentence, "[a-z]+")

# [[1]]
# [1] "abc"    "tiger"  "aabbcc" "dog"    "abc"   
```

```r
sentence <- "abc, tiger, aabbcc, dog, 1234678, abc123456, ABCDEFG"
str_extract_all(sentence, "[A-Z]+")

# [[1]]
# [1] "ABCDEFG"
```

```r
sentence <- "abc, tiger, aabbcc, dog, 1234678, abc123456, ABCDEFG"
str_extract_all(sentence, "[0-9]+")

# [[1]]
# [1] "1234678" "123456" 
```

同時若是要將條件混用只需將條件一同輸入即可。

```r
sentence <- "abc, tiger, aabbcc, dog, 1234678, abc123456, ABCDEFG"
str_extract_all(sentence, "[A-Z0-9]+")

# [[1]]
# [1] "1234678" "123456"  "ABCDEFG"
```

---

### `^`

若我們要添加除外的搜索條件，只需在條件前加上 ^ 即可，下面是在句子中剔除包含數字逗號及空格的表示法。


```r
sentence <- "abc, tiger, aabbcc, dog, 1234678, abc123456, ABCDEFG"
str_extract_all(sentence, "[^0-9^,^ ]+")

# [[1]]
# [1] "abc"     "tiger"   "aabbcc"  "dog"     "abc"     "ABCDEFG"
```

---

## 元字符

在正則表達式中，我們一樣可以透過加入元字符來做條件的搜索，下面是一些常見的元字符及其定義，它們一樣可以透過加入上面的基本搜索來豐富我們的字串查詢系統。

| 字符  | 定義                            |
| ---- | ------------------------------ |
| `\d` | 代表數字字符，意思等同於 `[0-9]`   |
| `\w` | 代表單詞字符，泛指英文、數字、下滑線 |
| `\s` | 代表空白及換行字符                |
| `\D` | 代表非數字字符，意思等同於 `^[0-9]` |
| `\W` | 代表非單詞字符                    |
| `\s` | 代表非空白及換行字符               |
| `.`  | 代表任意字符，但不包含換行字符      |

---

透過這些簡單的正則表達式語法，我們可以很好的運用它們在 R 語言中進行文字資訊的抓取，接下來我們會在下一篇文章中提到關於正則表達式的進階應用。