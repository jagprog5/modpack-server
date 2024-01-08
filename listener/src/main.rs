use actix_web::{get, web::Data, App, HttpResponse, HttpServer};
use std::{env, path::{Path, PathBuf}, process::Command};

#[get("/")]
async fn index(data: Data<PathBuf>) -> HttpResponse {
    let repo_root: &Path = data.as_path(); // slice
    let r = Command::new("make")
        .arg("start-minecraft-server")
        .current_dir(repo_root)
        .spawn();
    if let Err(_) = r {
        return HttpResponse::InternalServerError().body("failed spawn");
    }
    let r = r.unwrap().wait();
    if let Err(_) = r {
        return HttpResponse::InternalServerError().body("failed run");
    }
    let r = r.unwrap().code();
    if let None = r {
        return HttpResponse::InternalServerError().body("terminated by signal");
    }
    let r = r.unwrap();
    if r != 0 {
        HttpResponse::InternalServerError().body("nonzero exit")
    } else {
        HttpResponse::Ok().finish()
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let mut repo_root = env::current_exe()?;
    for _ in 0..4 {
        repo_root.pop();
    }
    HttpServer::new(move || App::new().app_data(Data::new(repo_root.clone())).service(index))
        .bind("0.0.0.0:25575")?
        .run()
        .await
}
