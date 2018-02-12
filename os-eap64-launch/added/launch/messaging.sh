#!/bin/sh
# Openshift EAP launch script routines for configuring messaging

HORNETQ_SUBSYSTEM_FILE=$JBOSS_HOME/bin/launch/hornetq-subsystem.xml

source $JBOSS_HOME/bin/launch/launch-common.sh
source $JBOSS_HOME/bin/launch/logging.sh

# Messaging doesn't currently support configuration using env files, but this is
# a start at what it would need to do to clear the env.  The reason for this is
# that the HornetQ subsystem is automatically configured if no service mappings
# are specified.  This could result in the configuration of both queuing systems.
function prepareEnv() {
  # HornetQ configuration
  unset HORNETQ_QUEUES
  unset HORNETQ_TOPICS
  unset HORNETQ_CLUSTER_PASSWORD

  # A-MQ configuration
  IFS=',' read -a brokers <<< $MQ_SERVICE_PREFIX_MAPPING
  for broker in ${brokers[@]}; do
    service_name=${broker%=*}
    service=${service_name^^}
    service=${service//-/_}
    type=${service##*_}
    prefix=${broker#*=}

    unset ${prefix}_PROTOCOL
    protocol_env=${protocol//[-+.]/_}
    protocol_env=${protocol_env^^}
    unset ${service}_${protocol_env}_SERVICE_HOST
    unset ${service}_${protocol_env}_SERVICE_PORT
    
    unset ${prefix}_JNDI
    unset ${prefix}_USERNAME
    unset ${prefix}_PASSWORD

    for queue in ${queues[@]}; do
      queue_env=${prefix}_QUEUE_${queue^^}
      queue_env=${queue_env//[-\.]/_}
      unset ${queue_env}_PHYSICAL
      unset ${queue_env}_JNDI
    done
    unset ${prefix}_QUEUES

    for topic in ${topics[@]}; do
      topic_env=${prefix}_TOPIC_${topic^^}
      topic_env=${topic_env//[-\.]/_}
      unset ${topic_env}_PHYSICAL
      unset ${topic_env}_JNDI
    done
    unset ${prefix}_TOPICS
  done
  
  unset MQ_SERVICE_PREFIX_MAPPING
  unset MQ_SIMPLE_DEFAULT_PHYSICAL_DESTINATION
}

function configure() {
  inject_brokers
  configure_hornetq
}

function configure_hornetq_destinations() {
  IFS=',' read -a queues <<< ${HORNETQ_QUEUES}
  IFS=',' read -a topics <<< ${HORNETQ_TOPICS}

  destinations=""
  if [ "${#queues[@]}" -ne "0" -o "${#topics[@]}" -ne "0" ]; then
    if [ "${#queues[@]}" -ne "0" ]; then
      for queue in ${queues[@]}; do
        destinations="${destinations}<jms-queue name=\"${queue}\"><entry name=\"/queue/${queue}\"/></jms-queue>"
      done
    fi
    if [ "${#topics[@]}" -ne "0" ]; then
      for topic in ${topics[@]}; do
        destinations="${destinations}<jms-topic name=\"${topic}\"><entry name=\"/topic/${topic}\"/></jms-topic>"
      done
    fi
  fi
  echo "${destinations}"
}

function configure_hornetq_cluster_password() {
  if [ -n "${HORNETQ_CLUSTER_PASSWORD}" ] ; then
    JBOSS_MESSAGING_ARGS="${JBOSS_MESSAGING_ARGS} -Djboss.messaging.cluster.password=${HORNETQ_CLUSTER_PASSWORD}"
  fi
}

function configure_hornetq() {
  if [ true != "$AMQ" ] ; then
    configure_hornetq_cluster_password

    destinations=$(configure_hornetq_destinations)
    hornetq_subsystem=$(sed -e "s|##DESTINATIONS##|${destinations}|" <"${HORNETQ_SUBSYSTEM_FILE}" | sed ':a;N;$!ba;s|\n|\\n|g')

    sed -i 's|<!-- ##MESSAGING_EXTENSION## -->|<extension module="org.jboss.as.messaging"/>|' "${CONFIG_FILE}"
    sed -i "s|<!-- ##MESSAGING_SUBSYSTEM## -->|${hornetq_subsystem%$'\n'}|" "${CONFIG_FILE}"
    sed -i 's|<!-- ##MESSAGING_PORTS## -->|<socket-binding name="messaging" port="5445"/><socket-binding name="messaging-throughput" port="5455"/>|' "${CONFIG_FILE}"
  fi
}

# Arguments:
# $1 - physical name
# $2 - jndi name
# $3 - class
function generate_object_config() {
  log_info "generating object config for $1" >&2

  ao="
                        <admin-object
                              class-name=\"$3\"
                              jndi-name=\"$2\"
                              use-java-context=\"true\"
                              pool-name=\"$1\">
                            <config-property name=\"PhysicalName\">$1</config-property>
                        </admin-object>"
  echo $ao
}

# Arguments:
# $1 - service name
# $2 - connection factory jndi name
# $3 - broker username
# $4 - broker password
# $5 - protocol
# $6 - broker host
# $7 - broker port
# $8 - prefix
# $9 - archive
# $10 - driver
# $11 - queue names
# $12 - topic names
function generate_resource_adapter() {
  log_info "Generating resource adapter configuration for service: $1 (${10})" >&2
  IFS=',' read -a queues <<< ${11}
  IFS=',' read -a topics <<< ${12}
  case "${10}" in
    "amq")
      prefix=$8
      ra="
                <resource-adapter id=\"$9\">
                    <archive>$9</archive>
                    <transaction-support>XATransaction</transaction-support>
                    <config-property name=\"UserName\">$3</config-property>
                    <config-property name=\"Password\">$4</config-property>
                    <config-property name=\"ServerUrl\">tcp://$6:$7?jms.rmIdFromConnectionId=true</config-property>
                    <connection-definitions>
                        <connection-definition
                              class-name=\"org.apache.activemq.ra.ActiveMQManagedConnectionFactory\"
                              jndi-name=\"$2\"
                              enabled=\"true\"
                              pool-name=\"$1-ConnectionFactory\">
                            <xa-pool>
                                <min-pool-size>1</min-pool-size>
                                <max-pool-size>20</max-pool-size>
                                <prefill>false</prefill>
                                <is-same-rm-override>false</is-same-rm-override>
                            </xa-pool>
                            <recovery>
                                <recover-credential>
                                    <user-name>$3</user-name>
                                    <password>$4</password>
                                </recover-credential>
                            </recovery>
                        </connection-definition>
                    </connection-definitions>
                    <admin-objects>"

      # backwards-compatability flag per CLOUD-329
      simple_def_phys_dest=$(echo "${MQ_SIMPLE_DEFAULT_PHYSICAL_DESTINATION}" | tr [:upper:] [:lower:])

      if [ "${#queues[@]}" -ne "0" ]; then
        for queue in ${queues[@]}; do
          queue_env=${prefix}_QUEUE_${queue^^}
          queue_env=${queue_env//[-\.]/_}

          if [ "${simple_def_phys_dest}" = "true" ]; then
            physical=$(find_env "${queue_env}_PHYSICAL" "$queue")
          else
            physical=$(find_env "${queue_env}_PHYSICAL" "queue/$queue")
          fi
          jndi=$(find_env "${queue_env}_JNDI" "java:/queue/$queue")
          class="org.apache.activemq.command.ActiveMQQueue"

          ra="$ra$(generate_object_config $physical $jndi $class)"
        done
      fi

      if [ "${#topics[@]}" -ne "0" ]; then
        for topic in ${topics[@]}; do
          topic_env=${prefix}_TOPIC_${topic^^}
          topic_env=${topic_env//[-\.]/_}

          if [ "${simple_def_phys_dest}" = "true" ]; then
            physical=$(find_env "${topic_env}_PHYSICAL" "$topic")
          else
            physical=$(find_env "${topic_env}_PHYSICAL" "topic/$topic")
          fi
          jndi=$(find_env "${topic_env}_JNDI" "java:/topic/$topic")
          class="org.apache.activemq.command.ActiveMQTopic"

          ra="$ra$(generate_object_config $physical $jndi $class)"
        done
      fi

      ra="$ra
                    </admin-objects>
                </resource-adapter>"
    ;;
  esac

  echo $ra | sed ':a;N;$!ba;s|\n|\\n|g'
}

# Finds the name of the broker services and generates resource adapters
# based on this info
function inject_brokers() {
  # Find all brokers in the $MQ_SERVICE_PREFIX_MAPPING separated by ","
  IFS=',' read -a brokers <<< $MQ_SERVICE_PREFIX_MAPPING

  AMQ=false
  if [ "${#brokers[@]}" -eq "0" ]; then
    ras=""
  else
    for broker in ${brokers[@]}; do

      log_info "Processing broker: $broker"

      service_name=${broker%=*}
      service=${service_name^^}
      service=${service//-/_}
      type=${service##*_}
      prefix=${broker#*=}

      # XXX: only tcp (openwire) is supported by EAP
      # Protocol environment variable name format: [NAME]_[BROKER_TYPE]_PROTOCOL
      protocol=$(find_env "${prefix}_PROTOCOL" "tcp")
      
      if [ "${protocol}" == "openwire" ]; then
        protocol="tcp"
      fi

      if [ "${protocol}" != "tcp" ]; then
        log_warning "There is a problem with your service configuration!"
        log_warning "Only openwire (tcp) transports are supported."
        continue
      fi

      protocol_env=${protocol//[-+.]/_}
      protocol_env=${protocol_env^^}

      host=$(find_env "${service}_${protocol_env}_SERVICE_HOST")
      port=$(find_env "${service}_${protocol_env}_SERVICE_PORT")

      if [ -z $host ] || [ -z $port ]; then
        log_warning "There is a problem with your service configuration!"
        log_warning "You provided following MQ mapping (via MQ_SERVICE_PREFIX_MAPPING environment variable): $brokers. To configure resource adapters we expect ${service}_SERVICE_HOST and ${service}_SERVICE_PORT to be set."
        log_warning
        log_warning "Current values:"
        log_warning
        log_warning "${service}_${protocol_env}_SERVICE_HOST: $host"
        log_warning "${service}_${protocol_env}_SERVICE_PORT: $port"
        log_warning
        log_warning "Please make sure you provided correct service name and prefix in the mapping. Additionally please check that you do not set portalIP to None in the $service_name service. Headless services are not supported at this time."
        log_warning
        log_warning "The ${type,,} broker for $prefix service WILL NOT be configured."
        continue
      fi

      # Custom JNDI environment variable name format: [NAME]_[BROKER_TYPE]_JNDI
      jndi=$(find_env "${prefix}_JNDI" "java:/$service_name/ConnectionFactory")

      # username environment variable name format: [NAME]_[BROKER_TYPE]_USERNAME
      username=$(find_env "${prefix}_USERNAME")

      # password environment variable name format: [NAME]_[BROKER_TYPE]_PASSWORD
      password=$(find_env "${prefix}_PASSWORD")

      # queues environment variable name format: [NAME]_[BROKER_TYPE]_QUEUES
      queues=$(find_env "${prefix}_QUEUES")

      # topics environment variable name format: [NAME]_[BROKER_TYPE]_TOPICS
      topics=$(find_env "${prefix}_TOPICS")

      case "$type" in
        "AMQ")
          driver="amq"
          archive="activemq-rar.rar"
          ;;
      esac

      ra=$(generate_resource_adapter $service_name $jndi $username $password $protocol $host $port $prefix $archive $driver "$queues" "$topics")
      ras="$ras$ra\n"
    done
    if [ -n "$ras" ] ; then
      AMQ=true
      JBOSS_MESSAGING_ARGS="${JBOSS_MESSAGING_ARGS} -Dejb.resource-adapter-name=activemq-rar.rar"
    fi
  fi

  sed -i "s|<!-- ##RESOURCE_ADAPTERS## -->|${ras%$'\n'}<!-- ##RESOURCE_ADAPTERS## -->|" $CONFIG_FILE
}
