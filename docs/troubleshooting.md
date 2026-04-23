# Troubleshooting

## 에러 표

| 증상 | 원인 | 조치 |
|---|---|---|
| `401 Unauthorized` / 인증 실패 | 자격증명 오류 | `.env`의 `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` 확인 |
| `403` + "IP not allowed" | 회사 IP 제한 | Jira 관리자에게 IP 화이트리스트 요청 |
| `JQL error` | JQL 문법 오류 | 문자열 값 따옴표 처리: `status = "해야 할 일"` |
| 읽기 시 `UnicodeEncodeError` | 터미널 UTF-8 문제 | `read_issues.py` 대신 `search_issues.py` (임시파일) 사용 |
| Story Points 업데이트 무반응 | 커스텀 필드 ID 불일치 | `.env`에 `JIRA_STORY_POINTS_FIELD` 설정 |
| `ModuleNotFoundError: jira` | venv 미설정 | `bash scripts/ensure_environment.sh` 재실행 |
| `python: command not found` | Python 미설치 | Python 3.11+ 설치 후 setup 재실행 |
| `.env`가 로드 안 됨 | 파일 없음 또는 위치 오류 | `.env`는 `config.py`와 같은 디렉토리에 있어야 함 |
| `--project ""` / 빈 프로젝트 | 쉘이 `$JIRA_PROJECT_KEY`를 빈 문자열로 확장 | 플래그 제거. 스크립트가 `config.py` 통해 `.env`에서 자동 로드 |
| Epic Link 실패 | 비표준 커스텀 필드 | 관리자에게 올바른 필드 ID 문의, `link_epic.py` 하드코딩 수정 |

## 디버깅 절차

### 1. `.env` 로드 확인

```bash
./.venv/bin/python -c "from config import JIRA_URL, JIRA_EMAIL, PROJECT_KEY; print(JIRA_URL, JIRA_EMAIL, PROJECT_KEY)"
```

빈 문자열이거나 placeholder (`your-email@example.com`)가 남아있으면 `.env` 수정.

### 2. Jira 연결 확인

```bash
./.venv/bin/python -c "
from config import *
from jira import JIRA
j = JIRA(server=JIRA_URL, basic_auth=(JIRA_EMAIL, JIRA_API_TOKEN))
print(j.myself())
"
```

### 3. 커스텀 필드 ID 확인

Story Points와 Epic Link 필드 ID는 Jira 인스턴스마다 다릅니다. 조회:

```bash
./.venv/bin/python -c "
from config import *
from jira import JIRA
j = JIRA(server=JIRA_URL, basic_auth=(JIRA_EMAIL, JIRA_API_TOKEN))
for f in j.fields():
    if 'Point' in f['name'] or 'Epic' in f['name']:
        print(f['id'], f['name'])
"
```

## 다음 단계

- Setup 문제 → `docs/setup.md`
- 읽기 작업 → `docs/reading.md`
- 쓰기 작업 → `docs/writing.md`
