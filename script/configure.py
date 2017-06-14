'Imports'

import json
import logging
import sys
import time
import os


def main(redisIP, postgresIP, scriptPath):
    '''
    Update airflow configurations and DAGs by using KeyVault and Blob storage.
    '''
    print('Redis IP: {}'.format(redisIP))
    print('Postgres IP: {}'.format(postgresIP))
    print('Updating airflow.cfg')
    with open(scriptPath, 'r+') as f:
        script = f.read()
        script = script.replace('REDIS_HOST:="redis"', 'REDIS_HOST:="{}"'.format(redisIP))
        script = script.replace('POSTGRES_HOST:="postgres"', 'POSTGRES_HOST:="{}"'.format(postgresIP))
        f.seek(0)
        f.write(script)


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print('Invalid argument. {}'.format(sys.argv))
        exit(1)
    print(sys.argv)
    redisIP = sys.argv[1]
    postgresIP = sys.argv[2]
    scriptPath = sys.argv[3]
    main(redisIP, postgresIP, scriptPath)