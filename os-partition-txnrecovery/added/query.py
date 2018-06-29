#!/bin/python
"""
Copyright 2018 Red Hat, Inc.

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

import argparse
import json
import logging
import urllib2

from enum import Enum


class QueryType(Enum):
    """
    Represents what could be queried.
    PODS: list of pods
    LOG: log from particular pod
    """

    PODS = 'pods'
    PODS_LIVING = 'pods_living'
    LOG = 'log'

    def __str__(self):
        return self.value

class OutputFormat(Enum):
    """
    Represents output format of this script.
    RAW: no formatting
    LIST_SPACE: if possible values are delimited with space and returned
    LIST_COMMA: comma separated list
    """

    RAW = "raw"
    LIST_SPACE = "list_space"
    LIST_COMMA = "list_comma"

    def __str__(self):
        return self.value


class OpenShiftQuery():
    """
    Utility class to help query OpenShift api. Declares constant
    to get token and uri of the query. Having methods doing the query etc.
    """

    API_URL = 'https://openshift.default.svc'
    TOKEN_FILE_PATH = '/var/run/secrets/kubernetes.io/serviceaccount/token'
    NAMESPACE_FILE_PATH = '/var/run/secrets/kubernetes.io/serviceaccount/namespace'
    CERT_FILE_PATH = '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt'
    STATUS_LIVING_PODS = ['Pending', 'Running', 'Unknown']

    @staticmethod
    def __readFile(fileToRead):
        with open(fileToRead, 'r') as readingfile:
            return readingfile.read().strip()

    @staticmethod
    def getToken():
        return OpenShiftQuery.__readFile(OpenShiftQuery.TOKEN_FILE_PATH)

    @staticmethod
    def getNameSpace():
        return OpenShiftQuery.__readFile(OpenShiftQuery.NAMESPACE_FILE_PATH)

    @staticmethod
    def queryApi(urlSuffix):
        request = urllib2.Request(OpenShiftQuery.API_URL + urlSuffix,
            headers = {'Authorization': 'Bearer ' + OpenShiftQuery.getToken(), "Accept": 'application/json'})
        logger.debug('query for: "%s"', request.get_full_url())
        try:
            return urllib2.urlopen(request, cafile = OpenShiftQuery.CERT_FILE_PATH).read()
        except:
            logger.critical('Cannot query OpenShift API for "%s"', request.get_full_url())
            raise



def getPodsJsonData():
    jsonText = OpenShiftQuery.queryApi('/api/v1/namespaces/{}/pods'.format(OpenShiftQuery.getNameSpace()))
    return json.loads(jsonText)

def getPods():
    jsonPodsData = getPodsJsonData()
    pods = []
    for pod in jsonPodsData["items"]:
        logger.debug('query pod %s of status %s', pod["metadata"]["name"], pod["status"]["phase"])
        pods.append(pod["metadata"]["name"])
    return pods

def getLivingPods():
    jsonPodsData = getPodsJsonData()

    pods = []
    for pod in jsonPodsData["items"]:
        logger.debug('query pod %s of status %s', pod["metadata"]["name"], pod["status"]["phase"])
        if pod["status"]["phase"] in OpenShiftQuery.STATUS_LIVING_PODS:
            pods.append(pod["metadata"]["name"])
    return pods

def getLog(podName, sinceTime, tailLine):
    sinceTimeParam = '' if sinceTime is None else '&sinceTime=' + sinceTime
    tailLineParam = '' if tailLine is None else '&tailLines=' + tailLine
    podLogLines = OpenShiftQuery.queryApi('/api/v1/namespaces/{}/pods/{}/log?timestamps=true{}{}'
            .format(OpenShiftQuery.getNameSpace(), podName, sinceTimeParam, tailLineParam))
    return podLogLines

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = "Queries OpenShift API, gathering the json and parsing it to get specific info from it")
    parser.add_argument("-q", "--query", required = False, type = QueryType, default = QueryType.PODS, choices=list(QueryType), help = "Query type/what to query\n"
      + "either printing log of a pod, or listing of all pods in the current namespace, or listing of living pods in the current namespace")
    parser.add_argument("-f", "--format", required = False, type = OutputFormat, default = OutputFormat.RAW, choices=list(OutputFormat), help = "Output format")
    parser.add_argument("--pod", required = False, type = str, default = None, help = "Pod name to work with")
    parser.add_argument("--sincetime", required = False, type = str, default = None,
        help = "what is time to log will be started to be shown from (relevant with '--query log')")
    parser.add_argument("--tailline", required = False, type = str, default = None,
        help = "how many lines to be printed from end of the log (relevant with '--query log')")
    parser.add_argument("-l", "--loglevel", default="CRITICAL", help="Log level",
        choices=["debug", "DEBUG", "info", "INFO", "warning", "WARNING", "error", "ERROR", "critical", "CRITICAL"])
    parser.add_argument("args", nargs = argparse.REMAINDER, help = "Arguments of the query (each query type has different)")

    args = parser.parse_args()

    # don't spam warnings (e.g. when not verifying ssl connections)
    logging.captureWarnings(True)
    logging.basicConfig(level = args.loglevel.upper())
    logger = logging.getLogger(__name__)

    logger.debug("Starting query openshift api with args: %s", args)

    if args.query == QueryType.PODS:
        queryResult = getPods()
    elif args.query == QueryType.PODS_LIVING:
        queryResult = getLivingPods()
    elif args.query == QueryType.LOG:
        if args.pod is None:
            logger.critical('query of type "--query log" requires one argument to be an existing pod name')
            exit(1)
        podName = args.pod
        sinceTime = args.sincetime
        tailLine = args.tailline
        queryResult = getLog(podName, sinceTime, tailLine)
    else:
        logger.critical('No handler for query type %s', args.query)
        exit(1)

    if args.format == OutputFormat.LIST_SPACE:
        print ' '.join(queryResult)
    elif args.format == OutputFormat.LIST_COMMA:
        print ','.join(queryResult)
    else: # RAW format
        print queryResult,

    exit(0)
