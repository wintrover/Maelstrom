---
name: git-atomic-commit
description: 변경 내용 단위로 원자적 커밋을 만들고 원격으로 푸시하는 절차. git 명령은 --no-pager를 사용하고, 커밋 메시지는 저장소 관례를 따른다.
license: Apache-2.0
metadata:
  author: ochestrator
  version: "1.0"
---

## When to Use

- 작업이 완료되어 변경을 묶어 전달할 준비가 되었을 때

## Rules

- 변경 내용 단위로 커밋을 쪼개고, 각 커밋은 독립적으로 빌드/테스트가 가능해야 한다
- 커밋 메시지는 기존 저장소 관례를 따른다(제목 간결, 본문 상세)
- git 명령은 항상 `--no-pager`

## Checklist

- 포맷/린트/타입체크/테스트가 통과했는가
- 커밋 범위가 하나의 목적을 가지는가
- 비밀/민감 정보가 포함되지 않았는가
