---
name: dockerfile-optimization
description: 이 저장소의 빌드/개발 환경은 Nix Flake 중심이다. Dockerfile을 다루게 되는 경우에만 최적화 원칙을 적용한다.
license: Apache-2.0
metadata:
  author: ochestrator
  version: "1.0"
---

## When to Use

- `flake.nix`/`shell.nix`/`package.nix` 등 Nix 기반 빌드/개발 환경을 수정할 때
- Dockerfile을 새로 추가하거나, 컨테이너 이미지 빌드 파이프라인을 도입/수정할 때

## Rules

- Nix devShell/패키지는 재현 가능하도록 입력(버전/해시)을 고정한다
- 로컬 스크립트는 가능하면 `nix develop --command ...` 경로로 실행 가능해야 한다
- Dockerfile을 도입하는 경우에만 멀티 스테이지/캐시 최적화/불필요한 레이어 유입 방지를 적용한다

## Repository Policy

- CI는 Nix Flake를 기준으로 동작한다

## Validation

- `prek-quality-gate`를 활성화하여 `./scripts/lint.sh`까지 통과시키기
