---
authors : ["施承翰"]
title : "如何使用 R 處理 MongoDB 中的數據"
date : "2024-06-13"
summary : "使用 R 連線至本地端的 MongoDB，並透過實際的程式演示來進行資料庫的基本 CRUD 操作"
categories : [
    "NoSQL",
    "R",
]
tags : [
    "MongoDB",
]
series : ["MongoDB"]
---


接續我們前面所建構的 MongoDB Server，我在本篇文章中將介紹如何利用 R 連線至 MongoDB，並且透過實際的程式演示來進行 MongoDB 的連線與執行基本的 CRUD（創建、讀取、更新、刪除）操作。

首先我們需要安裝並載入 `mongolite` package，我們透過它進行 R 與 MongoDB 之間的連線。由於我們在上一篇文章中只有一個空的資料庫，為了能更好的演示，接下來我將以 R 內建的 iris 數據作為操作的範例。

```r
install.packages("mongolite")
library(mongolite)
```

安裝完 `mongolite` 後，我們可以先載入 iris 數據便於後續的操作。

```r
data(iris)
```

## 創建並寫入數據

首先我們在本地端的伺服器中創建了一個名為 mydatabase 的儲存空間，並創建了一個位於容器內，名稱為 iris 的資料表，並將這個目標位址資訊儲存在 target 這個變數中。接著我們利用 mongolite 中的 `insert` 函數將內建的 iris 資料表寫入目標位址中。

```r
target <- mongo(collection = "iris", db = "mydatabase", url = "mongodb://localhost")
target$insert(iris)
```

## 從資料庫中讀取

由於我們上面已經將目標位址儲存在 target 這個變數中，因此當我們需要調用他時，只需要使用 `find` 函數就可以找出目標位址的資料，同時我們可以使用 `head` 來查看前幾筆的資料，並確認資料有順利寫入至資料庫中，同時我們可以使用 `dim` 函數知道寫入的資料有150筆，變數有5個。

```r
iris_data <- target$find()
head(iris_data)

#   Sepal_Length Sepal_Width Petal_Length Petal_Width Species
# 1          5.1         3.5          1.4         0.2  setosa
# 2          4.9         3.0          1.4         0.2  setosa
# 3          4.7         3.2          1.3         0.2  setosa
# 4          4.6         3.1          1.5         0.2  setosa
# 5          5.0         3.6          1.4         0.2  setosa
# 6          5.4         3.9          1.7         0.4  setosa

dim(iris_data)

# [1] 150   5
```


## 對資料庫寫入新數據

若我們只是需要將新數據繼續寫入同一個資料表，那麼我們只需要鎖定位址後，繼續使用 `insert` 函數寫入即可，例如我們可以再執行一次下面的寫入操作，

```r
new_data <- data.frame(Sepal.Length = 5.0, Sepal.Width = 3.6, Petal.Length = 1.4, Petal.Width = 0.2, Species = "setosa")
target$insert(new_data)
```
完成寫入後，我們將得到一個在加入新資料後資料總筆數為151筆的資料表，同時我們可以用 `nrow` 函數確認資料的筆數確實有151筆。

```r
nrow(iris_data)

# [1] 151
```

## 更新資料表內的數據

但我們有時可能會想更新資料表中的部分數據，若是我們想根據特定條件來對局部符合條件的數據進行替換、覆蓋或刪除時，我們可以採用下面的做法：

### 替換數據

我們可以使用 `replace` 函數來替換資料表中「符合搜尋條件」的「第一筆」數據，下面是一個簡單的例子，讓我來簡單的說明他：

1. 我將要用於替換的數據使用 JSON 格式的字串存入 new_data 這個變數中。

2. query 這個變數是用於搜尋的索引條件，在這裡我們一樣需要使用 JSON 格式的字串來儲存。

3. 最後我們將上面新增的變數使用 `replace` 函數來替換資料表中的數據。

```r
new_data <- '{"Sepal_Length": 5.1, "Sepal_Width": 3.5, "Petal_Length": 1.4, "Petal_Width": 0.2, "Species": "versicolor"}'
query <- '{"Species": "setosa"}'

target$replace(query, new_data)
```

在完成替換後，我們可以透過下面的程式查詢替換後的結果，並可以發現第一筆數據的鳶尾花種類變成了 **versicolor**。

```r
iris_data <- target$find()
head(iris_data)

#   Sepal_Length Sepal_Width Petal_Length Petal_Width    Species
# 1          5.1         3.5          1.4         0.2 versicolor
# 2          4.9         3.0          1.4         0.2     setosa
# 3          4.7         3.2          1.3         0.2     setosa
# 4          4.6         3.1          1.5         0.2     setosa
# 5          5.0         3.6          1.4         0.2     setosa
# 6          5.4         3.9          1.7         0.4     setosa
```

### 覆蓋數據

面對一筆以上需要替換的數據，若我們使用 `replace` 來一一替換顯得十分沒有效率，這時我們可以透過 `update` 這個函數來實現批量操作的效果，下面是我的程式說明及範例程式碼：

1. 我將要用於替換的數據使用 JSON 格式的字串存入 renew 這個變數中，在這裡我加入了 "$set" 來幫助我索引替換的變數位址而不是將整個資料表的所有變數完全替換成單一值。

2. 在這裏同樣以 query 這個變數是用於搜尋的索引條件，同時也需要使用 JSON 格式的字串來儲存。

3. 最後我們將上面新增的變數使用 `update` 函數來替換資料表中的數據，與前面不同的是，我加入了 `multiple = TRUE` 這個參數來讓更新的操作對資料表中符合條件的所有資料都可以同步進行。

```r
renew <- '{"$set": {"Species": "virginica"}}'
query <- '{"Species": "setosa"}'

target$update(query, renew, multiple = TRUE)
```

在完成更新後我們也可以透過下面的程式查詢替換後的結果，並可以發現所有種類為setosa的鳶尾花，它們的種類均變成了 **virginica**。

```r
iris_data <- target$find()
head(iris_data)

#   Sepal_Length Sepal_Width Petal_Length Petal_Width    Species
# 1          5.1         3.5          1.4         0.2 versicolor
# 2          4.9         3.0          1.4         0.2  virginica
# 3          4.7         3.2          1.3         0.2  virginica
# 4          4.6         3.1          1.5         0.2  virginica
# 5          5.0         3.6          1.4         0.2  virginica
# 6          5.4         3.9          1.7         0.4  virginica
```

### 刪除數據

當我們想從資料表中移除所有滿足特定條件的資料時，我們可以使用 `remove` 函數來對資料庫進行操作，接著我們開始範例程式碼的說明：

1. 我們以 query 這個 JSON 格式的變數來設定要刪除資料的索引條件，同時也需要使用字串形式來儲存它。

2. 接著我們將上面鎖定的變數使用 `remove` 函數來移除資料表中的所有滿足條件之數據。

```r
query <- '{"Species": "virginica"}'

target$remove(query)
```

透過執行下面的程式，我們可以發現所有種類為 **virginica** 的鳶尾花均被從資料表中移除了。

```r
iris_data <- target$find()
head(iris_data)

#   Sepal_Length Sepal_Width Petal_Length Petal_Width    Species
# 1          5.1         3.5          1.4         0.2 versicolor
# 2          7.0         3.2          4.7         1.4 versicolor
# 3          6.4         3.2          4.5         1.5 versicolor
# 4          6.9         3.1          4.9         1.5 versicolor
# 5          5.5         2.3          4.0         1.3 versicolor
# 6          6.5         2.8          4.6         1.5 versicolor
```

## 移除整個資料表

在移除資料表前，我們先查詢 mydatabase 資料庫中有哪些資料表，並印出他們的名稱。我們可以看到裡面包含我們欲刪除的資料表 **iris**。

```r
db_connection <- mongo(url = "mongodb://localhost/mydatabase")

collections <- db_connection$run('{"listCollections":1}')
collection_names <- collections$cursor$firstBatch$name
print(collection_names)

# [1] "iris"
```

最後，當我們想要從資料庫中移除整個資料表，由于我們前面已經定義了變數 target 為 iris 資料表的位址，因此我們可以透過 `drop` 函數來將整個資料表從目標位址中移除，下面是簡單的程式範例：

```r
target$drop()
```

在移除完畢後，我們可以從下面的程式碼搜尋資料庫的指定位址中所有資料表的名稱，因為我們剛剛將位於 mydatabase 中的 iris 移除了，因此資料庫中已沒有其他資料表，故執行程式後會得到 NULL 的結果表示空值的意思。

```r
db_connection <- mongo(url = "mongodb://localhost/mydatabase")

collections <- db_connection$run('{"listCollections":1}')
collection_names <- collections$cursor$firstBatch$name
print(collection_names)

# NULL
```

到這裡我們便完成了在 R 中對 MongoDB 基本的 CRUD 操作。
