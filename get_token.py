#!/usr/bin/env python3
import requests, getpass
api = 'https://data-proxy.ebrains.eu/api/'
resp = requests.post(api + 'auth/token', json={'username': input('Username: '), 'password': getpass.getpass()})
token = resp.json()
print(token)