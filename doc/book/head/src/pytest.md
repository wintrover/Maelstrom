# `maelstrom-pytest`

## Choosing a Python Image
Before we start running tests, we need to choose a python image.

First generate a `maelstrom-pytest.toml` file
```bash
maelstrom-pytest --init
```

Then update the image in the file to have the version of Python you desire.
```toml
[[directives]]
image = "docker://python:3.11-slim"
```
The default configuration and our example uses an
[image from Docker](https://hub.docker.com/_/python)

## Including Your Project Python Files
So that your tests can be run from the container, your project's python must be included.
Update the `added_layers` in the file to make sure it includes your project's Python.
```toml
added_layers = [ { glob = "**.py" } ]
```
This example just adds all files with a `.py` extension. You may also need to include `.pyi` files
or other files.

## Including `pip` Packages
If you have an image named "python", maelstrom-pytest will automatically include pip packages for
you as part of the container. It expects to read these packages from a `test-requirements.txt` file
in your project directory. This needs to at a minimum include the `pytest` package

`test-requirements.txt`
```
pytest==8.1.1
```

## Running Tests
Once you have finished the configuration, you only need invoke `maelstrom-pytest` to run all the
tests in your project. It must be run from an environment where `pytest` is in the Python path. If
you are using virtualenv for your project make sure to source that first.

## WSL2 Troubleshooting (Notes from Real Runs)

This repository is developed on Windows, but `maelstrom-pytest` executes tests inside Linux
containers. In practice that means:

- Build and run `maelstrom-pytest` inside WSL2.
- Keep `pytest` installed in the Python environment you use to invoke `maelstrom-pytest`.

### Reproducing Parallel Micro-Container Runs

The easiest way to validate parallelism is to prepare a test that expands into multiple cases (for
example, a `pytest.mark.parametrize(range(8))`) and then run with `--slots 8`:

```bash
cd /mnt/d/Coding/maelstrom
source /root/.maelstrom-venv/bin/activate
target/debug/maelstrom-pytest --ui simple --slots 8 --include 'file.equals(py/maelstrom_client_test.py)'
```

### Common Failures and Fixes

#### Filter expression quoting

When using `--include` / `--exclude` on Bash, wrap filter expressions in single quotes to avoid
shell parsing errors caused by parentheses and other characters.

#### `move_mount ... Invalid argument`

If you see errors like `move_mount for mount of tmpfs to /root: Invalid argument`, avoid stubbing
or mounting `/root`. Keep mounts focused on `/tmp`, `/proc`, `/sys` (optional bind), and a minimal
`/dev` device set.

#### Read-only cache directory during pip install

Some Python packages attempt to write cache files under `$XDG_CACHE_HOME` (or `$HOME/.cache`). In
non-writable containers this can fail with errors like `create_dir_all` on a read-only file system.
Setting a writable cache directory fixes it:

```toml
[directives.added_environment]
XDG_CACHE_HOME = "/tmp"
```

Ensure `/tmp` is mounted as a tmpfs:

```toml
mounts = [
  { type = "tmp", mount_point = "/tmp" },
]
```

#### `PYTEST_XDIST_AUTO_NUM_WORKERS`

If your project uses pytest-xdist, ensure it does not add its own parallelism inside each
container. In Maelstrom, the intended model is “one test case per job”, so set:

```toml
[directives.added_environment]
PYTEST_XDIST_AUTO_NUM_WORKERS = "1"
```

#### Protobuf / gRPC client mismatches

If Python gRPC bindings fail due to a `protobuf` version mismatch, pin a compatible version (for
example `protobuf==5.29.3`) and regenerate Python protobuf outputs.
