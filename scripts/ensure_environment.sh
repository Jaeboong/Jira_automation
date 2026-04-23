#!/usr/bin/env bash
set -euo pipefail

# Jira CLI 환경 준비 스크립트.
# Jira/ 디렉토리 기준 어디서 호출해도 정상 동작.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

echo "==> Jira 환경 준비"

# 1. Python 확인
if command -v python3 >/dev/null 2>&1; then
  PYTHON=python3
elif command -v python >/dev/null 2>&1; then
  PYTHON=python
else
  echo "ERROR: Python 3 를 찾을 수 없습니다. Python 3.11+ 설치 후 재실행하세요." >&2
  exit 1
fi

# 2. venv
if [ ! -d .venv ]; then
  echo "==> .venv 생성"
  "$PYTHON" -m venv .venv
fi

# 3. 의존성 설치
echo "==> 의존성 설치"
./.venv/bin/pip install --quiet --upgrade pip
./.venv/bin/pip install --quiet -r requirements.txt

# 4. .env 존재 확인
if [ ! -f .env ]; then
  echo "ERROR: .env 파일이 없습니다." >&2
  echo ".env.example을 복사해 값을 채우세요:" >&2
  echo "  cp .env.example .env" >&2
  exit 1
fi

# 5. placeholder 검사
if grep -qE '(your-email@example\.com|your-api-token-here|YOUR_PROJECT_KEY)' .env; then
  echo "ERROR: .env 에 placeholder 값이 남아 있습니다." >&2
  echo ".env 파일을 편집해 본인 Jira 값으로 교체하세요." >&2
  exit 1
fi

# 6. 연결 프로브
echo "==> Jira 연결 확인"
./.venv/bin/python - <<'PY'
import sys
from config import JIRA_URL, JIRA_EMAIL, JIRA_API_TOKEN
from jira import JIRA
try:
    j = JIRA(server=JIRA_URL, basic_auth=(JIRA_EMAIL, JIRA_API_TOKEN), timeout=10)
    user = j.myself()
    print(f"연결 성공: {user.get('displayName', user.get('emailAddress', 'unknown'))}")
except Exception as e:
    print(f"연결 실패: {e}", file=sys.stderr)
    sys.exit(1)
PY

echo "==> 준비 완료."
