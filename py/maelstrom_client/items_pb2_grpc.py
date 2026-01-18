from __future__ import annotations

import importlib.util
import sys
from pathlib import Path


def _load_from_target() -> object:
    repo_root = Path(__file__).resolve().parents[2]
    target_file = repo_root / "target" / "py" / "items_pb2_grpc.py"
    if not target_file.exists():
        raise FileNotFoundError(
            f"Missing generated protobuf module: {target_file}. "
            "Run py/protobuf_compile.sh to generate it."
        )

    spec = importlib.util.spec_from_file_location(__name__, target_file)
    if spec is None or spec.loader is None:
        raise ImportError(f"Failed to load module spec from: {target_file}")

    module = importlib.util.module_from_spec(spec)
    sys.modules[__name__] = module
    spec.loader.exec_module(module)
    sys.modules.setdefault("items_pb2_grpc", module)
    return module


_module = _load_from_target()
globals().update(_module.__dict__)
