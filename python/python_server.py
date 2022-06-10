from typing import List

import numpy
import pandas
from datetime import datetime
from numpy import transpose, array
import pickle
import socket
import sys

HOST = 'localhost'  # Symbolic name, meaning all available interfaces
PORT = 8888  # Arbitrary non-privileged port


def preprocess(features: List[List[float]]) -> List[List[float]]:
    # preprocess features
    return features


def predict(features: List[List[float]]) -> float:
    score = 0.0

    # ##############################################
    # implement strategy here (rule based, ML, etc)
    # ##############################################

    return score


if __name__ == '__main__':
    tstart = datetime.now()
    print('python_server() --> %s' % str(tstart))

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    print('Socket created')

    # Bind socket to local host and port
    try:
        s.bind((HOST, PORT))
    except socket.error as msg:
        print('Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
        sys.exit()

    print('Socket bind complete')

    # Start listening on socket
    s.listen(10)
    print('Socket now listening')

    # wait to accept a connection - blocking call
    conn, addr = s.accept()
    print('Connected with ' + addr[0] + ':' + str(addr[1]))
    numRequest = 0
    recv = True

    # now keep talking with the client
    while 1:
        if recv:
            data = conn.recv(400)
        print('Received msg: ' + repr(data))
        try:
            if not recv or not data or len(data) == 0:
                print('End of current connection [' + str(conn) + ']' + ', going to accept anew...')
                if conn is not None:
                    conn.close()
                conn, addr = s.accept()
                print('Connected with ' + addr[0] + ':' + str(addr[1]))
                recv = True
                continue

            data = data.decode('ASCII')
            if data == 'stop' or data == 'STOP':
                print('stop command received, shutdown...')
                break
            numRequest = numRequest + 1

            data = data.split('@')[0]
            features = data.split(';')
            # print('features str', features)
            features = [[float(value) for value in features]]
            # print('features num', features)
            features = preprocess(features)
            # print('features std', features)
            score = predict(features)

            print('score: ', score)
            msg = '@FAI@' + str(score) + "\r\n"
            print('[' + str(numRequest) + ']' + ' msg: ' + msg)
            msg = bytes(msg, 'ASCII')
            conn.send(msg)  # send server response (score)
        except:
            e = sys.exc_info()[0]
            print('error occured: ', e)
            print('close connection and accept again...')
            if conn is not None:
                conn.close()
            conn = None
            recv = False

    s.close()

    tend = datetime.now()
    print('uptime: %s' % str((tend - tstart)))
    print('python_server() <-- %s' % str(datetime.now()))
