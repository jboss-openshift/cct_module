
function listjars {
  FILES=$(ls $1*.jar)
  echo ${FILES}
}

function getfiles {
  OVERLAYS_PATH="$JBOSS_HOME/modules/system/layers/base/.overlays"
  MODULES_SOURCE_PATHS=("$JBOSS_HOME/modules/system/layers/base" "$JBOSS_HOME")

  # Did we apply any patches?
  if [ -f "$OVERLAYS_PATH/.overlays" ]; then
    # Yes, we did!
    # Use tac to reverse the content in the .overlays file
    for layer in $(tac $OVERLAYS_PATH/.overlays); do
      # Add the overlay to the list of modules sources
      MODULES_SOURCE_PATHS=("$OVERLAYS_PATH/$layer" ${MODULES_SOURCE_PATHS[@]})
    done
  fi

  name=$1

  for source_dir in "${MODULES_SOURCE_PATHS[@]}"; do
    if [ -d "$source_dir/${name}" ]; then
      files="$(listjars $source_dir/${name})"

      if [ -n "$files" ]; then
        echo "$files" | sed -e "s/^[ \t]*//" | sed -e "s| |:|g" | sed -e ":a;N;$!ba;s|\n|:|g"
        return
      fi
    else
      files="$(compgen -G "$source_dir/${name}*.jar")"

      if [ -n "$files" ]; then
        echo "${files[0]}"
        return
      fi
    fi
  done
 
  echo "Could not find any jar for the $name path, aborting"
  exit 1
}
