use std::{
    collections::HashMap,
    io::Write,
    sync::{Arc, Mutex},
};

use clap::{Parser, Subcommand};
use serde::{Deserialize, Serialize};
use tokio::sync::oneshot::channel;

#[derive(Serialize, Hash, Eq, PartialEq, Debug, Clone, Deserialize)]
struct Repo {
    stars: usize,
    repo_url: String,
    description: Option<String>,
}
#[derive(Serialize, Hash, Eq, PartialEq, Debug, Clone, Deserialize)]
struct GhRepo {
    #[serde(rename = "stargazers_count")]
    stars: usize,
    #[serde(rename = "full_name")]
    repo_url: String,
    description: Option<String>,
}

impl Into<Repo> for GhRepo {
    fn into(self) -> Repo {
        Repo {
            stars: self.stars,
            repo_url: self.repo_url,
            description: self.description,
        }
    }
}

#[derive(Serialize, Hash, Eq, PartialEq, Debug, Clone, Deserialize)]
struct GhRepoContainer {
    items: Vec<GhRepo>,
    total_count: usize,
    incomplete_results: bool,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct Data {
    light: Option<HashMap<String, String>>,
    dark: Option<HashMap<String, String>>,
}
impl Data {
    // fn fails(&self) -> bool {
    //     if self.light.is_none() && self.dark.is_none() {
    //         return true;
    //     }
    //     if let Some(light) = self.light.as_ref() {
    //         if light.iter().any(|(_, v)| v == "#000000") {
    //             return true;
    //         }
    //     }
    //     if let Some(dark) = self.dark.as_ref() {
    //         if dark.iter().any(|(_, v)| v == "#000000") {
    //             return true;
    //         }
    //     }
    //     false
    // }
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
fn get_dir_name(home: String, dir_base: String) -> String {
    format!("{}/confs/{}/nvim", home, dir_base)
}
// fn get_conf_nest_level() -> usize {
//     get_dir_name(".".to_string(), "sdf".to_string())
//         .split("/")
//         .count()
// }
// async fn ls(dir: String) -> Result<String, Box<dyn std::error::Error>> {
//     let mut cmd = tokio::process::Command::new("bash");
//     cmd.arg("-c").arg(format!("ls {} -a", dir));
//     let output = cmd.output().await?;
//     if output.status.code().unwrap() != 0 {
//         return Err("Error copying dir".into());
//     }
//     return Ok(String::from_utf8(output.stdout)?);
// }
async fn get_repo_colschemes(repo: &Repo) -> Result<Vec<String>, Box<dyn std::error::Error>> {
    //create a process that runs "gh api repos/repo.repo_url/contents/colors" and returns the output
    let json;
    loop {
        let mut cmd = tokio::process::Command::new("gh");
        cmd.arg("api")
            .arg(format!("repos/{}/contents/colors", repo.repo_url));
        // .arg("--cache 1h");

        let output = cmd.output().await?;
        let json2 = String::from_utf8(output.stdout)?;
        if !json2.contains("rate-limits") {
            json = json2;
            break;
        }
        println!("Rate limited, waiting 60 minutes");
        std::thread::sleep(std::time::Duration::new(3600, 0));
    }
    match serde_json::from_str::<PathData>(&json) {
        Ok(_) => return Ok(vec![]),
        Err(_) => {}
    };
    // println!("{}", json);
    let json: Vec<PathData> = match serde_json::from_str(&json) {
        Ok(v) => v,
        Err(e) => return Err(format!("{} from str: {}", e.to_string(), json).into()),
    };

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
fn clean_import() -> Result<(), Box<dyn std::error::Error>> {
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
            // let contents = std::io::BufReader::new(file);
            let actual_contents = std::io::read_to_string(file).unwrap_or("".to_string());
            let repo: Vec<GhRepoContainer> =
                serde_json::from_str(&actual_contents).unwrap_or(vec![]);
            let items = repo
                .iter()
                .map(|d| d.items.clone())
                // .take(1)
                .flatten()
                .collect::<Vec<GhRepo>>();
            println!("{:?}", items.len());
            items
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
        all_repos.insert(repo.repo_url.clone(), repo.into());
    }
    for repo in nv_craft_repos {
        all_repos.insert(repo.repo_url.clone(), repo);
    }
    let capacity = all_repos.capacity();
    println!("Capacity: {}", capacity);
    let mut all_repos = all_repos.into_iter().map(|(_, v)| v).collect::<Vec<Repo>>();
    all_repos.sort_by(|a, b| b.stars.partial_cmp(&a.stars).unwrap());
    let repos_str = serde_json::to_string_pretty(&all_repos).unwrap();

    std::fs::write("repos.json", repos_str)?;

    Ok(())
}

async fn make_color_data_for(repos: &Arc<Vec<Repo>>, schemes: &Arc<Mutex<Vec<Item>>>, i: usize) {
    let repo = &repos[i];
    let stars = repo.stars;
    let description = repo.description.clone();
    let repo_url = repo.repo_url.clone();
    let colschemes = match get_repo_colschemes(repo).await {
        Ok(s) => s,
        Err(e) => {
            eprintln!("Error on repo {}: {}", repo_url.clone(), e);
            return;
        }
    };
    if colschemes.len() == 0 {
        return;
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

    let mut lock = schemes.lock().unwrap();
    let items: &mut Vec<Item> = lock.as_mut();
    items.push(Item {
        name: repo_url.split("/").last().unwrap().to_string(),
        github_url: format!("https://github.com/{}", repo_url),
        description: description.unwrap_or("".to_string()),
        vim_color_schemes: colschemes,
        stargazers_count: Some(stars as u32),
        last_generated: None,
        last_no_ts_gen: None,
    });
}
async fn make_color_data(thread_count: usize) -> Result<(), Box<dyn std::error::Error>> {
    let repos_file = std::fs::File::open("repos.json")?;

    let repos: Vec<Repo> = serde_json::from_reader(repos_file)?;
    let repos_threadable: Arc<Vec<Repo>> = Arc::new(repos);

    let schemes: Arc<Mutex<Vec<Item>>> = Arc::new(Mutex::new(vec![]));
    let mut i = 0;
    let mut threads = vec![];
    while i < thread_count {
        let repos_threadable_t = repos_threadable.clone();
        let schemes_t = schemes.clone();
        threads.push(std::thread::spawn(move || {
            let rt = tokio::runtime::Runtime::new();
            let rt = match rt {
                Ok(v) => v,
                Err(_) => return,
            };
            rt.block_on(async {
                let mut j = 0;
                while j * thread_count + i < repos_threadable_t.len() {
                    let _ =
                        make_color_data_for(&repos_threadable_t, &schemes_t, j * thread_count + i)
                            .await;
                    j += 1;
                }
            });
        }));
        i += 1;
    }
    while !threads.iter().all(|t| t.is_finished()) {
        std::thread::sleep(std::time::Duration::from_millis(100));
    }

    let output = serde_json::to_string(&schemes.lock().unwrap().clone())?;
    std::fs::write("colors.json", output)?;

    Ok(())
}

async fn generate_colorscheme(
    dir_base: String,
    // repo_name: String,
    // config: String,
    colorscheme: String,
    dark: bool,
) -> Result<bool, Box<dyn std::error::Error>> {
    let current_dir = std::env::current_dir()?;
    // println!("yeet");
    let background = if dark { "dark" } else { "light" };
    let write_color_values = format!("\"autocmd ColorScheme * :lua vim.fn.timer_start(100, function() WriteColorValues('{}/gencolors.json', '{}', '{}');  vim.cmd('qa!') end)\"", get_dir_name(current_dir.to_str().unwrap().to_string(), dir_base.clone()), colorscheme, background);

    let set_background = format!("\"set background={}\"", background);
    let buf_enter2_autocmd =
        format!("\"autocmd VimEnter * :lua vim.fn.timer_start(50, function() end)\"",);
    let buf_enter_autocmd = format!(
        "\"autocmd VimEnter * :lua vim.fn.timer_start(40, function() SetUpColorScheme('{}') end)\"",
        colorscheme
    );
    // println!("{}", colorscheme);
    let auto_quit_autocmd =
        "\"autocmd VimEnter * :lua vim.fn.timer_start(3000, function() vim.cmd('q') end)\""
            .to_string();

    let current_dir = std::env::current_dir()?;
    let current_dir = current_dir.to_str().unwrap_or("osdf");
    let dir = get_dir_name(current_dir.to_string(), dir_base.clone());
    let args: Vec<String> = vec![
        "nvim".to_string(),
        "-c".to_string(),
        write_color_values,
        "-c".to_string(),
        set_background,
        "-c".to_string(),
        buf_enter_autocmd,
        "-c".to_string(),
        buf_enter2_autocmd,
        "-c".to_string(),
        auto_quit_autocmd,
        "--headless".to_string(),
        "-u".to_string(),
        "init.lua".to_string(),
        format!("{}/code_sample.vim", current_dir),
    ];
    // let dir_struct = ls(dir.clone()).await?;
    // println!("{}", dir_struct);
    //
    // println!("{}", args.join(", "));

    // let home_dir = std::env::var("HOME")?;
    let mut run_cmd = tokio::process::Command::new(format!("bash"));
    run_cmd
        .arg("-c")
        .arg(args.join(" "))
        // .stdout(Stdio::null())
        // .stderr(Stdio::null())
        .current_dir(dir);
    let mut spawn = run_cmd.spawn()?;

    let (send, recv) = channel::<()>();
    tokio::spawn(async move {
        tokio::time::sleep(std::time::Duration::from_secs(100)).await;
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

async fn generate(
    force: bool,
    filename: String,
    dir_base: String,
    file_lock: Arc<Mutex<bool>>,
    repo_locks: Arc<Mutex<Vec<bool>>>,
    items: Arc<Mutex<Vec<Item>>>,
    is_ts: bool,
) -> Result<(), Box<dyn std::error::Error>> {
    let items_len;
    {
        let items_lock = items.lock().unwrap();
        items_len = items_lock.len();
    }
    let mut j = 0;
    while j < items_len {
        {
            // println!("Acquiring arr lock");
            let mut arr2 = repo_locks.lock().unwrap();
            let arr: &mut Vec<bool> = arr2.as_mut();
            let mut arr = arr.clone();
            // let arr: &mut Vec<bool> = arr2.as_mut();
            // println!("Len: {}", arr.len());
            while arr.len() <= j {
                arr.push(false);
            }
            *arr2 = arr;
            if arr2[j] {
                j += 1;
                // println!("Freeing arr lock");
                continue;
            }
            arr2[j] = true;
            // println!("Freeing arr lock");
        }
        if std::path::Path::exists(std::path::Path::new("./kill.txt")) {
            break;
        }
        let len = items_len;
        let mut item = items.lock().unwrap()[j].clone();
        if is_ts {
            if item.last_generated.is_some() && !force {
                j += 1;
                continue;
            }
        } else {
            if item.last_no_ts_gen.is_some() && !force {
                j += 1;
                continue;
            }
        }

        //stop for 5s
        let split_url = item.github_url.split("/").collect::<Vec<_>>();
        let repo_name = split_url[split_url.len() - 2..=split_url.len() - 1]
            .join("/")
            .to_string();
        println!("{} / {}", j, len);
        println!("Installing {}", repo_name);
        let current_dir = std::env::current_dir()?;
        let current_dir = current_dir.to_str().unwrap_or("osdf");
        let p = format!(
            "{}/lua/stuff/colorscheme.lua",
            get_dir_name(current_dir.to_string(), dir_base.clone()),
        );
        std::fs::write(p, format!("return '{}'", repo_name))?;
        // println!("Starting prog");
        let start_dir = get_dir_name(current_dir.to_string(), dir_base.clone());
        // let path_dir = format!("{}/.local/share/bob/nvim-bin", home_dir);
        let nv_args = vec![
            "-u",
            "init.lua",
            "--headless",
            // repo_name.clone(),
            // "--noplugin",
            "-c",
            "\"lua vim.fn.timer_start(5000, function() print('ooga'); vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, true, true), 'n', true) end, { ['repeat'] = -1 })\"",
            "-c",
            "\"lua vim.fn.timer_start(100, function() vim.cmd('Lazy sync'); vim.cmd('qa!') end)\"",
        ];
        let mut install_cmd = tokio::process::Command::new("bash");
        install_cmd
            .arg("-c")
            .arg(format!(
                "nvim {}",
                nv_args
                    .iter()
                    .map(|v| v.to_string())
                    .reduce(|v1, v2| format!("{} {}", v1, v2))
                    .unwrap()
            ))
            .current_dir(start_dir);

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
            tokio::time::sleep(std::time::Duration::from_secs(200)).await;
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

        if was_killed {
            println!("Install process was killed");
            j += 1;
            continue;
        }
        let mut new_colorschemes = Vec::new();
        let mut i = 0;
        while i < item.vim_color_schemes.len() {
            let mut colorscheme = item.vim_color_schemes[i].clone();
            println!("Colorscheme {}.{}", j, colorscheme.name);
            // if colorscheme.backgrounds.is_some() && !force && is_ts {
            //     new_colorschemes.push(colorscheme);
            //     i += 1;
            //     continue;
            // }
            let was_killed = generate_colorscheme(
                // repo_name.clone(),
                // "./nvim_worker/init.lua".to_string(),
                dir_base.clone(),
                colorscheme.name.clone(),
                false,
            )
            .await?;
            if !was_killed {
                let read_spot = format!(
                    "{}/gencolors.json",
                    get_dir_name(current_dir.to_string(), dir_base.clone())
                );
                let data = match std::fs::read_to_string(read_spot) {
                    Ok(d) => d,
                    Err(_) => "".to_string(),
                };
                match serde_json::from_str::<HashMap<String, String>>(&data) {
                    Ok(parsed) if parsed.len() > 0 => {
                        colorscheme.backgrounds = Some(vec!["light".to_string()]);
                        // colorscheme.data.light = Some(parsed);
                        let mut new_data = colorscheme.data.light.unwrap_or(HashMap::new());
                        for (k, v) in parsed {
                            new_data.insert(k, v);
                        }
                        colorscheme.data.light = Some(new_data);
                    }
                    Err(_) => {
                        // println!("Data parse failed on data {}", data);
                        // println!("{:?}", e);
                    }
                    _ => {}
                };
            }

            let was_killed = generate_colorscheme(
                dir_base.to_string(),
                // repo_name.clone(),
                // "./nvim_worker/init.lua".to_string(),
                colorscheme.name.clone(),
                true,
            )
            .await?;
            if !was_killed {
                let read_spot = format!(
                    "{}/gencolors.json",
                    get_dir_name(current_dir.to_string(), dir_base.clone())
                );
                let data = match std::fs::read_to_string(read_spot) {
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
                        let mut new_data = colorscheme.data.dark.unwrap_or(HashMap::new());
                        for (k, v) in parsed {
                            new_data.insert(k, v);
                        }
                        colorscheme.data.dark = Some(new_data);
                    }
                    Err(_) => {
                        // println!("Data parse failed on data {}", data);
                        // println!("{:?}", e);
                    }
                    _ => {}
                };
            }

            // let _ = std::fs::remove_file("gencolors.json");
            // let _ = std::fs::write("gencolors.json", "{}");
            i += 1;
            new_colorschemes.push(colorscheme);
        }
        {
            let _lock = file_lock.lock();
            item.vim_color_schemes = new_colorschemes;
            if is_ts {
                item.last_generated = Some(
                    std::time::SystemTime::now()
                        .duration_since(std::time::UNIX_EPOCH)
                        .unwrap()
                        .as_secs(),
                );
            } else {
                item.last_no_ts_gen = Some(
                    std::time::SystemTime::now()
                        .duration_since(std::time::UNIX_EPOCH)
                        .unwrap()
                        .as_secs(),
                );
            }
            items.lock().unwrap()[j] = item;
            j += 1;
            let mut arr: Vec<Item> = items.lock().unwrap().to_vec();
            arr.sort_by(|l, r| {
                r.stargazers_count
                    .unwrap_or(0)
                    .partial_cmp(&l.stargazers_count.unwrap_or(0))
                    .expect("ooga boga")
            });
            match std::fs::write(
                filename.clone(),
                serde_json::to_string_pretty(&arr).unwrap(),
            ) {
                Ok(_) => {}
                Err(e) => {
                    println!("Error writing to file {}: {:?}", filename.clone(), e);
                    return Err(e.into());
                }
            };
        }
        // break;
    }

    // std::fs::write("colors.json", serde_json::to_string_pretty(&items).unwrap())?;

    Ok(())
}
async fn generate_no_ts(
    force: bool,
    filename: String,
    dir_base: String,
    file_lock: Arc<Mutex<bool>>,
    repo_locks: Arc<Mutex<Vec<bool>>>,
    items: Arc<Mutex<Vec<Item>>>,
) -> Result<(), Box<dyn std::error::Error>> {
    return generate(
        force, filename, dir_base, file_lock, repo_locks, items, false,
    )
    .await;
}
async fn generate_ts(
    force: bool,
    filename: String,
    dir_base: String,
    file_lock: Arc<Mutex<bool>>,
    repo_locks: Arc<Mutex<Vec<bool>>>,
    items: Arc<Mutex<Vec<Item>>>,
) -> Result<(), Box<dyn std::error::Error>> {
    return generate(
        force, filename, dir_base, file_lock, repo_locks, items, true,
    )
    .await;
}

async fn move_to_lua(filename: String) -> Result<(), Box<dyn std::error::Error>> {
    let file = std::fs::File::open(filename)?;
    let mut json: Vec<Item> = serde_json::from_reader(file)?;
    json.sort_by(|l, r| {
        r.stargazers_count
            .unwrap_or(0)
            .partial_cmp(&l.stargazers_count.unwrap_or(0))
            .expect("Needed an ordering or something")
    });
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
    #[arg(long)]
    force: bool,

    #[arg(long)]
    thread_count: Option<usize>,
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
// async fn move_dir(from: String, to: String) -> Result<(), Box<dyn std::error::Error>> {
//     let mut cmd = tokio::process::Command::new("bash");
//     cmd.arg("-c").arg(format!("mv {} {}", from, to));
//     let output = cmd.output().await?;
//     if output.status.code().unwrap() != 0 {
//         return Err("Error moving dir".into());
//     }
//     return Ok(());
// }
async fn cp_dir(from: String, to: String) -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = tokio::process::Command::new("bash");
    let dirs = to
        .split("/")
        .map(|v| v.to_string())
        .collect::<Vec<String>>();
    let dirs = dirs.iter().take(dirs.len() - 1).map(|v| v.clone());
    let str = dirs
        .reduce(|v, n| format!("{}/{}", v, n))
        .unwrap_or("".to_string());
    cmd.arg("-c")
        .arg(format!("mkdir {} -p && cp -r {} {}", str, from, to));
    let output = cmd.output().await?;
    if output.status.code().unwrap() != 0 {
        return Err("Error copying dir".into());
    }
    return Ok(());
}
async fn rm_dir(dir: String) -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = tokio::process::Command::new("bash");
    println!("{}", dir);
    cmd.arg("-c").arg(format!("rm -rf {}", dir));
    let output = match cmd.output().await {
        Ok(v) => v,
        Err(e) => return Err(format!("Error removing dir: {}", e).into()),
    };
    if output.status.code().unwrap() != 0 {
        return Err("Error removing dir".into());
    }
    return Ok(());
}
// A function to test stuff
async fn do_yeet() -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = tokio::process::Command::new("nvim");
    // cmd.arg("--headless");
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
        tokio::time::sleep(std::time::Duration::from_secs(400)).await;
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
    let file_lock: Arc<Mutex<bool>> = Arc::new(true.into());
    let repo_locks = Arc::new(Mutex::new(Vec::new()));
    let thread_count = cli.thread_count.unwrap_or(128);

    // You can check for the existence of subcommands, and if found use their
    // matches just as you would the top level cmd
    match &cli.command {
        Some(Commands::MoveToLua { .. }) => {
            println!("Moving to lua...");
            move_to_lua(cli.file.unwrap_or("colors.json".to_string())).await?;
        }
        Some(Commands::GenerateNoTs { .. }) => {
            println!("Generating...");
            let mut id = 0;
            let mut threads = Vec::new();
            // let force = cli.force.clone();
            let file = cli.file.clone().unwrap_or("colors.json".to_string());
            let json_file = match std::fs::File::open(file.clone()) {
                Ok(v) => v,
                Err(_) => return Ok(()),
            };
            let mut items: Vec<Item> = match serde_json::from_reader(json_file) {
                Ok(v) => v,
                Err(_) => return Ok(()),
            };
            items.sort_by(|l, r| {
                r.vim_color_schemes
                    .len()
                    .partial_cmp(&l.vim_color_schemes.len())
                    .expect("idk man")
            });
            let items_mutex = Arc::new(Mutex::new(items));
            while id < thread_count {
                let file_lock = file_lock.clone();
                let repo_locks = repo_locks.clone();
                let force = cli.force.clone();
                let file = cli.file.clone().unwrap_or("colors.json".to_string());
                let actual_items = items_mutex.clone();
                threads.push(std::thread::spawn(move || {
                    let rt = tokio::runtime::Runtime::new();
                    let rt = match rt {
                        Ok(v) => v,
                        Err(_) => return,
                    };
                    rt.block_on(async {
                        let dir_base = format!("ooga-{}", id);
                        let dir_name = get_dir_name(".".to_string(), dir_base.clone());

                        if match dir_exists(dir_name.clone()).await {
                            Ok(v) => v,
                            Err(_) => return,
                        } {
                            println!("Nvim config found, deleting");
                            match rm_dir(dir_name.clone()).await {
                                Ok(_) => {}
                                Err(_) => return,
                            }
                        }
                        match cp_dir("./nvim_worker_no_ts".to_string(), dir_name.clone()).await {
                            Ok(_) => {}
                            Err(_) => return,
                        }
                        let res = generate_no_ts(
                            force,
                            file,
                            dir_base.clone(),
                            file_lock,
                            repo_locks,
                            actual_items,
                        )
                        .await;
                        // return Ok(());
                        println!("Deleting config");
                        // rm_dir(format!("./{}", dir_base)).await?;
                        match res {
                            Err(e) => println!("{:?}", e),
                            _ => println!("Generate exited successfully"),
                        }
                        // return Ok(());
                    });
                }));
                id += 1;
            }
            while !threads.iter().all(|t| t.is_finished()) {
                std::thread::sleep(std::time::Duration::from_millis(100));
            }
        }
        Some(Commands::GenerateTs { .. }) => {
            println!("Generating...");
            let mut id = 0;
            let mut threads = Vec::new();
            threads.reserve_exact(thread_count);
            let force = cli.force.clone();
            let file = cli.file.clone().unwrap_or("colors.json".to_string());
            let json_file = match std::fs::File::open(file.clone()) {
                Ok(v) => v,
                Err(_) => {
                    println!("Could not open colors file");
                    return Ok(());
                }
            };
            let mut items: Vec<Item> = match serde_json::from_reader(json_file) {
                Ok(v) => v,
                Err(e) => {
                    println!("Could not parse json {}", e);
                    return Ok(());
                }
            };
            items.sort_by(|l, r| {
                r.vim_color_schemes
                    .len()
                    .partial_cmp(&l.vim_color_schemes.len())
                    .expect("idk man")
            });
            let items_mutex = Arc::new(Mutex::new(items));
            while id < thread_count {
                let file_lock = file_lock.clone();
                let repo_locks = repo_locks.clone();
                let actual_items = items_mutex.clone();
                let file_copy = file.clone();
                threads.push(std::thread::spawn(move || {
                    let file = file_copy;
                    let rt = tokio::runtime::Runtime::new();
                    let rt = match rt {
                        Ok(v) => v,
                        Err(_) => return,
                    };
                    rt.block_on(async {
                        let dir_base = format!("ooga-{}", id);
                        let dir_name = get_dir_name(".".to_string(), dir_base.clone());
                        if match dir_exists(dir_name.clone()).await {
                            Ok(v) => v,
                            Err(_) => return,
                        } {
                            println!("Nvim config found, deleting");
                            match rm_dir(dir_name.clone()).await {
                                Ok(_) => {}
                                Err(_) => return,
                            }
                        }
                        match cp_dir("./nvim_worker".to_string(), dir_name.clone()).await {
                            Ok(_) => {}
                            Err(_) => return,
                        }
                        let res = generate_ts(
                            force,
                            file,
                            dir_base.clone(),
                            file_lock,
                            repo_locks,
                            actual_items,
                        )
                        .await;
                        // return Ok(());
                        println!("Deleting config");
                        // rm_dir(format!("./{}", dir_base)).await?;
                        match res {
                            Err(e) => println!("{:?}", e),
                            _ => println!("Generate exited successfully"),
                        }
                        // return Ok(());
                    });
                }));
                id += 1;
            }
            while !threads.iter().all(|t| t.is_finished()) {
                std::thread::sleep(std::time::Duration::from_millis(100));
            }
        }
        Some(Commands::MakeColorData { .. }) => {
            println!("Making color data...");
            make_color_data(thread_count).await?;
        }
        Some(Commands::CleanImport { .. }) => {
            println!("Cleaning import...");
            clean_import()?;
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
            clean_import()?;
        }
    }

    // Continued program logic goes here...
    Ok(())
}
