**library=./lib/negbook.sh
mkdir -p ./lib
if [[ ! -f "$library" ]]; then
    curl -o "$library" https://raw.githubusercontent.com/ronthesoul/negbook/main/negbook.sh
fi
source "$library"**# negbook

**negbook** is a lightweight Bash utility library meant to be easily imported into your shell scripts and automation tools. It provides reusable functions and helpers to speed up scripting and ensure consistency across projects.

---

## Purpose

This repository is designed to serve as a modular, drop-in shell library for your Bash-based tooling.

Simply include the following snippet at the top of any Bash script to ensure the library is present and sourced correctly:

```bash
library=./lib/negbook.sh
mkdir -p ./lib
if [[ ! -f "$library" ]]; then
    curl -o "$library" https://raw.githubusercontent.com/ronthesoul/negbook/main/negbook.sh
fi
source "$library"
```

---

Author
Ron Negrov
GitHub: @ronthesoul

