# Writing Issues

이슈 생성, 수정, 에픽 연결. 모든 쓰기 작업은 `.env` `JIRA_PROJECT_KEY`로 스코프 고정.

## 사전 요구사항

1. `docs/setup.md` 완료
2. **`jiraconvention.md` 숙지** — 제목 형식, 설명 템플릿, Story Point 기준

## 컨벤션 체크리스트

생성/수정 전 확인:

- [ ] 제목이 `[파트] 작업 설명` 형식 (파트 ∈ `FE`, `BE`, `AI`, `DOCS`)
- [ ] Story Point 1-10이 `jiraconvention.md` 기준에 부합
- [ ] 상태 전환이 `To Do → In Progress → Code Review → Done` 흐름 준수

## `create_issues.py`

```bash
./.venv/bin/python create_issues.py \
  --project PROJECT \
  --summary "TITLE" \
  --description "DESC" \
  [--type Task|Story|Bug|Epic] \
  [--priority High|Medium|Low] \
  [--points N]
```

`--project`는 스크립트 자체가 required로 요구합니다. `.env` `JIRA_PROJECT_KEY` 값을 **리터럴**로 넣으세요 (`$JIRA_PROJECT_KEY`는 쉘에서 빈 문자열).

### 예시 — Story + Points

```bash
./.venv/bin/python create_issues.py \
  --project MYPROJ \
  --summary "[BE] JWT 인증 로직 구현" \
  --description "## 완료 조건\n- 토큰 발급\n- 검증 미들웨어\n\n## 기타\n- 만료 24h" \
  --type Story --priority High --points 8
```

### 예시 — Epic

```bash
./.venv/bin/python create_issues.py \
  --project MYPROJ \
  --summary "LLM 통합" \
  --type Epic --priority High
```

## `update_issues.py`

```bash
./.venv/bin/python update_issues.py --key ISSUE_KEY [OPTIONS]
```

### 인자

| Flag | 값 |
|---|---|
| `--key` | 필수. 예: `MYPROJ-3` |
| `--status` | `해야 할 일`, `진행 중`, `완료` (실제 Jira 워크플로우 레이블에 맞게) |
| `--assign` | `me` 또는 사용자명 |
| `--comment` | 코멘트 텍스트 |
| `--summary` | 제목 변경 |
| `--priority` | `High` / `Medium` / `Low` |
| `--points` | Story Points 정수 |

### 예시

```bash
./.venv/bin/python update_issues.py --key MYPROJ-3 --assign me
./.venv/bin/python update_issues.py --key MYPROJ-3 --status "진행 중" --comment "Started"
./.venv/bin/python update_issues.py --key MYPROJ-3 --points 8
./.venv/bin/python update_issues.py --key MYPROJ-3 --status "완료"
```

## `link_epic.py`

```bash
./.venv/bin/python link_epic.py --issue ISSUE_KEY --epic EPIC_KEY
```

스크립트는 Epic Link 필드 ID 3가지를 순서대로 시도합니다 (`customfield_10014`, `customfield_10008`, 이름 `Epic Link`). 모두 실패하면 Jira 관리자에게 올바른 필드 ID 문의.

### 예시

```bash
./.venv/bin/python link_epic.py --issue MYPROJ-82 --epic MYPROJ-80
```

## 전체 워크플로우 — Epic + Story + Link

```bash
# 1. Epic 생성
./.venv/bin/python create_issues.py --project MYPROJ --summary "LLM 통합" --type Epic
# -> 반환된 Epic 키 기억 (예: MYPROJ-80)

# 2. 하위 Story 생성
./.venv/bin/python create_issues.py --project MYPROJ \
  --summary "[BE] LLM 프롬프트 파이프라인" --type Story --points 8
# -> 반환된 Story 키 기억 (예: MYPROJ-82)

# 3. 연결
./.venv/bin/python link_epic.py --issue MYPROJ-82 --epic MYPROJ-80
```
