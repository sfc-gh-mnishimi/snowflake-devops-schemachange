# Snowflake DevOps with schemachange

このプロジェクトは **schemachange** を使用した Snowflake データベースの CI/CD パイプラインのサンプル実装です。

## 🎮 プロジェクト概要

Zelda ゲームデータを題材に、schemachange によるスキーマ管理と GitHub Actions による自動デプロイを実現しています。

## 📁 プロジェクト構造

```
snowflake-devops-schemachange/
├── .github/
│   └── workflows/
│       ├── deploy-dev.yml      # develop → SCHEMACHANGE_ZELDA_DEV
│       ├── deploy-test.yml     # test → SCHEMACHANGE_ZELDA_TEST
│       └── deploy-prod.yml     # main → SCHEMACHANGE_ZELDA_PROD
├── migrations/
│   ├── V1.0.0__create_raw_schema.sql
│   ├── V1.1.0__create_games_raw_table.sql
│   ├── V1.2.0__create_core_schema.sql
│   ├── V1.3.0__create_dim_game.sql
│   ├── V1.4.0__create_mart_schema.sql
│   └── R__create_views.sql
├── data/
│   └── zelda_games_raw.json
└── README.md
```

## 🔧 schemachange について

### schemachange とは？

[schemachange](https://github.com/Snowflake-Labs/schemachange) は Snowflake 向けの軽量なデータベースマイグレーションツールです。

### ファイル命名規則

| プレフィックス | 説明 | 例 |
|---------------|------|-----|
| `V` | Versioned - 一度だけ実行 | `V1.0.0__create_schema.sql` |
| `R` | Repeatable - 変更時に再実行 | `R__create_views.sql` |
| `A` | Always - 毎回実行 | `A__refresh_data.sql` |

## 🚀 開発フロー

```
┌─────────────────────────────────────────────────────────────────┐
│                        開発フロー                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [feature/*]  ──PR──▶  [develop]  ──PR──▶  [test]  ──PR──▶  [main] │
│                           │                  │               │   │
│                           ▼                  ▼               ▼   │
│                    GitHub Actions      GitHub Actions   GitHub Actions │
│                           │                  │               │   │
│                           ▼                  ▼               ▼   │
│                   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│                   │SCHEMACHANGE  │  │SCHEMACHANGE  │  │SCHEMACHANGE  │ │
│                   │_ZELDA_DEV    │  │_ZELDA_TEST   │  │_ZELDA_PROD   │ │
│                   └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 📦 データベース構造

各環境で以下のスキーマが作成されます：

| スキーマ | 用途 |
|---------|------|
| `RAW_ZELDA` | 生データ格納（VARIANT型） |
| `CORE_ZELDA` | クレンジング済みデータ（DIMテーブル） |
| `MART_ZELDA` | 分析用データマート（ビュー） |
| `SCHEMACHANGE` | 変更履歴管理 |

## ⚙️ GitHub Actions 設定

### 必要な Secrets

GitHub リポジトリの Settings → Secrets and variables → Actions で以下を設定：

| Secret名 | 説明 |
|----------|------|
| `SNOWFLAKE_ACCOUNT` | Snowflake アカウント識別子 |
| `SNOWFLAKE_USER` | ユーザー名 |
| `SNOWFLAKE_PRIVATE_KEY` | 秘密鍵（Base64エンコード） |
| `SNOWFLAKE_ROLE` | 使用するロール |
| `SNOWFLAKE_WAREHOUSE` | 使用するウェアハウス |

## 🛠️ ローカルでの実行

### 1. schemachange のインストール

```bash
pip install schemachange
```

### 2. 環境変数の設定

```bash
export SNOWFLAKE_ACCOUNT=your_account
export SNOWFLAKE_USER=your_user
export SNOWFLAKE_ROLE=your_role
export SNOWFLAKE_WAREHOUSE=your_warehouse
export SNOWFLAKE_PRIVATE_KEY_PATH=/path/to/key.p8
```

### 3. デプロイの実行

```bash
schemachange deploy \
  --root-folder migrations \
  --snowflake-account $SNOWFLAKE_ACCOUNT \
  --snowflake-user $SNOWFLAKE_USER \
  --snowflake-role $SNOWFLAKE_ROLE \
  --snowflake-warehouse $SNOWFLAKE_WAREHOUSE \
  --snowflake-database SCHEMACHANGE_ZELDA_DEV \
  --snowflake-private-key-path $SNOWFLAKE_PRIVATE_KEY_PATH \
  --change-history-table SCHEMACHANGE_ZELDA_DEV.SCHEMACHANGE.CHANGE_HISTORY \
  --create-change-history-table
```

## 📊 変更履歴の確認

schemachange は自動的に `SCHEMACHANGE.CHANGE_HISTORY` テーブルを作成し、適用済みのマイグレーションを記録します：

```sql
SELECT * FROM SCHEMACHANGE_ZELDA_DEV.SCHEMACHANGE.CHANGE_HISTORY
ORDER BY INSTALLED_ON DESC;
```

## 🔗 関連リンク

- [schemachange GitHub](https://github.com/Snowflake-Labs/schemachange)
- [Snowflake Documentation](https://docs.snowflake.com/)

## 📝 ライセンス

MIT License
