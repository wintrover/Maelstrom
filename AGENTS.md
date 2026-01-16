# AGENTS.md

이 파일은 이 저장소에서 AI 코딩 에이전트가 작업할 때 필요한 고정 규칙(항상 적용)과 실행 진입점을 제공합니다.

## Setup Commands

- 툴체인 확인(Windows): `rustc --version` / `cargo --version`
- 포맷 체크(Windows): `cargo fmt --all -- --check`
- 부분 빌드(Windows): `cargo check -p <crate>`
- 전체 빌드/테스트(리눅스 환경): `cargo test --workspace`
- 린트/정적 분석(리눅스 환경): `cargo clippy --workspace --all-targets -- -D warnings`
- CI와 동일 게이트(Linux + Nix): `./scripts/lint.sh`

## Standard Environment

- 개발 환경: Windows(기본)
- 목표: Windows + Docker Desktop + WSL2 환경에서 프로젝트가 정상 동작하도록 개선
- 현재 제약: 컨테이너/격리 실행 경로는 Linux 커널 기능(네임스페이스/FUSE 등)에 의존
- 스크립트 실행: `./scripts/*.sh`는 Bash/Nix 기반이며, Windows에서는 CI 또는 별도 Linux 환경에서 주로 실행
- git 명령 실행 시: 항상 `--no-pager` 사용

## Required Tooling Policy

- 코드 탐색: code-index MCP 사용
- 공식 문서 탐색: context7 MCP 사용
- 사고 과정 정리: sequential thinking MCP 사용
- 브라우저 로그 확인: Chrome DevTools MCP 사용

## Output Language

- 최종 산출물/사용자 응대: 한국어
- Git 커밋 메시지: 저장소 기존 커밋 관례를 따름(제목 간결, 본문 상세)

## Database Constraints

- 현재 코드베이스는 데이터베이스를 직접 사용하지 않음
- DB를 새로 도입해야 한다면 MariaDB만 사용(테스트/로컬 포함), SQLite 금지

## Logging Policy

- 로깅은 `slog`의 구조화 로그를 사용
- 과도한 진행/상태 로그는 지양하고, 수명주기(시작/종료) 및 오류 분석에 필요한 로그만 남김
- 오류 발생 시에는 원인 분석이 가능하도록 컨텍스트(입력 요약, 단계, 상관관계 ID 등)를 충분히 포함
- 비밀/민감 정보(토큰, 비밀번호, 개인정보 등)는 로그에 절대 포함하지 않음

## Development Principles

- SOLID 원칙 준수
- 관심사 분리(SoC)로 응집도↑, 결합도↓
- DRY 및 SSOT 지향(설정은 외부화)
- 임시/더미/하드코딩 금지
- 안정성 우선
- 오버헤드가 큰 작업은 `indicatif` 등으로 진행 상황 표시

## Quality Gates (Always)

- 변경 전: TDD로 테스트를 먼저 작성
- 변경 후(Windows): `cargo fmt --all -- --check` + 변경 크레이트 기준 `cargo check -p <crate>`
- 변경 후(Linux 게이트): `cargo test --workspace` + `cargo clippy --workspace --all-targets -- -D warnings` + CI 스크립트(`./scripts/lint.sh`)
- 변경 후(통합 회귀): 격리/브로커/워커 경로 변경이면 `./scripts/run-tests-on-maelstrom.sh`까지 포함

자세한 절차는 아래 Skills를 활성화해서 따릅니다.

## Skills Catalog

Skills는 `/skills/<skill-name>/SKILL.md`에 정의되어 있고, 필요할 때만 로드합니다(Progressive Disclosure).

- `change-validation`: 코드 변경(특히 기능/버그 수정) 시 기본 검증 워크플로우
- `mutation-testing`: 돌연변이 테스트 실행/리포트 절차
- `prek-quality-gate`: 품질 게이트 실행 절차(CI 스크립트 기준)
- `test-isolation`: 테스트 격리 원칙(병렬/OS 분기 포함)
- `dockerfile-optimization`: Nix/Docker 기반 빌드 환경 변경 절차
- `logging-policy`: 로깅 정책 적용 체크리스트
- `architecture-principles`: SOLID/SoC/DRY/SSOT 적용 체크리스트
- `merge-conflict-resolution`: 병합 충돌 해결 원칙
- `git-atomic-commit`: 원자적 커밋/푸시 절차

## Skill Activation Rules

- 코드 변경이 발생하면 `change-validation`을 먼저 활성화
- 비동기/테스트 변경이 크면 `test-isolation`을 추가 활성화
- 핵심 로직 변경 또는 회귀 리스크가 크면 `mutation-testing`을 추가 활성화
- Dockerfile/컨테이너 변경이면 `dockerfile-optimization`을 추가 활성화
- 로깅 관련 변경이면 `logging-policy`를 추가 활성화
- 구조/설계 변경이면 `architecture-principles`를 추가 활성화
- 커밋 단위 정리가 필요하면 `git-atomic-commit`을 추가 활성화
