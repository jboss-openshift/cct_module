#!/bin/bash
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

MODULES=()
OPENSHIFT_LAYER_PATH="$JBOSS_HOME/modules/system/layers/openshift"
OVERLAYS_PATH="$JBOSS_HOME/modules/system/layers/base/.overlays"

MODULES_SOURCE_PATHS=("$JBOSS_HOME/modules/system/layers/base")

# Did we apply any patches?
if [ -f "$OVERLAYS_PATH/.overlays" ]; then
  # Yes, we did!
  # Use tac to reverse the content in the .overlays file
  for layer in $(tac $OVERLAYS_PATH/.overlays); do
    # Add the overlay to the list of modules sources
    MODULES_SOURCE_PATHS=("$OVERLAYS_PATH/$layer" ${MODULES_SOURCE_PATHS[@]})
  done
fi

for module in $(find $OPENSHIFT_LAYER_PATH -name module.xml); do
  module_dir=$(dirname $module)
  MODULES+=(${module_dir#${OPENSHIFT_LAYER_PATH}/})
done

for module in "${MODULES[@]}"; do
  for source_dir in "${MODULES_SOURCE_PATHS[@]}"; do
    if [ -d "$source_dir/$module" ]; then
      if compgen -G "$OPENSHIFT_LAYER_PATH/$module/*.jar"; then
        # We found that there is already linked jar
        # We assume here that we will link only to a single file
        continue
      fi

      for jar_file in $source_dir/$module/*.jar; do

        jar_name=$(basename "$jar_file")

        # Find the first position of the integer preceded by a minus (-) sign
        pos=$(echo $jar_name | grep -o -b -E '\-[0-9]+' | head -1 | awk -F: '{ print $1 }')
        # Get everything from the beginning up to the position of the found minus sign
        var="${jar_name:0:$pos}"
        # Convert the string to upper case
        var="${var^^}"
        # Replace any minus signs with underscore
        var=$(echo $var | sed 's/-/_/g')
        # Replace any dots with underscore
        var=$(echo $var | sed 's/\./_/g')

        # Make sure the path exists
        mkdir -p $OPENSHIFT_LAYER_PATH/$module

        # Link relevant jar
        ln -s "$jar_file" $OPENSHIFT_LAYER_PATH/$module/$jar_name

        # Update the file name in module.xml
        sed -i "s/##$var##/$jar_name/g" "$OPENSHIFT_LAYER_PATH/$module/module.xml"
      done

      if grep -q -E "##.*##" "$OPENSHIFT_LAYER_PATH/$module/module.xml"; then
          echo "There was an issue with substitution of ##$var## variable, please check $OPENSHIFT_LAYER_PATH/$module/module.xml file!"
          exit 1
      fi
    fi
  done
done

cp -p "$ADDED_DIR/modules/layers.conf" "$JBOSS_HOME/modules/"
chown -R jboss:root $JBOSS_HOME
chmod -R g+rwX $JBOSS_HOME
