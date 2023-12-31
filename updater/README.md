# Pineapple updater

The thing that updates the massive list of themes that pineapple uses.

## Usage

The pineapple updater takes several steps to complete.

### 1. Scrape GitHub and neovimcraft for themes

Execute the following shell commands:

```bash
bash ./scrape_github.sh
bash ./scrape_neovimcraft.sh
```

These don't take very long to complete, probably less than 10 minutes.

The output of these commands is stored in the gh_out\_\*.json and nvc\_\*.json files.

Though one problem is that usually the GitHub scraper will be rate limited. This is accounted for in the bash script as it has a feature that allows some queries to be skipped.

### 2. Move all the themes into one file

Execute the following shell command:

```bash
cargo run --release -- clean-import
```

### 3. Generate possible colorschemes

Execute the following shell command:

```bash
cargo run --release -- make-color-data
```

### 4. Generate theme data for treesitter

This step and the following step, take about 1hr to complete each.

Execute the following shell command:

```bash
cargo run --release -- generate-ts
```

### 5. Generate non-treesitter theme data

Execute the following shell command:

```bash
cargo run --release -- generate-no-ts
```

### 6. Generate the lua data file

Execute the following shell command:

```bash
cargo run --release -- move-to-lua
```
