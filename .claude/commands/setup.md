---
description: jira-automation 원클릭 셋업 — 의존성 설치, .env 대화형 작성, 스킬 등록, 연결 진단까지.
---

# /setup — jira-automation 셋업

이 레포를 사용자 환경에 처음 설치할 때 실행합니다. 아래 단계를 **순서대로** 수행하세요. 각 단계가 성공한 뒤 다음으로 넘어가고, 실패하면 사용자에게 원인을 보고한 뒤 중단합니다.

## 0. 전제 확인

먼저 `pwd` 로 현재 디렉토리가 jira-automation 레포 루트인지 확인합니다 (루트에 `pyproject.toml` 과 `jira_automation/` 이 있어야 함). 아니면 사용자에게 `cd <레포>` 후 재실행을 안내하고 중단.

## 1. 기존 설정 감지

```bash
test -f ~/.config/jira-automation/.env && echo "EXISTS" || echo "MISSING"
```

- `EXISTS` 이면 "이미 `~/.config/jira-automation/.env` 가 있습니다. 덮어쓸까요?" 물어서 **명시적 yes 가 아니면 2단계를 건너뛰고 3단계로**.
- `MISSING` 이면 2단계 진행.

## 2. `.env` 대화형 작성

사용자에게 네 개 값을 **순차적으로** 질문하세요. 각 질문 전에 짧은 설명을 덧붙입니다. **API 토큰 질문 직전에는 반드시 이 경고를 먼저 표시**:

> ⚠️  다음 질문의 응답(API 토큰)은 이 채팅 컨텍스트에 기록됩니다. 세션을 공유/로그하는 환경이면 입력 후 https://id.atlassian.com/manage-profile/security/api-tokens 에서 회전(revoke+재발급)을 권장합니다. 회전이 부담되면 여기서 중단하고 `~/.config/jira-automation/.env` 를 직접 편집하셔도 됩니다.

질문 순서:

1. **JIRA_URL** — "Atlassian 사이트 주소 (예: `https://your-company.atlassian.net`)"
2. **JIRA_EMAIL** — "Atlassian 계정 이메일"
3. **(위 경고 후) JIRA_API_TOKEN** — "API 토큰. 없으시면 먼저 https://id.atlassian.com/manage-profile/security/api-tokens 에서 발급"
4. **JIRA_PROJECT_KEY** — "작업 스코프로 고정할 프로젝트 키 (예: `PROJ`)"

네 값이 모두 모이면:

```bash
mkdir -p ~/.config/jira-automation
cat > ~/.config/jira-automation/.env <<'EOF'
JIRA_URL=<입력값 1>
JIRA_EMAIL=<입력값 2>
JIRA_API_TOKEN=<입력값 3>
JIRA_PROJECT_KEY=<입력값 4>
EOF
chmod 600 ~/.config/jira-automation/.env
```

`<입력값 N>` 은 사용자가 준 실제 값으로 치환. **heredoc quote (`'EOF'`) 를 꼭 유지** — 토큰에 `$` 가 있으면 쉘 확장되는 사고를 막기 위함.

## 3. `pipx` 확인/설치

```bash
command -v pipx >/dev/null && echo "OK" || echo "MISSING"
```

- `OK` 이면 다음 단계.
- `MISSING` 이면 사용자에게 아래 안내하고 중단 (root 권한이 필요할 수 있어 자동 실행하지 않음):

  ```
  pipx 가 없습니다. 다음 명령으로 설치 후 /setup 을 다시 실행하세요:

      python3 -m pip install --user pipx
      python3 -m pipx ensurepath
      # 이후 새 셸을 열거나 source ~/.bashrc
  ```

## 4. 패키지 설치

현재 디렉토리(레포 루트)에서:

```bash
pipx install . --force
```

`--force` 로 재설치 포함 안전하게 처리. 실패하면 stderr 그대로 사용자에게 보고 후 중단.

## 5. 스킬 심링크

```bash
mkdir -p ~/.claude/skills
if [ -L ~/.claude/skills/jira ] || [ -e ~/.claude/skills/jira ]; then
  echo "SKIP: ~/.claude/skills/jira 이미 존재"
else
  ln -s "$(pwd)" ~/.claude/skills/jira && echo "LINKED"
fi
```

이미 있으면 건드리지 않음 — 사용자가 의도적으로 만든 다른 버전일 수 있음.

## 6. 진단

```bash
jira doctor
```

출력에 `[CONNECT] OK` 와 `[FIELD] ... (auto)` 가 모두 나오면 성공. 실패하면 에러 줄을 발췌해 사용자에게 보여주고 다음 권고:

- `JIRA .env 파일을 찾을 수 없습니다` → 2단계에서 쓴 경로 재확인
- `401 Unauthorized` → 이메일/토큰 재확인, 필요 시 토큰 재발급
- `Story Points / Epic Link ... UNRESOLVED` → 에러 메시지의 후보 id 를 `~/.config/jira-automation/.env` 에 `JIRA_STORY_POINTS_FIELD` / `JIRA_EPIC_LINK_FIELD` 로 추가

## 7. 요약 보고

마지막에 사용자에게 다음을 표시:

- `.env` 경로 (`~/.config/jira-automation/.env`)
- 심링크 상태 (`~/.claude/skills/jira → <pwd>`)
- `jira doctor` PASS 여부
- 다음에 쓸 명령: `jira --help`, `jira search --limit 10`

셋업 후 새 Claude Code 세션에서 "지라 이슈 검색해줘" 같은 요청 시 스킬이 자동 매칭됩니다.

## 안전 장치

- 이 파일에 지시된 것 외의 파일을 수정하거나 삭제하지 마세요.
- 어느 단계든 실패하면 **다음 단계로 진행하지 말고** 사용자에게 보고.
- 사용자가 중간에 중단을 요청하면 즉시 멈추고 현재까지의 상태를 요약.
