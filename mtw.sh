#!/bin/sh

# program name
myname="${0##*/}"

# program name to use if links are used
usename="megatools"

# megatools command to run
_comm=""

# megatools bin path
_binpath="/usr/bin"

#config file
CONFIG="${XDG_CONFIG_HOME:-~/.config}/mega/megarc"

case "${myname}" in
    mts|mtwrap|mtw) usename="megatools"  ;;
    megacopy)       usename="megacopy"   ;;
    megadf)         usename="megadf"     ;;
    megadl)         usename="megadl"     ;;
    megaexport)     usename="megaexport" ;;
    megaget)        usename="megaget"    ;;
    megals)         usename="megals"     ;;
    megamkdir)      usename="megamkdir"  ;;
    megaput)        usename="megaput"    ;;
    megareg)        usename="megareg"    ;;
    megarm)         usename="megarm"     ;;
    megatest)       usename="megatest"   ;;
esac

case "$1" in
    ls)
        _comm="ls"
        shift
    ;;
    df)
        _comm="df"
        shift
    ;;
    test)
        _comm="test"
        shift
    ;;
    export)
        _comm="export"
        shift
    ;;
    put)
        _comm="put"
        shift
    ;;
    mkdir)
        _comm="mkdir"
        shift
    ;;
    get)
        _comm="get"
        shift
    ;;
    copy)
        _comm="copy"
        shift
    ;;
    rm)
        _comm="rm"
        shift
    ;;
    dl)
        _comm="dl"
        shift
    ;;
    reg)
        _comm="reg"
        shift
    ;;
    *)
        : # do nothing
    ;;
esac

# string variable for internationalization
helpstr=help
helpdsc1="megatools wrapper to seamlessly load your megarc"
helpdsc2="megarc is loaded from '\$XDG_CONFIG_HOME/mega/megarc' as '\$CONFIG'"
helpdsc3="arguments to every command are prepended with: '--config \$CONFIG'"
usagestr=usage
usagemsg="simply replace 'megatools' with $myname in command"

_help() {
    _mesg=""
    [ -n "$2" ] && _mesg="$2"
    printf '%s %s:\t%s\n' "$myname" "$helpstr" "$_mesg"
    printf '\t%s\n' "$helpdsc1"
    printf '\t%s\n' "$helpdsc2"
    printf '\t%s\n' "$helpdsc3"
    printf '%s:\n'  "$usagestr"
    printf '\t%s\n' "$usagemsg"
    $_binpath/$usename "$_comm" -h
    exit "$1"
}

dispatcher () {
    if [ -z "$DryRun" ]; then
        $_binpath/$usename "$_comm" --config "$CONFIG" "$@"
    else
        printf '%s %s %s %s\n' "$_binpath/$usename" "$_comm " "$CONFIG" "$@"
    fi
}

# echo "$myname"
# echo "$#"

# Usage: read_file file
#
# Return: string 'line'
read_file() {
    while read -r FileLine
    do
        printf '%s\n' "$FileLine"
    done < "$1"
}

file_handler () {
    if [ -f "$1" ]; then
        printf "%s: %s\n" "$myname" "downloading links from file '${1}'"
        for link in $(read_file "$1"); do
            printf "\n%s: %s\n" "$myname" "downloading link '${link}'"
            dispatcher "$link"
        done
    else
        printf '%s: %s\n' "$myname" "argument ${1} is not a valid file!"
        exit 1
    fi
}

if [ "$#" -eq 0 ]; then
    _help 1 "no arguments"
else
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h|--help)
                _help 0
            ;;
            --dryrun|dryrun|-n)
                DryRun=1
            ;;
            --file|file|-f)
                file="$2"
                shift
            ;;
            *) # do nothing
                arguments="${arguments} ${1}"
            ;;
        esac
        shift
    done
    if [ -n "$file" ]; then
        file_handler "$file"
    else
        dispatcher $arguments
    fi
fi
