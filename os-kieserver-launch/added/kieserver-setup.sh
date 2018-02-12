#!/bin/sh
# if using vim, do ':set ft=zsh' for easier reading

source $JBOSS_HOME/bin/launch/logging.sh

function prepareEnv() {
    unset KIE_SERVER_JMS_QUEUES_REQUEST
    unset KIE_SERVER_JMS_QUEUES_RESPONSE
    unset KIE_SERVER_EXECUTOR_JMS_QUEUE
    unset KIE_SERVER_PERSISTENCE_DIALECT
    unset QUARTZ_JNDI
    unset KIE_SERVER_USER
    unset KIE_SERVER_PASSWORD
}

function configure() {
    setupKieServerForOpenShift
}

function generateKieServerStateXml() {
    java -jar $JBOSS_HOME/jboss-modules.jar -mp $JBOSS_HOME/modules $(getJBossModulesOptsForKieUtilities) org.openshift.kieserver.common.server.ServerConfig xml
}

function filterKieJmsFile() {
    kieJmsFile="${1}"
    if [ -e ${kieJmsFile} ] ; then
        sed -i "s,queue/KIE\.SERVER\.REQUEST,${KIE_SERVER_JMS_QUEUES_REQUEST},g" ${kieJmsFile}
        sed -i "s,queue/KIE\.SERVER\.RESPONSE,${KIE_SERVER_JMS_QUEUES_RESPONSE},g" ${kieJmsFile}
        sed -i "s,queue/KIE\.SERVER\.EXECUTOR,${KIE_SERVER_EXECUTOR_JMS_QUEUE},g" ${kieJmsFile}
    fi
}

function filterQuartzPropFile() {
    quartzPropFile="${1}"
    if [ -e ${quartzPropFile} ] ; then
        if [[ "${KIE_SERVER_PERSISTENCE_DIALECT}" == "org.hibernate.dialect.MySQL"* ]]; then
            sed -i "s,org.quartz.jobStore.driverDelegateClass=,org.quartz.jobStore.driverDelegateClass=org.quartz.impl.jdbcjobstore.StdJDBCDelegate," ${quartzPropFile}
            quartzDriverDelegateSet="true"
        elif [[ "${KIE_SERVER_PERSISTENCE_DIALECT}" == "org.hibernate.dialect.PostgreSQL"* ]]; then
            sed -i "s,org.quartz.jobStore.driverDelegateClass=,org.quartz.jobStore.driverDelegateClass=org.quartz.impl.jdbcjobstore.PostgreSQLDelegate," ${quartzPropFile}
            quartzDriverDelegateSet="true"
        fi
        if [ "x${DB_JNDI}" != "x" ]; then
            sed -i "s,org.quartz.dataSource.managedDS.jndiURL=,org.quartz.dataSource.managedDS.jndiURL=${DB_JNDI}," ${quartzPropFile}
            quartzManagedJndiSet="true"
        fi
        if [ "x${QUARTZ_JNDI}" != "x" ]; then
            sed -i "s,org.quartz.dataSource.notManagedDS.jndiURL=,org.quartz.dataSource.notManagedDS.jndiURL=${QUARTZ_JNDI}," ${quartzPropFile}
            quartzNotManagedJndiSet="true"
        fi
        if [ "${quartzDriverDelegateSet}" = "true" ] && [ "${quartzManagedJndiSet=}" = "true" ] && [ "${quartzNotManagedJndiSet=}" = "true" ]; then
            KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.quartz.properties=${quartzPropFile}"
        fi
    fi
}

setupKieServerForOpenShift() {
    # source the KIE config
    source $JBOSS_HOME/bin/kieserver-config.sh
    # set the KIE environment
    setKieFullEnv
    # dump the KIE environment
    dumpKieFullEnv | tee ${JBOSS_HOME}/kieEnv
    
    # save the environment for use by the probes
    sed -ri "s/^([^:]+): *(.*)$/\1=\"\2\"/" ${JBOSS_HOME}/kieEnv
    
    # generate the KIE Server state file
    generateKieServerStateXml > "${KIE_SERVER_STATE_FILE}"
    
    # filter the KIE Server kie-server-jms.xml and ejb-jar.xml files
    filterKieJmsFile "${JBOSS_HOME}/standalone/deployments/kie-server.war/META-INF/kie-server-jms.xml"
    filterKieJmsFile "${JBOSS_HOME}/standalone/deployments/kie-server.war/WEB-INF/ejb-jar.xml"
    
    # filter the KIE Server quartz.properties file
    filterQuartzPropFile "${JBOSS_HOME}/bin/quartz.properties"
    
    # CLOUD-758 - "Provider com.sun.script.javascript.RhinoScriptEngineFactory not found" is logged every time when a process uses Java Script.
    find $JBOSS_HOME/modules/system/layers/base -name javax.script.ScriptEngineFactory -exec sed -i "s|com.sun.script.javascript.RhinoScriptEngineFactory||" {} \;
    
    # append KIE Server options to JAVA_OPTS
    echo "# Append KIE Server options to JAVA_OPTS" >> $JBOSS_HOME/bin/standalone.conf
    echo "JAVA_OPTS=\"\$JAVA_OPTS ${KIE_SERVER_OPTS}\"" >> $JBOSS_HOME/bin/standalone.conf
    
    # add the KIE Server user
    $JBOSS_HOME/bin/add-user.sh -a -u "${KIE_SERVER_USER}" -p "${KIE_SERVER_PASSWORD}" -ro "kie-server,guest"
    if [ "$?" -ne "0" ]; then
        log_error "Failed to create the user ${KIE_SERVER_USER}"
        log_error "Exiting..."
        exit
    fi
}
