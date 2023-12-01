#!/usr/bin/python3
import datetime
import json
import os
import time
import requests


def main():
    # define variables
    BASE_URL = "https://jenkins.tcoedevicefarm.com:8443/job/Tcoe_PaymentServices"
    #USER_NAME = "Tcoe_PaymentServices"
    #USER_TOKEN = "'D/QfTGHqkuyPZ+#z(Pae0vAj"
    USER_NAME = "payment_services_globe"
    USER_TOKEN = "11f6bbb5171b029a8ba898e15ab1737c76"

    # set session, auth info, crumb request header
    session = requests.Session()
    session.auth = (USER_NAME, USER_TOKEN)
    response = session.get(
        "https://jenkins.tcoedevicefarm.com:8443/crumbIssuer/api/json"
    )
    session.headers.update(json.loads(response.text))

    # set the build info URL for this run
    # by getting the last build number and incrementing by 1

    #JOB_INFO_URL = "{}/lastBuild/api/json".format(BASE_URL)
    JOB_INFO_URL = "{}/lastBuild/api/json".format(BASE_URL)
    response = session.get(JOB_INFO_URL)
    info = json.loads(response.text)

    last_build_id = info["number"]
    current_build_id = int(last_build_id) + 1
    JOB_INFO_URL = "{}/{}/api/json".format(BASE_URL, current_build_id)

    # trigger new build
    #JOB_TRIGGER_URL = "{}/buildWithParameters?testsToRun=all".format(BASE_URL)
    JOB_TRIGGER_URL = "{}/build".format(BASE_URL)
    response = session.post(JOB_TRIGGER_URL)
    print("[LOG] Job has been triggered, waiting for status...")
    print(
        "[LOG] You may check it manually at: {}/{}/console".format(
            BASE_URL, current_build_id
        )
    )

    # polling logic
    while True:
        # wait for a while
        time.sleep(30)

        # poll info, get status code
        response = session.get(JOB_INFO_URL)
        status_code = response.status_code

        # handle status code
        if status_code == 200:
            pass
        elif status_code == 401:
            print("[LOG] 401 Unauthenticated. Please check your credentials.")
            exit(1)
        elif status_code == 403:
            print(
                "[LOG] 403 Unauthorized. Please check with TCOE regarding your user's permissions."
            )
            exit(1)
        elif status_code == 404:
            print(
                "[LOG] 404 Not found. Please check with TCOE the status of the worker."
            )
            exit(1)
        else:
            print("[LOG] Please check with TCOE the status of Jenkins or the job.")

        # handle info
        info = json.loads(response.text)
        result = info["result"]
        if result != None:
            JOB_LOGS_URL = "{}/{}/logText/progressiveText".format(
                BASE_URL, current_build_id
            )
            response = session.get(JOB_LOGS_URL)
            print("[LOG] Test finished executing. Outputting logs:\n")
            print(response.text)

            if result == "SUCCESS":
                print("[LOG] TCOE test passed.")
                exit(0)
            elif result == "FAILURE":
                print("[LOG] TCOE test failed.")
                exit(1)
            elif result == "UNSTABLE":
                print("[LOG] TCOE test unstable.")
                exit(1)
            else:
                print(
                    "[LOG] TCOE test failed/unknown error. Please check on TCOE side."
                )
                exit(2)
        else:
            print("[LOG] Test is ongoing...")


if __name__ == "__main__":
 main()
