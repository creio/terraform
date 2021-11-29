#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$1" == apache2* ]] || [ "$1" = 'php-fpm' ]; then
  uid="$(id -u)"
  gid="$(id -g)"
  if [ "$uid" = '0' ]; then
    case "$1" in
      apache2*)
        user="${APACHE_RUN_USER:-www-data}"
        group="${APACHE_RUN_GROUP:-www-data}"

        # strip off any '#' symbol ('#1000' is valid syntax for Apache)
        pound='#'
        user="${user#$pound}"
        group="${group#$pound}"
        ;;
      *) # php-fpm
        user='www-data'
        group='www-data'
        ;;
    esac
  else
    user="$uid"
    group="$gid"
  fi

  if [ ! -e index.php ]; then
    if [ "$uid" = '0' ] && [ "$(stat -c '%u:%g' .)" = '0:0' ]; then
      chown "$user:$group" .
    fi

    echo >&2 "cpatracker not found in $PWD - copying now..."
    sourceTarArgs=(
      --create
      --file -
      --directory /usr/src/cpatracker
      --owner "$user" --group "$group"
    )
    targetTarArgs=(
      --extract
      --file -
    )
    if [ "$uid" != '0' ]; then
      # avoid "tar: .: Cannot utime: Operation not permitted" and "tar: .: Cannot change mode to rwxr-xr-x: Operation not permitted"
      targetTarArgs+=( --no-overwrite-dir )
    fi

    for contentPath in \
      /usr/src/cpatracker/.htaccess \
    ; do
      contentPath="${contentPath%/}"
      [ -e "$contentPath" ] || continue
      contentPath="${contentPath#/usr/src/cpatracker/}"
      if [ -e "$PWD/$contentPath" ]; then
        echo >&2 "WARNING: '$PWD/$contentPath' exists! (not copying the WordPress version)"
        sourceTarArgs+=( --exclude "./$contentPath" )
      fi
    done
    tar "${sourceTarArgs[@]}" . | tar "${targetTarArgs[@]}"
    echo >&2 "Complete! cpatracker has been successfully copied to $PWD"
  fi

fi

exec "$@"
