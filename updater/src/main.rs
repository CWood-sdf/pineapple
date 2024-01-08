/// TODO: Need to add process timeout for generate
use std::{collections::HashMap, io::Write};

use clap::{Parser, Subcommand};
use serde::{Deserialize, Serialize};
use tokio::sync::oneshot::channel;

#[derive(Serialize, Hash, Eq, PartialEq, Debug, Clone, Deserialize)]
struct Repo {
    #[serde(rename = "stars")]
    stars: usize,
    repo_url: String,
    description: Option<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct Data {
    light: Option<HashMap<String, String>>,
    dark: Option<HashMap<String, String>>,
}
impl Data {
    fn fails(&self) -> bool {
        if self.light.is_none() && self.dark.is_none() {
            return true;
        }
        if let Some(light) = self.light.as_ref() {
            if light.iter().any(|(_, v)| v == "#000000") {
                return true;
            }
        }
        if let Some(dark) = self.dark.as_ref() {
            if dark.iter().any(|(_, v)| v == "#000000") {
                return true;
            }
        }
        false
    }
}
#[derive(Clone, Debug, Deserialize, Serialize)]
struct ColorSchemes {
    backgrounds: Option<Vec<String>>,
    name: String,
    data: Data,
}
#[derive(Clone, Debug, Deserialize, Serialize)]
struct Item {
    name: String,
    #[serde(rename = "githubURL")]
    github_url: String,
    description: String,
    #[serde(rename = "vimColorSchemes")]
    vim_color_schemes: Vec<ColorSchemes>,
    #[serde(rename = "stargazersCount")]
    stargazers_count: Option<u32>,
    #[serde(rename = "lastGenerated")]
    last_generated: Option<u64>,
    #[serde(rename = "lastNotsGen")]
    last_no_ts_gen: Option<u64>,
}
#[derive(Deserialize)]
struct NvCraftActualRepo {
    id: String,
    stars: usize,
    description: String,
}
#[derive(Deserialize)]
struct NvCraftRepo {
    plugin: NvCraftActualRepo,
}
#[derive(Deserialize)]
struct NvCraftRepos {
    results: Vec<NvCraftRepo>,
}
#[derive(Deserialize)]
struct PathData {
    name: String,
    // path: String,
    #[serde(rename = "type")]
    type_: String,
    download_url: Option<String>,
}
async fn get_repo_colschemes(repo: Repo) -> Result<Vec<String>, Box<dyn std::error::Error>> {
    //create a process that runs "gh api repos/repo.repo_url/contents/colors" and returns the output
    let mut cmd = tokio::process::Command::new("gh");
    cmd.arg("api")
        .arg(format!("repos/{}/contents/colors", repo.repo_url));
    // .arg("--cache 1h");

    let output = cmd.output().await?;
    let json = String::from_utf8(output.stdout)?;
    match serde_json::from_str::<PathData>(&json) {
        Ok(_) => return Ok(vec![]),
        Err(_) => {}
    };
    // println!("{}", json);
    let json: Vec<PathData> = serde_json::from_str(&json)?;

    let mut ret = Vec::new();

    for path_data in json {
        if path_data.type_ == "file" && path_data.name.ends_with(".lua") {
            ret.push(path_data.name.replace(".lua", ""));
        }
        if path_data.type_ == "file" && path_data.name.ends_with(".vim") {
            // the file name should be the color scheme name, but sometimes it's not
            let pushed = path_data.name.replace(".vim", "");
            ret.push(pushed.clone());
            // get file contents:
            let mut cmd = tokio::process::Command::new("curl");
            let download_url = path_data.download_url.unwrap();
            cmd.arg(download_url).arg("--silent");
            let output = cmd.output().await?;
            let contents = String::from_utf8(output.stdout)?;
            // 	vimColorSchemeName := regexp.MustCompile(`(let g?:?|vim\.g\.)colors?_name ?= ?['"]([a-zA-Z0-9-_ \(\)]+)['"]`)
            // 	Scan the file contents for the above go regex
            //
            // 	Then, if it matches, add the match to the list of color schemes
            let re = regex::Regex::new(
                r#"(let g?:?|vim\.g\.)colors?_name ?= ?['\"]([a-zA-Z0-9-_ \(\)]+)['\"]"#,
            )
            .unwrap();

            for cap in re.captures_iter(&contents) {
                if cap[2] == pushed {
                    continue;
                }
                ret.push(cap[2].to_string());
            }
        }
    }
    Ok(ret)
}
async fn clean_import() -> Result<(), Box<dyn std::error::Error>> {
    let repos = std::fs::read_dir(".")?;
    let repos = repos
        .into_iter()
        .filter(|r| {
            r.as_ref()
                .unwrap()
                .path()
                .to_str()
                .unwrap()
                .ends_with(".json")
        })
        .collect::<Vec<_>>();
    let mut new_repos = Vec::new();
    for repo in repos {
        new_repos.push(repo?);
    }
    let gh_repos = new_repos
        .iter()
        .map(|d| d)
        .filter(|d| d.path().to_str().unwrap().starts_with("./gh_out_"))
        .map(|d| {
            println!("{:?}", d);
            let file = std::fs::File::open(d.path()).unwrap();
            let contents = std::io::BufReader::new(file);
            let repo: Vec<Repo> = serde_json::from_reader(contents).unwrap();
            println!("{:?}", repo.len());
            repo
        })
        .flatten()
        .collect::<Vec<_>>();
    let nv_craft_repos = new_repos
        .iter()
        .filter(|d| d.path().to_str().unwrap().starts_with("./nvc_"))
        .map(|d| {
            println!("{:?}", d);
            let file = std::fs::File::open(d.path()).unwrap();
            let repos: NvCraftRepos = serde_json::from_reader(file).unwrap();
            println!("{:?}", repos.results.len());
            repos.results
        })
        .flatten()
        .map(|r| r.plugin)
        .map(|r| Repo {
            stars: r.stars,
            repo_url: r.id,
            description: Some(r.description),
        })
        .collect::<Vec<_>>();
    let mut all_repos: HashMap<String, Repo> = HashMap::new();
    for repo in gh_repos {
        all_repos.insert(repo.repo_url.clone(), repo);
    }
    for repo in nv_craft_repos {
        all_repos.insert(repo.repo_url.clone(), repo);
    }
    let capacity = all_repos.capacity();
    println!("Capacity: {}", capacity);
    let all_repos = all_repos.into_iter().map(|(_, v)| v).collect::<Vec<Repo>>();
    let repos_str = serde_json::to_string_pretty(&all_repos).unwrap();

    std::fs::write("repos.json", repos_str)?;

    Ok(())
}

async fn make_color_data() -> Result<(), Box<dyn std::error::Error>> {
    let repos_file = std::fs::File::open("repos.json")?;

    let repos: Vec<Repo> = serde_json::from_reader(repos_file)?;

    let mut schemes: Vec<Item> = vec![];

    let start_time = std::time::Instant::now();
    let check_count = repos.len();
    let mut i = 0;

    for repo in repos {
        // println!("Checking repo: {}", repo.repo_url);
        let stars = repo.stars;
        let description = repo.description.clone();
        let repo_url = repo.repo_url.clone();
        let colschemes = match get_repo_colschemes(repo).await {
            Ok(s) => s,
            Err(_) => {
                eprintln!("Error on repo {}", repo_url.clone());
                vec![]
            }
        };
        i += 1;
        if i % 10 == 0 {
            let elapsed = start_time.elapsed().as_secs_f64();
            let remaining = (check_count - i) as f64 * elapsed / i as f64;
            let minutes = remaining as usize / 60;
            let output = serde_json::to_string_pretty(&schemes)?;
            std::fs::write("colors.json", output)?;
            println!(
                "{} / {}, ETA: {}m {:.2}s",
                i,
                check_count,
                minutes,
                remaining - minutes as f64 * 60.0
            );
        }
        if colschemes.len() == 0 {
            continue;
        }
        let colschemes = colschemes
            .into_iter()
            .map(|s| ColorSchemes {
                backgrounds: None,
                name: s.clone(),
                data: Data {
                    light: None,
                    dark: None,
                },
            })
            .collect::<Vec<_>>();
        schemes.push(Item {
            name: repo_url.split("/").last().unwrap().to_string(),
            github_url: format!("https://github.com/{}", repo_url),
            description: description.unwrap_or("".to_string()),
            vim_color_schemes: colschemes,
            stargazers_count: Some(stars as u32),
            last_generated: None,
            last_no_ts_gen: None,
        });
        // println!("{:?}", colschemes);
    }

    let output = serde_json::to_string(&schemes)?;
    std::fs::write("colors.json", output)?;

    Ok(())
}

async fn generate_colorscheme(
    // repo_name: String,
    // config: String,
    colorscheme: String,
    dark: bool,
) -> Result<bool, Box<dyn std::error::Error>> {
    let current_dir = std::env::current_dir()?;
    let background = if dark { "dark" } else { "light" };
    let write_color_values = format!("autocmd ColorScheme * :lua vim.fn.timer_start(100, function() WriteColorValues(\"{}/gencolors.json\", \"{}\", \"{}\");  vim.cmd('qa') end)", current_dir.to_str().unwrap(), colorscheme, background);

    let set_background = format!("set background={}", background);
    let buf_enter_autocmd = format!(
        "autocmd UIEnter * :lua vim.fn.timer_start(50, function() vim.cmd('colorscheme {}') end)",
        colorscheme
    );
    let auto_quit_autocmd =
        "autocmd UIEnter * :lua vim.fn.timer_start(500, function() vim.cmd('q') end)".to_string();

    let mut args: Vec<String> = vec!["-c".to_string(), write_color_values];

    args.extend(vec![
        // "--headless".to_string(),
        "-c".to_string(),
        set_background,
        "-c".to_string(),
        buf_enter_autocmd,
        "-c".to_string(),
        auto_quit_autocmd,
        "./code_sample.vim".to_string(),
    ]);

    let mut run_cmd = tokio::process::Command::new("nvim");
    run_cmd.args(args);
    let mut spawn = run_cmd.spawn()?;

    let (send, recv) = channel::<()>();
    tokio::spawn(async move {
        tokio::time::sleep(std::time::Duration::from_secs(10)).await;
        let _ = send.send(());
    });
    let was_killed;

    tokio::select! {
        _ = spawn.wait() => {
            was_killed = false;
        }
        _ = recv => {
            was_killed = true;
            spawn.kill().await?;
            println!("Process was killed");

        }
    }
    // let kill_task = tokio::task::spawn(async move {
    //     tokio::time::sleep(std::time::Duration::from_secs(5)).await;
    //     let _ = tokio::process::Command::new("kill")
    //         .arg("-9")
    //         .arg(format!("{}", pid))
    //         .spawn();
    // });
    // let was_killed = out.status.code().unwrap() == 137;
    // if was_killed {
    //     println!("Process was killed");
    //     std::fs::write("gencolors.json", "{}")?;
    // }
    Ok(was_killed)
}

async fn generate_no_ts(force: bool, filename: String) -> Result<(), Box<dyn std::error::Error>> {
    println!("Using file {}", filename);
    let file = std::fs::File::open(filename.clone())?;
    let mut items: Vec<Item> = serde_json::from_reader(file)?;
    println!("Items: {}", items.len());
    let mut j = 0;
    while j < items.len() {
        let item = &mut items[j];
        // if item.last_generated.is_some() {
        //     j += 1;
        //     continue;
        // }
        if !item.vim_color_schemes.iter().any(|s| s.data.fails()) {
            j += 1;
            continue;
        }
        if item.last_no_ts_gen.is_some() && !force {
            j += 1;
            continue;
        }
        item.last_no_ts_gen = Some(
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
        );
        let split_url = item.github_url.split("/").collect::<Vec<_>>();
        let repo_name = split_url[split_url.len() - 2..=split_url.len() - 1]
            .join("/")
            .to_string();
        println!("Installing {}", repo_name);
        let home_dir = std::env::var("HOME")?;
        std::fs::write(
            format!("{}/.config/nvim/lua/stuff/colorscheme.lua", home_dir),
            format!("return '{}'", repo_name),
        )?;
        let mut install_cmd = tokio::process::Command::new("nvim");
        install_cmd
            .arg("--headless")
            // .arg("--noplugin")
            // .arg("--clean")
            .arg("-c")
            .arg(
                "lua vim.fn.timer_start(100, function() vim.cmd('Lazy! sync'); vim.cmd('qa!') end)",
            );
        let mut spawn = install_cmd.spawn()?;

        let (send, recv) = channel::<()>();
        let was_killed;
        tokio::spawn(async move {
            tokio::time::sleep(std::time::Duration::from_secs(40)).await;
            let _ = send.send(());
        });
        tokio::select! {
            _ = spawn.wait() => {
                was_killed = false;
            }
            _ = recv => {
                spawn.kill().await?;
                was_killed = true;

            }
        }
        if was_killed {
            println!("Process was killed");
            j += 1;
            continue;
        }

        // install_cmd.stdout(Stdio::piped()).stdin(Stdio::piped());

        // println!("{}", String::from_utf8(out.stdout)?);
        let mut new_colorschemes = Vec::new();
        let mut i = 0;
        while i < item.vim_color_schemes.len() {
            let mut colorscheme = item.vim_color_schemes[i].clone();
            if colorscheme.data.light.is_some()
                && colorscheme
                    .data
                    .light
                    .clone()
                    .unwrap()
                    .iter()
                    .any(|(_, hex)| hex == "#000000")
            {
                let was_killed = generate_colorscheme(
                    // repo_name.clone(),
                    // "./nvim_worker_no_ts/init.lua".to_string(),
                    colorscheme.name.clone(),
                    false,
                )
                .await?;
                if !was_killed {
                    let data = std::fs::read_to_string("gencolors.json")?;
                    match serde_json::from_str::<HashMap<String, String>>(&data) {
                        Ok(parsed) if parsed.len() > 0 => {
                            for (k, v) in parsed {
                                if v != "#000000" {
                                    colorscheme.data.light.as_mut().unwrap().insert(k, v);
                                }
                            }
                        }
                        Err(_) => {
                            // println!("Data parse failed on data {}", data);
                            // println!("{:?}", e);
                        }
                        _ => {}
                    };
                }
            }

            if colorscheme.data.dark.is_some()
                && colorscheme
                    .data
                    .dark
                    .clone()
                    .unwrap()
                    .iter()
                    .any(|(_, hex)| hex == "#000000")
            {
                let was_killed = generate_colorscheme(
                    // repo_name.clone(),
                    // "./nvim_worker_no_ts/init.lua".to_string(),
                    colorscheme.name.clone(),
                    true,
                )
                .await?;
                if !was_killed {
                    let data = std::fs::read_to_string("gencolors.json")?;
                    match serde_json::from_str::<HashMap<String, String>>(&data) {
                        Ok(parsed) if parsed.len() > 0 => {
                            for (k, v) in parsed {
                                if v != "#000000" {
                                    colorscheme.data.dark.as_mut().unwrap().insert(k, v);
                                }
                            }
                        }
                        Err(_) => {
                            // println!("Data parse failed on data {}", data);
                            // println!("{:?}", e);
                        }
                        _ => {}
                    };
                }
            }

            let _ = std::fs::remove_file("gencolors.json");
            let _ = std::fs::write("gencolors.json", "{}");
            i += 1;
            new_colorschemes.push(colorscheme);
        }
        item.vim_color_schemes = new_colorschemes;
        item.last_generated = Some(
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
        );
        j += 1;
        std::fs::write(
            filename.clone(),
            serde_json::to_string_pretty(&items).unwrap(),
        )?;
        // break;
    }

    // std::fs::write("colors.json", serde_json::to_string_pretty(&items).unwrap())?;

    Ok(())
}
async fn generate_ts(force: bool, filename: String) -> Result<(), Box<dyn std::error::Error>> {
    println!("Using file {}", filename);
    let file = std::fs::File::open(filename.clone())?;
    let mut items: Vec<Item> = serde_json::from_reader(file)?;
    println!("Items: {}", items.len());
    let mut j = 0;
    while j < items.len() {
        let item = &mut items[j];
        if item.last_generated.is_some() {
            j += 1;
            continue;
        }
        //stop for 5s
        let split_url = item.github_url.split("/").collect::<Vec<_>>();
        let repo_name = split_url[split_url.len() - 2..=split_url.len() - 1]
            .join("/")
            .to_string();
        println!("Installing {}", repo_name);
        let home_dir = std::env::var("HOME")?;
        std::fs::write(
            format!("{}/.config/nvim/lua/stuff/colorscheme.lua", home_dir),
            format!("return '{}'", repo_name),
        )?;
        let mut install_cmd = tokio::process::Command::new("nvim");
        install_cmd
            // .arg("--clean")
            // .arg("-u")
            // .arg("./nvim_worker/init.lua")
            .arg("--headless")
            // .arg(repo_name.clone())
            // .arg("--noplugin")
            .arg("-c")
            .arg(
                "lua vim.fn.timer_start(100, function() vim.cmd('Lazy! sync'); vim.cmd('qa!') end)",
            );

        // install_cmd.stdout(Stdio::piped()).stdin(Stdio::piped());

        let mut spawn = install_cmd.spawn()?;

        // tokio::task::spawn(async move {
        //     tokio::time::sleep(std::time::Duration::from_secs(5)).await;
        //     let _ = tokio::process::Command::new("kill")
        //         .arg("-9")
        //         .arg(format!("{}", pid))
        //         .spawn();
        // });
        let (send, recv) = channel::<()>();

        tokio::spawn(async move {
            tokio::time::sleep(std::time::Duration::from_secs(40)).await;
            let _ = send.send(());
        });
        let was_killed;

        tokio::select! {
            _ = spawn.wait() => {
                was_killed = false;
            }
            _ = recv => {
                was_killed = true;
                spawn.kill().await?;

            }
        }

        // let out = spawn.wait_with_output().await?;
        // let was_killed = out.status.code().unwrap() == 137;

        if was_killed {
            println!("Process was killed");
            j += 1;
            continue;
        }
        // println!("{}", String::from_utf8(out.stdout)?);
        let mut new_colorschemes = Vec::new();
        let mut i = 0;
        while i < item.vim_color_schemes.len() {
            let mut colorscheme = item.vim_color_schemes[i].clone();
            if colorscheme.backgrounds.is_some() && !force {
                new_colorschemes.push(colorscheme);
                i += 1;
                continue;
            }
            let was_killed = generate_colorscheme(
                // repo_name.clone(),
                // "./nvim_worker/init.lua".to_string(),
                colorscheme.name.clone(),
                false,
            )
            .await?;
            if !was_killed {
                let data = match std::fs::read_to_string("gencolors.json") {
                    Ok(d) => d,
                    Err(_) => "".to_string(),
                };
                match serde_json::from_str::<HashMap<String, String>>(&data) {
                    Ok(parsed) if parsed.len() > 0 => {
                        colorscheme.backgrounds = Some(vec!["light".to_string()]);
                        colorscheme.data.light = Some(parsed);
                    }
                    Err(e) => {
                        println!("Data parse failed on data {}", data);
                        println!("{:?}", e);
                    }
                    _ => {}
                };
            }

            let was_killed = generate_colorscheme(
                // repo_name.clone(),
                // "./nvim_worker/init.lua".to_string(),
                colorscheme.name.clone(),
                true,
            )
            .await?;
            if !was_killed {
                let data = match std::fs::read_to_string("gencolors.json") {
                    Ok(d) => d,
                    Err(_) => "".to_string(),
                };
                match serde_json::from_str::<HashMap<String, String>>(&data) {
                    Ok(parsed) if parsed.len() > 0 => {
                        if colorscheme.backgrounds.is_none() {
                            colorscheme.backgrounds = Some(vec![]);
                        }
                        if !colorscheme
                            .backgrounds
                            .clone()
                            .unwrap()
                            .contains(&"dark".to_string())
                        {
                            colorscheme
                                .backgrounds
                                .as_mut()
                                .unwrap()
                                .push("dark".to_string());
                        }
                        colorscheme.data.dark = Some(parsed);
                    }
                    Err(e) => {
                        println!("Data parse failed on data {}", data);
                        println!("{:?}", e);
                    }
                    _ => {}
                };
            }

            let _ = std::fs::remove_file("gencolors.json");
            let _ = std::fs::write("gencolors.json", "{}");
            i += 1;
            new_colorschemes.push(colorscheme);
        }
        item.vim_color_schemes = new_colorschemes;
        item.last_generated = Some(
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
        );
        j += 1;
        match std::fs::write(
            filename.clone(),
            serde_json::to_string_pretty(&items).unwrap(),
        ) {
            Ok(_) => {}
            Err(e) => {
                println!("Error writing to file {}: {:?}", filename.clone(), e);
                return Err(e.into());
            }
        };
        // break;
    }

    // std::fs::write("colors.json", serde_json::to_string_pretty(&items).unwrap())?;

    Ok(())
}

async fn move_to_lua(filename: String) -> Result<(), Box<dyn std::error::Error>> {
    let file = std::fs::File::open(filename)?;
    let json: Vec<Item> = serde_json::from_reader(file)?;
    std::fs::write("data.lua", "return {\n")?;
    let mut file = std::fs::OpenOptions::new().append(true).open("data.lua")?;
    for item in json {
        file.write(b"{\n")?;
        file.write(format!("    name = \"{}\",\n", item.name).as_bytes())?;
        file.write(
            format!(
                "    githubUrl = \"{}\",\n",
                item.github_url.replace("https://github.com/", "")
            )
            .as_bytes(),
        )?;
        file.write(
            format!(
                "    description = \"{}\",\n",
                item.description.replace("\\", "\\\\").replace("\"", "\\\"")
            )
            .as_bytes(),
        )?;
        file.write(
            format!(
                "    stargazersCount = {},\n",
                item.stargazers_count.unwrap()
            )
            .as_bytes(),
        )?;
        file.write(b"    vimColorSchemes = {\n")?;
        for scheme in item.vim_color_schemes {
            if scheme.backgrounds.is_none() {
                continue;
            }
            file.write(b"        {\n")?;
            file.write(format!("            name = \"{}\",\n", scheme.name).as_bytes())?;
            file.write(
                format!(
                    "            backgrounds = {{ {} }},\n",
                    scheme
                        .backgrounds
                        .unwrap()
                        .iter()
                        .map(|s| format!("\"{}\"", s))
                        .collect::<Vec<_>>()
                        .join(", ")
                )
                .as_bytes(),
            )?;
            file.write(b"            data = {\n")?;
            if scheme.data.light.is_some() {
                file.write(b"                light = {\n")?;
                for (k, v) in scheme.data.light.unwrap() {
                    file.write(
                        format!("                    [\"{}\"] = \"{}\",\n", k, v).as_bytes(),
                    )?;
                }
                file.write(b"                },\n")?;
            }
            if scheme.data.dark.is_some() {
                file.write(b"                dark = {\n")?;
                for (k, v) in scheme.data.dark.unwrap() {
                    file.write(
                        format!("                    [\"{}\"] = \"{}\",\n", k, v).as_bytes(),
                    )?;
                }
                file.write(b"                },\n")?;
            }
            file.write(b"            },\n")?;
            file.write(b"        },\n")?;
        }
        file.write(b"    },\n")?;
        file.write(b"},\n")?;
    }
    file.write(b"}\n")?;
    Ok(())
}

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,

    #[arg(short, long)]
    file: Option<String>,

    /// Force the command to run
    #[arg(short, long)]
    force: bool,
}

#[derive(Subcommand)]
enum Commands {
    /// does testing things
    Yeet {
        #[arg(short, long)]
        yeet: bool,
    },
    /// cleans the import (step 1)
    CleanImport {
        #[arg(short, long)]
        clean_import: bool,
    },
    /// Generates the potential themes (step 2)
    MakeColorData {
        #[arg(short, long)]
        make_color_data: bool,
    },
    /// Converts the colors.json file to a lua file (step 5)
    MoveToLua {
        #[arg(short, long)]
        move_to_lua: bool,
    },
    /// Converts the potential themes to a colordata list (step 3)
    GenerateTs {
        #[arg(short, long)]
        generate: bool,
    },
    /// Adds any data that may have been missed because of treesitter (step 4)
    GenerateNoTs {
        #[arg(short, long)]
        generate: bool,
    },
}
async fn dir_exists(dir: String) -> Result<bool, Box<dyn std::error::Error>> {
    let mut cmd = tokio::process::Command::new("bash");
    cmd.arg("-c").arg(format!("ls {}", dir));
    let output = cmd.output().await?;
    if output.status.code().unwrap() != 0 {
        return Ok(false);
    }
    return Ok(true);
}
async fn move_dir(from: String, to: String) -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = tokio::process::Command::new("bash");
    cmd.arg("-c").arg(format!("mv {} {}", from, to));
    let output = cmd.output().await?;
    if output.status.code().unwrap() != 0 {
        return Err("Error moving dir".into());
    }
    return Ok(());
}
async fn cp_dir(from: String, to: String) -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = tokio::process::Command::new("bash");
    cmd.arg("-c").arg(format!("cp -r {} {}", from, to));
    let output = cmd.output().await?;
    if output.status.code().unwrap() != 0 {
        return Err("Error copying dir".into());
    }
    return Ok(());
}
async fn rm_dir(dir: String) -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = tokio::process::Command::new("bash");
    cmd.arg("-c").arg(format!("rm -rf {}", dir));
    let output = cmd.output().await?;
    if output.status.code().unwrap() != 0 {
        return Err("Error removing dir".into());
    }
    return Ok(());
}
// A function to test stuff
async fn do_yeet() -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = tokio::process::Command::new("nvim");
    cmd.arg("--headless");
    // cmd.arg("-c").arg("nvim --headless");
    // cmd.arg("./timeout_nvim.sh 5 qa".to_string());
    // cmd
    //
    let mut spawn = cmd.spawn()?;
    let pid = match spawn.id() {
        Some(pid) => pid,
        None => {
            println!("Error getting pid");
            return Err("Error getting pid".into());
        }
    };

    println!("PID: {}", pid);
    let (send, recv) = channel::<()>();
    tokio::spawn(async move {
        tokio::time::sleep(std::time::Duration::from_secs(10)).await;
        let _ = send.send(());
    });
    tokio::select! {
        _ = spawn.wait() => {
            println!("Child process ended");
        }
        _ = recv => {
            spawn.kill().await?;

        }
    }
    // task.await?;
    println!("Yeet");
    Ok(())
}
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();
    println!("{}", cli.force);

    // You can check for the existence of subcommands, and if found use their
    // matches just as you would the top level cmd
    match &cli.command {
        Some(Commands::MoveToLua { .. }) => {
            println!("Moving to lua...");
            move_to_lua(cli.file.unwrap_or("colors.json".to_string())).await?;
        }
        Some(Commands::GenerateNoTs { .. }) => {
            println!("Generating...");

            if dir_exists("~/.config/nvim".to_string()).await? {
                println!("Nvim config found, moving to ~/.config/__pineapple_config_copy__");
                move_dir(
                    "~/.config/nvim".to_string(),
                    "~/.config/__pineapple_config_copy__".to_string(),
                )
                .await?;
            }
            cp_dir(
                "./nvim_worker_no_ts".to_string(),
                "~/.config/nvim".to_string(),
            )
            .await?;
            let res =
                generate_no_ts(cli.force, cli.file.unwrap_or("colors.json".to_string())).await;
            println!("Deleting ~/.config/nvim");
            rm_dir("~/.config/nvim".to_string()).await?;
            println!("Moving ~/.config/__pineapple_config_copy__ to ~/.config/nvim");
            if dir_exists("~/.config/__pineapple_config_copy__".to_string()).await? {
                move_dir(
                    "~/.config/__pineapple_config_copy__".to_string(),
                    "~/.config/nvim".to_string(),
                )
                .await?;
            }
            res?;
        }
        Some(Commands::GenerateTs { .. }) => {
            println!("Generating...");

            if dir_exists("~/.config/nvim".to_string()).await? {
                println!("Nvim config found, moving to ~/.config/__pineapple_config_copy__");
                move_dir(
                    "~/.config/nvim".to_string(),
                    "~/.config/__pineapple_config_copy__".to_string(),
                )
                .await?;
            }
            cp_dir("./nvim_worker".to_string(), "~/.config/nvim".to_string()).await?;
            let res = generate_ts(cli.force, cli.file.unwrap_or("colors.json".to_string())).await;
            println!("Deleting ~/.config/nvim");
            rm_dir("~/.config/nvim".to_string()).await?;
            println!("Moving ~/.config/__pineapple_config_copy__ to ~/.config/nvim");
            if dir_exists("~/.config/__pineapple_config_copy__".to_string()).await? {
                move_dir(
                    "~/.config/__pineapple_config_copy__".to_string(),
                    "~/.config/nvim".to_string(),
                )
                .await?;
            }
            res?;
        }
        Some(Commands::MakeColorData { .. }) => {
            println!("Making color data...");
            make_color_data().await?;
        }
        Some(Commands::CleanImport { .. }) => {
            println!("Cleaning import...");
            clean_import().await?;
        }
        Some(Commands::Yeet { .. }) => {
            println!("Yeeting...");
            do_yeet().await?;
            do_yeet().await?;
            // match task.await? {
            //     Ok(_) => {}
            //     Err(_) => {}
            // };
        }
        None => {
            println!("No subcommand was used");
        }
    }

    // Continued program logic goes here...
    Ok(())
}
