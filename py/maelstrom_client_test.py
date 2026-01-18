import os
import pytest

from maelstrom_client import (
    Client,
    ContainerRef,
    ContainerSpec,
    JobSpec,
    LayerSpec,
    PathsLayer,
    PrefixOptions,
    TarLayer,
)
from pathlib import Path


class Fixture:
    def __init__(self) -> None:
        self.client = Client(slots=4)


@pytest.fixture
def fixture():
    return Fixture()


@pytest.mark.parametrize("n", range(8))
def test_simple_job(fixture: Fixture, tmp_path: Path, n: int) -> None:
    layers = []

    tar_layer = TarLayer(path="crates/maelstrom-worker/src/executor-test-deps.tar")
    layers.append(LayerSpec(tar=tar_layer))

    test_script = os.path.join(tmp_path, "test.py")
    with open(test_script, "w") as f:
        f.write('import time\n')
        f.write('time.sleep(1)\n')
        f.write(f'print("hello {n}")\n')

    options = PrefixOptions(strip_prefix=str(tmp_path))
    layers.append(
        LayerSpec(paths=PathsLayer(paths=[test_script], prefix_options=options))
    )

    container = ContainerSpec(working_directory="/", layers=layers)
    spec = JobSpec(
        container=container,
        program="/usr/bin/python3",
        arguments=["/test.py"],
    )
    stream = fixture.client.run_job(spec)
    for status in stream:
        result = status.completed

    assert result.result.outcome.completed.exited == 0
    assert result.result.outcome.completed.effects.stderr.inline == b""
    assert (
        result.result.outcome.completed.effects.stdout.inline
        == f"hello {n}\n".encode("utf-8")
    )
