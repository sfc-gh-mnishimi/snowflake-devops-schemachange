# Snowflake DevOps - schemachange

schemachange を使った Snowflake Database Change Management (DCM) の検証用リポジトリ

## 概要

schemachange は Snowflake Labs が提供するオープンソースの Python ツールで、
Flyway に触発されたデータベースマイグレーションツールです。

- **ツール**: [schemachange](https://github.com/Snowflake-Labs/schemachange)
- **環境**: DEV / TEST / PROD（SCHEMACHANGE_*_DB）
- **CI/CD**: GitHub Actions

## アーキテクチャ

```
┌─────────────────────────────────────────────────────────────────┐
│                         GitHub                                  │
│  ┌──────────────┐   ┌──────────────┐                           │
│  │ migrations/  │   │ .github/     │                           │
│  │ ├── V1.0.0   │   │ workflows/   │                           │
│  │ ├── V1.1.0   │   │              │                           │
│  │ └── R1.0.0   │   │              │                           │
│  └──────────────┘   └──────────────┘                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                    Git Push / PR Merge
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      GitHub Actions                             │
│  1. Python インストール                                          │
│  2. pip install schemachange                                    │
│  3. schemachange deploy -f ./migrations ...                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Snowflake                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ SCHEMACHANGE_   │  │ SCHEMACHANGE_   │  │ SCHEMACHANGE_   │ │
│  │ DEV_DB          │  │ TEST_DB         │  │ PROD_DB         │ │
│  │ ├── APP         │  │ ├── APP         │  │ ├── APP         │ │
│  │ └── SCHEMACHANGE│  │ └── SCHEMACHANGE│  │ └── SCHEMACHANGE│ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                                 │
│  SCHEMACHANGE スキーマに change_history テーブルが作成される      │
└─────────────────────────────────────────────────────────────────┘
```

## ディレクトリ構成

```
.
├── .github/
│   └── workflows/
│       ├── deploy-dev.yml      # DEV環境デプロイ（develop へ push）
│       ├── deploy-test.yml     # TEST環境デプロイ（staging へ push）
│       └── deploy-prod.yml     # PROD環境デプロイ（main へ push）
│
├── migrations/
│   ├── V1.0.0__create_app_schema.sql      # スキーマ作成
│   ├── V1.1.0__create_users_table.sql     # テーブル作成
│   ├── V1.2.0__create_orders_table.sql    # テーブル作成
│   └── R1.0.0__create_user_view.sql       # ビュー作成（繰り返し実行可能）
│
└── README.md
```

## ブランチ戦略

```
feature/* ──PR──> develop ──PR──> staging ──PR──> main
     │                │                │            │
     ▼                ▼                ▼            ▼
  プレビュー       DEV環境          TEST環境      PROD環境
```

## schemachange ファイル命名規則

| プレフィックス | 説明 | 実行タイミング |
|---------------|------|---------------|
| **V** (Versioned) | バージョン管理されたスクリプト | 一度だけ実行 |
| **R** (Repeatable) | 繰り返し実行可能なスクリプト | 変更があれば毎回実行 |
| **A** (Always) | 常に実行されるスクリプト | 毎回最後に実行 |

## セットアップ

### 1. Snowflake データベース作成

```sql
-- DEV 環境
CREATE DATABASE IF NOT EXISTS SCHEMACHANGE_DEV_DB;

-- TEST 環境
CREATE DATABASE IF NOT EXISTS SCHEMACHANGE_TEST_DB;

-- PROD 環境
CREATE DATABASE IF NOT EXISTS SCHEMACHANGE_PROD_DB;
```

### 2. GitHub Secrets 設定

| Secret名 | 説明 |
|----------|------|
| SNOWFLAKE_ACCOUNT | Snowflakeアカウント名 |
| SNOWFLAKE_USER | ユーザー名（CI/CD用） |
| SNOWFLAKE_PRIVATE_KEY | 秘密鍵（Key-Pair認証用） |

## 参考リンク

- [schemachange GitHub](https://github.com/Snowflake-Labs/schemachange)
- [Snowflake DevOps ドキュメント](https://docs.snowflake.com/ja/developer-guide/builders/devops)

