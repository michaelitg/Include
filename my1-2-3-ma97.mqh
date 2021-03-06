
// -----------------------------------------------------------------------------------------------------------------------------    
/////////////////////////////////////////////////////////////////////|
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ma97Trade(int mag)
{
   string comment, sss[2];
   sss[0] = "swing";
   sss[1] = "trend";

   ClosePendingOrder(mag);
   comment = "ma97Trade:"+sss[1]+" add position";
   AddOrder2(mag, LotsOptimized(AddPercent), AddRate, TakeProfit, PlanRate, LimitRate,comment,MaxLots);
      
   double lots,tk,sl,RevPercent;
   int trend = 1;
   int op = getMa97Signal();
   if( op != -1 && ma97TradeEnabled) 
   {
      lots = Lots;
      tk = TakeProfit;
      sl = StopLoss;
      RevPercent = ReversePercent;
      int t = GetOrder(mag, OP_SELL);
      //double angle = iCustom(NULL, 0, "MA_Angle", 97, 48, 2, 0, 0);
      if( t == -1 ){
            comment = "BollerTrade:"+sss[trend]+"new "+ss[op]+" order";
            cm_OpenOrder(op, lots, sl, tk, mag, RevPercent, comment);
      }
      else{
            comment = "BollerTrade:"+sss[trend]+"Reverse "+ss[op]+" order "+"[org:"+ss[OrderType()]+" order "+t+"]";
            cm_OpenReverseOrder(t, op, lots, sl, tk, mag, RevPercent,comment);
      }
   }
}


int getMa97Signal()
{      
   int ind = iCustom(NULL, 0, "#Signal003-MA97", TradeMAPeriod,TakeProfit,StopLoss,AddRate,updownLevel,updowncount,shortma,shortmashift, cbars, 5, 0);
   if (ind == 0) {
              Print(Symbol() + " get ma97 Buy signal !!!!");
              PlaySound("alert");
              return OP_BUY;
   }
   else if (ind == 1) {
              Print(Symbol() + " get ma97 Sell signal !!!");
              PlaySound("alert");
              return OP_SELL;
   }
   return -1;
}

