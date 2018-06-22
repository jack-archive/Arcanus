#!/bin/bash

sudo apt-get update
sudo apt-get install -y git clang libncurses-dev  libcurl4-openssl-dev openssl libssl-dev uuid-dev sqlite3

git clone https://github.com/kylef/swiftenv.git ~/.swiftenv
echo 'export SWIFTENV_ROOT="$HOME/.swiftenv"' >> ~/.bashrc
echo 'export PATH="$SWIFTENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(swiftenv init -)"' >> ~/.bashrc

export SWIFTENV_ROOT="$HOME/.swiftenv"
export PATH="$SWIFTENV_ROOT/bin:$PATH"
eval "$(swiftenv init -)"

swiftenv install 4.1.2

git clone https://github.com/jmmaloney4/Arcanus.git
cd Arcanus
swift build
