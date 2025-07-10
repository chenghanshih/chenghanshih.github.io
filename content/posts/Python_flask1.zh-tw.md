---
authors : ["施承翰"]
title : "快速上手 Flask：從安裝到第一個網頁"
date : "2024-07-10"
summary : "這篇文章教你如何安裝 Flask，並建立由簡單程式碼所架設的網頁"
categories : [
    "web-development",
]
tags : [
    "python",
    "flask",
    "web-framework",
]
series : ["Flask"]

---

## 1. 介紹

### Flask 是什麼？

Flask 是一個 Python 的網頁框架，用於構建輕量級的網頁應用程式。它由 Armin Ronacher 開發，基於 Werkzeug WSGI 工具和 Jinja2 模板引擎。並以簡單、靈活和可擴展性強著稱，因此適合各種規模的專案、簡單的個人網站到複雜的企業應用程式。

### Flask 的歷史和背景

Flask 於 2010 年首次發布，旨在提供一個簡單易用的框架，讓開發者可以快速構建網頁應用程式。它被設計為「微框架」，這意味著它只提供最基本的功能，並允許開發者根據需要添加擴展和第三方模組。

### Flask 的適用範圍和特點

Flask 的特點包括：

- **輕量級和模組化**：只包含基本功能，其他功能可以通過擴展來添加。
- **簡單的路由定義**：使用裝飾器來定義 URL 路由。
- **強大的模板引擎**：使用 Jinja2 模板引擎生成 HTML 頁面。
- **開發伺服器和偵錯工具**：內建開發伺服器和偵錯工具，方便開發和測試。
- **豐富的擴展**：有許多第三方擴展可用來增加功能，如資料庫 ORM、表單處理、驗證等。

### 範例應用場景

- **個人網站**：利用 Flask 快速搭建一個簡單的個人網站。
- **企業應用**：開發小型至中型企業應用，如內部管理系統或客戶管理系統。
- **API 服務**：構建 RESTful API，提供數據服務。

---

## 2. 安裝與環境設置

### 安裝 Flask

首先我們需要在電腦中安裝 Flask。在開始之前需要先安裝 Python。如果尚未安裝，可以從 [Python 官方網站](https://www.python.org/)下載並安裝。

接著我們可以使用以下步驟來安裝 Flask：

1. 打開命令提示字元（Windows）或終端（macOS 和 Linux）。
2. 建立虛擬環境（可選，但強烈建議）在這裡我們以 conda 容器為例。

    ```bash
    # 建立虛擬環境
    conda create --name myflask

    # 啟動虛擬環境
    conda activate myflask
    ```

3. 使用 pip 安裝 Flask：

    ```bash
    pip install Flask
    ```

### 檢查安裝是否成功

我們可以使用以下命令來檢查 Flask 是否安裝成功：

    ```bash
    python -m flask --version
    ```

這會顯示 Flask 的版本號，如果一切正常，你應該會看到類似如下的輸出：

    ```
    Flask 2.x.x
    Python 3.x.x
    ```

### 建立第一個 Flask 網頁

現在讓我們來建立一個簡單的 Flask 網頁，驗證我們的安裝是否成功。

1. 在你的項目目錄中創建一個 Python 文件，例如 `app.py`。
2. 在 `app.py` 中添加以下程式碼：

    ```python
    from flask import Flask

    app = Flask(__name__)

    @app.route('/')
    def home():
        return "Hello, Flask!"

    if __name__ == '__main__':
        app.run(debug=True)
    ```

這段程式碼做了以下幾件事：

- 從 Flask 導入 Flask 類別。
- 創建一個 Flask 應用實例 `app`。
- 使用 `@app.route('/')` 裝飾器定義了一個路由，當用戶訪問根 URL (`/`) 時，會調用 `home` 函數並返回 "Hello, Flask!"。
- 使用 `app.run(debug=True)` 啟動網頁的開發伺服器，並開啟偵錯模式。

### 啟動開發伺服器

透過在命令提示字元或終端中運行以下命令啟動開發伺服器：

    ```bash
    python app.py
    ```

我們會得到如下方的輸出：

    ```
    * Serving Flask app "app" (lazy loading)
    * Environment: production
    WARNING: This is a development server. Do not use it in a production deployment.
    Use a production WSGI server instead.
    * Debug mode: on
    * Running on http://127.0.0.1:8080/ (Press CTRL+C to quit)
    ```

透過打開瀏覽器訪問 `http://127.0.0.1:8080/` 後，頁面上會顯示我們剛剛在程式碼中輸入的 "Hello, Flask!"。

### 小結

到此為止，我們已經安裝了 Flask，並成功創建並運行了一個簡單的 Flask 網頁。在接下來的章節中，我們將學習如何使用 Flask 的模板引擎來生成動態 HTML 頁面。

在下一章節中，我們將介紹如何使用 Jinja2 模板引擎來建立和渲染動態的 HTML 頁面，讓我們的 Flask 網頁更具互動性和吸引力。