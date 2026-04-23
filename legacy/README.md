# Legacy scripts

패키지화 이전의 일회성 유틸리티입니다. 지원 대상 아님, 참고용으로만 유지.

새 코드에서 사용하지 말고 `jira` CLI (`jira_automation/`) 를 쓰세요. 이 디렉토리의 스크립트는 `from config import ...` 에 의존했으나 해당 루트 `config.py` 는 패키지로 이동하면서 제거되었으므로, **현 상태에서는 import 가 깨져 실행되지 않습니다.**

복구가 필요하다면:

1. 상단 import 를 `from jira_automation.config import load_config` 로 바꾸고
2. 모듈 레벨 상수 참조 (`JIRA_URL` 등) 를 `cfg = load_config()` 후 `cfg.jira_url` 식으로 리팩터

하거나, 해당 로직이 여전히 필요하다면 `jira_automation/` 안으로 정식 포팅하세요.
