---
name: prek-quality-gate
description: 이 저장소의 정적 분석/품질 게이트를 실행하는 절차. CI와 동일한 스크립트를 우선하고, 로컬에서 대체 커맨드를 제공.
license: Apache-2.0
metadata:
  author: ochestrator
  version: "1.0"
---

## When to Use

- 코드 변경 후, 병합/커밋 전에 항상 수행

## Primary Gate

- Windows 로컬(우선): `cargo fmt --all -- --check` + 변경 크레이트 기준 `cargo check -p <crate>`
- CI와 동일(Linux + Nix): `./scripts/lint.sh`

## Incremental First

- 변경 범위가 명확하면, 아래 대체 커맨드로 로컬 확인을 먼저 수행할 수 있다
- 단, CI 안정성이 중요하면 `./scripts/lint.sh`로 최종 확인한다

## What This Covers (Repository)

- Rustfmt: `cargo fmt --all -- --check`
- Clippy: `cargo clippy --workspace --all-targets -- -D warnings`
- 컴파일 점검: `cargo check --all-targets`
- 린트(추가): `cargo xtask publish --lint`
- Python 파일 수정 시: `bash py/lint.sh`

## References

- `./scripts/lint-inner.sh`
- `.github/workflows/ci.yml`
