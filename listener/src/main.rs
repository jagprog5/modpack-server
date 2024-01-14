use actix_web::{get, web::Data, App, HttpResponse, HttpServer};
use std::{env, path::{Path, PathBuf}, process::Command};

#[get("/")]
async fn index(data: Data<PathBuf>) -> HttpResponse {
    let repo_root: &Path = data.as_path(); // slice
    let _ = Command::new("make")
        .arg("start")
        .current_dir(repo_root)
        .spawn();
    HttpResponse::Ok().body("attempting to start the server...\n")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let mut repo_root = env::current_exe()?;
    for _ in 0..4 {
        repo_root.pop();
    }
    HttpServer::new(move || App::new().app_data(Data::new(repo_root.clone())).service(index))
        .bind("0.0.0.0:25579")?
        .run()
        .await
}
