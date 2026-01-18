use anyhow::{bail, Result};

#[cfg(target_os = "linux")]
fn main() -> Result<()> {
    let config = maelstrom_worker::config::Config::new(
        "maelstrom/worker",
        ["MAELSTROM_WORKER", "MAELSTROM"],
    )?;
    maelstrom_util::process::clone_into_pid_and_user_namespace()?;
    maelstrom_util::log::run_with_logger(config.log_level, |log| {
        maelstrom_worker::main(config, log)
    })
}

#[cfg(not(target_os = "linux"))]
fn main() -> Result<()> {
    bail!("maelstrom-worker supports Linux only. Run it inside WSL2.")
}
