---
authors : ["施承翰"]
title : "SQLZOO解答與討論（More JOIN）"
date : "2024-06-03"
summary : "在 SQLZOO More JOIN 章節練習時的習題實作及詳解"
categories : [
    "programming",
]
tags : [
    "sql",
    "database",
    "mysql",
]
series : ["SQLZOO"]
---

## About Data

這是[SQLZOO](https://sqlzoo.net/wiki/SQL_Tutorial)學習紀錄系列的第二篇，這篇文章對應的章節是[More JOIN operations](https://sqlzoo.net/wiki/More_JOIN_operations)。我會在下方說明我的解題過程。讓我們來看到這次所使用的資料表：

![MovieDatabase](/images/SQL_sqlzoo_morejoinans/MovieDatabase.png)

---

**movie**

| id    | title               | yr   | director | budget   | gross     |
| ----- | ------------------- | ---- | -------- | -------- | --------- |
| 10003 | Crocodile Dundee II | 1988 | 38       | 15800000 | 239606210 |
| 10004 | Til There Was You   | 1997 | 49       | 10000000 |           |
| ...   |                     |      |          |          |           |

---

**actor**

| id  | name               | 
| --- | ------------------ | 
| 20  | Paul Hogan         | 
| 50  | Jeanne Tripplehorn | 
| ... |                    |  

---

**casting**

| movieid | actorid | ord |
| ------- | ------- | --- |
| 10003   | 20      | 4   |
| 10004   | 50      | 1   |
| ...     |         |     |
 
---

## Introduction

在這個章節中，我們會基於上個章節的內容做更多合併與檢索資料的練習。下面是這個章節中[例題](https://sqlzoo.net/wiki/More_JOIN_operations)的解答，同時我也會解說部分例題的解題思路：

**Question 1**

```sql
SELECT id, title
FROM movie
WHERE yr=1962;
```

**Question 2**

```sql
SELECT yr 
FROM movie
WHERE title= 'Citizen Kane';
```

**Question 3**

```sql
SELECT id, title, yr 
FROM movie
WHERE title LIKE '%Star Trek%'
ORDER BY yr;
```

**Question 4**

```sql
SELECT id 
FROM actor
WHERE name='Glenn Close';
```

**Question 5**

```sql 
SELECT id 
FROM movie
WHERE title='Casablanca';
```

**Question 6**

```sql    
SELECT name 
FROM casting 
    JOIN actor ON actorid=id
WHERE movieid=(
    SELECT id 
    FROM movie 
    WHERE title='Casablanca');
```

**Question 7**

```sql
SELECT name 
FROM casting 
    JOIN actor ON actorid=id
WHERE movieid=(
    SELECT id 
    FROM movie 
    WHERE title='Alien');
```

**Question 8**

```sql   
SELECT title 
FROM movie 
    JOIN actor ON movie.id=actor.id 
    JOIN casting ON movie.id=movieid
WHERE actorid=(
    SELECT id 
    FROM actor 
    WHERE name='Harrison Ford');
```

**Question 9**

```sql
SELECT title 
FROM casting 
    JOIN movie ON movieid=movie.id 
    JOIN actor ON actorid=actor.id
WHERE name='Harrison Ford' and ord!=1;
```

**Question 10**

```sql   
SELECT title, name 
FROM casting 
    JOIN movie ON movieid=movie.id 
    JOIN actor ON actorid=actor.id
WHERE yr=1962 AND ord=1;
```

## Harder Questions

**Question 11**

```sql   
SELECT yr,COUNT(title) 
FROM casting 
    JOIN movie ON movieid=movie.id 
    JOIN actor ON actorid=actor.id
WHERE name='Rock Hudson'
GROUP BY yr
HAVING COUNT(title) > 2;
```

**Question 12**

在這題中我原本使用 title 去做搜尋，但似乎有一部名為 "Little Miss Marker twice" 的電影有兩位主演，導致若是以名字去做搜尋會得到兩份結果，導致在網站中答案顯示不正確，但我覺得題目中並沒有提到當電影有兩位主演時只能顯示一位，因此我在這裡附上兩種答案，第一份是符合網站要求的標準答案，而第二份我同時顯示了 ord 來確認在這部電影中真的有兩位主演。

```sql
-- 標準答案
SELECT title, name 
FROM casting 
    JOIN movie ON movieid=movie.id 
    JOIN actor ON actorid=actor.id
WHERE movie.id IN (
    SELECT movie.id 
    FROM casting 
        JOIN movie ON movieid=movie.id 
        JOIN actor ON actorid=actor.id
    WHERE name='Julie Andrews') AND ord=1;
```

```sql
-- 若是以電影名稱下去檢索會出現回答錯誤
SELECT title, name, ord -- 可移除ord來顯示與標準答案格式相同的答案
FROM casting 
    JOIN movie ON movieid=movie.id 
    JOIN actor ON actorid=actor.id
WHERE title IN (
    SELECT title FROM casting 
        JOIN movie ON movieid=movie.id 
        JOIN actor ON actorid=actor.id
    WHERE name='Julie Andrews') AND ord=1;
```

**Question 13**

在這題中，我們需要輸出不重複的演員，同時這須演員必須至少要出演15部電影的主演。
因此在這裡我們使用`DISTINCT`確保輸出的演員名字不重複，在合併資料表後，我們使用`IN`來選擇符合要求的演員id，由`WHERE`選取主演的資料後，使用`GROUP BY`按照演員名字分組，最後使用`HAVING`判斷由`COUNT`統計的出現次數超過15次的演員名單後回傳。

```sql
SELECT DISTINCT name 
FROM casting
    JOIN movie ON movie.id=movieid
    JOIN actor ON actor.id=actorid
WHERE actorid IN (
	SELECT actorid FROM casting
	    WHERE ord=1
	    GROUP BY actorid
	    HAVING COUNT(actorid) >= 15)
ORDER BY name;
```

**Question 14**

```sql
SELECT title, COUNT(actorid) 
FROM casting
    JOIN movie ON movie.id=movieid
WHERE yr=1978
    GROUP BY movieid, title
    ORDER BY COUNT(actorid) DESC, title;
```

**Question 15**

在最後一題中，我們需要找出與 "Art Garfunkel" 一起出演過電影的演員，在這裡我們需要由電影搜尋哪些演員曾在他出演過的電影中出現，同時我們需要加上一個不能為他本人的條件確保輸出的結果正確。

```sql
SELECT DISTINCT name 
FROM casting
    JOIN actor ON actorid = actor.id
WHERE movieid IN (
	SELECT movieid
	FROM casting
        JOIN movie ON movie.id=movieid
        JOIN actor ON actor.id=actorid
	WHERE name = 'Art Garfunkel') AND name != 'Art Garfunkel';
```
