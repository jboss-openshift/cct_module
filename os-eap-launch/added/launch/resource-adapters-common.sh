source $JBOSS_HOME/bin/launch/launch-common.sh
source $JBOSS_HOME/bin/launch/logging.sh

function clearResourceAdapterEnv() {
  local prefix=$1

  unset ${prefix}_ID
  unset ${prefix}_MODULE_SLOT
  unset ${prefix}_MODULE_ID
  unset ${prefix}_CONNECTION_CLASS
  unset ${prefix}_CONNECTION_JNDI
  unset ${prefix}_POOL_PREFILL
  unset ${prefix}_POOL_MAX_SIZE
  unset ${prefix}_POOL_MIN_SIZE
  unset ${prefix}_POOL_XA
  unset ${prefix}_POOL_IS_SAME_RM_OVERRIDE
  unset ${prefix}_POOL_FLUSH_STRATEGY
  unset ${prefix}_RECOVERY_USERNAME
  unset ${prefix}_RECOVERY_PASSWORD
  unset ${prefix}_ADMIN_OBJECTS
  unset ${prefix}_TRACKING

  for xa_prop in $(compgen -v | grep -s "${prefix}_PROPERTY_"); do
    unset ${xa_prop}
  done

  for admin_object in $(compgen -v | grep -s "${prefix}_ADMIN_OBJECT_"); do
    unset ${admin_object}
  done
}

function clearResourceAdaptersEnv() {
  for ra_prefix in $(echo $RESOURCE_ADAPTERS | sed "s/,/ /g"); do
    clearResourceAdapterEnv $ra_prefix
  done
  unset RESOURCE_ADAPTERS
}

function add_admin_objects() {
  admin_object_list="$1"

  admin_objects=
  IFS=',' read -a objects <<< ${admin_object_list}
  if [ "${#objects[@]}" -ne "0" ]; then
    for object in ${objects[@]}; do
      class_name=$(find_env "${ra_prefix}_ADMIN_OBJECT_${object}_CLASS_NAME")
      physical_name=$(find_env "${ra_prefix}_ADMIN_OBJECT_${object}_PHYSICAL_NAME")
      if [ -n "$class_name" ] && [ -n "$physical_name" ]; then
        admin_objects="${admin_objects}<admin-object class-name=\"$class_name\" jndi-name=\"java:/${physical_name}\" use-java-context=\"true\" pool-name=\"${physical_name}\"><config-property name=\"PhysicalName\">${physical_name}</config-property></admin-object>"
      else
        log_warning "Cannot configure admin-object $object for resource adapter $ra_prefix. Missing ${ra_prefix}_ADMIN_OBJECT_${object}_CLASS_NAME and/or ${ra_prefix}_ADMIN_OBJECT_${object}_PHYSICAL_NAME"
      fi
    done
  fi

  echo $admin_objects
}

function inject_resource_adapters_common() {

  resource_adapters=
  
  hostname=`hostname`

  for ra_prefix in $(echo $RESOURCE_ADAPTERS | sed "s/,/ /g"); do
    ra_id=$(find_env "${ra_prefix}_ID")
    if [ -z "$ra_id" ]; then
      log_warning "${ra_prefix}_ID is missing from resource adapter configuration, defaulting to ${ra_prefix}"
      ra_id="${ra_prefix}"
    fi

    ra_module_slot=$(find_env "${ra_prefix}_MODULE_SLOT")
    if [ -z "$ra_module_slot" ]; then
      log_warning "${ra_prefix}_MODULE_SLOT is missing from resource adapter configuration, defaulting to main"
      ra_module_slot="main"
    fi

    ra_archive=$(find_env "${ra_prefix}_ARCHIVE")
    ra_module_id=$(find_env "${ra_prefix}_MODULE_ID")
    if [ -z "$ra_module_id" ] && [ -z "$ra_archive" ]; then
      log_warning "${ra_prefix}_MODULE_ID and ${ra_prefix}_ARCHIVE are missing from resource adapter configuration. One is required. Resource adapter will not be configured"
      continue
    fi

    ra_class=$(find_env "${ra_prefix}_CONNECTION_CLASS")
    if [ -z "$ra_class" ]; then
      log_warning "${ra_prefix}_CONNECTION_CLASS is missing from resource adapter configuration. Resource adapter will not be configured"
      continue
    fi

    ra_jndi=$(find_env "${ra_prefix}_CONNECTION_JNDI")
    if [ -z "$ra_jndi" ]; then
      log_warning "${ra_prefix}_CONNECTION_JNDI is missing from resource adapter configuration. Resource adapter will not be configured"
      continue
    fi

    resource_adapter="<resource-adapter id=\"$ra_id\">"

    if [ -z "${ra_archive}" ]; then
      resource_adapter="${resource_adapter}<module slot=\"$ra_module_slot\" id=\"$ra_module_id\"></module>"
    else
      resource_adapter="${resource_adapter}<archive>$ra_archive</archive>"
    fi

    transaction_support=$(find_env "${ra_prefix}_TRANSACTION_SUPPORT")
    if [ -n "$transaction_support" ]; then
      resource_adapter="${resource_adapter}<transaction-support>$transaction_support</transaction-support>"
    fi

    resource_adapter="${resource_adapter}<connection-definitions><connection-definition"

    tracking=$(find_env "${ra_prefix}_TRACKING")
    if [ -n "${tracking}" ]; then
      # monitor applications, look for unclosed resources.
      resource_adapter="${resource_adapter} tracking=\"${tracking}\""
    fi
    resource_adapter="${resource_adapter} class-name=\"${ra_class}\" jndi-name=\"${ra_jndi}\" enabled=\"true\" use-java-context=\"true\">"

    ra_props=$(compgen -v | grep -s "${ra_prefix}_PROPERTY_")
    if [ -n "$ra_props" ]; then
      for ra_prop in $(echo $ra_props); do
        prop_name=$(echo "${ra_prop}" | sed -e "s/${ra_prefix}_PROPERTY_//g")
        prop_val=$(find_env $ra_prop)

        resource_adapter="${resource_adapter}<config-property name=\"${prop_name}\">${prop_val}</config-property>"
      done
    fi

    ra_pool_min_size=$(find_env "${ra_prefix}_POOL_MIN_SIZE")
    ra_pool_max_size=$(find_env "${ra_prefix}_POOL_MAX_SIZE")
    ra_pool_prefill=$(find_env "${ra_prefix}_POOL_PREFILL")
    ra_pool_flush_strategy=$(find_env "${ra_prefix}_POOL_FLUSH_STRATEGY")
    ra_pool_is_same_rm_override=$(find_env "${ra_prefix}_POOL_IS_SAME_RM_OVERRIDE")

    if [ -n "$ra_pool_min_size" ] || [ -n "$ra_pool_max_size" ] || [ -n "$ra_pool_prefill" ] || [ -n "$ra_pool_flush_strategy" ]; then
      ra_pool_xa=$(find_env "${ra_prefix}_POOL_XA")
      if [ -n "$ra_pool_xa" ] && [ "$ra_pool_xa" == "true" ]; then
        resource_adapter="${resource_adapter}<xa-pool>"
      else
        resource_adapter="${resource_adapter}<pool>"
      fi

      if [ -n "$ra_pool_min_size" ]; then
        resource_adapter="${resource_adapter}<min-pool-size>${ra_pool_min_size}</min-pool-size>"
      fi

      if [ -n "$ra_pool_max_size" ]; then
        resource_adapter="${resource_adapter}<max-pool-size>${ra_pool_max_size}</max-pool-size>"
      fi

      if [ -n "$ra_pool_prefill" ]; then
        resource_adapter="${resource_adapter}<prefill>${ra_pool_prefill}</prefill>"
      fi

      if [ -n "$ra_pool_flush_strategy" ]; then
        resource_adapter="${resource_adapter}<flush-strategy>${ra_pool_flush_strategy}</flush-strategy>"
      fi

      if [ -n "$ra_pool_is_same_rm_override" ]; then
        resource_adapter="${resource_adapter}<is-same-rm-override>${ra_pool_is_same_rm_override}</is-same-rm-override>"
      fi

      if [ -n "$ra_pool_xa" ] && [ "$ra_pool_xa" == "true" ]; then
        resource_adapter="${resource_adapter}</xa-pool>"
      else
        resource_adapter="${resource_adapter}</pool>"
      fi
    fi

    recovery_username=$(find_env "${ra_prefix}_RECOVERY_USERNAME")
    recovery_password=$(find_env "${ra_prefix}_RECOVERY_PASSWORD")
    if [ -n "$recovery_username" ] && [ -n "$recovery_password" ]; then
      resource_adapter="${resource_adapter}<recovery><recover-credential><user-name>$recovery_username</user-name><password>$recovery_password</password></recover-credential></recovery>"
    fi

    resource_adapter="${resource_adapter}</connection-definition></connection-definitions>"

    admin_object_list=$(find_env "${ra_prefix}_ADMIN_OBJECTS")
    if [ -n "$admin_object_list" ]; then
      admin_objects="$(add_admin_objects $admin_object_list)"
    fi
    if [ -n "$admin_objects" ]; then
      resource_adapter="${resource_adapter}<admin-objects>${admin_objects}</admin-objects>"
    fi

    resource_adapter="${resource_adapter}</resource-adapter>"

    resource_adapters="${resource_adapters}${resource_adapter}"
  done

  if [ -n "$resource_adapters" ]; then
    resource_adapters=$(echo "${resource_adapters}" | sed -e "s/localhost/${hostname}/g")
    sed -i "s|<!-- ##RESOURCE_ADAPTERS## -->|${resource_adapters}<!-- ##RESOURCE_ADAPTERS## -->|" $CONFIG_FILE
  fi
}

