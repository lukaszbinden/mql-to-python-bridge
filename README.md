# mql-to-python-bridge
### MetaTrader MQL to Python bridge
Use MetaTrader as your trading platform but implement your strategy logic with the powerful Python ecosystem.


### Short manual:
1) start python_server.py using Python (write your strategy logic using Python ecosystem)
2) use mq_client.mq4 as MetaTrader EA to forward OnTick() calls to python server for processing thereof (e.g. strategy using rigid logic, ML approach, etc).

### Note: 
- the socket calls from MQ space to python space are implemented as synchronous calls.
- you might need to change the protocol between the EA and the python server, e.g. it does not transfer history of feature values, just the current.

Support is available on demand.