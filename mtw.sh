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
CONFIG="${XDG_CONFIG_HOME:-${HOME}/.config}/mega/megarc"

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

# string variable for internationalization
helpstr=help
helpdsc1="megatools wrapper to seamlessly load your megarc"
helpdsc2="megarc is loaded from '\$XDG_CONFIG_HOME/mega/megarc' as '\$CONFIG'."
helpdsc3="arguments to every command are prepended with: '--config \$CONFIG'."
usagestr=Usage
usagemsg="simply replace 'megatools' with $myname in command."
optionsstr="Options"
optionsmsg="these options apply only to the wrapper."
optfilestr="-f <file>, --file <file>, file <file>"
optfilemsg="use download links from the provided text file."
optdryrstr="-n, --dryrun, dryrun"
optdryrmsg="perform no action and only output the megatools command to run."
opthelpstr="-h, --help, help"
opthelpmsg="show this wrapper's help message."

_help() {
    _mesg=""
    if [ -n "$2" ]; then
        printf '%s: %s\n' "$myname" _mesg="$2"
    fi
    printf '%s %s:\n' "$myname" "$helpstr"
    printf '  %s\n' "$helpdsc1"
    printf '  %s\n' "$helpdsc2"
    printf '  %s\n' "$helpdsc3"
    printf '%s:\n'  "$usagestr"
    printf '  %s\n' "$usagemsg"
    printf '%s:\n'  "$optionsstr"
    printf '  %s\n' "$optionsmsg"
    printf '  %s\n' "$optfilestr"
    printf '\t%s\n' "$optfilemsg"
    printf '  %s\n' "$optdryrstr"
    printf '\t%s\n' "$optdryrmsg"
    printf '  %s\n' "$opthelpstr"
    printf '\t%s\n' "$opthelpmsg"
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

# Usage: read_file file
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

#parse short opts
while getopts "hnf:" o; do case "${o}" in
    n) DryRun=1 ;;
    f) file="$OPTARG" ;;
    h) _help 0 ;;
    *) _help 1 ;;
esac done
shift $(( OPTIND - 1 ))

if [ "$#" -eq 0 ]; then
    _help 1 "no arguments"
else
    # parse long opts
    while [ "$#" -gt 0 ]; do
        case "$1" in
            help|--help|-h)
                _help 0
            ;;
            dryrun|--dryrun|-n)
                DryRun=1
                shift
            ;;
            file|--file|-f)
                shift
                file="$1"
                shift
            ;;
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
            *) # do nothing
                # :
                arguments="${arguments} ${1}"
                shift
            ;;
        esac
    done
    if [ -n "$file" ]; then
        file_handler "$file"
    fi
    if [ -n "$arguments" ]; then
        dispatcher $arguments
    fi
fi
