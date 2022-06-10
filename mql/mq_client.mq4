#include <socket-library-mt4-mt5.mqh>

#define SOCKET_LIBRARY_USE_EVENTS

input string   Hostname = "localhost";    // Server hostname or IP address
input ushort   ServerPort = 8888;        // Server port


ClientSocket * glbClientSocket = NULL;


input double threshhold = 2;
input double tradeVolume = 0.1;

double gOrderTicket;   // ID of current order
double gOpeningPrice;  // opening price of current order
double gTakeProfit;   // target price of current order
double gStopLoss;     // 
double gPredictedScore;   // prediction from python strategy

int gFileHandle;
int gNumTicks = 0;
int gNumTrades = 0;
double gSumTradePipDelta = 0;

int OnInit()  {    
   gFileHandle = FileOpen("report.csv", FILE_CSV|FILE_WRITE, ","); 

   return(INIT_SUCCEEDED);   
}
  
void OnDeinit(const int reason) {
   if (glbClientSocket) {
      delete glbClientSocket;
      glbClientSocket = NULL;
   }
   if (gNumTrades > 0) {
      Print("Sum of trade pip difference: " + gSumTradePipDelta);
      Print("Average trade pip difference: " + gSumTradePipDelta/gNumTrades);
   }
}


void OnTick()
  {
   if (!glbClientSocket) {
      glbClientSocket = new ClientSocket(Hostname, ServerPort);
      if (glbClientSocket.IsSocketConnected()) {
         Print("Client connection succeeded");
      } else {
         Print("Client connection failed");
      }
  }
  gNumTicks++;
   int mygNumTicks = gNumTicks;

   if (glbClientSocket.IsSocketConnected()) {
   
        // send current indicator values to python strategy
        double MA50 = iMA(NULL, 0, 50, 0, MODE_SMA, PRICE_CLOSE, 0);

        // stochastic
        double stochastic = iStochastic(NULL, 0, 14, 3, 3, MODE_SMA, 1, MODE_MAIN, 0);
  
        //MACD
        double MACD = iMACD(NULL, 0, 15, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);

        // more indicators etc.

        // assemble indicator values etc. to message according to mql-python protocol
        string values = MA50 + ";" + stochastic + ";"+ MACD;

        // could send mygNumTicks as well

        // a message must always be of length 400, thus 0-pad
        values = values + "@";
        while (StringLen(values) < 400) {values = values + "0";}
        // Print(values);
        
        // send current indicator values etc. to python strategy
        glbClientSocket.Send(values);
         
   } else {
      // Either the connection above failed, or the socket has been closed since an earlier
      // connection. We handle this in the next block of code...
   }
   
   
   // If the socket is closed, destroy it, and attempt a new connection
   // on the next call to OnTick()
   if (!glbClientSocket.IsSocketConnected()) {
      // Destroy the server socket. A new connection
      // will be attempted on the next tick
      Print("Client disconnected. Will retry.");
      delete glbClientSocket;
      glbClientSocket = NULL;
   }  

      // update prediction: receive score from python strategy
      double gPredictedScore;
      string msg;
      int cntMsgEmpty = 0;
      // Print("enter dowhile --> [" + mygNumTicks + "]");
      uint start = GetTickCount();
      do {
         msg = glbClientSocket.Receive("\r\n");
         if (StringLen(msg) > 0) {
            Print("Msg: " + msg);
         } else {
            cntMsgEmpty++;
         }
      } while (StringLen(msg) == 0 || StringFind(msg, "@FAI@", 0) != 0);
      // could verify mygNumTicks here
      gPredictedScore  = StrToDouble(StringSubstr(msg, 5));
      // uint time = GetTickCount() - start;
      Print("Receive() <-- [" + mygNumTicks + "] [D:" + gPredictedScore + ", A:" + Ask + ", B:" + Bid + "]");
      // Print("Receive() <-- [" + mygNumTicks + ", " + cntMsgEmpty + ", " + gPredictedScore + ", A:" + Ask + ", B:" + Bid + "] " + time + "ms");

     // Implement order execution and management based on score received from python strategy...
     if (gPredictedScore > threshhold) {
          // buy?
     }
     if (gPredictedScore < -threshhold) {
          // sell?
     }
     // etc.
}