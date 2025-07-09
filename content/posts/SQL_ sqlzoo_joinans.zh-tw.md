---
authors : ["施承翰"]
title : "SQLZOO解答與討論（JOIN）"
date : "2024-05-30"
summary : "在 SQLZOO JOIN 章節練習時的習題實作及詳解"
categories : [
    "SQL",
]
tags : [
    "MySQL",
]
series : ["SQLZOO"]
---

## About Data

這裡是我在 [SQLZOO](https://sqlzoo.net/wiki/SQL_Tutorial)這個網站的學習紀錄，這篇文章對應的章節是[The Join operation](https://sqlzoo.net/wiki/The_JOIN_operation)。我會在下方說明我的解題過程。首先讓我們來看到這個章節所使用的資料表：

![FootballERD](/images/SQL_sqlzoo_joinans/FootballERD.png)

---

**game**

| id   | mdate        | stadium                   | team1 | team2 |
| ---- | ------------ | ------------------------- | ----- | ----- |
| 1001 | 8 June 2012  | National Stadium, Warsaw  | POL   | GRE   |
| 1002 | 8 June 2012  | Stadion Miejski (Wroclaw) | RUS   | CZE   |
| 1003 | 12 June 2012 | Stadion Miejski (Wroclaw) | GRE   | CZE   |
| 1004 | 12 June 2012 | National Stadium, Warsaw  | POL   | RUS   |
| ...  |              |                           |       |       |

---

**goal**

| matchid | teamid | player               | gtime |
| ------- | ------ | -------------------- | ----- |
| 1001    | POL    | Robert Lewandowski   | 17    |
| 1001    | GRE    | Dimitris Salpingidis | 51    |
| 1002    | RUS    | Alan Dzagoev         | 15    |
| 1002    | RUS    | Roman Pavlyuchenko   | 82    |
| ...     |        |                      |       |

---

**eteam**

| id  | teamname       | coach            |
| --- | -------------- | ---------------- |
| POL | Poland         | Franciszek Smuda |
| RUS | Russia         | Dick Advocaat    |
| CZE | Czech Republic | Michal Bilek     |
| GRE | Greece         | Fernando Santos  |
| ... |                |                  |

---

上面的資料在SQLZOO有[下載連結](http://sqlzoo.net/euro2012.sql)，表格中包含波蘭和烏克蘭舉行的 2012 年歐洲足球錦標賽的所有比賽和進球。

---

## Introduction

在這個章節中，我們可以學到在調用多個資料庫時合併資料庫查詢資料的方法，假設我們分別有兩個資料表為table1及table2，若我們想把它們根據各自的id合併並輸出合併後全部的資料，那麼我們可以用下面的語法來做到。

```sql
SELECT * FROM table1 JOIN table2 ON id1=id2
```

下面是這個章節中[例題](https://sqlzoo.net/wiki/The_JOIN_operation)的解答，同時我也會解說部分例題的解題思路：

**Question 1**

```sql
SELECT matchid, player
FROM goal
WHERE teamid='GER';
```

**Question 2**

```sql
SELECT id,stadium,team1,team2 
FROM game
WHERE id=1012;
```

**Question 3**

```sql
SELECT player, teamid, stadium, mdate 
FROM game JOIN goal ON (id=matchid)
WHERE teamid='GER';
```

**Question 4**

在這裡我們有使用到前面章節所提到的正則表達式，若我們想找出名字前綴為'Mario’的球員，我們可以用 WHERE player LIKE 'Mario%' 來做查詢。

```sql
SELECT team1, team2, player 
FROM game JOIN goal ON (id=matchid)
WHERE player LIKE 'Mario%';
```

**Question 5**

```sql 
SELECT player, teamid, coach, gtime 
FROM goal JOIN eteam ON (id=teamid)
WHERE gtime<=10;
```

**Question 6**

```sql    
SELECT mdate, teamname 
FROM game JOIN eteam ON (team1=eteam.id)
WHERE coach='Fernando Santos';
```

**Question 7**

```sql
SELECT player 
FROM game JOIN goal ON (id=matchid)
WHERE stadium='National Stadium, Warsaw';
```

**Question 8**

在這題中，我們想要知道有與德國隊比賽的隊伍中，哪些球員曾經將球踢進了德國隊的球門，由於同一名球員可能曾經進球超過一次，因此我們在輸出時使用 DISTINCT(player) 來將這些球員的名字取不重複的名單出來。

```sql   
SELECT DISTINCT(player) 
FROM game JOIN goal ON (id=matchid)
WHERE (team1='GER' OR team2='GER') AND teamid != 'GER';
```

**Question 9**

由於這裡我們想統計個別球隊的球隊名稱與其進球數，與上一題不同的是，我們這裡可以用 GROUP BY teamname 來將各個輸出結果以球隊分類，同時我們在輸出時也使用 COUNT(player) 來統計每一隊進球的總數。

```sql
SELECT teamname, COUNT(player) 
FROM eteam JOIN goal ON (id=teamid)
GROUP BY teamname;
```

**Question 10**

```sql   
SELECT stadium, COUNT(player) 
FROM game JOIN goal ON (id=matchid)
GROUP BY stadium;
```

**Question 11**

```sql   
SELECT matchid, mdate, COUNT(player) 
FROM game JOIN goal ON id=matchid 
WHERE team1 = 'POL' OR team2 = 'POL'
GROUP BY id, mdate;
```

**Question 12**

```sql
SELECT matchid, mdate, COUNT(player) 
FROM game JOIN goal ON id=matchid
WHERE teamid='GER'
GROUP BY id, mdate;
```

**Question 13**

在最後一題中，我們使用到了CASE這個語法，它的目的是將原始輸出的結果透過條件式來更改成指定的輸出，類似於將Ｒ或Python中的if-else條件判斷式嵌入其中；由於題目要求的是比賽雙方的得分數，因此我們在使用SUM將更改後的輸出做加總；同時為了更符合題目的要求，我們將輸出的表格名稱定義為score1及score2，最後我們再依照mdate、id、team1、team的順序依序做分群及排列。

```sql
SELECT mdate, 
	team1, SUM(CASE WHEN teamid = team1 THEN 1 ELSE 0 END) AS score1, 
	team2, SUM(CASE WHEN teamid = team2 THEN 1 ELSE 0 END) AS score2
FROM game LEFT JOIN goal ON id=matchid    
GROUP BY mdate, id, team1, team2
ORDER BY mdate, id, team1, team2
```