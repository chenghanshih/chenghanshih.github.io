---
authors : ["施承翰"]
title : "如何在 Mac 上部署 MongoDB Server"
date : "2024-06-12"
summary : "在這篇文章中我將介紹如何在 Mac 電腦上部署本地端的 MongoDB"
categories : [
    "NoSQL",
]
tags : [
    "MongoDB",
]
series : ["MongoDB"]
---

MongoDB 是一種 NoSQL 資料庫，以其高性能、靈活的資料模型和良好的可擴展性而廣受歡迎。與傳統的關聯式資料庫不同，MongoDB 使用類似 JSON 格式的文件來存儲資料，使得它特別適合處理多變且非結構化的數據。在現代應用程序中，尤其是需要處理大數據和實時分析的場景下，MongoDB 提供了優異的解決方案。

因此我計劃撰寫一部 MongoDB 的入門指南，藉由實際操作來學習 MongoDB 為自己培養新的技能。本篇文章將介紹如何在 Mac 電腦上部署 MongoDB，透過本地端的部署可以讓我們後續橋接程式使用構建開發環境。



## 安装Homebrew

Homebrew 是一個開源的安裝包管理器，專為 macOS 和 Linux 系統設計。它讓用戶能夠輕鬆地在終端幾上安裝、更新和管理各種插件和工具。透過 Homebrew 我們可以將工具安裝過程簡化，避免用戶手動處理各插件之間的依賴關係和繁瑣的配置文件。通過簡單的命令如 brew install，使用戶可以輕鬆獲取和安裝他們需要的工具，讓開發者和系統管理員能夠更高效地管理電腦內的環境。

在開始安裝MongoDB前，我們可以透過以下命令安装並更新Homebrew至最新版本，便於我們後續從 Homebrew 上下載 MongoDB：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
```

## 透過 Homebrew 下載及使用 MongoDB

接著我們將透過 Homebrew 下載 MongoDB community 的 5.0 版本。

```bash
brew tap mongodb/brew
brew install mongodb-community@5.0
```

當安裝完成後，我們可以用下面的指令啟動 MongoDB。

```bash
brew services start mongodb/brew/mongodb-community
```

安裝完畢之後我們可以透過檢查 MongoDB 的版本來確認是否有順利完成安裝。

```bash
mongo --version
```

如果順利安裝，我們可以終端機中看到相似於下列的訊息。

```
MongoDB shell version v5.0.27
Build Info: {
    "version": "5.0.27",
    "gitVersion": "49571988f1fea870e803f71a3ef8417173f3fbb1",
    "modules": [],
    "allocator": "system",
    "environment": {
        "distarch": "x86_64",
        "target_arch": "x86_64"
    }
}
```


若是需要「重新啟動」或是「關閉」運行中的 Mongodb 我們只需運行下面的指令便能做到。

```bash
brew services restart mongodb/brew/mongodb-community
```

```bash
brew services stop mongodb/brew/mongodb-community
```

到這裡我們便完成了本地端的資料庫部署，我們會在這個系列的下一篇文章中示範如何使用程式語言連線至 Mongodb 進行操作。

## 附錄：安裝中可能遇到的問題

如果在啟動 MongoDB後出現下面的訊息，表示 MongoDB 雖然已經順利安裝並運行，但它没有被自動連接到你的 PATH 環境中。所以我們需要手動將 MongoDB 的路徑新增至 PATH 環境變數中。

```
mongodb-community@5.0 is keg-only, which means it was not symlinked into /opt/homebrew,
because this is an alternate version of another formula.

If you need to have mongodb-community@5.0 first in your PATH, run:
  echo 'export PATH="/opt/homebrew/opt/mongodb-community@5.0/bin:$PATH"' >> ~/.zshrc

To start mongodb/brew/mongodb-community@5.0 now and restart at login:
  brew services start mongodb/brew/mongodb-community@5.0
```

我們可以透過編輯 .zshrc 文件將 MongoDB 的路徑新增到 PATH 環境變數中，接著我們重新載入 .zshrc 文件後便可以成功將 MongoDB 的新路徑加入 PATH 環境變數中。

```bash
echo 'export PATH="/opt/homebrew/opt/mongodb-community@5.0/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```
