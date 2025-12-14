use kernel::prelude::*;

module! {
    type: HelloRust,
    name: "hello_rust",
    authors: ["Evgeny Golyshev"],
    description: "Hello-World-style example for a Linux kernel module written in Rust",
    license: "GPL",
}

struct HelloRust;

impl kernel::Module for HelloRust {
    fn init(_module: &'static ThisModule) -> Result<Self> {
        pr_info!("Hello, World from Rust!\n");

        Ok(HelloRust)
    }
}

impl Drop for HelloRust {
    fn drop(&mut self) {
        pr_info!("Goodbye, World from Rust!\n");
    }
}
