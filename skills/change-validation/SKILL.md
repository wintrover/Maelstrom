---
name: change-validation
description: 코드 변경 시 TDD로 테스트를 선행하고, 단위/통합/E2E 회귀 테스트 및 품질 게이트를 병렬로 수행하는 절차. 테스트/회귀/검증/prek/컨테이너/증분 키워드 포함.
license: Apache-2.0
metadata:
  author: ochestrator
  version: "1.0"
---

## When to Use

- 기능 추가/버그 수정/리팩터링 등 코드 변경이 있는 모든 작업

## Preconditions

- Rust는 크레이트별 `src/**`의 단위 테스트 및 `tests/` 통합 테스트로 커버
- OS 의존 기능은 `#[cfg(target_os = "linux")]` / `#[cfg(windows)]`로 분리하고, Windows에서 컴파일/테스트 가능한 경로를 유지

## Workflow

### 1) TDD 선행

- 변경 전 실패하는 테스트를 먼저 작성(EP-BVA, Pairwise, State Transition 중 적합한 기법 적용)
- 기존 테스트가 충분하면, 먼저 실패하는 회귀 테스트로 재현 후 수정

### 2) 빠른 로컬 회귀(증분 우선)

- 특정 크레이트만: `cargo test -p <crate>`
- 워크스페이스 전체: `cargo test --workspace`
- Windows에서 빠른 게이트: `cargo fmt --all -- --check` + 변경 크레이트 기준 `cargo check -p <crate>`
- Python 파일을 수정한 경우: `bash py/lint.sh`

### 3) 격리/클러스터 회귀(필요 시)

- 목표가 Windows + Docker Desktop + WSL2 지원인 경우, 해당 환경에서 재현 가능한 최소 시나리오(브로커/워커/클라이언트)를 포함해 검증
- 아직 Windows에서 전체 회귀가 불가능하면, Windows에서는 컴파일/단위 테스트를 우선 통과시키고 통합 회귀는 CI(Linux)에서 보강
- CI와 동일한 형태의 전체 회귀: `./scripts/run-tests-on-maelstrom.sh <token> <url>`

### 4) 품질 게이트

- `prek-quality-gate`를 활성화하고 해당 절차를 수행

### 5) 돌연변이 테스트(병렬)

- 핵심 로직/회귀 위험이 있는 변경이면 `mutation-testing`을 활성화하고 절차 수행

## Completion Criteria

- 새 테스트가 추가되어 변경을 커버하고, 회귀 테스트가 모두 통과
- 품질 게이트가 모두 통과
- 핵심 변경인 경우 돌연변이 테스트 리포트가 생성되고 기준에 부합

## Repository References

- CI 린트 게이트: `./scripts/lint.sh`
- CI 전체 테스트(Maelstrom on Maelstrom): `./scripts/run-tests-on-maelstrom.sh`
- Python 정적 검사: `py/lint.sh`
