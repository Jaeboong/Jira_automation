---
description: jira-automation 원클릭 셋업 — .env/컨벤션 자동 발견·복사, 의존성 설치, 스킬 등록, 연결 진단까지.
---

# /setup — jira-automation 셋업

이 레포를 사용자 환경에 처음 설치할 때 실행합니다. 아래 단계를 **순서대로** 수행하세요. 각 단계가 성공한 뒤 다음으로 넘어가고, 실패하면 사용자에게 원인을 보고한 뒤 중단합니다.

## 0. 전제 확인

먼저 `pwd` 로 현재 디렉토리가 jira-automation 레포 루트인지 확인합니다 (루트에 `pyproject.toml` 과 `jira_automation/` 이 있어야 함). 아니면 사용자에게 `cd <레포>` 후 재실행을 안내하고 중단.

## 1. 기존 `.env` 감지

사용자 설정 위치와 레포 루트 둘 다 확인합니다:

```bash
test -f ~/.config/jira-automation/.env && echo "USER_ENV_EXISTS" || echo "USER_ENV_MISSING"
test -f ./.env && echo "REPO_ENV_EXISTS" || echo "REPO_ENV_MISSING"
```

분기:

- **`USER_ENV_EXISTS`** → "이미 `~/.config/jira-automation/.env` 가 있습니다. 덮어쓸까요?" 명시적 yes 가 아니면 **2단계 스킵, 2.5 로**.
- **`USER_ENV_MISSING` + `REPO_ENV_EXISTS`** → 레포 루트의 `.env` 사용 의사 확인. "레포 루트에 `.env` 가 있습니다 (`./.env`). 사용자 설정 위치 (`~/.config/jira-automation/.env`) 로 복사할까요? (y/n)" — yes 면:
  ```bash
  mkdir -p ~/.config/jira-automation
  cp ./.env ~/.config/jira-automation/.env
  chmod 600 ~/.config/jira-automation/.env
  ```
  복사 후 **2단계 스킵, 2.5 로**. no 면 2단계 진행 (대화형으로 새로 작성).
- **둘 다 MISSING** → 2단계 진행.

> 자동 복사하지 않고 굳이 묻는 이유: 레포의 `.env` 에는 API 토큰이 들어있을 수 있고, 사용자가 이걸 사용자 설정으로 옮기려고 의도했는지 확실하지 않기 때문.

## 2. `.env` 대화형 작성

(1단계에서 명시적으로 이 단계로 분기된 경우만 실행)

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

## 2.5. Jira 컨벤션 설정

먼저 기존 컨벤션 감지:

```bash
test -f ~/.config/jira-automation/convention.md && echo "EXISTS" || echo "MISSING"
```

- `EXISTS` → "이미 `~/.config/jira-automation/convention.md` 가 있습니다. 덮어쓸까요?" 명시적 yes 가 아니면 **이 단계 스킵, 3단계로**.
- `MISSING` → 아래 자동 발견 절차.

### 자동 발견: `conventions/` 스캔

`conventions/` 디렉토리에서 `default.md` 를 제외한 `.md` 파일 목록을 만듭니다 (`default.md` 는 더 이상 디폴트로 쓰지 않지만, 포크에서 다시 추가될 수 있어 방어적으로 제외):

```bash
mapfile -t CONV_FILES < <(find conventions -maxdepth 1 -type f -name '*.md' ! -name 'default.md' | sort)
echo "FOUND=${#CONV_FILES[@]}"
printf '%s\n' "${CONV_FILES[@]}"
```

분기:

- **`FOUND=1`** → 자동 사용:
  ```bash
  mkdir -p ~/.config/jira-automation
  cp "${CONV_FILES[0]}" ~/.config/jira-automation/convention.md
  ```
  사용자에게 "`<파일명>` 을 컨벤션으로 적용했습니다" 알림.

- **`FOUND>=2`** → 사용자에게 목록 보여주고 어느 걸 쓸지 묻기. 답 받으면 위와 동일하게 `cp`.

- **`FOUND=0`** → 대화형 (아래):

  > **팀이 사용하는 Jira 컨벤션 문서가 있나요? (y/n)**
  >
  > - `y` — 경로 (로컬 파일 또는 URL) 를 알려주시거나, 내용을 직접 붙여넣어 주세요.
  > - `n` — 컨벤션 없이 진행. 이슈 생성/수정 시 일반적인 베스트프랙티스를 따릅니다. 나중에 `~/.config/jira-automation/convention.md` 를 직접 작성해 덮어쓸 수 있습니다.

  사용자 응답에 따라:

  **(y — 로컬 경로)** :
  ```bash
  mkdir -p ~/.config/jira-automation
  cp "<user-provided-path>" ~/.config/jira-automation/convention.md
  ```

  **(y — 내용 붙여넣기)** :
  ```bash
  mkdir -p ~/.config/jira-automation
  cat > ~/.config/jira-automation/convention.md <<'EOF'
  <사용자가 붙여넣은 내용 그대로>
  EOF
  ```

  **(y — URL)** :
  ```bash
  mkdir -p ~/.config/jira-automation
  curl -fsSL <url> -o ~/.config/jira-automation/convention.md
  ```
  실패 시 URL 재확인 요청.

  **(n)** : 컨벤션 파일 생성 없이 다음 단계로. (생성/수정 명령은 `~/.config/jira-automation/convention.md` 가 없어도 동작.)

저장 후 간단히 확인 출력 (생성한 경우만):

```bash
echo "---"; head -5 ~/.config/jira-automation/convention.md; echo "..."
```

## 3. Python / pipx 준비

먼저 파이썬을 찾습니다 (플랫폼별 이름 차이):

```bash
for py in python3 python py; do command -v "$py" >/dev/null 2>&1 && { PY=$py; break; }; done
echo "PY=${PY:-MISSING}"
```

- `PY=MISSING` 이면 중단하고 사용자에게 Python 3.10+ 설치 안내 (https://www.python.org/downloads/ — Windows Installer 는 "Add Python to PATH" 체크 필수).
- 발견되면 이후 모든 명령에서 이 인터프리터를 사용하세요 (Bash 변수 `$PY`).

그다음 pipx:

```bash
command -v pipx >/dev/null 2>&1 && echo "HAVE_PIPX" || echo "NO_PIPX"
```

- `HAVE_PIPX` 이면 다음 단계.
- `NO_PIPX` 이면 **자동 설치를 시도**합니다 (root 불필요, 사용자 site-packages):

  ```bash
  $PY -m pip install --user --upgrade pipx
  ```

  성공 후에도 이 셸 PATH 에는 `pipx` 바이너리가 아직 없을 수 있으니, 이후 pipx 호출은 **반드시 `$PY -m pipx`** 형식으로 합니다 (PATH 우회).

  `pip install` 자체가 실패하면 (managed 환경, 네트워크 등) stderr 를 그대로 보고하고 중단. PEP 668 (`externally-managed-environment`) 이면 사용자에게 다음 옵션 안내:
  - `sudo apt install pipx` (Debian/Ubuntu/WSL)
  - `brew install pipx` (macOS)
  - `python3 -m pip install --user --break-system-packages pipx` (시스템 보호 우회 — 비권장)

## 4. 패키지 설치

```bash
# HAVE_PIPX 였던 경우
pipx install . --force

# NO_PIPX 여서 방금 설치한 경우 (권장 — 양쪽 다 안전)
$PY -m pipx install . --force
```

`--force` 로 재설치 포함 멱등 처리. 실패하면 stderr 를 그대로 보고하고 중단.

> **PATH 주의:** pipx 가 새로 설치됐다면 `jira` 바이너리의 위치 (예: `~/.local/bin/jira`) 가 현재 셸 PATH 에 아직 없을 수 있습니다. 이 setup 내에서 `jira` 를 직접 호출하지 말고, PATH 의존성 없는 **`$PY -m jira_automation <cmd>`** 를 사용하세요. 사용자 편의를 위해 아래 명령을 한 번 돌려둡니다 (실패해도 무시):
>
> ```bash
> $PY -m pipx ensurepath 2>/dev/null || true
> ```
>
> `ensurepath` 가 추가한 PATH 는 **새 셸** 에서만 반영됩니다. 7단계 요약에서 이 점을 사용자에게 안내하세요.

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

PATH 의존성을 피해 모듈 형태로 호출합니다:

```bash
$PY -m jira_automation doctor
```

(`jira` 바이너리가 PATH 에 반영됐다면 `jira doctor` 도 동일 결과)

출력에 `[CONNECT] OK` 와 `[FIELD] ... (auto)` 가 모두 나오면 성공. 실패하면 에러 줄을 발췌해 사용자에게 보여주고 다음 권고:

- `JIRA .env 파일을 찾을 수 없습니다` → 1/2단계에서 쓴 경로 재확인
- `401 Unauthorized` → 이메일/토큰 재확인, 필요 시 토큰 재발급
- `Story Points / Epic Link ... UNRESOLVED` → 에러 메시지의 후보 id 를 `~/.config/jira-automation/.env` 에 `JIRA_STORY_POINTS_FIELD` / `JIRA_EPIC_LINK_FIELD` 로 추가

## 7. 요약 보고

마지막에 사용자에게 다음을 표시:

- `.env` 경로 (`~/.config/jira-automation/.env`) + 출처 ("repo 루트에서 복사" / "대화형 입력" / "기존 유지")
- 컨벤션 경로 (`~/.config/jira-automation/convention.md`) + 출처 ("conventions/<파일명> 자동 선택" / "사용자 입력" / "기존 유지" / "없음")
- 심링크 상태 (`~/.claude/skills/jira → <pwd>`)
- `doctor` PASS 여부
- **pipx 를 방금 설치했다면**: "`jira` 바이너리는 새 셸에서부터 PATH 에 반영됩니다. 현재 셸에서 쓰려면 `$PY -m jira_automation ...` 를 사용하거나 새 터미널을 여세요." 안내
- 다음에 쓸 명령: `jira --help` (또는 `$PY -m jira_automation --help`), `jira search --limit 10`

셋업 후 새 Claude Code 세션에서 "지라 이슈 검색해줘" 같은 요청 시 스킬이 자동 매칭됩니다.

## 안전 장치

- 이 파일에 지시된 것 외의 파일을 수정하거나 삭제하지 마세요.
- 어느 단계든 실패하면 **다음 단계로 진행하지 말고** 사용자에게 보고.
- 사용자가 중간에 중단을 요청하면 즉시 멈추고 현재까지의 상태를 요약.
