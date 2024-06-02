#!/usr/bin/env bash
# Copyright 2023-2024 Broadcom. All rights reserved.
# SPDX-License-Identifier: BSD-2

follow_link() {
    file="$1"
    while [ -L "$file" ]; do
        file=$(readlink "$file")
    done
    echo "$file"
}

# Get the script path.
#script_path=$(realpath "$(dirname "$(follow_link "$0")")")
script_path=$(
    cd "$(dirname "$(follow_link "$0")")" || exit
    pwd
)

run_check_dependencies=false
run_check_jq=false
run_show_help=false

# This function prompts the user to press Enter to continue.
press_enter_continue() {
    printf "Press \033[32mEnter\033[0m to continue.\n"
    read -r
    exec "$0"
}

# This function prompts the user to press Enter to exit.
press_enter_exit() {
    printf "Press \033[31mEnter\033[0m to exit.\n"
    read -r
    exit 0
}

# This function prompts the user to press Enter to continue.
press_enter() {
    cd "$script_path" || exit
    printf "Press \033[32mEnter\033[0m to continue.\n"
    read -r
    exec $0
}

# Set config_path if it's not already set
if [ -z "$config_path" ]; then
    config_path=$(
        cd "${script_path}/config" || exit
        pwd
    )
fi

# This function displays the information about the script and project.
info() {
    project_name=$(get_project_info "name")
    project_description=$(get_project_info "description")
    project_version=$(get_project_info "version")
    project_license=$(get_project_info "license[0].name")
    project_github_url=$(get_project_info "urls.github")
    project_docs_url=$(get_project_info "urls.documentation")
    clear
    printf "\033[32m%s\033[0m: \033[34m%s\033[0m\n\n" "$project_name" "$project_version"
    printf "Copyright 2023-%s Broadcom. All Rights Reserved.\n\n" "$(date +%Y)"
    printf "License: %s\n\n" "$project_license"
    printf "%s\n\n" "$project_description"
    printf "GitHub Repository: %s\n" "$project_github_url"
    printf "Documentation: %s\n\n" "$project_docs_url"
    show_help "continue"
    press_enter_continue
}

# This function displays the help message.
show_help() {
    local exit_after=${1:-"exit"}
    script_name=$(basename "$0")
    printf "Usage: %s [options]\n\n" "$script_name"
    printf "Options:\n"
    printf "  --help, -h, -H       Display this help message.\n\n"
    printf "  --deps, -d, -D       Check the dependencies.\n"
    printf "  --debug, -b, -B      Enable debug mode.\n"
    printf "  --json, -j, -J       Specify the JSON file path.\n"
    printf "  --show, -s, -S       Display the build command used to build the image.\n"
    if [[ -z "$input" ]]; then
        [ "$exit_after" = "exit" ] && exit 0
    else
        press_enter_continue
    fi
}

json_path="project.json"

# Check for jq
check_jq() {
    cmd="jq"
    if ! command -v $cmd &>/dev/null; then
        echo -e "\033[0;31m[✘]\033[0m $cmd is not installed."
        exit 1
    fi
}

check_ansible() {
    cmd="ansible"
    local deps_version=$(jq -r --arg cmd $cmd '.dependencies[] | select(.name == $cmd ) | .version_requirement' $json_path)
    required_version=$(echo "$deps_version" | tr -d '>=' | xargs)
    if ! command -v $cmd &>/dev/null; then
        echo -e "\033[0;31m[✘]\033[0m $cmd is not installed. $required_version or later is required."
        exit 1
    else
        installed_version=$($cmd --version | head -n 1 | awk '{print $3}' | tr -d '[]')
        if [ "$(printf '%s\n' "$required_version" "$installed_version" | sort -V | head -n1)" != "$required_version" ]; then
            echo -e "\033[0;31m[✘]\033[0m $cmd-core $installed_version installed. $required_version or later is required."
            exit 1
        fi
    fi
}

check_packer() {
    cmd="packer"
    local deps_version=$(jq -r --arg cmd $cmd '.dependencies[] | select(.name == $cmd ) | .version_requirement' $json_path)
    required_version=$(echo "$deps_version" | tr -d '>=' | xargs)
    if ! command -v $cmd &>/dev/null; then
        echo -e "\033[0;31m[✘]\033[0mP $cmd is not installed. $required_version or later is required."
        exit 1
    else
        installed_version=$($cmd version | head -n 1 | awk '{print $2}' | tr -d 'v')
        if [ "$(printf '%s\n' "$required_version" "$installed_version" | sort -V | head -n1)" != "$required_version" ]; then
            echo -e "\033[0;31m[✘]\033[0m $cmd $installed_version installed. $required_version or later is required."
            exit 1
        fi
    fi
}

# Check if jq is installed.
check_jq

# Check if ansible is installed.
check_ansible

# Check if packer is installed.
check_packer

check_command() {
    cmd=$1
    capitalized_cmd=$(echo "$cmd" | awk '{print toupper(substr($0,1,1))substr($0,2)}')
    version_requirement=$(jq -r --arg cmd "$cmd" '.dependencies[] | select(.name == $cmd) | .version_requirement' "$json_path")
    operator=$(echo "$version_requirement" | cut -d " " -f 1)
    required_version=$(echo "$version_requirement" | cut -d " " -f 2)

    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color

    CHECKMARK="${GREEN}[✔]${NC}"
    CROSSMARK="${RED}[✘]${NC}"

    if command -v "$cmd" &>/dev/null; then
        installed_version=$($cmd --version | head -n 1 | awk '{print $NF}' | sed 's/[^0-9.]*//g')
        case $operator in
        ">=")
            if echo -e "$required_version\n$installed_version" | sort -V -C; then
                echo -e "$CHECKMARK $capitalized_cmd: $installed_version is installed. $required_version or later is required."
            else
                echo -e "$CROSSMARK $capitalized_cmd: $installed_version is installed. $required_version or later is required."
            fi
            ;;
        "==")
            if [ "$installed_version" == "$required_version" ]; then
                echo -e "$CHECKMARK $capitalized_cmd: $installed_version is installed. $required_version or later is required."
            else
                echo -e "$CROSSMARK $capitalized_cmd: $installed_version is installed. $required_version or later is required."
            fi
            ;;
        *)
            echo -e "$CROSSMARK Unknown operator: $operator"
            ;;
        esac
    else
        echo -e "$CROSSMARK $capitalized_cmd is not installed. $required_version or later required."
    fi
}

# This function checks if the required dependencies are installed.
check_dependencies() {
    for cmd in packer ansible terraform git gomplate; do
        check_command $cmd
    done
    printf "\nPress \033[32mEnter\033[0m to continue."
    read -r input
    if [[ -z "$input" ]]; then
        return
    else
        printf "\nPress \033[32mEnter\033[0m to continue."
    fi
}

show_command=0
# Script options.
while (("$#")); do
    case "$1" in
    --json | -j | -J)
        json_path="$2"
        run_check_jq=true
        shift 2
        ;;
    --deps | -d | -D)
        check_dependencies
        shift
        ;;
    --show | -s | -S)
        show_command=1
        shift
        ;;
    --debug | -b | -B)
        debug=1
        debug_option="-debug"
        shift
        ;;
    --help | -h | -H)
        run_show_help=true
        show_help
        shift
        ;;
    *)
        config_path=$(realpath "$1")
        shift
        ;;
    esac
done

# After the loop, check if show_help needs to be run
if $run_show_help; then
    show_help
fi

if $run_check_dependencies; then
    check_dependencies
fi

# Set the default values for the variables.
os_names=$(jq -r '.os[] | .name' "$json_path")
os_array=($os_names)

# Get the project information from the JSON file.
get_project_info() {
    local field=$1
    jq -r ".project.${field}" "$json_path"
}

# Get the build information from the JSON file.
get_build_info() {
    local field=$1
    jq -r ".build.${field}" "$json_path"
}

# Get the settings from the JSON file.
get_settings() {
    local field=$1
    jq -r ".settings.${field}" "$json_path"
}

validate_windows_username() {
    build_username=$(grep 'build_username' "$1" | awk -F '"' '{print $2}')
    if [[ ! ${build_username} =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}'\$')$ ]]; then
        echo -e "\n\033[31mBuild username \033[33m$build_username\033[31m is invalid for Linux OS. Please check the build.pkrvars.hcl file."
        echo -e "\nUsername validation rules:"
        echo -e "\n1. It should start (^) with only a lowercase letter or an underscore ([a-z_]). This occupies exactly 1 character."
        echo -e "\n2. Then it should be one of either (( ... )):"
        echo -e "\n   a. From 0 to 31 characters ({0,31}) of letters, numbers, underscores, and/or hyphens ([a-z0-9_-]),"
        echo -e "\n   OR (|)"
        echo -e "\n   b. From 0 to 30 characters of the above plus a US dollar sign symbol (\$) at the end,"
        echo -e "\n3. No more characters past this pattern ($).\033[0m"
        exit 1
    fi
}

validate_linux_username() {
    build_username=$(grep 'build_username' "$1" | awk -F '"' '{print $2}')
    if [[ ! ${build_username} =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}'\$')$ ]]; then
        echo -e "\n\033[31mBuild username \033[33m$build_username\033[31m is invalid for Linux OS. Please check the build.pkrvars.hcl file."
        echo -e "\nUsername validation rules:"
        echo -e "\n1. It should start (^) with only a lowercase letter or an underscore ([a-z_]). This occupies exactly 1 character."
        echo -e "\n2. Then it should be one of either (( ... )):"
        echo -e "\n   a. From 0 to 31 characters ({0,31}) of letters, numbers, underscores, and/or hyphens ([a-z0-9_-]),"
        echo -e "\n   OR (|)"
        echo -e "\n   b. From 0 to 30 characters of the above plus a US dollar sign symbol (\$) at the end,"
        echo -e "\n3. No more characters past this pattern ($).\033[0m"
        exit 1
    fi
}

# Get the settings from the JSON file.
logging_enabled=$(get_settings build_logging_enabled)
logging_path=$(get_settings build_logging_path)
logfile_filename=$(get_settings build_logging_filename)

# This function prompts the user to go back or quit.
prompt_user() {
    printf "Enter \033[32mb\033[0m to go back, or \033[31mq\033[0m to quit.\n\n"
}

# This function prints a message to the console based on the message type.
print_message() {
    local type=$1
    local message=$2

    case $type in
    error)
        printf "\033[31m%s\033[0m$message"
        ;;
    info)
        printf "\033[37m%s\033[0m$message"
        ;;
    warn)
        printf "\033[33m%s\033[0m$message"
        ;;
    debug)
        printf "\033[34m%s\033[0m$message"
        ;;
    *)
        printf "%s" "$message"
        ;;
    esac

    if $logging_enabled; then
        # Remove color formatting from the log message
        local no_color_message=$(echo -e "$message" | sed -r "s/\x1b\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")]
        log_message "$type" "$no_color_message"
    fi
}

log_message() {
    local type=$1
    local message=$2
    if $logging_enabled; then
        printf "$(date '+%Y-%m-%d %H:%M:%S') [%s]: %s\n" "$(echo "$type" | tr '[:lower:]' '[:upper:]')" "$message" >>"$log_file"
    fi
}

print_title() {
    project_name=$(jq -r '.project.name' "$json_path")
    project_version=$(jq -r '.project.version' "$json_path")
    line_width=80
    title="${project_name} ${project_version}"
    subtitle="B U I L D"
    padding_title=$((($line_width - ${#title}) / 2))
    padding_subtitle=$((($line_width - ${#subtitle}) / 2))

    # Check if the current directory is a git repository
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        # Get the current branch name
        branch_name=$(git rev-parse --abbrev-ref HEAD)
        title="${title} (Branch: ${branch_name})"
        padding_title=$((($line_width - ${#title}) / 2))

        # Check if the branch name contains a /
        if [[ "$branch_name" == *"/"* ]]; then
            branch_contains_slash=true
        else
            branch_contains_slash=false
        fi
    fi

    printf "\033[34m%*s%s\033[0m\n" $padding_title '' "$title"
    printf "\033[32m%*s%s\033[0m\n" $padding_subtitle '' "$subtitle"
}

# This function selects the guest operating system family.
# Only `Linux` and `Windows` are supported presently in the JSON file.
select_os() {
    clear
    print_title
    printf "\nSelect a guest operating system:\n\n"
    for i in "${!os_array[@]}"; do
        printf "$((i + 1)): ${os_array[$i]}\n"
    done
    printf "\nEnter \033[31mq\033[0m to quit or \033[34mi\033[0m for info.\n\n"

    while true; do
        read -r -p "Select a guest operating system: " os_input
        if [[ $os_input == [qQ] ]]; then
            exit 0
        elif [[ $os_input == [iI] ]]; then
            info
        elif ((os_input >= 1 && os_input <= ${#os_array[@]})); then
            os=${os_array[$((os_input - 1))]}
            select_distribution
            break
        else
            printf "\n"
            print_message warn "\033[33mInvalid Selection:\033[0m Enter a number between 1 and ${#os_array[@]}."
            printf "\n\n"
        fi
    done
}

select_distribution() {
    # Check if the selected guest operating system is Linux or Windows.
    print_title
    case "$os" in
    "Linux")
        dist_descriptions=$(jq -r --arg os "$os" '.os[] | select(.name == $os) | .distributions[] | .description' "$json_path")
        ;;
    "Windows")
        dist_descriptions=$(jq -r --arg os "$os" '.os[] | select(.name == $os) | .types[] | .description' "$json_path")
        ;;
    *)
        print_message error "Unsupported guest operating system. Exiting..."
        ;;
    esac

    # Check if the distribution descriptions are empty.
    if [ -z "$dist_descriptions" ]; then
        printf "\nNo distributions found for $os.\n"
        select_os
        return
    fi

    # Convert the distribution descriptions to an array.
    IFS=$'\n' read -rd '' -a dist_array <<<"$dist_descriptions"

    # Sort the array.
    IFS=$'\n' dist_array=($(sort <<<"${dist_array[*]}"))
    unset IFS

    # Print the submenu.
    clear
    print_title
    printf "\nSelect a %s:\n\n" "$([[ "$os" == "Windows" ]] && echo "$os type" || echo "$os distribution")"
    for i in "${!dist_array[@]}"; do
        printf "%d: %s\n" "$((i + 1))" "${dist_array[$i]}"
    done
    printf "\n"
    prompt_user

    while true; do
        read -r -p "Enter a number of the $([[ "$os" == "Windows" ]] && echo "$os type" || echo "$os distribution"): " dist_input
        if [[ $dist_input == [qQ] ]]; then
            exit 0
        elif [[ $dist_input == [bB] ]]; then
            select_os
            break
        elif ((dist_input >= 1 && dist_input <= ${#dist_array[@]})); then
            dist=${dist_array[$((dist_input - 1))]}
            select_version
            break
        else
            printf "\n"
            print_message warn "\033[33mInvalid Selection:\033[0m Enter a number between 1 and ${#dist_array[@]}."
            printf "\n\n"
        fi
    done
}

# This function selects the version based on the guest operating system's distribution or type.
select_version() {
    # Check if the selected guest operating system is Windows.
    if [[ "$dist" == *"Windows"* ]]; then
        # Parse the JSON file to get the versions for the selected distribution Windows
        version_descriptions=$(jq -r --arg os "$os" --arg dist "$dist" '.os[] | select(.name == $os) | .types[] | select(.description == $dist) | .versions | to_entries[] | select(.value[] | .enabled == "true") | .key' "$json_path")
    else
        version_descriptions=$(jq -r --arg os "$os" --arg dist "$dist" '.os[] | select(.name == $os) | .distributions[] | select(.description == $dist) | .versions | to_entries[] | select(.value[] | .enabled == "true") | .key' "$json_path")
    fi

    # Convert the version descriptions to an array and sort it in descending order.
    IFS=$'\n' read -rd '' -a version_array <<<"$(echo "$version_descriptions" | sort -r)"

    # Print the submenu.
    clear
    print_title
    printf "\nSelect a version:\n\n"
    for i in "${!version_array[@]}"; do
        printf "$((i + 1)): $dist ${version_array[$i]}\n"
    done
    printf "\n"
    prompt_user

    # Select a version.
    while true; do
        read -r -p "Select a version: " version_input
        if [[ "$version_input" == [qQ] ]]; then
            exit 0
        elif [[ $version_input == [bB] ]]; then
            select_distribution
            break
        elif [[ $version_input =~ ^[0-9]+$ ]] && ((version_input >= 1 && version_input <= ${#version_array[@]})); then
            version=${version_array[$((version_input - 1))]}
            if [[ "$dist" == *"Windows"* ]]; then
                select_edition
            else
                select_build
            fi
            break
        else
            printf "\n"
            print_message warn "\033[33mInvalid Selection:\033[0m Enter a number between 1 and ${#version_array[@]}.\n"
            printf "\n"
        fi
    done
}

select_edition() {
    edition_descriptions=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" '.os[] | select(.name == $os) | .types[] | select(.description == $dist) | .versions[$version][] | .editions[] | select(.enabled == "true") | .edition' "$json_path")
    IFS=$'\n' read -rd '' -a edition_array <<<"$(echo "$edition_descriptions" | sort -r)"

    # Print the submenu.
    clear
    printf "\nSelect an edition:\n\n"
    for i in "${!edition_array[@]}"; do
        printf "$((i + 1)): $dist ${edition_array[$i]}\n"
    done
    printf "\n"
    prompt_user

    # Select an edition.
    while true; do
        read -r -p "Select an edition: " edition_input
        if [[ "$edition_input" == [qQ] ]]; then
            exit 0
        elif [[ $edition_input == [bB] ]]; then
            select_version
            break
        elif [[ $edition_input =~ ^[0-9]+$ ]] && ((edition_input >= 1 && edition_input <= ${#edition_array[@]})); then
            edition=${edition_array[$((edition_input - 1))]}
            select_build
            break
        else
            printf "\n"
            print_message warn "\033[33mInvalid Selection:\033[0m Enter a number between 1 and ${#edition_array[@]}.\n"
            printf "\n"
        fi
    done
}

select_build() {
    if [[ "$dist" == *"Red Hat"* ]]; then
        dist_name="rhel"
    elif [[ "$dist" == *"SUSE"* ]]; then
        dist_name="sles"
    elif [[ "$dist" == *"Photon"* ]]; then
        dist_name="photon"
    elif [[ "$dist" == *"Windows Server"* ]]; then
        dist_name="server"
    elif [[ "$dist" == *"Windows Desktop"* ]]; then
        dist_name="desktop"

    else
        dist_name_split="${dist%% *}"
        #dist_name="${dist_name_split,,}"
        dist_name=$(echo "$dist_name_split" | tr '[:upper:]' '[:lower:]')
    fi

    if [[ "$dist" == *"Ubuntu"* ]]; then
        version=$version
        version=$(echo "$version" | sed 's/\./-/g')-LTS
        INPUT_PATH="$script_path"/builds/$(echo "$os" | tr '[:upper:]' '[:lower:]')/$(echo "$dist_name" | tr '[:upper:]' '[:lower:]')/$(echo "$version" | tr '[:upper:]' '[:lower:]')/
    else
        version=$(echo "$version" | tr '[:upper:]' '[:lower:]')
        INPUT_PATH="$script_path"/builds/$(echo "$os" | tr '[:upper:]' '[:lower:]')/$(echo "$dist_name" | tr '[:upper:]' '[:lower:]')/$version/
    fi

    if [ ! -d "$INPUT_PATH" ]; then
        printf "\n"
        print_message error "\033[31mError:\033[0m The build directory does not exist: \e[34m$INPUT_PATH\e[0m."
        while true; do
            read -r -p "$(echo -e '\n\nWould you like to go (\e[33mb\e[0m)ack or (\e[31mq\e[0m)uit? ')" action
            log_message "info" "User selected: $action"
            case $action in
            [b]*)
                # Go back to the previous menu or step.
                select_version
                break
                ;;
            [q]*)
                # Quit the script.
                exit 0
                ;;
            esac
        done
    fi
    BUILD_PATH=${INPUT_PATH#"${script_path}/builds/"}
    BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

    echo -e "\nBuild a $dist $version virtual machine image for VMware vSphere?"

    # Check if the branch_contains_slash variable is true
    if $branch_contains_slash; then
      printf "\n\033[33mWarning:\033[0m The branch name contains a slash ('\033[33m/\033[0m') which may cause issues with the build.\n\n"
    fi

    while true; do
        prompt=$(printf '\nWould you like to (\e[32mc\e[0m)ontinue, go (\e[33mb\e[0m)ack, or (\e[31mq\e[0m)uit? ')
        read -r -p "$prompt" action
        log_message "info" "User selected: $action"
        case $action in
        [Cc]*)
            # Continue the Build.
            break
            ;;
        [Qq]*)
            # Quit the script.
            exit 0
            ;;
        [Bb]*)
            # Go back to the menu.
            select_version
            break
            ;;
        esac
    done

    printf "\nInitializing HashiCorp Packer and the required plugins...\n"
    packer init "$INPUT_PATH"

    # Check if the selected guest operating system is Linux or Windows.
    if [[ "$os" == *"Linux"* ]]; then
        vsphere_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" '.os[] | select(.name == $os) | .distributions[] | select(.description == $dist) | .versions | to_entries[] | .value[] | select(.version == $version) | .build_files[0].vsphere' "$json_path")

    elif [[ "$dist" == *"Windows"* ]]; then
        vsphere_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" --arg edition "$edition" '.os[] | select(.name == $os) | .types[] | select(.description == $dist) | .versions[$version][] | .editions[] | select(.edition == $edition) | .build_files[0].vsphere' "$json_path")
    fi

    if [[ "$os" == *"Linux"* ]]; then
        build_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" '.os[] | select(.name == $os) | .distributions[] | select(.description == $dist) | .versions | to_entries[] | .value[] | select(.version == $version) | .build_files[0].build' "$json_path")
    elif [[ "$dist" == *"Windows"* ]]; then
        build_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" --arg edition "$edition" '.os[] | select(.name == $os) | .types[] | select(.description == $dist) | .versions[$version][] | .editions[] | select(.edition == $edition) | .build_files[0].build' "$json_path")
    fi

    if [[ "$os" == *"Linux"* ]]; then
        ansible_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" '.os[] | select(.name == $os) | .distributions[] | select(.description == $dist) | .versions | to_entries[] | .value[] | select(.version == $version) | .build_files[0].ansible' "$json_path")
    elif [[ "$dist" == *"Windows"* ]]; then
        ansible_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" --arg edition "$edition" '.os[] | select(.name == $os) | .types[] | select(.description == $dist) | .versions[$version][] | .editions[] | select(.edition == $edition) | .build_files[0].ansible' "$json_path")
    fi

    if [[ "$os" == *"Linux"* ]]; then
        proxy_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" '.os[] | select(.name == $os) | .distributions[] | select(.description == $dist) | .versions | to_entries[] | .value[] | select(.version == $version) | .build_files[0].proxy' "$json_path")
    elif [[ "$dist" == *"Windows"* ]]; then
        proxy_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" --arg edition "$edition" '.os[] | select(.name == $os) | .types[] | select(.description == $dist) | .versions[$version][] | .editions[] | select(.edition == $edition) | .build_files[0].proxy' "$json_path")
    fi

    if [[ "$os" == *"Linux"* ]]; then
        common_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" '.os[] | select(.name == $os) | .distributions[] | select(.description == $dist) | .versions | to_entries[] | .value[] | select(.version == $version) | .build_files[0].common' "$json_path")
    elif [[ "$dist" == *"Windows"* ]]; then
        common_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" --arg edition "$edition" '.os[] | select(.name == $os) | .types[] | select(.description == $dist) | .versions[$version][] | .editions[] | select(.edition == $edition) | .build_files[0].common' "$json_path")
    fi

    if [[ "$os" == *"Linux"* ]]; then
        network_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" '.os[] | select(.name == $os) | .distributions[] | select(.description == $dist) | .versions | to_entries[] | .value[] | select(.version == $version) | .build_files[0].network' "$json_path")
    fi

    if [[ "$os" == *"Linux"* ]]; then
        storage_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" '.os[] | select(.name == $os) | .distributions[] | select(.description == $dist) | .versions | to_entries[] | .value[] | select(.version == $version) | .build_files[0].storage' "$json_path")
    fi

    if [[ "$dist" == *"Red Hat"* ]]; then
        rshm_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" '.os[] | select(.name == $os) | .distributions[] | select(.description == $dist) | .versions | to_entries[] | .value[] | select(.version == $version) | .build_files[0].rshm' "$json_path")
    fi

    if [[ "$dist" == *"SUSE"* ]]; then
        scc_vars=$(jq -r --arg os "$os" --arg dist "$dist" --arg version "$version" '.os[] | select(.name == $os) | .distributions[] | select(.description == $dist) | .versions | to_entries[] | .value[] | select(.version == $version) | .build_files[0].scc' "$json_path")
    fi

    case "$dist" in
    "Debian" | "Ubuntu Server" | "AlmaLinux OS" | "Rocky Linux" | "Oracle Linux" | "CentOS" | "Fedora Server")
        var_files=("vsphere_vars" "build_vars" "ansible_vars" "proxy_vars" "common_vars" "network_vars" "storage_vars" "BUILD_VARS")
        validate_linux_username "$config_path/build.pkrvars.hcl"
        printf "Starting the build of %s %s...\n\n" "$dist" "$version"
        command="packer build -force -on-error=ask $debug_option"

        for var_file in "${var_files[@]}"; do
            command+=" -var-file=\"$config_path/${!var_file}\""
        done

        command+=" \"$INPUT_PATH\""

        if [ $show_command -eq 1 ]; then
            printf "\n"
            printf "\n\033[32mThe following command is ran for this build:\033[0m\n"
            printf "\n\e[34m%s\e[0m\n" "$command"
        fi

        eval "$command"
        ;;
    "Red Hat Enterprise Linux")
        var_files=("vsphere_vars" "build_vars" "ansible_vars" "proxy_vars" "common_vars" "network_vars" "storage_vars" "rshm_vars" "BUILD_VARS")
        validate_linux_username "$config_path/build.pkrvars.hcl"
        printf "Starting the build of %s %s...\n\n" "$dist" "$version"
        command="packer build -force -on-error=ask $debug_option"

        for var_file in "${var_files[@]}"; do
            command+=" -var-file=\"$config_path/${!var_file}\""
        done

        command+=" \"$INPUT_PATH\""

        if [ $show_command -eq 1 ]; then
            printf "\n"
            printf "\n\033[32mThe following command is ran for this build:\033[0m\n"
            printf "\n\e[34m%s\e[0m\n" "$command"
        fi

        eval "$command"
        ;;
    "VMware Photon OS")
        var_files=("vsphere_vars" "build_vars" "ansible_vars" "proxy_vars" "common_vars" "network_vars" "BUILD_VARS")
        validate_linux_username "$config_path/build.pkrvars.hcl"
        printf "Starting the build of %s %s...\n\n" "$dist" "$version"
        command="packer build -force -on-error=ask $debug_option"

        for var_file in "${var_files[@]}"; do
            command+=" -var-file=\"$config_path/${!var_file}\""
        done

        command+=" \"$INPUT_PATH\""

        if [ $show_command -eq 1 ]; then
            printf "\n"
            printf "\n\033[32mThe following command is ran for this build:\033[0m\n"
            printf "\n\e[34m%s\e[0m\n" "$command"
        fi

        eval "$command"
        ;;
    "SUSE Linux Enterprise Server")
        var_files=("vsphere_vars" "build_vars" "ansible_vars" "network_vars" "proxy_vars" "common_vars" "scc_vars" "BUILD_VARS")
        validate_linux_username "$config_path/build.pkrvars.hcl"
        printf "Starting the build of %s %s...\n\n" "$dist" "$version"
        command="packer build -force -on-error=ask $debug_option"

        for var_file in "${var_files[@]}"; do
            command+=" -var-file=\"$config_path/${!var_file}\""
        done

        command+=" \"$INPUT_PATH\""

        if [ $show_command -eq 1 ]; then
            printf "\n"
            printf "\n\033[32mThe following command is ran for this build:\033[0m\n"
            printf "\n\e[34m%s\e[0m\n" "$command"
        fi

        eval "$command"
        ;;
    "Windows Server")
        case "$edition" in
        "Standard")
            var_files=("vsphere_vars" "build_vars" "ansible_vars" "proxy_vars" "common_vars" "BUILD_VARS")
            build_username=$(grep 'build_username' "$config_path/build.pkrvars.hcl" | awk -F '"' '{print $2}')
            validate_windows_username "$config_path/build.pkrvars.hcl"
            printf "Starting the build of %s %s...\n\n" "$dist" "$version"
            command="packer build -force -on-error=ask $debug_option"
            command+=" --only=vsphere-iso.windows-server-standard-dexp,vsphere-iso.windows-server-standard-core"

            for var_file in "${var_files[@]}"; do
                command+=" -var-file=\"$config_path/${!var_file}\""
            done

            command+=" \"$INPUT_PATH\""

            if [ $show_command -eq 1 ]; then
                printf "\n"
                printf "\n\033[32mThe following command is ran for this build:\033[0m\n"
                printf "\n\e[34m%s\e[0m\n" "$command"
            fi

            eval "$command"
            ;;
        "Datacenter")
            var_files=("vsphere_vars" "build_vars" "ansible_vars" "proxy_vars" "common_vars" "BUILD_VARS")
            validate_windows_username "$config_path/build.pkrvars.hcl"
            printf "Starting the build of %s %s...\n\n" "$dist" "$version"
            command="packer build -force -on-error=ask $debug_option"
            command+=" --only vsphere-iso.windows-server-datacenter-dexp,vsphere-iso.windows-server-datacenter-core"

            for var_file in "${var_files[@]}"; do
                command+=" -var-file=\"$config_path/${!var_file}\""
            done

            command+=" \"$INPUT_PATH\""

            if [ $show_command -eq 1 ]; then
                printf "\n"
                printf "\n\033[32mThe following command is ran for this build:\033[0m\n"
                printf "\n\e[34m%s\e[0m\n" "$command"
            fi

            eval "$command"
            ;;
        *)
            print_message error "Unsupported $dist edition: $edition"
            ;;
        esac
        ;;
    "Windows Desktop")
        case "$edition" in
        "Enterprise")
            var_files=("vsphere_vars" "build_vars" "ansible_vars" "proxy_vars" "common_vars" "BUILD_VARS")
            validate_windows_username "$config_path/build.pkrvars.hcl"
            printf "Starting the build of %s %s...\n\n" "$dist" "$version"
            command="packer build -force -on-error=ask $debug_option"
            command+=" --only vsphere-iso.windows-desktop-ent"

            for var_file in "${var_files[@]}"; do
                command+=" -var-file=\"$config_path/${!var_file}\""
            done

            command+=" \"$INPUT_PATH\""

            if [ $show_command -eq 1 ]; then
                printf "\n"
                printf "\n\033[32mThe following command is ran for this build:\033[0m\n"
                printf "\n\e[34m%s\e[0m\n" "$command"
            fi

            eval "$command"
            ;;
        "Professional")
            var_files=("vsphere_vars" "build_vars" "ansible_vars" "proxy_vars" "common_vars" "BUILD_VARS")
            validate_windows_username "$config_path/build.pkrvars.hcl"
            printf "Starting the build of %s %s...\n\n" "$dist" "$version"
            command="packer build -force -on-error=ask $debug_option"
            command+=" --only vsphere-iso.windows-desktop-pro"

            for var_file in "${var_files[@]}"; do
                command+=" -var-file=\"$config_path/${!var_file}\""
            done

            command+=" \"$INPUT_PATH\""

            if [ $show_command -eq 1 ]; then
                printf "\n"
                printf "\n\033[32mThe following command is ran for this build:\033[0m\n"
                printf "\n\e[34m%s\e[0m\n" "$command"
            fi

            eval "$command"
            ;;
        *)
            print_message error "Unsupported edition: $dist $edition"
            ;;
        esac
        ;;
    *)
        print_message error "Unsupported distribution: $dist"
        ;;
    esac
}

# Check if logging is enabled.
if $logging_enabled; then
    # If logging_path is empty, use the current directory
    if [[ -z "$logging_path" ]]; then
        logging_path=$(pwd)
    fi

    log_file="$logging_path/$logfile_filename"

    # Check if the log file exists. If not, create it.
    if [[ ! -f "$log_file" ]]; then
        touch "$log_file"
        log_message "info" "Log file created: $log_file."
    fi
fi

# Start the script with the selecting the guest operating system.
select_os

# Prompt the user to continue or quit.
while true; do
    action=""
    printf "Would you like to \033[0;32mc\033[0m)ontinue, or \033[0;31mq\033[0m)uit? %s" "$action"
    read -r action
    log_message "info" "User selected: $action"
    case $action in
    [cC]*)
        select_os
        ;;
    [qQ]*) exit ;;
    esac
done
