import socket
import sys

HOST = 'localhost'    # The remote host
PORT = 8888              # The same port as used by the server
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))

if len(sys.argv) > 1:
    str = sys.argv[1]
    print('override msg to send by: ', str)
    str = bytes(str, 'ASCII')
else:
    str = b'1.168493335797132;1.168679517848715;1.169505800000015;1.168371705997467;-0.0001160976152330129;-50.18450184474978;1.167063643376716;1.16868333333333;1.170303023289943;0.0001100000000000545;1.170231857858301;100.0094168407355;21.2493243010327;-0.8470899999999877;-0.2132366666663925;-0.2204042857144166;-0.7004969230768845;1.168647905001893;1.16823'

s.send(str)
data = s.recv(1024)
s.close()
msg = data.decode('ASCII')
print('Received: ', msg)
print('Predicted orig: ', '1.0911356')
print('Expected: ', '1.168666')
