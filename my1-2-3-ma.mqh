
// -----------------------------------------------------------------------------------------------------------------------------    
/////////////////////////////////////////////////////////////////////|
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//------
//must be global to use continually
int debugStop = 0;

void bollerTrade(int mag)
{
   if( BollerTrade >= 0)
   {
      double sl, tp,newtp;
      double lots = Lots;
      int n;
       double bPrice = iBands(Symbol(),0,Band,2,0,PRICE_CLOSE,MODE_LOWER,0);
       if( UseMidAsUporDown == 0) bPrice = iBands(Symbol(),0,Band,2,0,PRICE_CLOSE,MODE_MAIN,0);
       double sPrice = iBands(Symbol(),0,Band,2,0,PRICE_CLOSE,MODE_UPPER,0);
       if( UseMidAsUporDown == 1) sPrice = iBands(Symbol(),0,Band,2,0,PRICE_CLOSE,MODE_MAIN,0);
       double buyPrice = NormalizeDouble(bPrice + StepUpper*getPoint(), Digits);
       double sellPrice = NormalizeDouble(sPrice - StepLower*getPoint(), Digits);

       if( BollerTrade == 0 || BollerTrade == 2){
      //挂单在下轨买入，止盈上轨，止损用参数
       sl = NormalizeDouble(buyPrice - Boller_StopLoss*getPoint(), Digits);
       tp = NormalizeDouble(sellPrice,Digits);
       //没有买单，下挂单
       n = GetTotalOrders2(mag+Period(), OP_BUY );
       if( n <= 0)
       {
         OpenDoubleOrder(OP_BUYLIMIT, lots, buyPrice, sl, tp, mag+Period(), version, Blue);
       }
       else{
       //已经有买单且价格变化很大，修改价格到最新的上下轨
           int needModify = false;
           Print( "Total orders=",n, " Booler-BuyOrderPrice=",MathAbs( buyPrice - OrderOpenPrice()),"/", PriceChange*getPoint() ," Boller-CurrentPrice=",MathAbs( buyPrice - (Ask+Bid)/2));
           for( int k = 0; k < n; k++)
           {
              Print("Check order ",glbOrderTicket[k], " Order Type=", ss[OrderType()]);
              Print("=DEBUG ",glbOrderTicket[k]," buyPrice= ", buyPrice," OrderOpenPrice=",OrderOpenPrice()," orderprofit=",OrderTakeProfit(), " gap=",PriceChange * getPoint(), " SL= ", sl, " TP= ", tp, "newtp=", newtp);

              if( OrderSelect(glbOrderTicket[k], SELECT_BY_TICKET, MODE_TRADES) == false) break;
              if( OrderType() != OP_BUYLIMIT && OrderType() != OP_BUY) continue;
           
              if( MathAbs(OrderOpenPrice() - buyPrice) >= PriceChange * getPoint() || MathAbs(OrderTakeProfit() - tp) >= PriceChange * getPoint() )
              {
                  needModify = true;
                 
                  newtp = tp;
                  if( OrderType() == OP_BUY ) sl = OrderStopLoss();
                  if( OrderType() == OP_BUYLIMIT && MathAbs(OrderTakeProfit() - tp) >= 3*PriceChange * getPoint()) newtp = OrderTakeProfit() + PriceChange * getPoint();
                  if(OrderModify(glbOrderTicket[k], buyPrice, sl, newtp, 0, Green) == false)
                      Print("Err (", GetLastError(), ") Modify Buy Price= ", buyPrice, " SL= ", sl, " TP= ", tp, "newtp=", newtp);
                  /********************
                  
                  debugStop = 1;
                  
                  ************************/
              }
             
           }
           if( needModify){
               n = GetTotalOrders2(mag+Period()+1, OP_SELL );
               for( k = 0; k < n; k++)
               {
                  if( OrderSelect(glbOrderTicket[k], SELECT_BY_TICKET, MODE_TRADES) == false) break;
                  if( OrderType() != OP_BUYLIMIT && OrderType() != OP_BUY) continue;
                  newtp = tp;
                  if( OrderType() == OP_BUY ) sl = OrderStopLoss();
                  if( OrderType() == OP_BUYLIMIT && MathAbs(OrderTakeProfit() - tp) >= 3*PriceChange * getPoint()) newtp = OrderTakeProfit() + PriceChange * getPoint();
                  if(OrderModify(glbOrderTicket[k], buyPrice, sl, NormalizeDouble(newtp+1*(newtp-buyPrice),Digits), 0, Green) == false)
                      Print("Err (", GetLastError(), ") Modify Buy Price= ", buyPrice, " SL= ", sl, " TP= ", tp, "newtp=", newtp);
              }
             
           }
         }
      } 
      if( BollerTrade == 1 || BollerTrade == 2){
      //挂单在上轨卖出，止盈下轨，止损用参数
       sl = NormalizeDouble(sellPrice + Boller_StopLoss*getPoint(),Digits);
       tp = NormalizeDouble(buyPrice,Digits);
       //没有卖单，下挂单
       n = GetTotalOrders2(mag+Period(), OP_SELL);
       if( n <=  0 )
       {
         OpenDoubleOrder(OP_SELLLIMIT, lots, sellPrice, sl, tp, mag+Period(), version, Red);
       }
       //已经有卖单且价格变化很大，修改价格到最新的上下轨
       else{
           needModify = false;
           Print( "Total orders=",n, " Booler-SellOrderPrice=",MathAbs( sellPrice - OrderOpenPrice())," Booler-CurrentPrice=",MathAbs( sellPrice - (Ask+Bid)/2));
           for( k = 0; k < n; k++)
           {
                Print("Check order ",glbOrderTicket[k], " Order Type=", ss[OrderType()]);
               if( OrderSelect(glbOrderTicket[k], SELECT_BY_TICKET, MODE_TRADES) == false) break;
               if( OrderType() != OP_SELLLIMIT && OrderType() != OP_SELL) continue;
               if((OrderType() == OP_SELLLIMIT &&MathAbs(OrderOpenPrice() - sellPrice) >= PriceChange * getPoint()) || (MathAbs(OrderTakeProfit() - tp) >= PriceChange * getPoint() && MathAbs(OrderTakeProfit() - tp) < 3*PriceChange*getPoint()) )
               {
                   needModify = true;
                   newtp = tp;
                   if( OrderType() == OP_SELL ) sl = OrderStopLoss();
                   if( OrderType() == OP_SELLLIMIT && MathAbs(OrderTakeProfit() - tp) >= 3*PriceChange * getPoint()) newtp = OrderTakeProfit();
                   if(OrderModify(glbOrderTicket[k], sellPrice, sl, newtp, 0, Red) == false)
                       Print("Err (", GetLastError(), ") Modify Sell Price= ", sellPrice, " SL= ", sl, " TP= ", tp, "newtp=", newtp);

               }
           }
           if( needModify){
               n = GetTotalOrders(mag+Period()+1, OP_SELLSTOP );
               for( k = 0; k < n; k++)
              {
                  if( OrderSelect(glbOrderTicket[k], SELECT_BY_TICKET, MODE_TRADES) == false) break;
                  if( OrderType() != OP_SELLLIMIT && OrderType() != OP_SELL) continue;
                      newtp = tp;
                      if( OrderType() == OP_SELL ) sl = OrderStopLoss();
                      if( OrderType() == OP_SELLLIMIT && MathAbs(OrderTakeProfit() - tp) >= 3*PriceChange * getPoint()) newtp = OrderTakeProfit();
                      if(OrderModify(glbOrderTicket[k], sellPrice, sl, NormalizeDouble(newtp+1*(newtp-sellPrice),Digits), 0, Red) == false)
                          Print("Err (", GetLastError(), ") Modify Sell Price= ", sellPrice, " SL= ", sl, " TP= ", tp, "newtp=", newtp);

              }
           }
       }
     }
   }
   else
      ClosePendingOrder(mag);
}

void OpenDoubleOrder(int op, double aLots, double aprice, double aStopLoss, double aTakeProfit, int mag, string c="", int inc=1, int clr=Blue)
{
           double point = getPoint();
           if( c == "") c = "bollinger trader open order";
           RefreshRates();
           double onelot = 1;
           if( aLots >= 4) onelot = 2;
           if( Ask < 500){
             onelot *= 0.1;  //AUD
             aLots *= 0.1;
           }
           double lot = 0;
           int    factor = 0;  //one long, one short
           int    n = 0;
           if( op == 0 || op == 2)
                     n = GetTotalOrders(mag+1, OP_BUY );
           else
                    n = GetTotalOrders(mag+1, OP_SELL );
           int newmag = mag;     
           while( lot < aLots - n)
           {
                  if(OrderSend(Symbol(), op, onelot, NormalizeDouble(aprice, Digits), 500, NormalizeDouble(aStopLoss,Digits), NormalizeDouble(aTakeProfit+factor*(aTakeProfit-aprice),Digits), c, newmag, 0, clr) == -1)
                  { 
                     string e = ErrorDescription(GetLastError());
                     Print("aStopLoss=",aStopLoss," myea Error = ",e); 
                  }
                  Sleep(1000);
                  lot += onelot;
                  if(inc > 0){
                      factor = 1 - factor;
                      newmag = mag + factor;
                  }
           }
           Print("OpenOrder total:",(aLots - n),"n=",n,"onelot=",onelot,"==",aprice,"=lots=",aLots,"==op==",op,"=sl=",aStopLoss,"==tk",aTakeProfit);

}
