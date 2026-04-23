# Reading Issues

모든 조회 작업은 `search_issues.py`를 사용합니다. 스크립트는 결과를 임시 markdown 파일에 저장하고 경로를 출력합니다.

## 사전 요구사항

`docs/setup.md` 완료.

## 읽기 계약 (반드시 지킬 것)

1. 스크립트 실행
2. stdout에서 `TEMP_FILE_PATH:<path>` 라인 파싱
3. 파일 읽기 도구로 해당 markdown 파일 읽기
4. 사용자에게 정리된 요약으로 제시

**절대 터미널 출력에서 이슈 본문을 직접 파싱하지 말 것** — Windows 터미널의 UTF-8 깨짐, 여러 줄 설명의 파싱 실패 위험.

## 사용법

```bash
./.venv/bin/python search_issues.py [--filter KEYWORD] [--jql JQL_QUERY]
```

`--project` 인자는 기본값이 `.env` `JIRA_PROJECT_KEY` 이므로 **일반적으로 생략**합니다.

### 인자

| Flag | 용도 |
|---|---|
| `--filter KEYWORD` | summary 또는 description에 대소문자 무시 매칭 |
| `--jql JQL_QUERY` | 직접 JQL |
| `--project KEY` | 프로젝트 스코프 오버라이드 (비권장 — `.env` 사용) |

### 출력 형식

```
Connecting to Jira...
TEMP_FILE_PATH:/tmp/tmpXXXXXXXX.md
ISSUE_COUNT:N
```

## 예시

### 설정된 프로젝트의 모든 이슈

```bash
./.venv/bin/python search_issues.py
```

### 키워드 필터

```bash
./.venv/bin/python search_issues.py --filter "WebSocket"
```

### 직접 JQL

```bash
./.venv/bin/python search_issues.py --jql "project = MYPROJ AND issuetype = Epic"
./.venv/bin/python search_issues.py --jql "assignee = currentUser()"
./.venv/bin/python search_issues.py --jql "project = MYPROJ AND status = '해야 할 일'"
```

JQL 문자열 안의 프로젝트 키는 **리터럴로 작성**하세요. 쉘은 `.env` 값을 확장하지 않습니다.

## JQL 빠른 참조

```
project = MYPROJ
project = MYPROJ AND issuetype = Epic
project = MYPROJ AND status = "해야 할 일"
assignee = currentUser()
key in (MYPROJ-1, MYPROJ-3)
project = MYPROJ AND updated >= -7d
```
