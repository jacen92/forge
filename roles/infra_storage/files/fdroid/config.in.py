#!/usr/bin/env python3

import os

# Values from the original config file
DATA = {
    "repo_url": "{{ FDROID_URL_IN_CONFIG }}:{{ FDROID_PORT }}/repo",
    "repo_name": "Nicolas Gargaud <jacen92@gmail.com> repository",
    "repo_icon": "fdroid-icon.png",
    "repo_description": [
        "This is the repository of apps to be used with F-Droid."
        "Applications in this repository are official binaries built by the original application developers."
    ],

    "archive_older": 3,
    "archive_url": "{{ FDROID_URL_IN_CONFIG }}:{{ FDROID_PORT }}/repo",
    "archive_name": "Nicolas Gargaud <jacen92@gmail.com> repository",
    "archive_icon": "fdroid-icon.png",
    "archive_description": [
        "The release repository of older versions of applications from the main repository."
    ]
}

def compare_line(l):
    for d in DATA:
        if type(DATA[d]) == str:
            if l.startswith("{} = ".format(d)):
                l = '{} = "{}"{}'.format(d, DATA[d], os.linesep)
        if type(DATA[d]) == list:
            if l.startswith("{} = ".format(d)):
                print("Not implemented: {}".format(d))
    return l

if __name__ == "__main__":
    """
        This script update the config.py script of fdroid with custom parameters.
    """
    config_py = os.path.join(os.environ.get("HTML_INTERNAL_PATH"), os.environ.get("CONFIG_PY"))
    print("Merge this file content to {}".format(config_py))
    repo_url = os.environ.get("REPO_URL")
    repo_name = os.environ.get("REPO_NAME")
    if repo_url:
        print("Update repo url from env: {}".format(repo_url))
        DATA["repo_url"] = repo_url
        DATA["archive_url"] = repo_url

    if repo_name:
        print("Update repo repo_name from env: {}".format(repo_name))
        DATA["repo_name"] = repo_name

    conf = None
    with open(config_py, "r") as f:
        conf = f.readlines()

    with open(config_py, "w") as f:
        for l in conf:
            l = compare_line(l)
            f.write(l)
