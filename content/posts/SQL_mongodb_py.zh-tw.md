---
authors : ["施承翰"]
title : "如何使用 Python 處理 MongoDB 中的數據"
date : "2024-06-14"
summary : "以 Python 連線至本地端的 MongoDB，並且結合 pandas 來演示基本的 CRUD 操作"
categories : [
    "NoSQL",
    "Python",
]
tags : [
    "MongoDB",
]
series : ["MongoDB"]
---


這是 MongoDB 的第三篇，我在本篇文章中將介紹如何利用 Python 連線至 MongoDB，並且一樣透過實際的程式演示來進行操作。

首先我們需要先透過 pip 安裝 `pymongo` 我們透過它進行 Python 與 MongoDB 之間的連線，接著我們需要透過安裝 `scikit-learn` 來取得 iris 數據，scikit-learn 是一個關於在 Python 中運行機器學習的框架，其中也包含一些用於示範的資料，而 iris 數據便是其中之一，不過在這篇文章中我們只會將其用來做示範資料的讀取。最後我們需要安裝 `pandas` 來做資訊處理便於演示，pandas 是個在 Python 中負責資料處理的模塊，它擴充了原本不足的資料分析領域的功能。


```bash
pip install pymongo
pip install scikit-learn
pip install pandas
```

安裝完 `pymongo` 及 `scikit-learn` 後，我們可以先載入在 Python 中載入 iris 數據並將其轉換成 DataFrame 的格式便於後續的操作。

```python
from pymongo import MongoClient
from sklearn.datasets import load_iris

iris = load_iris()
iris_df = pd.DataFrame(data=iris.data, columns=iris.feature_names)
iris_df['species'] = pd.Categorical.from_codes(iris.target, iris.target_names)
print(iris_df.head())
```

## 創建並寫入數據

首先我們在本地端的伺服器中創建了一個名為 mydatabase 的儲存空間，並創建了一個位於容器內，名稱為 iris 的資料表，並將這個目標位址資訊儲存在 target 這個變數中。

```python
client = MongoClient("mongodb://localhost:27017/")
db = client["mydatabase"]
target = db["iris"]
```

接著我們使用 pandas 中的 `to_dict("records")` 將原本的 DataFrame 轉換成 Dict 的 Key-Value 形式，便於將資料寫入 NoSQL 中，然後我們便可以用 pymongo 中的 `insert_many` 函數將 iris 資料表的所有內容寫入目標位址了。

```python
iris_dict = iris_df.to_dict("records")
target.insert_many(iris_dict)
```
## 從資料庫中讀取

由於我們上面已經將目標位址儲存在 target 這個變數中，因此當我們需要調用他時，只需要使用 pymongo 中的 `find` 函數就可以找出目標位址的資料，同時我們可以使用 `limit` 來限制查找的筆數，確認資料有順利寫入至資料庫中。

```python
print("Inserted data:")
for doc in target.find().limit(6):
    print(doc)

# Inserted data:
# {'_id': ObjectId('666bc5c379402ab306210638'), 'sepal length (cm)': 5.1, 'sepal width (cm)': 3.5, 'petal length (cm)': 1.4, 'petal width (cm)': 0.2, 'species': 'setosa'}
# {'_id': ObjectId('666bc5c379402ab306210639'), 'sepal length (cm)': 4.9, 'sepal width (cm)': 3.0, 'petal length (cm)': 1.4, 'petal width (cm)': 0.2, 'species': 'setosa'}
# {'_id': ObjectId('666bc5c379402ab30621063a'), 'sepal length (cm)': 4.7, 'sepal width (cm)': 3.2, 'petal length (cm)': 1.3, 'petal width (cm)': 0.2, 'species': 'setosa'}
# {'_id': ObjectId('666bc5c379402ab30621063b'), 'sepal length (cm)': 4.6, 'sepal width (cm)': 3.1, 'petal length (cm)': 1.5, 'petal width (cm)': 0.2, 'species': 'setosa'}
# {'_id': ObjectId('666bc5c379402ab30621063c'), 'sepal length (cm)': 5.0, 'sepal width (cm)': 3.6, 'petal length (cm)': 1.4, 'petal width (cm)': 0.2, 'species': 'setosa'}
# {'_id': ObjectId('666bc5c379402ab30621063d'), 'sepal length (cm)': 5.4, 'sepal width (cm)': 3.9, 'petal length (cm)': 1.7, 'petal width (cm)': 0.4, 'species': 'setosa'}
```

## 對資料庫寫入新數據

若我們需要將一筆新數據繼續寫入同一個資料表，那麼我們只需要鎖定位址後，繼續使用 `insert_one` 函數寫入即可，例如我們可以再執行一次下面的寫入操作，

```python
new_data = {
    "sepal length (cm)": 5.0,
    "sepal width (cm)": 3.6,
    "petal length (cm)": 1.4,
    "petal width (cm)": 0.2,
    "species": "setosa"
}
target.insert_one(new_data)

# InsertOneResult(ObjectId('666be4ee79402ab3062106ce'), acknowledged=True)
```
完成寫入後，我們將得到一個在加入新資料後資料總筆數為151筆的資料表，同時我們一樣可以可以用函數確認資料的筆數確實有151筆。

```python
count = target.count_documents({})
print(f"Total number of documents: {count}")

# Total number of documents: 151
```

## 更新資料表內的數據

但我們有時可能會想更新資料表中的部分數據，若是我們想根據特定條件來對局部符合條件的數據進行替換、覆蓋或刪除時，我們可以採用下面的做法：

### 替換單筆數據

不同於 R，在 Python 中我們可以分別使用 `replace_one` 函數來替換資料表中「符合搜尋條件」的「第一筆」數據，下面是一個簡單的例子，讓我來簡單的說明他：

1. 我將要用於替換的數據使用 Dict 的 Key-Value 格式存入 new_data 這個變數中。

2. query 這個變數是用於搜尋的索引條件，在這裡我們一樣需要使用 Dict 的 Key-Value 格式來儲存。

3. 最後我們將上面新增的變數使用 `replace_one` 函數來替換資料表中的數據。

```python
new_data = {
    "sepal length (cm)": 5.1,
    "sepal width (cm)": 3.5,
    "petal length (cm)": 1.4,
    "petal width (cm)": 0.2,
    "species": "versicolor"
}
query = {"species": "setosa"}

result = target.replace_one(query, new_data)
```

在完成替換後，我們可以透過下面的程式查詢替換後的結果，並可以發現第一筆數據的鳶尾花種類變成了 **versicolor**。

```python
print("Data after replacement:")
for doc in target.find().limit(6):
    print(doc)

# Data after replacement:
# {'_id': ObjectId('666bc5c379402ab306210638'), 'sepal length (cm)': 5.1, 'sepal width (cm)': 3.5, 'petal length (cm)': 1.4, 'petal width (cm)': 0.2, 'species': 'versicolor'}
# {'_id': ObjectId('666bc5c379402ab306210639'), 'sepal length (cm)': 4.9, 'sepal width (cm)': 3.0, 'petal length (cm)': 1.4, 'petal width (cm)': 0.2, 'species': 'setosa'}
# {'_id': ObjectId('666bc5c379402ab30621063a'), 'sepal length (cm)': 4.7, 'sepal width (cm)': 3.2, 'petal length (cm)': 1.3, 'petal width (cm)': 0.2, 'species': 'setosa'}
# {'_id': ObjectId('666bc5c379402ab30621063b'), 'sepal length (cm)': 4.6, 'sepal width (cm)': 3.1, 'petal length (cm)': 1.5, 'petal width (cm)': 0.2, 'species': 'setosa'}
# {'_id': ObjectId('666bc5c379402ab30621063c'), 'sepal length (cm)': 5.0, 'sepal width (cm)': 3.6, 'petal length (cm)': 1.4, 'petal width (cm)': 0.2, 'species': 'setosa'}
# {'_id': ObjectId('666bc5c379402ab30621063d'), 'sepal length (cm)': 5.4, 'sepal width (cm)': 3.9, 'petal length (cm)': 1.7, 'petal width (cm)': 0.4, 'species': 'setosa'}
```

### 覆蓋數據

面對一筆以上需要替換的數據，若我們使用 `replace_one` 來一一替換顯得十分沒有效率，這時我們可以透過 `update＿many` 這個函數來實現批量操作的效果，下面是我的程式說明及範例程式碼：

1. 我將要用於替換的數據使用 Dict 格式的字串存入 update_data 這個變數中。

2. 在這裏同樣以 query 這個變數是用於搜尋的索引條件，同時也需要使用 Dict 格式的字串來儲存。

3. 最後我們將上面新增的變數使用 `update_many` 函數來同時替換資料表中符合條件的所有資料。

```python
query = {"species": "setosa"}
update_data = {"$set": {"species": "virginica"}}

result = target.update_many(query, update_data)
```

在完成更新後我們也可以透過下面的程式查詢替換後的結果，並可以發現所有種類為setosa的鳶尾花，它們的種類均變成了 **virginica**。

```python
print("Data after update:")
for doc in target.find().limit(6):
    print(doc)

# Data after update:
# {'_id': ObjectId('666bc5c379402ab306210638'), 'sepal length (cm)': 5.1, 'sepal width (cm)': 3.5, 'petal length (cm)': 1.4, 'petal width (cm)': 0.2, 'species': 'versicolor'}
# {'_id': ObjectId('666bc5c379402ab306210639'), 'sepal length (cm)': 4.9, 'sepal width (cm)': 3.0, 'petal length (cm)': 1.4, 'petal width (cm)': 0.2, 'species': 'virginica'}
# {'_id': ObjectId('666bc5c379402ab30621063a'), 'sepal length (cm)': 4.7, 'sepal width (cm)': 3.2, 'petal length (cm)': 1.3, 'petal width (cm)': 0.2, 'species': 'virginica'}
# {'_id': ObjectId('666bc5c379402ab30621063b'), 'sepal length (cm)': 4.6, 'sepal width (cm)': 3.1, 'petal length (cm)': 1.5, 'petal width (cm)': 0.2, 'species': 'virginica'}
# {'_id': ObjectId('666bc5c379402ab30621063c'), 'sepal length (cm)': 5.0, 'sepal width (cm)': 3.6, 'petal length (cm)': 1.4, 'petal width (cm)': 0.2, 'species': 'virginica'}
# {'_id': ObjectId('666bc5c379402ab30621063d'), 'sepal length (cm)': 5.4, 'sepal width (cm)': 3.9, 'petal length (cm)': 1.7, 'petal width (cm)': 0.4, 'species': 'virginica'}
```

### 刪除數據

當我們想從資料表中移除所有滿足特定條件的資料時，我們可以使用 `delete_many` 函數來對資料庫進行操作，接著我們開始範例程式碼的說明：

1. 我們以 query 這個 Dict 格式的變數來設定要刪除資料的索引條件，同時也需要使用字串形式來儲存它。

2. 接著我們將上面鎖定的變數使用 `delete_many` 函數來移除資料表中的所有滿足條件之數據。

```python
query = {"species": "virginica"}

result = target.delete_many(query)
```

透過執行下面的程式，我們可以發現所有種類為 **virginica** 的鳶尾花均被從資料表中移除了。

```python
print("Remaining data:")
for doc in target.find().limit(6):
    print(doc)
print(f"Documents deleted: {result.deleted_count}")

# Remaining data:
# {'_id': ObjectId('666bc5c379402ab306210638'), 'sepal length (cm)': 5.1, 'sepal width (cm)': 3.5, 'petal length (cm)': 1.4, 'petal width (cm)': 0.2, 'species': 'versicolor'}
# {'_id': ObjectId('666bc5c379402ab30621066a'), 'sepal length (cm)': 7.0, 'sepal width (cm)': 3.2, 'petal length (cm)': 4.7, 'petal width (cm)': 1.4, 'species': 'versicolor'}
# {'_id': ObjectId('666bc5c379402ab30621066b'), 'sepal length (cm)': 6.4, 'sepal width (cm)': 3.2, 'petal length (cm)': 4.5, 'petal width (cm)': 1.5, 'species': 'versicolor'}
# {'_id': ObjectId('666bc5c379402ab30621066c'), 'sepal length (cm)': 6.9, 'sepal width (cm)': 3.1, 'petal length (cm)': 4.9, 'petal width (cm)': 1.5, 'species': 'versicolor'}
# {'_id': ObjectId('666bc5c379402ab30621066d'), 'sepal length (cm)': 5.5, 'sepal width (cm)': 2.3, 'petal length (cm)': 4.0, 'petal width (cm)': 1.3, 'species': 'versicolor'}
# {'_id': ObjectId('666bc5c379402ab30621066e'), 'sepal length (cm)': 6.5, 'sepal width (cm)': 2.8, 'petal length (cm)': 4.6, 'petal width (cm)': 1.5, 'species': 'versicolor'}
```

## 移除整個資料表

在移除資料表前，我們先查詢 mydatabase 資料庫中有哪些資料表，並印出他們的名稱。我們可以看到裡面包含我們欲刪除的資料表 **iris**。

```r
collections_before = db.list_collection_names()
print("Collections before dropping:", collections_before)

# Collections before dropping: ['iris']
```

最後，當我們想要從資料庫中移除整個資料表，由于我們前面已經定義了變數 target 為 iris 資料表的位址，因此我們可以透過 `drop` 函數來將整個資料表從目標位址中移除，下面是簡單的程式範例：

```r
if "iris" in collections_before:
    db["iris"].drop()
    print("Iris collection dropped.")
else:
    print("Iris collection does not exist.")

# Iris collection dropped.
```

在移除完畢後，我們可以從下面的程式碼搜尋資料庫的指定位址中所有資料表的名稱，因為我們剛剛將位於 mydatabase 中的 iris 移除了，因此資料庫中已沒有其他資料表，故執行程式後會得到 [] 的結果。

```r
collections_after = db.list_collection_names()
print("Collections after dropping:", collections_after)

# Collections after dropping: []
```

到這裡我們便完成了在 Python 中對 MongoDB 基本的 CRUD 操作。
