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
