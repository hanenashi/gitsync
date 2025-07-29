#!/bin/bash
set -e

TERMUX_DIR="$HOME/GIT"
SHARED_DIR="/storage/emulated/0/GIT"

mkdir -p "$TERMUX_DIR" "$SHARED_DIR"

echo "Mirror (Termux → Shared) or Sync (interactive)? [M/S]: "
read -r mode_choice

# List repo names (directories)
termux_repos=($(ls -1 "$TERMUX_DIR"))
shared_repos=($(ls -1 "$SHARED_DIR"))
all_repos=($(printf "%s\n" "${termux_repos[@]}" "${shared_repos[@]}" | sort -u))

echo "Detected repositories:"
index=1
declare -A repo_map
for repo in "${all_repos[@]}"; do
    present_termux="[ ]"
    present_shared="[ ]"
    [[ -d "$TERMUX_DIR/$repo" ]] && present_termux="[T]"
    [[ -d "$SHARED_DIR/$repo" ]] && present_shared="[S]"
    echo "  [$index] $repo $present_termux$present_shared"
    repo_map[$index]=$repo
    ((index++))
done

echo
read -p "Enter number of repo to process: " selection
repo_name="${repo_map[$selection]}"
if [ -z "$repo_name" ]; then
    echo "Invalid selection."
    exit 1
fi

TERMUX_PATH="$TERMUX_DIR/$repo_name"
SHARED_PATH="$SHARED_DIR/$repo_name"

if [[ "$mode_choice" =~ ^[Mm]$ ]]; then
    if [ ! -d "$TERMUX_PATH/.git" ]; then
        echo "❌ No .git found in Termux repo. Aborting mirror."
        exit 1
    fi
    echo "Mirroring $repo_name from Termux → Shared..."
    rm -rf "$SHARED_PATH"
    cp -r "$TERMUX_PATH" "$SHARED_PATH"

    echo "Adding safe.directory exception for Git..."
    git config --global --add safe.directory "$SHARED_PATH"

    echo "Checking Git status in shared folder..."
    cd "$SHARED_PATH"
    git status
    git remote -v
    echo "✅ Mirror completed."
    exit 0
fi

# Interactive sync mode
if [ -d "$TERMUX_PATH" ] && [ ! -d "$SHARED_PATH" ]; then
    echo "Repo exists only in Termux. Copying to Shared..."
    cp -r "$TERMUX_PATH" "$SHARED_PATH"
elif [ ! -d "$TERMUX_PATH" ] && [ -d "$SHARED_PATH" ]; then
    echo "Repo exists only in Shared. Copying to Termux..."
    cp -r "$SHARED_PATH" "$TERMUX_PATH"
elif [ -d "$TERMUX_PATH" ] && [ -d "$SHARED_PATH" ]; then
    echo "Repo exists in both locations."
    echo "Comparing..."
    
    diff -qr "$TERMUX_PATH" "$SHARED_PATH" || true
    echo
    read -p "Push Termux → Shared [T], Shared → Termux [S], Skip [Enter]? " choice
    if [ "$choice" = "T" ]; then
        echo "Copying from Termux to Shared..."
        rm -rf "$SHARED_PATH"
        cp -r "$TERMUX_PATH" "$SHARED_PATH"
    elif [ "$choice" = "S" ]; then
        echo "Copying from Shared to Termux..."
        rm -rf "$TERMUX_PATH"
        cp -r "$SHARED_PATH" "$TERMUX_PATH"
    else
        echo "Skipped."
    fi
else
    echo "Repo doesn't exist in either location. Nothing to sync."
    exit 1
fi

echo "✅ Sync completed for $repo_name."
