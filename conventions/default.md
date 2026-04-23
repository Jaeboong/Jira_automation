# Jira Convention — Global Default

`/setup` 에서 "팀 컨벤션 없음" 을 선택하면 이 문서가 `~/.config/jira-automation/convention.md` 에 복사됩니다. Atlassian / Scrum 기본 관례를 따릅니다. 프로젝트 상황에 맞지 않으면 `~/.config/jira-automation/convention.md` 를 직접 편집하세요.

---

## 1. Issue 유형

| Type | 용도 |
|---|---|
| Epic | 여러 릴리즈에 걸칠 수 있는 큰 작업 덩어리 |
| Story | 사용자 가치를 전달하는 기능 단위 |
| Task | 사용자 노출 없는 기술적 작업 |
| Bug | 결함 수정 |
| Sub-task | 위 항목의 세부 쪼갬 |

일반 구조: `Epic → Story/Task → Sub-task`

---

## 2. 제목 형식

- **명령조 (imperative)** 로 작성: "Add X", "Fix Y", "Refactor Z"
- 영역 태그는 선택: `[BE] 로그인 API 추가` 처럼 prefix 가능하지만 강제 아님
- 한 줄 요약이 이해되지 않으면 제목이 너무 크므로 쪼갤 신호

---

## 3. Story Points (Fibonacci)

| Point | 기준 |
|---|---|
| 1 | 사소 — 오타, 설정 한 줄 |
| 2 | 작음, 잘 이해된 작업 |
| 3 | 하루치 표준 작업 |
| 5 | 중간 — 며칠 걸릴 수 있음 |
| 8 | 큼 — 불확실성 포함 |
| 13 | 매우 큼 — **분할 고려** |

Story Point 는 시간이 아니라 상대적 복잡도/노력 입니다. 13 이상은 스프린트에 넣지 말고 쪼개세요.

---

## 4. 상태 흐름

기본 Atlassian Scrum 워크플로우:

```
To Do → In Progress → Done
```

리뷰 게이트가 있는 팀:

```
Backlog → Selected for Development → In Progress → In Review → Done
```

실제 상태 이름은 Jira 프로젝트 워크플로우 설정에 따라 다릅니다. `jira update <KEY> --status ...` 실패 시 에러 메시지의 "가능:" 목록을 참고하세요.

---

## 5. 우선순위

`Highest / High / Medium / Low / Lowest` 중에서 Jira 프로젝트가 허용하는 값. Medium 이 기본.

---

## 6. 설명 (Description)

- **Acceptance Criteria / Definition of Done** 를 명시
- Epic / 블로커 / 관련 이슈 링크
- 500 단어 이하를 권장 — 세부 논의는 코멘트로

템플릿:

```
## 배경
<왜 필요한가>

## 완료 조건
- [ ] ...
- [ ] ...

## 관련
- 상위 Epic: PROJ-12
- 블로킹: PROJ-34
```

---

## 7. 라벨 / 컴포넌트

팀 합의가 없다면:
- **라벨** 은 가벼운 필터용 (예: `tech-debt`, `spike`)
- **컴포넌트** 는 코드 영역 (예: `backend`, `frontend`, `infra`)

둘 다 선택 — 강제 아님.

---

## 편집

이 기본값이 팀에 맞지 않으면 `~/.config/jira-automation/convention.md` 를 편집하세요. `/setup` 을 다시 실행하지 않아도 에이전트는 이 경로의 최신본을 읽습니다.
