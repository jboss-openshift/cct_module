#!/usr/bin/env bats

load common

@test "inject_datasources: DATASOURCES - NONXA - Validation" {
    DATASOURCES="TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_DRIVER="sybase"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_NONXA="true"
    TEST_JTA="false"
    TEST_URL="jdbc:sybase:Tds:localhost:5000/DATABASE?JCONNECT_VERSION=6"
    TEST_CONNECTION_CHECKER="org.jboss.jca.adapters.jdbc.extensions.sybase.SybaseValidConnectionChecker"
    TEST_EXCEPTION_SORTER="org.jboss.jca.adapters.jdbc.extensions.sybase.SybaseExceptionSorter"
    TEST_BACKGROUND_VALIDATION="false"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "datasources_sybase_validation_nonxa.xml"
}

@test "inject_datasources: DATASOURCES - NONXA - PoolSize" {
    DATASOURCES="TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_DRIVER="sybase"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_NONXA="true"
    TEST_JTA="false"
    TEST_URL="jdbc:sybase:Tds:localhost:5000/DATABASE?JCONNECT_VERSION=6"
    TEST_MAX_POOL_SIZE="11"
    TEST_MIN_POOL_SIZE="9"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "datasources_sybase_pool_nonxa.xml"
}

@test "inject_datasources: DATASOURCES - NONXA - URL " {
    DATASOURCES="TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_DRIVER="postgresql"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_URL="jdbc:postgresql://localhost:5432/postgresdb"
    TEST_NONXA="true"
    TEST_JTA="false"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "datasources_postgresql_nonxa.xml"
}

@test "inject_datasources: DATASOURCES - PostgreSQL - NONXA" {
    DATASOURCES="TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_DRIVER="postgresql"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_URL="jdbc:postgresql://localhost:5432/postgresdb"
    TEST_NONXA="true"
    TEST_JTA="false"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "datasources_postgresql_nonxa.xml"
}

@test "inject_datasources: DATASOURCES - MySQL - NONXA" {
    DATASOURCES="TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_DRIVER="mysql"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_URL="jdbc:mysql://localhost:3306/jbossdb"
    TEST_NONXA="true"
    TEST_JTA="false"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "datasources_mysql_nonxa.xml"
}

@test "inject_datasources: DATASOURCES - Other - NONXA" {
    DATASOURCES="TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_DRIVER="oracle"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_URL="jdbc:oracle:thin:@10.1.1.1:1521:testdb"
    TEST_NONXA="true"
    TEST_JTA="false"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "datasources_other_nonxa.xml"
}

@test "inject_datasources: DATASOURCES - XA - Host+Port+Database" {
    DATASOURCES="TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_DRIVER="postgresql"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_NONXA="false"

    TEST_SERVICE_HOST="localhost"
    TEST_SERVICE_PORT="5432"
    TEST_DATABASE="testdb"
    TEST_MAX_POOL_SIZE="11"
    TEST_MIN_POOL_SIZE="9"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "datasources_postgresql_nourl_xa.xml"
}

@test "inject_datasources: DATASOURCES - XA - Empty URL" {
    DATASOURCES="TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_DRIVER="postgresql"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_NONXA="false"

    TEST_SERVICE_HOST="localhost"
    TEST_SERVICE_PORT="5432"
    TEST_DATABASE="testdb"
    TEST_MAX_POOL_SIZE="11"
    TEST_MIN_POOL_SIZE="9"
    TEST_XA_CONNECTION_PROPERTY_URL=""

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "datasources_postgresql_nourl_xa.xml"
}

@test "inject_datasources: DATASOURCES - XA - URL" {
    DATASOURCES="TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_DRIVER="oracle"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_NONXA="false"
    TEST_XA_CONNECTION_PROPERTY_URL="jdbc:oracle:thin:@oracleHostName:1521:orcl"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "datasources_other_xa.xml"
}

@test "inject_datasources: DATASOURCES - XA_CONNECTION_PROPERTY" {
    DATASOURCES="TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_DRIVER="ibmdb2"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_NONXA="false"

    TEST_XA_CONNECTION_PROPERTY_ServerName="localhost"
    TEST_XA_CONNECTION_PROPERTY_PortNumber="50000"
    TEST_XA_CONNECTION_PROPERTY_DatabaseName="ibmdb2db"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "datasources_ibmdb2_xa.xml"
}

# H2 is not added by default
# Validation section is added
@test "inject_datasources: DB_SERVICE_PREFIX_MAPPING - NONXA" {
    DB_SERVICE_PREFIX_MAPPING="test-postgresql=TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_URL="jdbc:postgresql://localhost:5432/postgresdb"
    TEST_NONXA="true"
    TEST_JTA="false"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "prefix_postgresql_nonxa.xml"
}

@test "inject_datasources: DB_SERVICE_PREFIX_MAPPING - XA - Host+Port+Database" {
    DB_SERVICE_PREFIX_MAPPING="test-postgresql=TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_NONXA="false"
    TEST_POSTGRESQL_SERVICE_HOST="localhost"
    TEST_POSTGRESQL_SERVICE_PORT="5432"
    TEST_DATABASE="postgresdb"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "prefix_postgresql_xa.xml"
}

@test "inject_datasources: DB_SERVICE_PREFIX_MAPPING - XA - MySQL - Host+Port+Database" {
    DB_SERVICE_PREFIX_MAPPING="test-mysql=TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_NONXA="false"
    TEST_XA_CONNECTION_PROPERTY_URL="jdbc:mysql://localhost:3306/jbossdb"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "prefix_mysql_xa.xml"
}

@test "inject_datasources: DB_SERVICE_PREFIX_MAPPING - XA - Oracle" {
    DB_SERVICE_PREFIX_MAPPING="test-oracle=TEST"
    TEST_DRIVER="oracle"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_NONXA="false"
    TEST_XA_CONNECTION_PROPERTY_URL="jdbc:oracle:thin:@oracleHostName:1521:orcl"
    TEST_CONNECTION_CHECKER="org.jboss.jca.adapters.jdbc.extensions.oracle.OracleValidConnectionChecker"
    TEST_EXCEPTION_SORTER="org.jboss.jca.adapters.jdbc.extensions.oracle.OracleExceptionSorter"
    TEST_BACKGROUND_VALIDATION="false"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "prefix_oracle_xa.xml"
}

@test "inject_datasources: DB_SERVICE_PREFIX_MAPPING - XA_CONNECTION_PROPERTY" {
    DB_SERVICE_PREFIX_MAPPING="test-postgresql=TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_NONXA="false"
    TEST_XA_CONNECTION_PROPERTY_ServerName="localhost"
    TEST_XA_CONNECTION_PROPERTY_PortNumber="5432"
    TEST_XA_CONNECTION_PROPERTY_DatabaseName="postgresdb"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "prefix_postgresql_xa.xml"
}

@test "inject_datasources: DB_SERVICE_PREFIX_MAPPING - XA_CONNECTION_PROPERTY - IBMDB2" {
    DB_SERVICE_PREFIX_MAPPING="test-ibmdb2=TEST"
    TEST_DRIVER="ibmdb2"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_NONXA="false"

    TEST_XA_CONNECTION_PROPERTY_ServerName="localhost"
    TEST_XA_CONNECTION_PROPERTY_PortNumber="50000"
    TEST_XA_CONNECTION_PROPERTY_DatabaseName="ibmdb2db"

    run inject_datasources

    [ "$status" -eq 0 ]
    assert_datasources "prefix_ibmdb2_xa.xml"
}

@test "inject_datasources: DATASOURCES - Missing required values" {
    DATASOURCES="TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_DRIVER="postgresql"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_NONXA="false"

    TEST_XA_CONNECTION_PROPERTY_PortNumber="50000"
    TEST_XA_CONNECTION_PROPERTY_DatabaseName="ibmdb2db"

    run inject_datasources

    expected=`expected_warn "Missing configuration for XA datasource TEST. Either TEST_XA_CONNECTION_PROPERTY_URL or TEST_XA_CONNECTION_PROPERTY_ServerName, and TEST_XA_CONNECTION_PROPERTY_PortNumber, and TEST_XA_CONNECTION_PROPERTY_DatabaseName is required. Datasource will not be configured."`
    [ "$output" = "$expected" ]
}

@test "inject_datasources: DB_SERVICE_PREFIX_MAPPING - Missing required values" {
    DB_SERVICE_PREFIX_MAPPING="test-postgresql=TEST"
    TEST_JNDI="java:/jboss/datasources/testds"
    TEST_USERNAME="kermit"
    TEST_PASSWORD="thefrog"
    TEST_NONXA="false"

    TEST_XA_CONNECTION_PROPERTY_PortNumber="50000"
    TEST_XA_CONNECTION_PROPERTY_DatabaseName="ibmdb2db"

    run inject_datasources

    msg=`expected_warn "Missing configuration for datasource TEST. TEST_POSTGRESQL_SERVICE_HOST, TEST_POSTGRESQL_SERVICE_PORT, and/or TEST_DATABASE is missing. Datasource will not be configured."`
    [ "$output" = "$msg" ]
}