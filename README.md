# chenghanshih.github.io（已封存 / Archived）

這是我 2022 至 2024 年求學期間的個人網站與技術筆記，內容以 R、SQL、統計模擬為主。
自 2026 年 9 月起不再更新，僅保留線上版本供查閱：<https://chenghanshih.github.io>

This is my personal site and study notes from 2022 to 2024 (mostly R, SQL and statistical simulation).
Frozen since September 2026; the live site stays online for reference.

## 分支說明 / Branches

- `master`：Hugo 原始碼（內容、設定、Blowfish 主題 submodule）
- `main`：建置後的靜態檔案，GitHub Pages 的來源

## 建置與部署 / Build & deploy

```bash
git clone --recurse-submodules -b master https://github.com/chenghanshih/chenghanshih.github.io.git
cd chenghanshih.github.io
hugo server        # 本機預覽
./deploy.sh        # 建置並強制推送 public/ 到 main
```

## 站內自帶的附件 / Self-contained assets

原本放在其他倉庫的內容已搬進本站，避免外部依賴：

- `static/html/MovieLens_100k_Recommender_System.html`：推薦系統專案的互動報告
- `static/pkg/APLM_0.1.0.tar.gz`：逐步迴歸文章使用的 R 套件原始碼
