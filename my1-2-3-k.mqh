
// -----------------------------------------------------------------------------------------------------------------------------    
/////////////////////////////////////////////////////////////////////|
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void kTrade(int mag)
   {

   //Alert("KTradeMode=",KTradeMode,"time=",(TimeCurrent() - Time[0]));     
      RefreshRates(); 
      double price[2];
      price[0] = Ask;
      price[1] = Bid;
      int sl = StopLoss; // MathAbs(Close[0] - objPrice) / Point / 10 + StopLoss;
      int tp = MathCeil((double)sl * TkRate);
      int op = -1;
      //msg = "Time:"+(TimeCurrent() - Time[0]);
      if( Immediate )
      {
         msg = "KTrade Now ";
         op = KTradeMode;
         Immediate = false;
      }
      else{
         msg = "";
         if( TimeCurrent() - KTradeModeTime > RunPeriod*60){ msg = "KTrade expired!"; KTradeMode = -1; ExtDialog.UpdateKTradeMode();return; }
         if( TimeCurrent() - Time[0] < RunPeriod * 60 - 15){ ExtDialog.UpdateLabel("KTrade is waiting for candle closing..."); return;}
         if( KTradeMode == 0 && Close[0] > MathMax(Open[1],Close[1])) op = 0;
         if( KTradeMode == 1 && Close[0] < MathMin(Open[1],Close[1])) op = 1;
      }
      if( op == 0 || op == 1)
      {
         int t = GetOrder(mag, OP_SELL);
         double lot = Lots;
         if( t == -1 ){
               string comment = "123("+Period()+")"+"K line new "+ss[op]+" order";
               OpenOrder(op, lot, sl, tp, mag, comment);
         }
         else{
               comment = "123("+Period()+")"+"K line reverse "+ss[op]+" order";
               OpenReverseOrder(t, op, lot, sl, tp, mag,comment);
         } 
         msg += comment;
         KTradeMode = -1;
         ExtDialog.UpdateKTradeMode();
      }
   }