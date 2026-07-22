#!/bin/bash
# sync_translations_to_i18n.sh
# Recursively syncs the translations directory from the main repository to the i18n repository.
# Usage: ./sync_translations_to_i18n.sh <release_version>
#
# Requires the environment variable I18N_TOKEN to authenticate with the i18n repository.
# Requires the environment variable I18N_REPO_URL to be defined (base URL without token).
# The script constructs the full repository URL using these variables.

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <release_version>"
    exit 1
fi

# Ensure I18N_TOKEN is defined
if [ -z "$I18N_TOKEN" ]; then
    echo "Error: The environment variable I18N_TOKEN is not defined."
    exit 1
fi

# Ensure I18N_REPO_URL is defined
if [ -z "$I18N_REPO_URL" ]; then
    echo "Error: The environment variable I18N_REPO_URL is not defined."
    exit 1
fi

VERSION=$1
LANGUAGES=("es_CR" "es_ES" "en" "ca")

# Directories (adjust these paths if needed)
MAIN_REPO_PATH=$(pwd)  # Main repository (current directory)
LOCALE_DIR="$MAIN_REPO_PATH/locale"
# Local path for the i18n repository; assumed to be a sibling directory
I18N_REPO_PATH="../Giswater-Documentation-i18n"
# Construct the full URL including the token for HTTPS authentication
I18N_REPO_FULL_URL="https://${I18N_TOKEN}@${I18N_REPO_URL}"

echo "Syncing translation files to the i18n repository for version $VERSION..."

# If the i18n repository does not exist locally, clone it
if [ ! -d "$I18N_REPO_PATH" ]; then
    echo "Cloning i18n repository from $I18N_REPO_FULL_URL..."
    git clone "$I18N_REPO_FULL_URL" "$I18N_REPO_PATH"
else
    echo "Updating i18n repository..."
    cd "$I18N_REPO_PATH"
    git pull origin master
    cd "$MAIN_REPO_PATH"
fi

# Ensure that the specified version folder exists in the i18n repository.
if [ ! -d "$I18N_REPO_PATH/$VERSION" ]; then
    echo "Error: Version folder '$VERSION' does not exist in the i18n repository."
    exit 1
fi

echo "Syncing translations to the i18n repository for version $VERSION..."

for lang in "${LANGUAGES[@]}"; do
    SOURCE_DIR="$LOCALE_DIR/$lang/LC_MESSAGES"
    TARGET_DIR="$I18N_REPO_PATH/$VERSION/locale/$lang/LC_MESSAGES"

    # For no_TR, or if a language directory does not exist, use 'en' as a fallback.
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "Warning: Source directory for language '$lang' does not exist. Using 'en' as fallback."

        SOURCE_DIR_EN="$LOCALE_DIR/en/LC_MESSAGES"
        if [ -d "$SOURCE_DIR_EN" ]; then
            mkdir -p "$TARGET_DIR"
            rsync -av --checksum --delete "$SOURCE_DIR_EN"/ "$TARGET_DIR"/
            echo "Copied 'en' files to '$lang' for version '$VERSION' in $TARGET_DIR"
        else
            # This is a critical issue if 'en' is missing, as it's the fallback.
            echo "Error: Source directory for 'en' language does not exist. Cannot create fallback for '$lang'."
            exit 1
        fi
    else
        # Existing logic for languages with an existing source directory
        mkdir -p "$TARGET_DIR"
        rsync -av --checksum --delete "$SOURCE_DIR"/ "$TARGET_DIR"/
        echo "Copied files for language '$lang' to $TARGET_DIR"
    fi
done

echo "Sync completed for version $VERSION."

# Commit and push changes in the i18n repository
cd "$I18N_REPO_PATH"

# Configure Git identity for CI
git config user.email "admin-giswater@users.noreply.github.com"
git config user.name "Giswater Admin"

# Check for changes including untracked files
if [ -n "$(git status --porcelain)" ]; then
    git add .
    git commit -m "chore: auto-sync translations for version $VERSION"
    git push origin master
    echo "Changes committed and pushed to the i18n repository."
else
    echo "No changes to commit in the i18n repository."
fi

echo "Sync completed for version $VERSION."