# Setup

Jira CLI 도구의 환경 초기화. 워크스페이스당 한 번만 수행합니다.

## 사전 요구사항

- Python 3.11+
- Jira API 토큰: https://id.atlassian.com/manage-profile/security/api-tokens

## 절차

### 1. `.env` 생성

리포지토리는 `.env.example`만 제공합니다. 복사해서 본인 값으로 채우세요.

```bash
cp .env.example .env
```

필수 키:

| Key | 설명 |
|---|---|
| `JIRA_URL` | Atlassian 사이트, 예: `https://ssafy.atlassian.net` |
| `JIRA_EMAIL` | Atlassian 계정 이메일 |
| `JIRA_API_TOKEN` | 위 링크에서 발급한 토큰 |
| `JIRA_PROJECT_KEY` | 모든 작업을 고정할 프로젝트 키 |
| `JIRA_STORY_POINTS_FIELD` | 선택. 기본값 `customfield_10031` |

### 2. 환경 스크립트 실행

```bash
bash scripts/ensure_environment.sh
```

이 스크립트가 하는 일:

- `.venv/` 생성
- `jira`, `python-dotenv` 설치
- `.env`에 placeholder 값이 남아있는지 검증
- Jira 연결 프로브

## `.env` 값이 스크립트에 전달되는 방식

`.env` 값은 `config.py`를 거쳐 모든 스크립트에 자동 주입됩니다.

1. `config.py`가 `dotenv.load_dotenv()`로 `.env`를 읽어 **파이썬 프로세스 환경**에 적재
2. 각 스크립트는 `from config import JIRA_URL, JIRA_EMAIL, ...` 로 값을 받음
3. URL/email/token/project key는 **CLI 인자로 넘길 필요 없음**

### 쉘 변수로 참조하면 안 됨

`python-dotenv`는 `.env`를 **파이썬 프로세스 안**에서만 로드합니다. 쉘은 이 값을 모릅니다.

```bash
# 잘못됨 — $JIRA_PROJECT_KEY는 쉘에서 빈 문자열
./.venv/bin/python search_issues.py --project $JIRA_PROJECT_KEY

# 올바름 — 스크립트가 config.py 통해 .env에서 자동 로드
./.venv/bin/python search_issues.py
```

정말로 쉘에서 `.env` 값이 필요하면 해당 쉘에서 `set -a; source .env; set +a`를 실행하면 되지만, 스크립트가 이미 처리하므로 보통 불필요합니다.

## 문제 발생 시

`docs/troubleshooting.md` 참조.
