
// -----------------------------------------------------------------------------------------------------------------------------    
/////////////////////////////////////////////////////////////////////|
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void breakTrade(int mag)
{
   if( breakTradeEnabled == 0) return;
   
   int op = getBreakSignal();
   if( CloseSignal == 1)
   {
      int t = GetOrder(mag, OP_SELL);
      if( t > 0){
         Print("Bands is shrinking width, close positions.........................");
         CloseOrder(t, 1 - OrderType());
      }
   }
   
   //if( true )
   {
      //double macd = iMACD(Symbol(), Period(), 24, 52, 9, PRICE_CLOSE, MODE_MAIN,0 );
      //if( macd > 0 && op == 1) op = 0;
      //else if( macd < 0 && op == 0) op = 1;
      //else op = -1;
   }
   
   while( op != -1 ) 
   {
      string s[2];
      s[0] = "break up "; s[1] = "break down ";
      double price[2];
      price[0] = Ask;
      price[1] = Bid;
      int sl = StopLoss; // MathAbs(Close[0] - objPrice) / Point / 10 + StopLoss;
      int tp = MathCeil((double)sl * TkRate);
      string bn;
      if( StringLen(trendLineName) == 0) bn = "Indicator "+indName;
      else bn = trendLineName;
      if( TimeCurrent() - dtime3 > 180)
      {
           dtime3 = TimeCurrent();
           Print("my1-2-3: ",Symbol()," ",Period()," ",s[op],bn,",",ss[op],"price:",price[op],"ind price:",signalPrice);
      } 
      if( (TradeMode == 2 || TradeMode == op) && getHistoryOrder(mag, 1, op) < 0 )
      {
         t = GetOrder(mag, OP_SELL);
         double lot = Lots;
         if( StringLen(trendLineName) == 0) bn = indName;
         else bn = changeShortName(trendLineName);
         if( t == -1 ){
               at = TimeCurrent();
               string comment = "123("+Period()+")"+s[op]+bn+" new "+ss[op]+" order";
               Print("OpenOrder ",op,lot,comment);
               //OpenOrder(op, lot, sl, tp, mag, comment);
         }
         else if(false){
               if( OrderType() == op && OrderProfit() > 0 && TimeCurrent() - at > 180)
               {
                  at = TimeCurrent();
                  double tt = getTotalOrderLots(mag, op);
                  if( Ask < 500) tt *= 10;
                  if( tt >= MaxLots) break;
                  if( lot > MaxLots - tt) lot = MaxLots - tt;
                  comment = "123("+Period()+")"+s[op]+bn+" add "+ss[op]+" order";
                  OpenOrder(op, lot, sl, tp, mag, comment);
               }
               else{
                  comment = "123("+Period()+")"+s[op]+bn+" reverse "+ss[op]+" order";
                  OpenReverseOrder(t, op, lot, sl, tp, mag,comment);
               }
         }     
      }    
      break;
   }
}


int getBreakSignal()
{
   int i,j,ObjType;
   double price[4];
   double point = getPoint();
   //1 hour k线反转信号
   if( Period() >= 60 && EnableKReverse == 1)
   {  
      int timeframe = 0;
      int ii = 1;
      trendLineName = "K line reverse ";
      if( TimeCurrent() - dtime1 > 180)
      {
           Print("getBreakSignal K reverse: N+2=",iOpen(Symbol(), timeframe, ii+1),"-",iClose(Symbol(), timeframe, ii+1),
                  "N+1=",iOpen(Symbol(), timeframe, ii),"-",iClose(Symbol(), timeframe, ii));
      }

      if( iOpen(Symbol(), timeframe, ii+1) >= iClose(Symbol(), timeframe, ii+1)+KSpace*point &&  //ii+1 is down
          iOpen(Symbol(), timeframe, ii) <= iClose(Symbol(), timeframe, ii)-KSpace*point && //ii is up
          iClose(Symbol(), timeframe, ii) > iOpen(Symbol(), timeframe, ii+1) ) //ii is reverse ii+1
      {
         dtime1 = TimeCurrent(); return 0;
      }
      if( iOpen(Symbol(), timeframe, ii+1) <= iClose(Symbol(), timeframe, ii+1)-KSpace*point &&  //ii+1 is up
          iOpen(Symbol(), timeframe, ii) >= iClose(Symbol(), timeframe, ii)+KSpace*point && //ii is down
          iClose(Symbol(), timeframe, ii) < iOpen(Symbol(), timeframe, ii+1) ) //ii is reverse ii+1
      {
         dtime1 = TimeCurrent(); return 1;
      }
   }
   //趋势线突破信号
   dtime1 = TimeCurrent();
   for (i = 0; i < ObjectsTotal(); i++)
   {
       trendLineName = ObjectName(i);
       string f = StringSubstr(trendLineName,0,1);
       if( f == "#" || f == "_" || f == "K" ) continue; //skip the system lines for orders
       ObjType = ObjectType(trendLineName);
       switch (ObjType)
       {
         case OBJ_HLINE:
           for( j = 1; j <= 3; j++) price[j] = ObjectGet(trendLineName, OBJPROP_PRICE1);
           break;
         case OBJ_TREND :
         case OBJ_TRENDBYANGLE :
           for( j = 1; j <= 3; j++) price[j] = ObjectGetValueByShift(trendLineName, j);
           ///Print("ObjName=",ObjName,"y1=",y1,"y2=",y2);
           break;
         default :
           continue;
       }
       if( TimeCurrent() - dtime2 > 180)
       {
           Print("getBreakSignal Line: ", trendLineName, " price1=",price[1]," price2=",price[2]," price3=",price[3],"Close[1]=",Close[1]);
       }
       int r = getSignal(price);
       if( r >= 0){ dtime2 = TimeCurrent(); return r;}
    }
    //指标突破信号
    dtime2 = TimeCurrent();
    trendLineName = "";
    if( Period() < 5 || EnableInd == 0) return(-1);
    int ct = ChartIndicatorsTotal(0,0);
    int ret;
    if( TestFlag > 0) ct = 1;
    for( int ck = 0; ck < ct; ck++) 
    {
      if( TestFlag > 0) indName = "Bands("+IntegerToString(TestFlag)+")";
      else indName = ChartIndicatorName(0, 0, ck);
      /*
      if( StringFind(indName, "Bands") >= 0)
      {
         for( int bk = 0; bk <=2; bk++)
         {
            ret = getIndPrice(indName, price, bk); //MODE_MAIN 0 MODE_UPPER 1 MODE_LOWER 2
            if( ret < 0) continue;
            r = getSignal(price);
            if( r >= 0) return r;
         }
      }
      else
      */
      {
      ret = getIndPrice(indName, price);
      if( ret < 0) continue;
      if( TimeCurrent() - dtime5 > 180)
      {
           Print("getBreakSignal Indicator: ", indName, " price=",price[1]," price2=",price[2]," price3=",price[3],"Close[1]=",Close[1]);
      }         
      r = getSignal(price);
      if( r >= 0){dtime5 = TimeCurrent();  return r;}
      }     
    }
    dtime5 = TimeCurrent();
    /*
       {
          int para = 50;
          if( iBands(Symbol(),0,para,2,0,PRICE_CLOSE,MODE_MAIN,1) - iBands(Symbol(),0,para,2,0,PRICE_CLOSE,MODE_MAIN,10) > TestSignal  )
          {
             return 0;
          }
          if( iBands(Symbol(),0,para,2,0,PRICE_CLOSE,MODE_MAIN,10) - iBands(Symbol(),0,para,2,0,PRICE_CLOSE,MODE_MAIN,1) > TestSignal  )
          {
             return 1;
          }
       }
    */
    return -1;
  }

int getSignal(double& price[4])
{
       int relation[4];
       int ret = -1;
       for(int j = 1; j <= 3; j++)
       {
         if( Close[j] < price[j]) relation[j] = 0;
         else relation[j] = 1;
         //if( High[j] < price[j]) relation[j] = 0;
         //else relation[j] = 1;

       }
       if( Period() < 60)
       {
         if( relation[3] == 0 && relation[2] == 1 && relation[1] == 1) ret = 0;
         if( relation[3] == 1 && relation[2] == 0 && relation[1] == 0) ret = 1;
       }
       else
       {
         if( relation[2] == 0 && relation[1] == 1) ret = 0;
         if( relation[2] == 1 && relation[1] == 0) ret = 1;
       }
       if( ret >= 0)
       {
             if( TimeCurrent() - dtime4 > 180)
             {
                 dtime4 = TimeCurrent();
                 Print("getSignal: Find signale(M",Period(),") ",trendLineName, "-", indName, "close[1]=",Close[1],"signal price=",price[1],"gap=",MathAbs(Close[1]-price[1]));
             } 
             if( Period() < 60 && MathAbs(Close[1] - price[1]) > MaxGap * getPoint() ){ ret = -1; }
       }
       signalPrice = price[1];
       return ret;
}

int getParam(string name)
{
   int s = StringFind(name, "(", 0);
   if( s < 0) return -1;
   int e = StringFind(name, ")", s);
   if( e < 0) return -1;
   string tmp = StringSubstr(name, s+1, e-s-1);
   return( StringToInteger(tmp));
}

int getIndPrice(string name, double& price[4], int mode= 0)
{
   int para = getParam(name);
   if( para < 0) return -1;
   int j;
   if( StringFind(name, "Bands", 0) >= 0)
   {
      /*
      double width = iBands(Symbol(),0,para,2,0,PRICE_CLOSE,MODE_UPPER,1) - iBands(Symbol(),0,para,2,0,PRICE_CLOSE,MODE_LOWER,j);
      if( iBands(Symbol(),0,para,2,0,PRICE_CLOSE,MODE_UPPER,3) - iBands(Symbol(),0,para,2,0,PRICE_CLOSE,MODE_LOWER,3) > 
          iBands(Symbol(),0,para,2,0,PRICE_CLOSE,MODE_UPPER,1) - iBands(Symbol(),0,para,2,0,PRICE_CLOSE,MODE_LOWER,1) + BandsGap  )
          {
             CloseSignal = 1;
             return -1;
          }
      if( width < BandsSpace) return -1;
      double p = iBands(Symbol(),0,para,2,0,PRICE_CLOSE,MODE_MAIN,0);
      if( Bid >  p && iBands(Symbol(),0,para,2,0,PRICE_CLOSE,MODE_UPPER,0) - Bid < PriceSpace) return -1;
      if( Ask < p && Ask - iBands(Symbol(),0,para,2,0,PRICE_CLOSE,MODE_LOWER,0) < PriceSpace) return -1;
      */
      for( j = 1; j <= 3; j++) price[j] = iBands(Symbol(),0,para,2,0,PRICE_CLOSE,mode,j);     
      return 0;
   }
   else if(StringFind(name, "MA", 0) >= 0)
   {
      for( j = 1; j <= 3; j++) price[j] = iMA(Symbol(),0,para,0,MODE_SMA,PRICE_CLOSE,j);
      return 0;
   }
   return -1;
}