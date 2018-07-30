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

from collections import OrderedDict

from probe.api import qualifiedClassName, BatchingProbe, Status, Test

class DmrProbe(BatchingProbe):
    """
    A Probe implementation that sends a batch of queries to a server using EAP's
    management interface.  Tests should provide JSON queries specific to EAP's
    management interface and should be able to handle DMR results.
    """

    def __init__(self, tests = []):
        super(DmrProbe, self).__init__(tests)
        self.logger = logging.getLogger(qualifiedClassName(self))
        self.__readConfig()
        
    def __readConfig(self):
        """
        Configuration consists of:
            host: localhost
            port: 9990 + $PORT_OFFSET
            user: $ADMIN_USERNAME
            password: $ADMIN_PASSWORD
        """
        
        self.host = "localhost"
        self.port = 9990 + int(os.getenv('PORT_OFFSET', 0))
        self.user = os.getenv('ADMIN_USERNAME')
        self.password = os.getenv('ADMIN_PASSWORD')
        if self.password != "":
          if self.user is None or self.user == "":
            self.user = os.getenv('DEFAULT_ADMIN_USERNAME')
        self.logger.debug("Configuration set as follows: host=%s, port=%s, user=%s, password=***", self.host, self.port, self.user)

    def getTestInput(self, results, testIndex):
        return results["result"].values()[testIndex]

    def createRequest(self):
        steps = []
        for test in self.tests:
            steps.append(test.getQuery())
        return {
                    "operation": "composite",
                    "address": [],
                    "json.pretty": 1,
                    "steps": steps
                }

    def sendRequest(self, request):
        url = "http://%s:%s/management" % (self.host, self.port)
        self.logger.info("Sending probe request to %s", url)
        if self.logger.isEnabledFor(logging.DEBUG):
            self.logger.debug("Probe request = %s", json.dumps(request, indent=4, separators=(',', ': ')))
        response = requests.post(
            url,
            json = request,
            headers = {
                "Accept": "text/plain"
            },
            proxies = {
                "http": None,
                "https": None
            },
            auth = requests.auth.HTTPDigestAuth(self.user, self.password) if self.user else None,
            verify = False
        )
        self.logger.debug("Probe response: %s", response)

        if response.status_code != 200:
            """
            See if this non-200 represents an unusable response, or just a failure
            response because one of the test steps failed, in which case we pass the
            response to the tests to let them decide how to handle things
            """
            self.failUnusableResponse(response)

        return response.json(object_pairs_hook = OrderedDict)

    def failUnusableResponse(self, response):
        respDict = None
        try:
            respDict = response.json(object_pairs_hook = OrderedDict)
        except ValueError:
            self.logger.debug("Probe request failed with no parseable json response")

        unusable = not respDict or not respDict["outcome"] or respDict["outcome"] != "failed" or not respDict["result"]
        if not unusable:
            """
            An outcome=failed response is usable if the result node has an element for each test
            """
            stepResults = respDict["result"].values()
            for index, test in enumerate(self.tests):
                if not stepResults[index]:
                    unusable = True
                    break;

        if unusable:
            self.logger.error("Probe request failed.  Status code: %s", response.status_code)
            raise Exception("Probe request failed, code: " + str(response.status_code) + str(url) + str(request) + str(response.json(object_pairs_hook = OrderedDict)))
