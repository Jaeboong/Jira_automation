# Jira CLI Tools — Codex Agent Guide

이 워크스페이스의 Jira CLI 스크립트용 에이전트 진입점. Codex가 매 세션 자동 로드합니다.

## 절대 규칙

1. 명령 실행 전 반드시 이 디렉토리로 `cd`.
2. `./.venv/bin/python`을 사용. raw `python` 금지.
3. 스코프는 `.env` `JIRA_PROJECT_KEY`로 고정. 다른 프로젝트 키 언급 시 설정된 키로 재작성.
4. 조회는 `search_issues.py` + 임시 markdown 파일 경유. **터미널 출력에서 이슈 본문을 직접 파싱하지 말 것.**
5. `.env` 값은 `config.py`가 파이썬 프로세스 안에서 자동 로드. **쉘 변수로 참조하지 말 것.**
6. 세션 첫 명령은 `bash scripts/ensure_environment.sh`.
7. 생성/수정 전 `jiraconvention.md` 반드시 숙지.

## 언제 무엇을 읽을지

| 상황 | 먼저 읽기 |
|---|---|
| 이 프로젝트가 낯설 때 | `README.md` |
| 첫 세션 / setup 오류 | `docs/setup.md` |
| 이슈 검색 / 목록 / 조회 | `docs/reading.md` |
| 이슈 생성 / 수정 / 에픽 연결 | `docs/writing.md` + `jiraconvention.md` |
| 에러 발생 시 | `docs/troubleshooting.md` |

## 주력 스크립트

- `search_issues.py` — 모든 읽기
- `create_issues.py` — 생성
- `update_issues.py` — 상태 / 담당자 / 포인트 / 코멘트 수정
- `link_epic.py` — Story/Task를 Epic에 연결

다른 `.py` 파일은 deprecated 이거나 일회성 유틸리티입니다. 사용자가 명시적으로 요청하지 않는 한 실행하지 마세요.
