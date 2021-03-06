#include <stdlib.mqh>
datetime debugp = 0;
int glbOrderType[100];
int glbOrderTicket[100];
//+------------------------------------------------------------------+
//| Read the XML file, for EA testing, should be in tester/files     |
//+------------------------------------------------------------------+
string xmlRead(string fileName)
  {
//---
   string data = "";
   ResetLastError();
   int FileHandle=FileOpen(fileName,FILE_BIN|FILE_READ);
   if(FileHandle!=INVALID_HANDLE)
     {
      //--- receive the file size 
      ulong size=FileSize(FileHandle);
      //--- read data from the file
      while(!FileIsEnding(FileHandle))
         data=FileReadString(FileHandle,(int)size);
      //--- close
      FileClose(FileHandle);
     }
//--- check for errors   
   else PrintFormat("Failed to open %s file, Error code = %d",fileName,GetLastError());
//---
   return data;
  }
void SetObject(string name,datetime T1,double P1,datetime T2,double P2,color clr)
  {
   if(ObjectFind(name) == -1)
     {
       ObjectCreate(name, OBJ_TREND, 0, T1, P1, T2, P2);
       ObjectSet(name, OBJPROP_COLOR, clr);
       ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
     }
   else
     {
       ObjectSet(name, OBJPROP_TIME1, T1);
       ObjectSet(name, OBJPROP_PRICE1, P1);
       ObjectSet(name, OBJPROP_TIME2, T2);
       ObjectSet(name, OBJPROP_PRICE2, P2);
       ObjectSet(name, OBJPROP_COLOR, clr);
       ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
     } 
  }
  
 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void ObjectMakeLabel( int clockcorner, string n, int xoff, int yoff ) {
   ObjectCreate( n, OBJ_LABEL, 0, 0, 0 );
   ObjectSet( n, OBJPROP_CORNER, clockcorner );
   ObjectSet( n, OBJPROP_XDISTANCE, xoff );
   ObjectSet( n, OBJPROP_YDISTANCE, yoff );
   ObjectSet( n, OBJPROP_BACK, true );
} 

// -----------------------------------------------------------------------------------------------------------------------------
string FormatDateTime(int nYear,int nMonth,int nDay,int nHour,int nMin,int nSec)
  {
   string sMonth,sDay,sHour,sMin,sSec;
//----
   sMonth=(string)(100+nMonth);
   sMonth=StringSubstr(sMonth,1);
   sDay=(string)(100+nDay);
   sDay=StringSubstr(sDay,1);
   sHour=(string)(100+nHour);
   sHour=StringSubstr(sHour,1);
   sMin=(string)(100+nMin);
   sMin=StringSubstr(sMin,1);
   sSec=(string)(100+nSec);
   sSec=StringSubstr(sSec,1);
//----
   return(StringConcatenate(nYear,".",sMonth,".",sDay," ",sHour,":",sMin,":",sSec));
  }
  
// -----------------------------------------------------------------------------------------------------------------------------
int Explode(string str, string delimiter, string& arr[])
{
   int i = 0;
   int pos = StringFind(str, delimiter);
   while(pos != -1)
   {
      if(pos == 0) arr[i] = ""; else arr[i] = StringSubstr(str, 0, pos);
      i++;
      str = StringSubstr(str, pos+StringLen(delimiter));
      pos = StringFind(str, delimiter);
      if(pos == -1 || str == "") break;
   }
   arr[i] = str;

   return(i+1);
}

//+------------------------------------------------------------------+
string myTimeToString( int show12HourTimeFlag, datetime when ) {
   if ( !show12HourTimeFlag )
      return (TimeToStr( when, TIME_MINUTES ));      
   int hour = TimeHour( when );
   int minute = TimeMinute( when );
   
   string ampm = " AM";
   
   string timeStr;
   if ( hour >= 12 ) {
      hour = hour - 12;
      ampm = " PM";
   }
      
   if ( hour == 0 )
      hour = 12;
   timeStr = DoubleToStr( hour, 0 ) + ":";
   if ( minute < 10 )
      timeStr = timeStr + "0";
   timeStr = timeStr + DoubleToStr( minute, 0 );
   timeStr = timeStr + ampm;
   
   return (timeStr);
}


datetime dtime2 = 0;
  
bool skiptime(int mag, string skiptime)
{
   if( StringFind(skiptime,TimeToStr(TimeCurrent(), TIME_DATE)) != -1)
   {
         //Print("Skip ",TimeToStr(TimeCurrent(), TIME_DATE)," in ",skiptime);
         int t = GetOrder(mag, OP_SELL);
         if( t != -1)
         {
            int op = OP_BUY;
            if( OrderType() == OP_BUY) op = OP_SELL;
            CloseOrder(t, op);
         }
         return(true);
   }
   return(false);
}

double getPoint()
{
      double apoint=MarketInfo(Symbol(),MODE_POINT);
      if( apoint <= 0.0001) apoint = 0.0001;
      else apoint = 0.01;
      if( Ask > 800) apoint = 0.1;  //gold
      if( Ask > 3000) apoint = 1;  //index
      return(apoint);
}

double getOrderPoint()
{
      double apoint=MarketInfo(OrderSymbol(),MODE_POINT);
      if( apoint <= 0.0001) apoint = 0.0001;
      else apoint = 0.01;
      if( OrderOpenPrice() > 800) apoint = 0.1;  //gold
      if( OrderOpenPrice() > 3000) apoint = 1;  //index
      return(apoint);
}

double LotsOptimized(double percent)
{
   double p = Ask;
   if( Ask > 1500) p = Ask / 10000;
   else if( Ask > 800) p = Ask / 1000;
   
   //double amount = AccountBalance();
   double amount = AccountFreeMargin();
   if( amount < 3000) percent /= 2.0;
   //if( amount > 100000) amount = amount * 1 / 1000;
   double aLots = MathCeil( amount * percent /  (p * 100)  );
   if( Ask < 2) aLots = aLots / 10;
   else aLots = MathCeil(aLots / 10);
   //Print("Lots=",Lots,"-",percent,"-",AccountBalance(),"-",Ask);
   //if( Lots > 50) Lots = 50; 
   double m = MarketInfo(Symbol(), MODE_MAXLOT);
   if( aLots > m) aLots = m;
   return(aLots);
}


int GetOrder(int mag, int maxType)
{
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if( (mag != 0 && OrderMagicNumber()!= mag) || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if( OrderType() <= maxType) return(OrderTicket());
     }
     return(-1);
}
//-------------------used in bollinger trader my1-2-3-ma.mqh 18-03-2021 ok----------------
int GetTotalOrders2(int mag, int oType)
{
   int totalOrders = 0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if( (mag != 0 && MathAbs(OrderMagicNumber() - mag) >= 10) || OrderSymbol()!=Symbol()) continue;
      //---- check order type
      if( OrderType() == oType || OrderType() == oType + 2 || OrderType() == oType + 4)
      {
         glbOrderType[totalOrders] = OrderType();
         glbOrderTicket[totalOrders] = OrderTicket();
         totalOrders++;
      }
     }
     return(totalOrders);
}


int GetTotalOrders(int mag, int maxType)
{
   int totalOrders = 0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if( (mag != 0 && OrderMagicNumber()!= mag) || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if( OrderType() <= maxType) totalOrders++;
     }
     return(totalOrders);
}
//---------------------------------------------18-03-2021 ok------------------------------------

datetime getLastOrderTime(int mag, int maxType)
{
   datetime ret = 0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if( (mag != 0 && OrderMagicNumber()!= mag) || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if( OrderType() <= maxType) ret = OrderOpenTime();
     }
     return(ret);
}

/* cause loss delete
bool CheckBigK(double price, int StopLoss, int TakeProfit, int mag, double ReversePercent)
{
   double apoint = getPoint();
   //大的实体阴线穿过均线   
   if( Open[0] > price && price - Close[0] > 30 * apoint && Open[0] - Close[0] > 100 * apoint)
   {
      int t = GetOrder(mag, OP_SELL);
      if( t == -1 ){
            OpenOrder(OP_SELL, LotsOptimized(ReversePercent), 2 * StopLoss, 2 * TakeProfit, mag, ReversePercent);
      }
      else{
            OpenReverseOrder(t, OP_SELL, LotsOptimized(ReversePercent), 2 * StopLoss, 2 * TakeProfit, mag, ReversePercent);
      }
      Print("xxxxxxxxxxxxxSELLxxxxxxxxxxxxxxxx",price,"x",Open[0],"x",Close[0],"x",Open[0]-Close[0],"x",apoint);
      return(true);
   }
   else if( Open[0] < price && Close[0] - price > 30 * apoint && Close[0] - Open[0] > 100 * apoint)
   {
      t = GetOrder(mag, OP_SELL);
      if( t == -1 ){
            OpenOrder(OP_BUY, LotsOptimized(ReversePercent), 2 * StopLoss, 2 * TakeProfit, mag, ReversePercent);
      }
      else{
            OpenReverseOrder(t, OP_BUY, LotsOptimized(ReversePercent), 2 * StopLoss, 2 * TakeProfit, mag, ReversePercent);
      }
      Print("xxxxxxxxxxxxxxxBUYxxxxxxxxxxxxxx",price,"x",Open[0],"x",Close[0],"x",Open[0]-Close[0],"x",apoint);
      return(true);
   }
   return(false);
}


//测试看到信号直接按固定盈利开仓，结果会亏损
void OpenShortOrder(int op, double Lots, int StopLoss, int TakeProfit, int mag)
{
           double apoint = getPoint();
           double price, sl, tk;
           if( op == OP_BUY)
           {     
                  //Print("==",apoint,"==",Ask,"==",Ask - StopLoss * apoint,"==",Ask + TakeProfit * apoint);
                  price = Ask;
                  sl = Ask - StopLoss * apoint;
                  if( TakeProfit > 0) tk = Ask + TakeProfit * apoint;
                  else tk = 0;
           }
           if( op == OP_SELL)
           {
                  price = Bid;
                  sl = Bid + StopLoss * apoint;
                  if( TakeProfit > 0) tk = Bid - TakeProfit * apoint;
                  else tk = 0;
           }
           if(!OrderSend(Symbol(), op, Lots, price, 50, sl, tk, "myea new sell", mag))
           { Print("myea Error = ",GetLastError()); }
}
*/
void cm_OpenOrder(int op, double aLots, int aStopLoss, int aTakeProfit, int mag, double LotPercent, string c="")
{
           double lots;
           double apoint = getPoint();
           double price, sl, tk;
           if( c == "") c = "myeaMACD openorder";
           int coef = 1;
           if(  Ask > 800){ apoint = 1; coef = 1; }//Lots = Lots * 100;
           if( op == OP_BUY)
           {
                  price = Ask;
                  sl = Ask - aStopLoss * apoint;
                  if( aTakeProfit > 0){
                     tk = Ask + aTakeProfit * apoint;
                  }
                  else tk = 0;
                  RefreshRates();
                  if(OrderSend(Symbol(), op, aLots*coef, NormalizeDouble(Ask, Digits), 500, sl, tk, c+"buy", mag) == -1)
                  { Print("myea Error = ",GetLastError()); }
           }
           if( op == OP_SELL)
           {
                  price = Bid;
                  sl = Bid + aStopLoss * apoint;
                  if( aTakeProfit > 0) tk = Bid - aTakeProfit * apoint;
                  else tk = 0;
                  RefreshRates();
                  if(OrderSend(Symbol(), op, aLots*coef, NormalizeDouble(Bid, Digits), 500, sl, tk, c+"sell", mag) == -1)
                  { Print("myea Error = ",GetLastError()); }
           }
           Print(c,"==apoint=",apoint,"Ask==",Ask,"=lots=",aLots*coef,"==op==",op,"==price=",price,"=sl=",sl,"==tk",tk);

      if(LotPercent > 0)
      {
           lots = LotsOptimized(LotPercent)*coef;
           int precise = 0;
           if(apoint < 1) precise = 1;
           double lots2 = NormalizeDouble(LotsOptimized(LotPercent)*coef/2,precise);

           if( op == OP_BUY && Ask - aStopLoss * apoint < Low[1])
           {
                  //Print("==",apoint,"==",Ask,"==",Ask - StopLoss * apoint,"==",Ask + TakeProfit * apoint);
                  if(OrderSend(Symbol(), OP_SELLSTOP, lots, Ask - aStopLoss * apoint, 50, Ask + aStopLoss * apoint, Ask - (aStopLoss + 2*aTakeProfit) * apoint, c+"pending sellstop", mag) == -1)
                  { Print(c+"open pending Error = ",GetLastError(), "lots=", lots); }

                  if(lots2 >= apoint){
                     if(OrderSend(Symbol(), OP_SELLSTOP, lots2, Ask - aStopLoss * apoint, 50, Ask + aStopLoss * apoint, Ask - (aStopLoss + aTakeProfit) * apoint, c+"pending2 sellstop", mag) == -1)
                     { Print(c+" open pending2 Error = ",GetLastError(), "lots2=", lots2); }
                  }
           }
           if( op == OP_SELL && Bid + aStopLoss * apoint > High[1])
           {
                  if(OrderSend(Symbol(), OP_BUYSTOP, lots, Bid + aStopLoss * apoint, 50, Bid - aStopLoss * apoint, Bid + (aStopLoss + 2*aTakeProfit) * apoint, c+"pending buystop", mag) == -1)
                  { Print(c+"open pending Error = ",GetLastError(), "lots=", lots); }
                  if(lots2 >= apoint){
                     if(OrderSend(Symbol(), OP_BUYSTOP, lots2, Bid + aStopLoss * apoint, 50, Bid - aStopLoss * apoint, Bid + (aStopLoss + aTakeProfit) * apoint, c+"pending2 buystop", mag) == -1)
                     { Print(c+"open pending2 Error = ",GetLastError(), "lots2=", lots2); }
                  }
           }
           Print(c,"LotPercent=",LotPercent,"lots=",LotsOptimized(LotPercent)*coef,"==op==",op,"==price=",price,"=sl=",sl,"==tk",tk);

      }

}

int CloseOrder2(int mag)
{
   bool done;
   do{
      done = true;
      for(int i = OrdersTotal() - 1;i >= 0; i--)
       {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if( (mag != 0 && OrderMagicNumber()!= mag) || OrderSymbol()!=Symbol()) continue;
         //---- check order type
         if( OrderType() <= OP_SELLLIMIT)
         {
            if(OrderType()==OP_BUY || OrderType() == OP_BUYLIMIT)
               if( !OrderClose(OrderTicket(),OrderLots(),Bid,50,White)){Print(GetLastError());}
            else
               if( !OrderClose(OrderTicket(),OrderLots(),Ask,50,White)){Print(GetLastError());}
            Print("===================CloseOrder2: bounce back, close and wait......");
            done = false;
            break;
         }
        }
     }while(!done);
     return(-1);
}

int CloseOrder(int ticket, int op)
{
      int t;
      int nClosed = 0;
      if( OrderSelect(ticket,SELECT_BY_TICKET, MODE_TRADES)==false )return(false);
      int mag = OrderMagicNumber();
      if(OrderType()==OP_BUY && op == OP_SELL)
        {
         if(!OrderClose(OrderTicket(),OrderLots(),Bid,50,White)){Print(GetLastError());}
         nClosed++;
         t = GetOrder(mag, OP_SELL);
         while( t >= 0)
         {
             if(!OrderClose(OrderTicket(),OrderLots(),Bid,50,White)){Print(GetLastError());}
             nClosed++;
             t = GetOrder(mag, OP_SELL);
         }
         ClosePendingOrder(mag, true);

         t = GetOrder(mag+40, OP_SELL);
         while( t >= 0)
         {
             if(!OrderClose(OrderTicket(),OrderLots(),Bid,50,White)){Print(GetLastError());}
             t = GetOrder(mag+40, OP_SELL);
         }
         return(nClosed);
        }
      if(OrderType()==OP_SELL && op == OP_BUY)
        {
         if(!OrderClose(OrderTicket(),OrderLots(),Ask,50,White)){Print(GetLastError());}
         nClosed++;
         t = GetOrder(mag, OP_SELL);
         while( t >= 0)
         {
             if(!OrderClose(OrderTicket(),OrderLots(),Ask,50,White)){Print(GetLastError());}
             nClosed++;
             t = GetOrder(mag, OP_SELL);
         }
         ClosePendingOrder(mag, true);

         t = GetOrder(mag+40, OP_SELL);
         while( t >= 0)
         {
             if(!OrderClose(OrderTicket(),OrderLots(),Ask,50,White)){Print(GetLastError());}
             t = GetOrder(mag+40, OP_SELL);
         }
         return(nClosed);
        }
        /*同向信号加仓错误的！！！！！
        if( GetOrder(mag+40, OP_SELL) >= 0) return(false);
        if(OrderType()==OP_BUY && op == OP_BUY)
        {
           if(!OrderSend(Symbol(), OP_BUY, 0.1, Ask, 50, OrderStopLoss(), OrderTakeProfit(), "myea new buy", mag+40))
           { Print("myea Error = ",GetLastError()); }
        }
        if(OrderType()==OP_SELL && op == OP_SELL)
        {
           if(!OrderSend(Symbol(), OP_SELL, 0.1, Bid, 50, OrderStopLoss(), OrderTakeProfit(), "myea new sell", mag+40))
           { Print("myea Error = ",GetLastError()); }
        }
        */
      return(nClosed);
}

void ClosePendingOrder(int mag, bool force=false)
{
   int t = GetOrder(mag, OP_SELL);
   if( force == false && t >= 0) return;

   int k = 0;
   bool done = false;
   while( !done)
   {
   done = true;
   for( int i = 0; i < OrdersTotal(); i++)
   {
      if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false )return;
      double apoint = getOrderPoint();
      //if( OrderTicket() == 153){ OrderPrint();Print("*****************",MathAbs( OrderOpenPrice() - Ask ) / apoint);}
      if(OrderType()<= OP_SELL || OrderSymbol() != Symbol() || OrderMagicNumber() != mag ) continue;
      if( MathAbs( OrderOpenPrice() - Ask ) / apoint > 20)  //保留了价格接近的挂单
      {
            //Print("=====t=",t,"====",mag, "----", OrdersTotal(), "--",OrderTicket());
            if(!OrderDelete(OrderTicket())){Print(GetLastError());}
            done = false;
            break;
      }
   }
   }
}
/*
//检查是否有在0，1两根K线内平仓的单子
int getHistoryOrder(int mag)
{
   int hstTotal=OrdersHistoryTotal();
   int i;
   int k = hstTotal-10;
   if(k < 0) k = 0;
   for( i = hstTotal-1; i >= k; i--){
        if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)== true)
            if(OrderType()<=OP_SELL &&   // check for opened position
               OrderSymbol()==Symbol())  // check for symbol
               {
                  if( (OrderMagicNumber()) == mag)
                  {
                      if( ( OrderCloseTime() - Time[1] < 2*Period() * 60) && (OrderCloseTime() - Time[1] >= 0) ) return(OrderTicket());
                      //return(i);
                  }
               }
   }
   return(-1);
}
/*
void CheckTkOrder(int mag, double Lots, int StopLoss, int TakeProfit, double LotPercent)
{
     if( GetOrder(mag, OP_SELL) < 0) return;
     if( OrderTakeProfit() > 0) return; //for buylimit/selllimit, use the order takeprofit
     if( OrderProfit()/OrderLots() >= TakeProfit*10)
     {
           //Print("**********",OrderTicket(),"***",OrderProfit());
           CloseOrder(OrderTicket(), 1-OrderType());
     }
}

void CheckTkOrder(int mag, double Lots, int StopLoss, int TakeProfit, double LotPercent)
{
     if( GetOrder(mag, OP_SELL) >= 0) return;
     int t = getHistoryOrder(mag);
     if( t == -1) return;
     if( OrderProfit() > 1.8*TakeProfit)
     {
           OpenOrder(1-OrderType(), Lots, StopLoss, TakeProfit, mag, LotPercent);
     }
}
*/
void cm_OpenReverseOrder(int ticket, int op, double aLots, int aStopLoss, int aTakeProfit, int mag,double LotPercent, string c="")
{
      if( OrderSelect(ticket,SELECT_BY_TICKET, MODE_TRADES)==false )return;
      //第一个单子只能用来找方向，盈利靠加仓！！！
      //double lots = OrderLots() * 2;
      //if( OrderProfit() > 0) lots = Lots;
      //if( AccountBalance() > 6000) lots *= 2;
      double lots = OrderLots();
      double opt = OrderProfit();
      int n;
      n = CloseOrder(ticket, op);

      if( n == 1 && opt < 0 ){
         lots = 2 * lots;
         if( lots > LotsOptimized(0.2)) lots = LotsOptimized(0.2);
      }
      else lots = aLots;
      //Print("====myea-OpenReverseOrder","==lots=",lots,"==n=",n,"==op=",op);
      if( n > 0 )
      {
         cm_OpenOrder(op, lots, aStopLoss, aTakeProfit, mag, LotPercent, c);
       }
}

void AddOrder(int mag, double lots, double aAddRate, int aTakeProfit, string c="")
{
   int t = GetTotalOrders(mag, OP_SELL);
   if( t == 0 || t >= 2) return;
   if( c == "") c = "Add ";
   t = GetOrder(mag, OP_SELL);
   double apoint = getOrderPoint(); 
   double coef = 10;
   if( Ask > 1000){ coef = 1; apoint = 1; }
   if( MathAbs(OrderTakeProfit()-OrderOpenPrice())/apoint > aTakeProfit+10) return;

   //Print("=====coef=",coef,"====",OrderProfit() / (OrderLots() * coef),"=====",aAddRate * aTakeProfit);
   if(OrderProfit() / (OrderLots() * coef) > aAddRate * aTakeProfit * apoint && OrderProfit() / (OrderLots() * coef) < (aAddRate+0.2) * aTakeProfit * apoint )
   {
         Print(c, "Add Orig[",t,"]:", OrderProfit(), "-",aAddRate,"-",lots);
         double tk = OrderTakeProfit();
         if( OrderType() == OP_BUY)
         {
            if(!OrderSend(Symbol(),OP_BUY,lots,Ask,50,OrderStopLoss(), tk,c+"buy",mag,0,Blue)){Print(GetLastError());}
         }
         else{
            if(!OrderSend(Symbol(),OP_SELL,lots,Bid,50,OrderStopLoss(),tk,c+"sell",mag,0,Red)){Print(GetLastError());}
         }
   }
   /*
   追踪止损只适合于趋势性很强的如AUDUSD
   if( OrderProfit() / (OrderLots() * 10) > TakeProfit )
   {
      int TrailingStop = TakeProfit;
      if( OrderType() == OP_BUY)
      { 
         if(OrderStopLoss()< Bid-apoint*TrailingStop)
         {
              OrderModify(OrderTicket(),OrderOpenPrice(),Bid-apoint*TrailingStop,0,0,Green);
         }
      }
      else{
         if((OrderStopLoss()>(Ask+apoint*TrailingStop)) )
         {
              OrderModify(OrderTicket(),OrderOpenPrice(),Ask+apoint*TrailingStop,0,0,Red);
         }
      }

   }
   */
}

bool checkAdd(int mag, int op)
{
   //Print("checkAdd-------", OrderTicket(),"-",mag,"-",op);
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if( (mag != 0 && OrderMagicNumber()!= mag) || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if( OrderType() == op+2){return(true);}
     }
     return(false);
}

double symbolLots()
{
   double lots = 0;
   for(int i = 0; i < OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if( OrderSymbol() != Symbol() || OrderType() > OP_SELL) continue;
      lots += OrderLots();
   }
   return(lots);
}

void AddOrder2(int mag, double lots, double aAddRate, int aTakeProfit, double rate, double limit, string c="", int maxLots = 0)
{
   int t, total;

   double m = MarketInfo(Symbol(), MODE_MAXLOT);
   total = GetTotalOrders(mag, OP_SELL);

   if( total == 0 || total >= 3) return;
   //if( t == 0 || t >= 2) return;
   if( rate == 0 )
   {
      AddOrder(mag, lots, aAddRate, aTakeProfit,c);
      return;
   }

   if( c== "") c = "Add ";
   t = GetOrder(mag, OP_SELL);
   double apoint = getOrderPoint(); 
   double coef = 10;
   if( Ask > 1000){ coef = 1; apoint = 1;}
   //Print("==========tl1=",OrderProfit() / (OrderLots() * coef),"tl2=",aAddRate * aTakeProfit * apoint,"updown=",OrderProfit() / (OrderLots() * coef),"4=",(aAddRate+limit) * aTakeProfit * apoint);         
   if( MathAbs(OrderTakeProfit() - OrderOpenPrice()) / apoint > aTakeProfit + 10) return; //如果订单的止盈超过了TakeProfit，说明是stop，不能加仓
   if( checkAdd(mag, OrderType())) return; //已经下过加仓的挂单，就返回
   int t2 = OrderTicket();

   //Print("====+++++++=coef=",coef,"==OrderLots==",OrderLots(),"====",OrderProfit() / (OrderLots() * coef),"=====",AddRate * TakeProfit);
   bool notdone = true;
   while(notdone)
   { 
      notdone = false;
      double profit;
      if( OrderType() == 0) profit = Ask - OrderOpenPrice();
      else profit = OrderOpenPrice() - Bid; 
   if( total < 2)  // 第一次加仓，挂单
   {
      RefreshRates();
      if( OrderSelect(t, SELECT_BY_TICKET, MODE_TRADES) == FALSE){
       Print("AddOrder2 failed0: ",ErrorDescription(GetLastError()));
       return;
      }
      ///*
      //if( TimeCurrent() - debugp > 1800){
            //Print("coef=",coef,"profit=",profit,"x", profit / (OrderLots() * coef)," > ",aAddRate * aTakeProfit * apoint," && ",profit / (OrderLots() * coef)," < ",(aAddRate+limit) * aTakeProfit * apoint);
            //debugp = TimeCurrent();
      //}
      //*/

      if(profit / (OrderLots() * coef) > aAddRate * aTakeProfit * apoint && profit / (OrderLots() * coef) < (aAddRate+limit) * aTakeProfit* apoint )
      {
            if( OrderSelect(t, SELECT_BY_TICKET, MODE_TRADES) == FALSE){
             Print("AddOrder2 failed0: ",ErrorDescription(GetLastError()));
             return;
            }
            Print(c, "Add2 orgin[",t,"][",OrderTicket(),"]:OrderType=",OrderType(),"OrderProfit=",OrderProfit(), "-",aAddRate,"-",lots,"-",mag);
            double tk = OrderTakeProfit();
            if( OrderType() == OP_BUY)
            {
               if(!OrderSend(Symbol(),OP_BUYLIMIT,lots, NormalizeDouble(Ask-(rate*aTakeProfit*apoint),Digits),50,NormalizeDouble(OrderStopLoss(),Digits), tk,c+"buylimit position",mag,0,Blue)){Print(GetLastError());}
            }
            else{
               if(!OrderSend(Symbol(),OP_SELLLIMIT,lots,NormalizeDouble(Bid+(rate*aTakeProfit*apoint),Digits),50,NormalizeDouble(OrderStopLoss(),Digits),tk,c+"selllimit position",mag,0,Red)){Print(GetLastError());}
             }
            Sleep(10000);
      }
    }
    else{  //已经加过仓，在回到达40%时再加仓
      //datetime dt = OrderOpenTime();
      //if( TimeCurrent() - dt > Period()*2*60)
      {
     if( maxLots > 0)
     {
         int totalOrders = 0;
         for(int i=0;i<OrdersTotal();i++)
         {
          if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
          if( OrderSymbol()!=Symbol()) continue;
          //---- check order type 
          if( OrderType() <= OP_SELL) totalOrders++;
         }
         if( totalOrders >= maxLots )  return;
     }
      RefreshRates();
      if( OrderSelect(t, SELECT_BY_TICKET, MODE_TRADES) == FALSE){
       Print("AddOrder2 failed2: ",ErrorDescription(GetLastError()));
       return;
      }
      if(profit / (OrderLots() * coef) > aAddRate * aTakeProfit && profit / (OrderLots() * coef) < (aAddRate+limit) * aTakeProfit )
      {
            double newlots = lots*2;
            if( newlots + symbolLots() < 50 && newlots < m)
            {
               if( OrderSelect(t, SELECT_BY_TICKET, MODE_TRADES) == FALSE){
                  Print("AddOrder2 failed3: ",ErrorDescription(GetLastError()));
                  return;
               }
               double sl = OrderStopLoss();  //org
               //sl = OrderOpenPrice();  //new method1 => decrease profit, but can avoid burst death
               Print(c, "Add2-2Origin[",t,"][",OrderTicket(),"]op=",OrderType(),"ask=",Ask,"bid=",Bid,"-",aAddRate,"lots=",newlots,"-",mag);
               if( OrderType() == OP_BUY){
                  if(OrderSend(Symbol(),OP_BUY,newlots, Ask,0,sl, OrderTakeProfit(),c+"2nd add buy",mag,0,Blue)){Print(GetLastError());}
               }
               else{
                  if(OrderSend(Symbol(),OP_SELL,newlots,Bid,0,sl,OrderTakeProfit(),c+"2nd add sell",mag,0,Red)){Print(GetLastError());}
               }
               //Print("Result:",ErrorDescription(GetLastError()));
               //if( OrderType() == OP_BUYSTOP) OrderSend(Symbol(),OP_BUYSTOP,lots, NormalizeDouble(Ask+(rate*TakeProfit*apoint),Digits),50,NormalizeDouble(OrderStopLoss(),Digits), tk,c+"buylimit2 position",mag,0,Blue);
               //else  OrderSend(Symbol(),OP_SELLSTOP,lots,NormalizeDouble(Bid-(rate*TakeProfit*apoint),Digits),50,NormalizeDouble(OrderStopLoss(),Digits),tk,c+"selllimit2 position",mag,0,Red);
            }
            Sleep(10000);
      }
      if( GetLastError() == 131){
          //lots = NormalizeDouble(lots / 2, 1);
          //notdone = true;
      }
      }
    }//else
  } //while
   /*
   if( OrderProfit() / (OrderLots() * 10) > TakeProfit )
   {
      int TrailingStop = TakeProfit;
      if( OrderType() == OP_BUY)
      { 
         if(OrderStopLoss()< Bid-apoint*TrailingStop)
         {
              OrderModify(OrderTicket(),OrderOpenPrice(),Bid-apoint*TrailingStop,0,0,Green);
         }
      }
      else{
         if((OrderStopLoss()>(Ask+apoint*TrailingStop)) )
         {
              OrderModify(OrderTicket(),OrderOpenPrice(),Ask+apoint*TrailingStop,0,0,Red);
         }
      }

   }
   */
}

/*
void OpenOrder1(int op, double Lots, int StopLoss, int TakeProfit, int mag, double LotPercent)
{
           double apoint = getPoint();
           double lots = 50;
           int mag1 = mag;
           if( Lots >= 50)
           {
                  for( int i = 0; i < Lots / 50; i++)
                  {
                   if( op == OP_BUY)
                   {     
                          //Print("==",apoint,"==",Ask,"==",Ask - StopLoss * apoint,"==",Ask + TakeProfit * apoint); 
                          if(!OrderSend(Symbol(), OP_BUY, lots, Ask, 50, Ask - StopLoss * apoint, Ask + TakeProfit * apoint, "myea new buy", mag1))
                          { Print("myea Error = ",GetLastError()); }
                   }
                   if( op == OP_SELL)
                   {
                          if(!OrderSend(Symbol(), OP_SELL, lots, Bid, 50, Bid + StopLoss * apoint, Bid - TakeProfit * apoint, "myea new sell", mag1))
                          { Print("myea Error = ",GetLastError()); }
                   }
                   mag1 = mag + 40;
               }
           }
           lots = Lots - MathFloor(Lots / 50.0) * 50;
                  if( lots > 0)
                  {
                   if( op == OP_BUY)
                   {     
                          //Print("==",apoint,"==",Ask,"==",Ask - StopLoss * apoint,"==",Ask + TakeProfit * apoint);
                          if(!OrderSend(Symbol(), OP_BUY, lots, Ask, 50, Ask - StopLoss * apoint, Ask + TakeProfit * apoint, "myea new buy", mag1))
                          { Print("myea Error = ",GetLastError()); }
                   }
                   if( op == OP_SELL)
                   {
                          if(!OrderSend(Symbol(), OP_SELL, lots, Bid, 50, Bid + StopLoss * apoint, Bid - TakeProfit * apoint, "myea new sell", mag1))
                          { Print("myea Error = ",GetLastError()); }
                   }
               }
               
               //----------------------------
           lots = 50;
           mag1 = mag;
           if( LotsOptimized(LotPercent) >= 50)
           {
                  for( i = 0; i < LotsOptimized(LotPercent) / 50; i++)
                  {
                   if( op == OP_BUY)
                   {     
                          //Print("==",apoint,"==",Ask,"==",Ask - StopLoss * apoint,"==",Ask + TakeProfit * apoint);
                          if(!OrderSend(Symbol(), OP_SELLSTOP, lots, Ask - StopLoss * apoint, 50, Ask + StopLoss * apoint, Ask - (StopLoss + 2*TakeProfit) * apoint, "myea new buy-sell", mag1))
                          { Print("myea Error = ",GetLastError()); }
                   }
                   if( op == OP_SELL)
                   {
                          if(!OrderSend(Symbol(), OP_BUYSTOP, lots, Bid + StopLoss * apoint, 50, Bid - StopLoss * apoint, Bid + (StopLoss + 2*TakeProfit) * apoint, "myea new sell-buy", mag1))
                          { Print("myea Error = ",GetLastError()); }
                   }
                   mag1 = mag+40;
               }
           }
           lots = LotsOptimized(LotPercent) - MathFloor(LotsOptimized(LotPercent) / 50.0) * 50;
                  if( lots > 0)
                  {
                   if( op == OP_BUY)
                   {     
                          if(!OrderSend(Symbol(), OP_SELLSTOP, lots, Ask - StopLoss * apoint, 50, Ask + StopLoss * apoint, Ask - (StopLoss + 2*TakeProfit) * apoint, "myea new buy-sell", mag1))
                          { Print("myea Error = ",GetLastError()); }
                   }
                   if( op == OP_SELL)
                   {
                          if(!OrderSend(Symbol(), OP_BUYSTOP, lots, Bid + StopLoss * apoint, 50, Bid - StopLoss * apoint, Bid + (StopLoss + 2*TakeProfit) * apoint, "myea new sell-buy", mag1))
                          { Print("myea Error = ",GetLastError()); }
                   }
               }
           

}
*/
//ToDo: add half swing half trend processing??