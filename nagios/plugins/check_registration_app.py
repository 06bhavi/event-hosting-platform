#!/usr/bin/env python3
"""check_registration_app.py - Nagios plugin for the event registration site.

Checks: page reachable, HTTP 200, expected text present, response time.
Exit codes: 0 OK, 1 WARNING, 2 CRITICAL, 3 UNKNOWN
"""
import argparse
import socket
import sys
import time
import urllib.error
import urllib.request

OK, WARNING, CRITICAL, UNKNOWN = 0, 1, 2, 3


def main():
    parser = argparse.ArgumentParser(description="Check the event registration page")
    parser.add_argument("-H", "--host", required=True, help="web server address")
    parser.add_argument("-p", "--port", type=int, default=80)
    parser.add_argument("-u", "--uri", default="/")
    parser.add_argument("-s", "--search", default="Register",
                        help="text that must appear in the page")
    parser.add_argument("-w", "--warning", type=float, default=1.0,
                        help="warning threshold in seconds")
    parser.add_argument("-c", "--critical", type=float, default=3.0,
                        help="critical threshold in seconds")
    parser.add_argument("-t", "--timeout", type=float, default=10.0)
    args = parser.parse_args()

    url = f"http://{args.host}:{args.port}{args.uri}"
    start = time.time()
    try:
        with urllib.request.urlopen(url, timeout=args.timeout) as resp:
            status = resp.status
            body = resp.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as err:
        print(f"CRITICAL - {url} returned HTTP {err.code}")
        return CRITICAL
    except (urllib.error.URLError, socket.timeout, ConnectionError) as err:
        print(f"CRITICAL - cannot reach {url}: {err}")
        return CRITICAL
    except Exception as err:  # anything unexpected
        print(f"UNKNOWN - unexpected error: {err}")
        return UNKNOWN

    elapsed = time.time() - start
    perf = f"time={elapsed:.3f}s;{args.warning};{args.critical};0"

    if status != 200:
        print(f"CRITICAL - {url} returned HTTP {status} | {perf}")
        return CRITICAL
    if args.search not in body:
        print(f"CRITICAL - text '{args.search}' not found in page | {perf}")
        return CRITICAL
    if elapsed >= args.critical:
        print(f"CRITICAL - page took {elapsed:.3f}s | {perf}")
        return CRITICAL
    if elapsed >= args.warning:
        print(f"WARNING - page took {elapsed:.3f}s | {perf}")
        return WARNING

    print(f"OK - registration page served in {elapsed:.3f}s, '{args.search}' found | {perf}")
    return OK


if __name__ == "__main__":
    sys.exit(main())
