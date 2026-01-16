---
name: test-isolation
description: 테스트를 결정적(deterministic)으로 유지하고 병렬 실행에서도 독립성을 보장하는 원칙과 적용 절차. 런타임이 Linux 전용인 특성을 고려한다.
license: Apache-2.0
metadata:
  author: ochestrator
  version: "1.0"
---

## Rules

- 테스트는 단위 테스트(`src/**`)와 통합 테스트(`tests/`)로 나눠 관리
- 병렬 실행 시에도 테스트 간 상태 공유(전역 상태/고정 포트/공용 디렉토리)를 금지
- 파일 시스템은 `tempfile` 등 임시 디렉토리를 사용하고 테스트 종료 시 정리
- 시간/랜덤/환경변수 의존성은 최소화하고, 필요 시 입력을 명시적으로 주입
- OS 의존 기능(네임스페이스/FUSE/소켓/경로 등)은 테스트를 분리하고, Windows에서도 최소 컴파일/유닛 테스트가 가능하도록 경계를 둔다

## Rust

- 크레이트 범위를 좁혀 반복 실행: `cargo test -p <crate> <test_name>`
- Linux 전용 테스트는 `#[cfg(target_os = "linux")]`로 분리

## Python (있을 때)

- Python 파일 변경 시 정적 검증: `bash py/lint.sh`

## Completion Criteria

- 테스트가 다른 테스트 실행 순서/병렬 워커에 영향을 받지 않음
- 단독 실행/전체 실행에서 안정적으로 재현 및 통과
