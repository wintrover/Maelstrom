use anyhow::{bail, Result};

#[cfg(target_os = "linux")]
fn main() -> Result<maelstrom_util::process::ExitCode> {
    maelstrom_test_runner::main::<maelstrom_pytest::TestRunner>(clap::command!(), std::env::args())
}

#[cfg(not(target_os = "linux"))]
fn main() -> Result<()> {
    bail!("maelstrom-pytest supports Linux only. Run it inside WSL2.")
}
