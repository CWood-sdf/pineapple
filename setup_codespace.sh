curl https://sh.rustup.rs -sSf | sh

source ~/.bashrc

cargo install --git https://github.com/MordechaiHadad/bob.git

bob use nightly

echo 'export PATH="$PATH:~/.local/share/bob/nvim-bin"' >> ~/.bashrc

source ~/.bashrc

cd updater

cargo build --release

cargo run --release -- generate-ts

cargo run --release -- generate-no-ts

cargo run --release -- move-to-lua

