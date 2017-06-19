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

import json
import logging
import os
import requests
import sys
import ConfigParser
import StringIO

from collections import OrderedDict

from probe.api import qualifiedClassName, BatchingProbe, Status, Test

class JolokiaProbe(BatchingProbe):
    """
    A Probe implementation that sends a batch of queries to a server using
    Jolokia's REST API.  Tests should provide JSON queries specific to Jolokia
    and should be able to handle Jolokia formatted results.
    """

    def __init__(self, tests = []):
        super(JolokiaProbe, self).__init__(tests)
        self.logger = logging.getLogger(qualifiedClassName(self))
        self.__readConfig()
        
    def __readConfig(self):
        """
        Configuration is read from /opt/jolokia/etc/jolokia.properties and
        consists of:
            host: localhost
            port: jolokia.port + $PORT_OFFSET
            protocol: jolokia.protocol
            user: jolokia.user
            password: jolokia.password
        """
        
        jolokiaConfig = ConfigParser.ConfigParser(
            defaults = {
                "port": 8778,
                "user": None,
                "password": None,
                "protocol": "http"
            }
        )
        
        self.logger.info("Reading jolokia properties file")
        with open("/opt/jolokia/etc/jolokia.properties") as jolokiaProperties:
            # fake a section
            jolokiaConfig.readfp(StringIO.StringIO("[jolokia]\n" + jolokiaProperties.read()))
        
        self.host = "localhost"
        self.port = int(jolokiaConfig.get("jolokia", "port")) + int(os.getenv('PORT_OFFSET', 0))
        self.protocol = jolokiaConfig.get("jolokia", "protocol")
        self.user = jolokiaConfig.get("jolokia", "user")
        self.password = jolokiaConfig.get("jolokia", "password")

        self.logger.debug("Configuration set as follows: host=%s, port=%s, protocol=%s, user=%s, password=***", self.host, self.port, self.protocol, self.user)

    def getTestInput(self, results, testIndex):
        return results[testIndex]

    def createRequest(self):
        request = []
        for test in self.tests:
            request.append(test.getQuery())
        return request

    def sendRequest(self, request):
        url = "%s://%s:%s/jolokia/" % (self.protocol, self.host, self.port)
        self.logger.info("Sending probe request to %s", url)
        if self.logger.isEnabledFor(logging.DEBUG):
            self.logger.debug("Probe request = %s", json.dumps(request, indent=4, separators=(',', ': ')))
        response = requests.post(
            url,
            json = request,
            proxies = {
                "http": None,
                "https": None
            },
            auth = requests.auth.HTTPBasicAuth(self.user, self.password) if self.user else None,
            verify = False
        )
        self.logger.debug("Probe response: %s", response)

        if response.status_code != 200:
            self.logger.error("Probe request failed.  Status code: %s", response.status_code)
            raise Exception("Probe request failed, code: " + str(response.status_code))

        return response.json(object_pairs_hook = OrderedDict)
