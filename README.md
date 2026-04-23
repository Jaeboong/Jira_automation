# JIRA CLI 도구

JIRA API를 사용하여 이슈를 조회, 생성, 수정하는 Python 스크립트 모음.

사용자는 AI 에이전트(Claude Code, Codex 등)에게 자연어로 요청하면, 에이전트가 이 도구들을 실행해서 결과를 정리해 돌려줍니다.

---

## 사용자 가이드

### 설정

1. `.env.example`를 복사해 `.env`를 만들고 본인 값을 입력합니다.

```bash
cp .env.example .env
```

필요한 값:

```env
JIRA_URL=https://your-company.atlassian.net
JIRA_EMAIL=your-email@example.com
JIRA_API_TOKEN=your-api-token-here
JIRA_PROJECT_KEY=YOUR_PROJECT_KEY
```

API 토큰 생성: https://id.atlassian.com/manage-profile/security/api-tokens

2. 환경 스크립트 실행 (venv 생성 + 의존성 설치 + `.env` 검증 + 연결 확인):

```bash
bash scripts/ensure_environment.sh
```

### 사용 방법

자연어로 AI 에이전트에게 요청하세요.

- "JIRA 최근 이슈 10개 알려줘"
- "나에게 할당된 이슈 목록 확인해줘"
- "WebSocket 관련 이슈 검색해줘"
- "[BE] 로그인 API 구현 Task 만들어줘"
- "MYPROJ-3 상태를 진행 중으로 바꿔줘"

---

## AI 에이전트 가이드

에이전트는 하네스별 자동 로드 파일을 먼저 읽습니다.

- **Claude Code** → `CLAUDE.md`
- **Codex** → `AGENTS.md`

세부 운영 문서는 주제별로 `docs/`에 분리되어 있습니다.

| 문서 | 언제 읽는가 |
|---|---|
| `docs/setup.md` | 첫 세션, 환경 오류 |
| `docs/reading.md` | 이슈 조회 / 검색 / 목록 |
| `docs/writing.md` | 이슈 생성 / 수정 / 에픽 연결 |
| `docs/troubleshooting.md` | 에러 발생 시 |
| `jiraconvention.md` | 이슈 생성/수정 전 필수 |

---

## 파일 구조

```
Jira/
├── README.md              # 이 파일 — 오버뷰
├── CLAUDE.md              # Claude Code 에이전트 진입점
├── AGENTS.md              # Codex 에이전트 진입점
├── SKILL.md               # 스킬 메타데이터 (프론트매터)
├── jiraconvention.md      # 이슈 명명 / Story Point 규약
├── docs/
│   ├── setup.md
│   ├── reading.md
│   ├── writing.md
│   └── troubleshooting.md
├── scripts/
│   └── ensure_environment.sh
├── config.py              # .env 로더 (단일 진리원천)
├── search_issues.py       # 조회
├── create_issues.py       # 생성
├── update_issues.py       # 수정
├── link_epic.py           # 에픽 연결
├── .env.example
└── requirements.txt
```
