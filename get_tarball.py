#!/usr/bin/env python3
import github
import os
g = github.Github()
repo = g.get_repo('ins-amu/hip-tvb-app')
rls = repo.get_latest_release()
ast = rls.get_assets()
for a in ast:
    os.system(f'curl -LO# --retry 5 --retry 10 --retry-max-time 0 -C - {a.browser_download_url}')
