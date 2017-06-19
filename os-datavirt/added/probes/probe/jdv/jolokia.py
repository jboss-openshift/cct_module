"""
Copyright 2017 Red Hat, Inc.

Red Hat licenses this file to you under the Apache License, version
2.0 (the "License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied.  See the License for the specific language governing
permissions and limitations under the License.
"""

from probe.api import Status, Test
from probe.jolokia import JolokiaProbe

class JdvProbe(JolokiaProbe):
    """
    JDV probe which uses the Jolokia interface to query server state (i.e.
    RESTful JMX queries).  It defines tests for JDBC and ODATA transport status.
    """

    def __init__(self):
        super(JdvProbe, self).__init__(
            [
                JdbcTransportStatusTest(),
                SecureJdbcTransportStatusTest(),
                OdataTransportStatusTest()
            ]
        )

class AbstractTransportStatusTest(Test):
    """
    Checks the status of a JDV transport.
    """

    def __init__(self, query):
        super(AbstractTransportStatusTest, self).__init__(query)

    def evaluate(self, results):
        """
        Evaluates the test:
            READY for UP, WONT_START or unknown transport name
            HARD_FAILURE for PROBLEM, CANCELLED, START_FAILED or REMOVED
            NOT_READY for NEW or WAITING if mode is ACTIVE (i.e. don't go
                NOT_READY for passive, lazy or on-demand) 
        """

        if results["status"] != 200:
            return (Status.FAILURE, "Jolokia query failed")

        value = results["value"]
        if not value:
            return (Status.READY, "Transport not configured")
    
        mode = value["modeName"]
        state = value["stateName"]
        substate = value["substateName"]
        
        status = Status.READY
        if substate == "UP" or substate == "WONT_START":
            # short circuit
            status = Status.READY
        elif substate == "PROBLEM" or substate == "CANCELLED" or substate == "START_FAILED" or substate == "REMOVED":
            status = Status.HARD_FAILURE
        elif mode == "ACTIVE" and (substate == "NEW" or substate == "WAITING"):
            status = Status.NOT_READY
        
        return (status, value)

class JdbcTransportStatusTest(AbstractTransportStatusTest):
    """
    Checks the status of the JDBC transport.
    """

    def __init__(self):
        super(JdbcTransportStatusTest, self).__init__(
            {
                "type": "exec",
                "operation": "getServiceStatus",
                "arguments": [ "jboss.teiid.transport.jdbc" ],
                "mbean": "jboss.msc:type=container,name=jboss-as"
            }
        )

class SecureJdbcTransportStatusTest(AbstractTransportStatusTest):
    """
    Checks the status of the JDBC transport.
    """

    def __init__(self):
        super(SecureJdbcTransportStatusTest, self).__init__(
            {
                "type": "exec",
                "operation": "getServiceStatus",
                "arguments": [ "jboss.teiid.transport.secure-jdbc" ],
                "mbean": "jboss.msc:type=container,name=jboss-as"
            }
        )

class OdataTransportStatusTest(AbstractTransportStatusTest):
    """
    Checks the status of the ODATA transport.
    """

    def __init__(self):
        super(OdataTransportStatusTest, self).__init__(
            {
                "type": "exec",
                "operation": "getServiceStatus",
                "arguments": [ "jboss.teiid.transport.odata" ],
                "mbean": "jboss.msc:type=container,name=jboss-as"
            }
        )

