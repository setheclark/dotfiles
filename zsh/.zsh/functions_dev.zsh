function upfind() {
    dir=`pwd`
    while [ "$dir" != "/" ]; do
        p=`find "$dir" -maxdepth 1 -name $1`
        if [ ! -z $p ]; then
            echo "$p"
            return
        fi
        dir=`dirname "$dir"`
    done 
}

# Executes closest gradlew in dir heirarchy
function gw() {
    GW="$(upfind gradlew)"
    if [ -z "$GW" ]; then
        echo "Gradle wapper not found."
    else
        $GW $@
    fi
}

# Switch the active JDK for the current shell using fzf.
# Lists all JDKs known to /usr/libexec/java_home, marks the current one with *.
function jdk() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "jdk: fzf is required" >&2
        return 1
    fi
    if [[ ! -x /usr/libexec/java_home ]]; then
        echo "jdk: /usr/libexec/java_home not found (macOS only)" >&2
        return 1
    fi

    local current="${JAVA_HOME:-}"
    local listing selection new_home
    listing=$(/usr/libexec/java_home -V 2>&1 | awk -v cur="$current" '
        /^[[:space:]]+[0-9]/ {
            marker = ($NF == cur) ? "*" : " "
            sub(/^[[:space:]]+/, "")
            printf "%s %s\n", marker, $0
        }')
    if [[ -z "$listing" ]]; then
        echo "jdk: no JDKs installed" >&2
        return 1
    fi

    selection=$(print -r -- "$listing" | fzf \
        --prompt='JDK> ' \
        --header='* = current        enter = select        esc = cancel' \
        --no-multi) || return 0

    new_home="${selection##* }"
    if [[ ! -d "$new_home" ]]; then
        echo "jdk: could not parse path from selection" >&2
        return 1
    fi

    if [[ -n "$JAVA_HOME" ]]; then
        path=("${(@)path:#$JAVA_HOME/bin}")
    fi
    export JAVA_HOME="$new_home"
    path=("$JAVA_HOME/bin" $path)

    echo "JAVA_HOME=$JAVA_HOME"
    java -version
}
