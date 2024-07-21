#! /usr/bin/env python
"""A program that downloads one particular activity from a given Garmin
Connect account and stores it locally on the user's computer.
"""
import argparse
import getpass
import logging
import os
from datetime import datetime, timedelta

import codecs
import dateutil.parser
import json

import garminexport.backup
from garminexport.garminclient import GarminClient
from garminexport.logging_config import LOG_LEVELS
from garminexport.retryer import Retryer, ExponentialBackoffDelayStrategy, MaxRetriesStopStrategy

logging.basicConfig(level=logging.INFO, format="%(asctime)-15s [%(levelname)s] %(message)s")
log = logging.getLogger(__name__)


def main():
    parser = argparse.ArgumentParser(
        description="Downloads one particular activity for a given Garmin Connect account.")

    # positional args
    parser.add_argument(
        "username", metavar="<username>", type=str, help="Account user name.")

    # optional args
    parser.add_argument(
        "--password", type=str, help="Account password.")
    parser.add_argument(
        "--destination", metavar="DIR", type=str,
        help="Destination directory for downloaded activity. Default: ./activities/",
        default=os.path.join("/", "tmp"))
    parser.add_argument(
        "--log-level", metavar="LEVEL", type=str,
        help="Desired log output level (DEBUG, INFO, WARNING, ERROR). Default: INFO.",
        default="INFO")
    parser.add_argument(
        "--token",
        default=None,
        type=str,
        help=("Authentication header token. Use with 'jwt_fgp' instead of username and password, for example "
              "if login fails due to ReCaptcha."))
    parser.add_argument(
        "--jwt_fgp",
        default=None,
        type=str,
        help=("Authentication JWT_FGP Cookie. Use with 'token' instead of username and password, for example "
              "if login fails due to ReCaptcha."))

    args = parser.parse_args()

    if args.log_level not in LOG_LEVELS:
        raise ValueError("Illegal log-level argument: {}".format(args.log_level))

    logging.root.setLevel(LOG_LEVELS[args.log_level])

    try:
        if not os.path.isdir(args.destination):
            os.makedirs(args.destination)

        prompt_password = not args.password and (not args.token or not args.jwt_fgp)
        if prompt_password:
            args.password = getpass.getpass("Enter password: ")

        with GarminClient(args.username, args.password, args.token, args.jwt_fgp) as client:
            log.info("fetching goals")

            date = datetime.now().strftime('%Y-%m-%d')
            query = {"query":"query{{userDailySummaryV2Scalar(startDate:\"{0}\", endDate:\"{0}\")}}".format(date)}
            headers = {'Content-type': 'application/json'}
            response = client.session.post("https://connect.garmin.com/graphql-gateway/graphql", json=query)
            if response.status_code != 200:
                log.error(u"failed to fetch goals: %d\n%s",
                        response.status_code, response.text)
                raise Exception(u"failed to fetch goals: {}\n{}".format(
                    response.status_code, response.text))
            resp =  json.loads(response.text)

            dest = os.path.join(args.destination, "goal.json")
            with codecs.open(dest, encoding="utf-8", mode="w") as f:
                f.write(json.dumps(resp, ensure_ascii=False, indent=4))
    except Exception as e:
        log.error("failed with exception: %s", e)
        raise

if __name__ == "__main__":
    main()