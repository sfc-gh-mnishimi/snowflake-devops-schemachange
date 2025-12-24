# Snowflake DevOps with schemachange

このプロジェクトは **schemachange** を使用した Snowflake データベースの CI/CD パイプラインのサンプル実装です。

## 🎮 プロジェクト概要

Zelda ゲームデータを題材に、schemachange によるスキーマ管理と GitHub Actions による自動デプロイを実現しています。

> ⚠️ **免責事項**: 本プロジェクトは学習・検証目的で作成されています。動作の保証はありません。本ソースコードを利用する場合は自己責任でお願いします。

### 検証で確認した内容

- ✅ schemachange による Versioned / Repeatable スクリプトの管理
- ✅ GitHub Actions と KeyPair 認証によるセキュアなデプロイ
- ✅ DEV → TEST → PROD 環境への段階的デプロイフロー
- ✅ ネットワークポリシー制限下での CI/CD 実行

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

### 特徴

| 項目 | 説明 |
|------|------|
| **SQL ネイティブ** | Snowflake の第一言語である SQL で直接記述 |
| **軽量** | 古典的な DB マイグレーションツールの手法を踏襲 |
| **Jinja テンプレート** | 環境変数の埋め込みやコード再利用が可能 |

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

### ブランチ戦略

| ブランチ | デプロイ先 | トリガー |
|---------|-----------|---------|
| `feature/*` | - | - |
| `develop` | DEV 環境 | push / PR |
| `test` | TEST 環境 | push / PR |
| `main` | PROD 環境 | push / PR |

## 📦 データベース構造

各環境で以下のスキーマが作成されます：

| スキーマ | 用途 |
|---------|------|
| `RAW_ZELDA` | 生データ格納（VARIANT型） |
| `CORE_ZELDA` | クレンジング済みデータ（DIMテーブル） |
| `MART_ZELDA` | 分析用データマート（ビュー） |
| `SCHEMACHANGE` | 変更履歴管理 |

### データレイヤー構成

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  RAW_ZELDA  │ ──▶ │ CORE_ZELDA  │ ──▶ │ MART_ZELDA  │
├─────────────┤     ├─────────────┤     ├─────────────┤
│ GAMES_RAW   │     │ DIM_GAME    │     │ V_GAMES_BY_ │
│ (VARIANT)   │     │ (構造化)     │     │ DEVELOPER   │
│             │     │             │     │ V_GAMES_BY_ │
│             │     │ V_GAMES     │     │ PUBLISHER   │
│             │     │             │     │ V_GAMES_BY_ │
│             │     │             │     │ DECADE      │
└─────────────┘     └─────────────┘     └─────────────┘
```

## ⚙️ GitHub Actions 設定

### 認証方式: KeyPair 認証

本プロジェクトでは **KeyPair 認証** を使用しています。これにより：

- パスワード不要でセキュア
- GitHub Actions から Snowflake へ安全に接続

### ネットワークポリシー対応

Snowflake にアカウントレベルのネットワークポリシー（VPN 制限など）が設定されている場合、GitHub Actions からの接続がブロックされます。

**解決策:** 専用ユーザーにユーザーレベルのネットワークポリシーを適用

```sql
-- GitHub Actions 専用ユーザーの作成
CREATE USER GITHUB_ACTIONS_SCHEMACHANGE
  DEFAULT_ROLE = SYSADMIN
  DEFAULT_WAREHOUSE = COMPUTE_WH;

-- 許可範囲の広いネットワークポリシーを適用
ALTER USER GITHUB_ACTIONS_SCHEMACHANGE SET NETWORK_POLICY = 'GITHUB_ACTIONS_POLICY';

-- KeyPair 認証の設定
ALTER USER GITHUB_ACTIONS_SCHEMACHANGE SET RSA_PUBLIC_KEY = '...';
```

### 必要な Secrets

GitHub リポジトリの Settings → Secrets and variables → Actions で以下を設定：

| Secret名 | 説明 |
|----------|------|
| `SNOWFLAKE_ACCOUNT` | Snowflake アカウント識別子 |
| `SNOWFLAKE_USER` | GitHub Actions 専用ユーザー名 |
| `SNOWFLAKE_PRIVATE_KEY` | 秘密鍵（Base64エンコード） |
| `SNOWFLAKE_ROLE` | 使用するロール |
| `SNOWFLAKE_WAREHOUSE` | 使用するウェアハウス |

### 秘密鍵の Base64 エンコード

```bash
# macOS / Linux
cat snowflake_key.p8 | base64 | tr -d '\n'

# 結果を SNOWFLAKE_PRIVATE_KEY Secret に設定
```

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

## 🎲 テストデータについて

### データソース

本プロジェクトで使用しているテストデータは [Zelda API](https://docs.zelda.fanapis.com/docs/) から取得しています。

- **API エンドポイント**: `https://zelda.fanapis.com/api/games`
- **データ形式**: JSON
- **取得データ**: ゼルダの伝説シリーズ全32作品の情報

### データ取得方法

```bash
# Zelda API からゲームデータを取得
curl -s "https://zelda.fanapis.com/api/games" > data/zelda_games_raw.json
```

### データ投入方法

取得した JSON データは Python スクリプトで Snowflake に投入しています：

```python
import json
import snowflake.connector

# JSON ファイルを読み込み
with open('data/zelda_games_raw.json', 'r') as f:
    data = json.load(f)

# Snowflake に接続
conn = snowflake.connector.connect(...)
cursor = conn.cursor()

# RAW テーブルに投入
cursor.execute(f"""
    INSERT INTO RAW_ZELDA.GAMES_RAW (RAW_DATA)
    SELECT PARSE_JSON($${json.dumps(data)}$$)
""")

# CORE テーブルに変換・投入
for game in data['data']:
    cursor.execute("""
        INSERT INTO CORE_ZELDA.DIM_GAME 
        (GAME_ID, GAME_NAME, DESCRIPTION, DEVELOPER, PUBLISHER, RELEASED_DATE)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (game['id'], game['name'], game.get('description', ''), 
          game.get('developer', ''), game.get('publisher', ''), 
          game.get('released_date', '')))
```

### 投入データの確認

```sql
-- ゲーム数の確認
SELECT COUNT(*) FROM CORE_ZELDA.DIM_GAME;  -- 32件

-- 年代別ゲーム数
SELECT * FROM MART_ZELDA.V_GAMES_BY_DECADE;
-- 1980s: 2件, 1990s: 10件, 2000s: 10件, 2010s: 9件, 2020s: 1件
```

## 🔗 関連リンク

### schemachange
- [schemachange GitHub](https://github.com/Snowflake-Labs/schemachange)
- [schemachange PyPI](https://pypi.org/project/schemachange/)
- [Snowflake Quickstart: DevOps Database Change Management with schemachange](https://quickstarts.snowflake.com/guide/devops_dcm_schemachange_github/)

### Snowflake
- [Snowflake Documentation](https://docs.snowflake.com/)

### テストデータ
- [Zelda API Documentation](https://docs.zelda.fanapis.com/docs/) - 本プロジェクトのテストデータ取得元

## 📝 ライセンス

MIT License
