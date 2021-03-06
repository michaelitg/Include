#include<stdlib.mqh>

extern double ProtectPercent = 1;
extern double KFilter = 4;
extern int    band = 100;

extern double TkRate1 = 2.3;
extern double TkRate2 = 1; //should be dynamic 1-1.6;

//计算当前的止盈，注意趋势发展后要及时跟上修改止盈
//mode1: build position once mode2: build graduately
double CalTakeProfit(int mode)
  {
      //计算止盈
      double bup=iBands(Symbol(),0,band,2,0,PRICE_CLOSE,MODE_UPPER,0);
      double bdn=iBands(Symbol(),0,band,2,0,PRICE_CLOSE,MODE_LOWER,0);
      double TakeProfit1 = MathCeil((bup - bdn) / getPoint() );
      if( mode == 1){
         TakeProfit1 *= TkRate1;
      }
      else
      {
         TakeProfit1 *= TkRate2;
      }
      return(TakeProfit1);
  }
  
  //=================================ZigZag 前低止损=======================================================
//low = 2 high = 1
double CalStopLoss(int highorlow)
{
   double val = 0;
   int reverse = 3 - highorlow;
//*
   for(int i = 0; i<=1000; i++)
   {
      val = iCustom(Symbol(),0,"ZigZag",12,5,3,reverse,i);
      if( val > 0 ) break;
   }
   
   for(int k = i; k<=1000; k++)
   {
      val = iCustom(Symbol(),0,"ZigZag",12,5,3,highorlow,k);
      if( val > 0 ) break;
   }
//*/
/*
   for(int k = 0; k<=1000; k++)
   {
      val = iCustom(Symbol(),0,"ZigZag",12,5,3,highorlow,k);
      if( val > 0 ){
          break;
      }
   }
   */
   return val;
 
}

//=================================End of ZigZag 前低止损================================================
//=================================仓位管理==============================================================
double GetMaxLots(double maxLoss, double amaxLossPercent)
{

   //仓位系数，不同平台对手数定义不同
   double coef = 1;
   double level = 200;
   if( StringFind(TerminalName(), "FXCM") >= 0 && Ask > 500){
      coef = 0.01; //FXCM 1gold = 0.01 10 = 0.1 
   }
   else{
      if( StringFind(TerminalName(), "FOREX") >= 0 && Ask > 500){
         coef = 0.1; //Forex 1gold = 0.1 10 = 1 
         level = 100;
      }
   }
   //FXCM: 10000
   double maxLots = MarketInfo(Symbol(), MODE_MAXLOT);
   //卖出价格
   double p = Ask;
   if( Ask > 500) p = 1300; //FXCM 1 = 0.01 6.50 
   else p = Ask * 10000;
   double cost = p / level;
   //
   double amount = AccountFreeMargin() * amaxLossPercent;
   double optLots = MathCeil( amount /  maxLoss  ) ;
   
   if( optLots > maxLots) optLots = maxLots;
   //Print("maxLoss = ",maxLoss, "amount=",amount, "maxLots = ",maxLots, "optLos=",optLots);
   return(optLots);
}

double AddMaxLots(double aAddPercent)
{
   double maxLots = MarketInfo(Symbol(), MODE_MAXLOT);
   double p = Ask;
   if( Ask > 500) p = Ask / 1000;
   else p = Ask * 10000;
   double coef = 1;
   double curLots = symbolLots(OP_SELLSTOP);
   if( StringFind(TerminalName(), "FXCM") >= 0 && Ask > 500){
      coef = 0.01; //FXCM 1gold = 0.01 10 = 0.1 
   }
   else{
      if( StringFind(TerminalName(), "FOREX") >= 0 && Ask > 500){
         coef = 0.1; //Forex 1gold = 0.1 10 = 1 
      }
   }
   if( AccountEquity() > 5000){ ProtectPercent *= 2;}
   if( AccountEquity() > 10000){ ProtectPercent *= 4;}
   
   double amount = AccountFreeMargin() - curLots * coef * Ask * (1 + ProtectPercent);
   amount = amount*aAddPercent;
   /*
      if( TimeCurrent() - dt2 > 1500)
      {
         dt2 = TimeCurrent();
         double a = (1 + protectPercent) * Ask * 0.1;
         Print("free=",AccountFreeMargin(),"a=",a,"curLots=",curLots, "protectPercent=",protectPercent, "protectPercent=",protectPercent,"amount=",amount);
      }
     */
   if( amount < 0 || amount < (1 + ProtectPercent) * Ask * 0.1 ) return(0);
   double optLots = MathCeil( amount /  (p * 100)  ) / 10;
   if( optLots > maxLots) optLots = maxLots;

   return(optLots);
}
//=================================End of 仓位管理=======================================================
bool skiptime(string skiptime)
{
   bool action = false;
   int len = StringLen(skiptime);
   int d = 0;
   for(int j = 0; j < len; j+=11)
   {
      string s = StringSubstr(skiptime, j, 10);
      if( StringFind(TimeToStr(TimeCurrent(), TIME_DATE), s) == 0)
      {
         action = true;
         break;
      }
      if( StringFind(TerminalName(), "FOREX") >= 0){
      /*
         if (TimeHour(TimeCurrent()) < 8)  //对于Forex平台，比标准时间多8个小时，必须考虑进去
         {
            MqlDateTime strt;
            TimeToStruct(TimeCurrent(), strt);
            strt.day = strt.day - 1;
            string a = TimeToStr(StructToTime(strt), TIME_DATE);
            if( StringFind(a, s) == 0)
            {
               action = true;
               break;
            }
         }
        */
      }
   }

      /*debug
      if( TimeCurrent() - ptime2 > 360)
      {
         ptime2 = TimeCurrent();
         Print(TimeToStr(TimeCurrent(), TIME_DATE), skiptime1, "d=",d);
      }
      */
  if ( TimeDayOfWeek(TimeCurrent()) >= 5 && TimeDay(TimeCurrent()) > 1 && TimeDay(TimeCurrent()) < 9 )
  {
     //if (TimeHour(TimeCurrent()) >= 8 && TimeHour(TimeCurrent()) <= 18)  //limit the hours only
     {
         action = true;
     }
  }
  if (StringFind(TerminalName(), "FOREX") && TimeHour(TimeCurrent()) < 8 && TimeDayOfWeek(TimeCurrent()) <= 5)  //对于Forex平台，比标准时间多8个小时，必须考虑进去 
  {
      action = false;
  }
  if(action)
  {
      int totalOrders = OrdersTotal();
      for(int i=0;i<totalOrders;i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if( OrderSymbol()!=Symbol() ) continue;
         Print("*****************skip time close order ************************");
         //---- check order type 
         if( OrderType() <= OP_SELL) 
         {
            double price = Ask;
            if( OrderType() == OP_BUY) price = Bid;
            if( OrderClose(OrderTicket(),OrderLots(),price,50,White) != true)
            {
               Print("Close order ",OrderTicket(), "error:",ErrorDescription(GetLastError()));
            }
         }
         else
            if( OrderDelete(OrderTicket()) != true)
            {
               Print("Delete order",OrderTicket(), " error:",ErrorDescription(GetLastError()));
            }
        }
      return(true);
  }
  return(false);
}

double getPoint()
{
      double point=MarketInfo(Symbol(),MODE_POINT);
      if( point <= 0.0001) point = 0.0001;
      else point = 0.01;
      if( Ask > 500) point = 0.1;  //gold
      
      return(point);
}

//检查是否有在n根K线内平仓的单子,-1则直接返回最后一个单子
int getHistoryOrder(int mag, int aKFilter)
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
                      if( aKFilter == -1 ||  CurTime() - OrderCloseTime() < aKFilter * Period() * 60 ) return(OrderTicket());
                  }
               }
   }
   return(-1);
}

int checkHistoryOrder(int mag)
{
   int hstTotal=OrdersHistoryTotal();
   int i;
   int k = hstTotal-10;
   int ng = 0;
   int buy = 0;
   int sell = 0;
   if(k < 0) k = 0;
   for( i = hstTotal-1; i >= k; i--){
        if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)== true)
            if(OrderType()<=OP_SELL &&   // check for opened position 
               OrderSymbol()==Symbol())  // check for symbol
               {
                  if( (OrderMagicNumber()) == mag)
                  {
                      if( OrderProfit() > 10)
                      {  
                        break;
                      }
                      if( OrderType() == OP_BUY) buy++;
                      else sell++;
                      ng++;
                  }
               }
   }
   if( buy > sell)  return(ng);
   else return (-ng);
}

int getPreHistoryOrder(int mag, int t)
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
                      if(OrderTicket() == t){
                        Print("-------------------------i=",i,t);
                        if(OrderSelect(i-1,SELECT_BY_POS,MODE_HISTORY)== true)
                           return(OrderTicket());
                        return(-1);
                      }
                  }
               }
   }
   return(-1);
}
void OpenOrder(int op, double aLots, int aStopLoss, int aTakeProfit, int mag, string c="", int tkPercent=0, double tkLots = 0.1)
{
           double point = getPoint();
           double aprice, sl, tk;
           if( c == "") c = "myea openorder";
           int coef = 1;
           if( StringFind(TerminalName(), "FXCM") >= 0 && Ask > 500) coef = 100; //Lots = Lots * 100; 
           if( StringFind(TerminalName(), "FOREX") >= 0 && Ask > 500) coef = 10; //Lots = Lots * 100;
           double lot= NormalizeDouble( aLots*(1 + AccountEquity()/10000), 1);
           if( op == OP_BUY)
           {     
                  aprice = Ask;
                  if( aStopLoss > 0){
                     sl = Ask - aStopLoss * point;
                  }
                  else if (aStopLoss < 0){
                     sl = MathMin(Ask - MathAbs(aStopLoss) * point, Low[iLowest(NULL, 0, MODE_LOW, 4, 0)]);
                  }
                  else sl = 0;
                  if( aTakeProfit > 0){
                     tk = Ask + aTakeProfit * point;
                  }
                  else tk = 0;
                  RefreshRates();
                  if( tkPercent > 0)
                  {
                     double tk2 = 0;
                     double sl2 = 0;
                     if( aTakeProfit > 0){
                        tk2 = Ask + aTakeProfit / tkPercent * point;
                        sl2 = Ask - MathAbs(sl - Ask) / tkPercent ;
                     }
                     if(OrderSend(Symbol(), op, tkLots*coef, NormalizeDouble(Ask, Digits), 500, sl2, tk2, c+"buy2", mag-1) == -1)
                     { Print("myea Error = ",ErrorDescription(GetLastError()),"price1=",NormalizeDouble(Ask, Digits),"tk=",tk2,"sl=",sl2); }
                  }
                  
                  if(OrderSend(Symbol(), op, aLots*coef, NormalizeDouble(Ask, Digits), 500, sl, tk, c+"buy", mag) == -1)
                  { Print("myea Error = ",ErrorDescription(GetLastError()),"price2=",NormalizeDouble(Ask, Digits),"tk=",tk,"sl=",sl); }
           }
           if( op == OP_SELL)
           {
                  aprice = Bid;
                  if( aStopLoss > 0){
                     sl = Bid + aStopLoss * point;
                  }
                  else if (aStopLoss < 0){
                     sl = MathMax( Bid + MathAbs(aStopLoss) * point,High[iHighest(NULL, 0, MODE_HIGH, 4, 0)]);
                  }
                  else sl = 0;
                  if( aTakeProfit > 0) tk = Bid - aTakeProfit * point;
                  else tk = 0;
                  RefreshRates();
                  if( tkPercent > 0)
                  {
                     tk2 = 0;
                     if( aTakeProfit > 0){
                        tk2 = Bid - aTakeProfit / tkPercent * point;
                        sl2 = Bid + MathAbs(sl - Bid) / tkPercent;
                     }
                     if(OrderSend(Symbol(), op, tkLots*coef, NormalizeDouble(Bid, Digits), 500, sl2, tk2, c+"sell2", mag-1) == -1)
                     { Print("myea Error = ",ErrorDescription(GetLastError()),"price1=",NormalizeDouble(Ask, Digits),"tk=",tk2,"sl=",sl2); }
                  }
                  if(OrderSend(Symbol(), op, aLots*coef, NormalizeDouble(Bid, Digits), 500, sl, tk, c+"sell", mag) == -1)
                  { Print("myea Error = ",ErrorDescription(GetLastError()),"price2=",NormalizeDouble(Ask, Digits),"tk=",tk,"sl=",sl); }
           }
           //Print(c,"OpenOrder: point=",point,"Ask=",Ask,"lots=",aLots,"op",op,"price=",aprice,"sl=",sl,"tk=",tk);

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

int GetOrderA(int mag, int type)
{
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if( (mag != 0 && OrderMagicNumber()!= mag) || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if( OrderType() == type) return(OrderTicket());
     }
     return(-1);
}

void OpenReverseOrder(int ticket, int op, double aLots, int aStopLoss, int aTakeProfit, int mag, string c="")
{
      if( OrderSelect(ticket,SELECT_BY_TICKET, MODE_TRADES)==false )return;
      int coef = 1;
      if( StringFind(TerminalName(), "FXCM") >= 0 && Ask > 500) coef = 100; //Lots = Lots * 100; 
      if( StringFind(TerminalName(), "FOREX") >= 0 && Ask > 500) coef = 10; //Lots = Lots * 100;
      double lots = OrderLots()/coef;
      double opt = OrderProfit();
      int n;
      if( CurTime() - OrderOpenTime() < KFilter * Period() * 60) return;
      n = CloseOrder(ticket, op);
      
      if( n == 1 && opt < 0 && aLots > 0){
         lots = 2 * lots;
         double max = AddMaxLots(ProtectPercent);
         if( lots > max) lots = max;
      }
      else lots = MathAbs(aLots);
      
      //Print("====myea-OpenReverseOrder","==lots=",lots,"==n=",n,"==op=",op);
      if( n > 0 )
      {
         if( lots == 0) lots = 0.1;
         OpenOrder(op, lots, aStopLoss, aTakeProfit, mag, c);
       }
}

void CloseOrder2(int mag, int op)
{
   bool done = false;
   Print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxClose all for ",mag);
   while( !done)
   {
        done = true; 
        RefreshRates();
      for(int i=0;i<OrdersTotal();i++)
     {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if( (mag != 0 && OrderMagicNumber()!= mag) || OrderSymbol()!=Symbol()) continue;
            if( OrderType() == op || op == 4)
            {
               double p = Bid;
               if( OrderType() == OP_SELL) p = Ask;
               int t = OrderTicket();
               if( OrderClose(t, OrderLots(),p,50,White) != true)
               {
                  int e = GetLastError();
                  Print("Close2 order ",t, " error:",ErrorDescription(e));
                  if( e == 138) Sleep(5000);
               }
               done = false;
               Sleep(2000);
             }  
     }    
     Sleep(1000);   
    }
}

int CloseOrder(int ticket, int op)
{
      int nClosed = 0;
      if( OrderSelect(ticket,SELECT_BY_TICKET, MODE_TRADES)==false )return(false);
      int mag = OrderMagicNumber();
      if(OrderType()==OP_BUY && op == OP_SELL)
        {
         if( OrderClose(OrderTicket(),OrderLots(),Bid,50,White) != true)
         {
            Print("Close order error:",ErrorDescription(GetLastError()));
         }
         Sleep(2000);
         nClosed++;
         int t = GetOrder(mag, OP_SELL);
         while( t >= 0)
         {
            if( OrderClose(OrderTicket(),OrderLots(),Bid,50,White) != true)
            {
               int e = GetLastError();
               Print("Close order ",t, " error:",ErrorDescription(e));
               if( e == 138) return(nClosed);
            }
            Sleep(2000);
             nClosed++;
             t = GetOrder(mag, OP_SELL);
         }
         
         return(nClosed);
        }
      if(OrderType()==OP_SELL && op == OP_BUY)
        {

         if( OrderClose(OrderTicket(),OrderLots(),Ask,50,White) != true)
         {
               e = GetLastError();
               Print("Close order ",t, " error:",ErrorDescription(e));
               if( e == 138) return(nClosed);
         }
         Sleep(2000);
         nClosed++;
         t = GetOrder(mag, OP_SELL);
         while( t >= 0)
         {
            if( OrderClose(OrderTicket(),OrderLots(),Ask,50,White) != true)
            {
               e = GetLastError();
               Print("Close order ",t, " error:",ErrorDescription(e));
               if( e == 138) return(nClosed);
            }
            Sleep(2000);
             nClosed++;
             t = GetOrder(mag, OP_SELL);
         }
         return(nClosed);
        }
      return(nClosed);
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

int checkProfitOrders(int mag)
{
   int totalOKOrders = 0;
   int totalNGOrders = 0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if( (mag != 0 && OrderMagicNumber()!= mag) || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if( OrderTakeProfit() > 0) totalOKOrders++;
      else totalNGOrders++;
     }
     if( totalOKOrders >= totalNGOrders)
      return True;
     return False;
}

double getOrderProfit(int mag, int otype)
{
   double totalprofit = 0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if( (mag != 0 && OrderMagicNumber()!= mag) || OrderSymbol()!=Symbol() || OrderType()!= otype) continue;
      //---- check order type 
      totalprofit += OrderProfit();
     }
     return totalprofit;
}

int GetTotalOrdersA(int mag, int type)
{
   int totalOrders = 0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if( (mag != 0 && OrderMagicNumber()!= mag) || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if( OrderType() == type) totalOrders++;
     }
     return(totalOrders);
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

double symbolLots(int maxType)
{
   double lots = 0;
   for(int i = 0; i < OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if( OrderSymbol() != Symbol() || OrderType() > maxType) continue;
      lots += OrderLots();
   }
   return(lots);
}

double getOrderPoint()
{
      double point=MarketInfo(OrderSymbol(),MODE_POINT);
      if( point <= 0.0001) point = 0.0001;
      else point = 0.01;
      if( OrderOpenPrice() > 500) point = 0.1;  //gold
      return(point);
}

int GetLastOrder(int mag, int maxType)
{
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if( (mag != 0 && OrderMagicNumber()!= mag) || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if( OrderType() <= maxType) return(OrderTicket());
     }
     return(-1);
}

void AddOrder2(int mag, double aAddRate, int aTakeProfit, double rate, double limit, string c="", double addPercent=0.2, double thirdlots = 0)
{
   int t, total;
   double m = MarketInfo(Symbol(), MODE_MAXLOT);
   total = GetTotalOrders(mag, OP_SELL);
   if( total == 0 || total >= 3) return;
   double lots = AddMaxLots(addPercent);
   if( lots <= 0) return;
   double coef = 10;
   if( StringFind(TerminalName(), "FXCM") >= 0 && Ask > 500){
      coef = 0.1; //FXCM 1gold = 0.01 10 = 0.1 
      lots *= 100;
   }
   else{
      if( StringFind(TerminalName(), "FOREX") >= 0 && Ask > 500){
         coef = 1; //FXCM 1gold = 0.01 10 = 0.1 
         lots *= 10;
      }
   }
   if( c== "") c = "Add ";
   t = GetOrder(mag, OP_SELL);
   double tk = OrderTakeProfit();
   double point = getOrderPoint(); 
   //Print("=====coef=",coef,"==OrderLots==",OrderLots(),"====",OrderProfit() / (OrderLots() * coef),"=====",aAddRate * aTakeProfit);
   { 
   if( total < 2)  // 第一次加仓
   {
      RefreshRates();
      if( OrderSelect(t, SELECT_BY_TICKET, MODE_TRADES) == FALSE){
       Print("AddOrder2 failed0: ",ErrorDescription(ErrorDescription(GetLastError())));
       return;
      }
      /*
      if( TimeCurrent() - dt2 > 600)
      {
         dt2 = TimeCurrent();
         Print("*************debug: open=",OrderOpenPrice(),"ask=",Ask,"bid=",Bid,"orderprofit=",OrderProfit(),"profit=",OrderProfit() / (OrderLots() * coef));
      }
      */
      if(OrderProfit() / (OrderLots() * coef) > aAddRate * aTakeProfit && OrderProfit() / (OrderLots() * coef) < (aAddRate+limit) * aTakeProfit )
      {
            if( OrderSelect(t, SELECT_BY_TICKET, MODE_TRADES) == FALSE){
             Print("AddOrder2 failed0: ",ErrorDescription(ErrorDescription(GetLastError())));
             return;
            }
            Print(c, "Add2原单[",t,"][",OrderTicket(),"]:OrderType=",OrderType(),"OrderProfit=",OrderProfit(), "-",aAddRate,"-",lots,"-",mag);
            //Print("xxodstoploss",OrderStopLoss(),"xxodopenprice",OrderOpenPrice(),"xx",Ask - OrderOpenPrice(),"++Ask=",Ask,"++rate=",rate,"++",aTakeProfit,"++",point,"++",Ask-(rate*aTakeProfit*point));
            if( OrderType() == OP_BUY) 
            {
               if( OrderSend(Symbol(),OP_BUY,lots, NormalizeDouble(Ask,Digits),50,NormalizeDouble(OrderStopLoss(),Digits), tk,c+"buy",mag,0,Blue) == -1)
               { Print("Send order error: ", ErrorDescription(GetLastError()));
               }
            }
            else{
               if(  OrderSend(Symbol(),OP_SELL,lots,NormalizeDouble(Bid,Digits),50,NormalizeDouble(OrderStopLoss(),Digits),tk,c+"sell",mag,0,Red) == -1)
                           { Print("Send order error: ", ErrorDescription(GetLastError()));
                           }
            }
            Sleep(10000);
      }
    }
    else
    {
      if( thirdlots > 0)
      {
         if( getHistoryOrder(mag, KFilter) > 0) return;
         RefreshRates();
         if( OrderSelect(t, SELECT_BY_TICKET, MODE_TRADES) == FALSE){
          Print("AddOrder2 failed2: ",ErrorDescription(ErrorDescription(GetLastError())));
          return;
         }
         if(OrderProfit() / (OrderLots() * coef) > aAddRate * aTakeProfit && OrderProfit() / (OrderLots() * coef) < (aAddRate+limit) * aTakeProfit )
         {
               int t2 = GetLastOrder(mag, OP_SELL);
               double newlots = lots * thirdlots;
               if( newlots > 0 && newlots + symbolLots(OP_SELL)  < m)
               {
                  if( OrderSelect(t, SELECT_BY_TICKET, MODE_TRADES) == FALSE){
                     Print("AddOrder2 failed3: ",ErrorDescription(ErrorDescription(GetLastError())));
                     return;
                  }
                  double sl = OrderOpenPrice();  //the first order open price as stoploss
                  Print(c, "Add2-2原单[",t,"][",OrderTicket(),"]op=",OrderType(),"ask=",Ask,"bid=",Bid,"-",aAddRate,"lots=",newlots,"-",mag);
                  if( OrderType() == OP_BUY)
                  {
                     if(OrderSend(Symbol(),OP_BUY,newlots, Ask,0,sl-5*Point, tk,c+"2nd add buy",mag,0,Blue) == -1)
                              { Print("Send order error: ", ErrorDescription(GetLastError()));
                              }
                  }else
                  {
                      if( OrderSend(Symbol(),OP_SELL,newlots,Bid,0,sl+5*Point,tk,c+"2nd add sell",mag,0,Red) == -1)
                              { Print("Send order error: ", ErrorDescription(GetLastError()));
                              }
                  }
                }
               Sleep(10000);
          }
      }
    }
  } 
}

void AddOrder3(int mag, double aAddRate, int aTakeProfit, double rate, double limit, string c="", double addPercent=0.2, double thirdlots = 0)
{
   //Print("===================--------------------");
   int t;
   double m = MarketInfo(Symbol(), MODE_MAXLOT);
   double lots = AddMaxLots(addPercent);
   //if( lots <= 0) return;
   double coef = 10;
   if( StringFind(TerminalName(), "FXCM") >= 0 && Ask > 500){
      coef = 0.1; //FXCM 1gold = 0.01 10 = 0.1 
      lots *= 100;
   }
   else{
      if( StringFind(TerminalName(), "FOREX") >= 0 && Ask > 500){
         coef = 1; //FXCM 1gold = 0.01 10 = 0.1 
         lots *= 10;
      }
   }
   if( c== "") c = "Add ";
   t = GetOrder(mag, OP_SELL);
   if( t == -1) return;
   double tk = OrderTakeProfit();
   double point = getOrderPoint(); 
   if( OrderLots() > 0) Print("=====thirdLots=",thirdlots,"==OrderLots==",OrderLots(),"atK=",aTakeProfit,"====",OrderProfit() / (OrderLots() * coef),"=====",aAddRate * aTakeProfit,"=====", (aAddRate+limit) * aTakeProfit);
      if( thirdlots > 0)
      {
         if( getHistoryOrder(mag, KFilter) > 0) return;
         RefreshRates();
         if( OrderSelect(t, SELECT_BY_TICKET, MODE_TRADES) == FALSE){
          Print("AddOrder3 failed2: ",ErrorDescription(ErrorDescription(GetLastError())));
          return;
         }
         if(OrderProfit() / (OrderLots() * coef) > aAddRate * aTakeProfit && OrderProfit() / (OrderLots() * coef) < (aAddRate+limit) * aTakeProfit )
         {
               int t2 = GetLastOrder(mag, OP_SELL);
               double newlots = lots * thirdlots;
               Print("==========newlots=",newlots);
               if( newlots > 0 && newlots + symbolLots(OP_SELL)  < m)
               {
                  if( OrderSelect(t, SELECT_BY_TICKET, MODE_TRADES) == FALSE){
                     Print("AddOrder3 failed3: ",ErrorDescription(ErrorDescription(GetLastError())));
                     return;
                  }
                  double sl = OrderOpenPrice();  //the first order open price as stoploss
                  Print(c, "Add3原单[",t,"][",OrderTicket(),"]op=",OrderType(),"ask=",Ask,"bid=",Bid,"-",aAddRate,"lots=",newlots,"-",mag);
                  if( OrderType() == OP_BUY)
                  {
                     if(OrderSend(Symbol(),OP_BUY,newlots, Ask,0,sl-5*Point, tk,c+"2nd add buy",mag,0,Blue) == -1)
                              { Print("Send order error: ", ErrorDescription(GetLastError()));
                              }
                  }else
                  {
                      if( OrderSend(Symbol(),OP_SELL,newlots,Bid,0,sl+5*Point,tk,c+"2nd add sell",mag,0,Red) == -1)
                              { Print("Send order error: ", ErrorDescription(GetLastError()));
                              }
                  }
                }
               Sleep(10000);
          }
      }
}
void ClosePendingOrder(int mag, bool force=false)
{
   int t = GetOrder(mag, OP_SELL);
   if( force == false && t >= 0) return;
   
   int at[100];
   int k = 0;
   bool done = false;
   while( !done)
   {
   done = true;
   for( int i = 0; i < OrdersTotal(); i++)
   {
      if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false )return;
      double point = getOrderPoint();
      //if( TimeCurrent() - pc > 360)
      //{
         //pc = TimeCurrent();
         //Print("========xxxxxxxticket=",OrderTicket(),"mag=",OrderMagicNumber(),"type=",OrderType(),"sym=",OrderSymbol(),"point=",point);
      //}
      if(OrderType()<= OP_SELL || OrderSymbol() != Symbol() || OrderMagicNumber() != mag ) continue;
      if( MathAbs( OrderOpenPrice() - Ask ) / point > 20)  //保留了价格接近的挂单
      {
            //Print("=====t=",t,"====",mag, "----", OrdersTotal(), "--",OrderTicket());
            if(OrderDelete(OrderTicket())!=true)
            {
               Print("Delete order error:",ErrorDescription(GetLastError()));
            }
            done = false;
            break;
      }
   }
   }
}

// the end.