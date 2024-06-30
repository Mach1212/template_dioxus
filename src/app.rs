mod api;
mod pages;

use crate::app::pages::route::*;
use dioxus::prelude::*;
use tracing::Level;

// Urls are relative to your Cargo.toml file
const _TAILWIND_URL: &str = manganis::mg!(file("public/tailwind.css"));

fn App() -> Element {
    rsx! { Router::<Route> {} }
}

pub fn run() {
    // Init logger
    dioxus_logger::init(Level::INFO).expect("failed to init logger");
    launch(App);
}
