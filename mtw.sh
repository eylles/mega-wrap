#!/bin/sh

# program name
myname="${0##*/}"

# program name to use if links are used
usename=""

# megatools command to run
_comm=""

# megatools bin path
_binpath="/usr/bin"

#config file
CONFIG="${XDG_CONFIG_HOME:-~/.config}/mega/megarc"

case "${myname}" in
  mts|mtwrap|mtw) usename="megatools" ;;
  megacopy)       usename="megacopy" ;;
  megadf)         usename="megadf" ;;
  megadl)         usename="megadl" ;;
  megaexport)     usename="megaexport" ;;
  megaget)        usename="megaget" ;;
  megals)         usename="megals" ;;
  megamkdir)      usename="megamkdir" ;;
  megaput)        usename="megaput" ;;
  megareg)        usename="megareg" ;;
  megarm)         usename="megarm" ;;
  megatest)       usename="megatest" ;;
esac

case "$1" in
  ls)     _comm="ls"
          shift
          ;;
  df)     _comm="df"
          shift
          ;;
  test)   _comm="test"
          shift
          ;;
  export) _comm="export"
          shift
          ;;
  put)    _comm="put"
          shift
          ;;
  mkdir)  _comm="mkdir"
          shift
          ;;
  get)    _comm="get"
          shift
          ;;
  copy)   _comm="copy"
          shift
          ;;
  rm)     _comm="rm"
          shift
          ;;
  dl)     _comm="dl"
          shift
          ;;
  reg)    _comm="reg"
          shift
          ;;
  *)      : # do nothing
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
  printf '%s:\n' "$usagestr"
  printf '\t%s\n' "$usagemsg"
  $_binpath/$usename "$_comm" -h
  exit "$1"
}

# echo "$myname"
# echo "$#"

if [ "$#" -eq 0 ]; then
  _help 1 "no arguments"
else
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        _help 0
        ;;
      -n|--dryrun)
        DryRun=1
        ;;
      *) # do nothing
        :
        ;;
    esac
  done
  if [ -z "$DryRun" ]; then
    $_binpath/$usename "$_comm" --config "$CONFIG" "$@"
  else
    echo "$_comm " "$CONFIG" "$@"
  fi
fi
