---
name: mutation-testing
description: 돌연변이 테스트를 수행하는 절차. 이 저장소에는 현재 돌연변이 테스트 도구가 CI에 고정되어 있지 않으며, 필요 시 도구를 선택해 도입한다.
license: Apache-2.0
metadata:
  author: ochestrator
  version: "1.0"
---

## When to Use

- 핵심 도메인 로직, 인증/권한, 파일 처리, 워크플로우, 장애/예외 처리 등 회귀 리스크가 큰 변경

## Current State

- CI에서 돌연변이 테스트를 실행하지 않는다
- 도입이 필요해지면 Rust 중심으로 도구를 선택하고(예: `cargo-mutants`), 실행 비용/플레이키 처리/기준치를 합의한다

## Rust (Option) — cargo-mutants

### Run

- 설치 후 실행(예시): `cargo mutants --workspace`

### Notes

- 런타임이 Linux 전용인 크레이트는 Linux 환경에서 실행한다
- 실행 시간이 길어질 수 있으므로, 변경 범위를 좁혀서 시작하는 것을 권장한다(패키지/모듈 단위)

## Completion Criteria

- 실행이 실패하지 않고 리포트가 생성됨
- 생존(survived) 돌연변이가 발생하면, 테스트 보강 또는 설계/검증 로직 개선으로 제거
