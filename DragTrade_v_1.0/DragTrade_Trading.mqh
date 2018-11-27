/* =============================================================================================== */
/* Copyright (c) 2010 Andrey Nikolaevich Trukhanovich (aka TheXpert)                                  */
/*                                                                                                 */
/* Permission is hereby granted, free of charge, to any person obtaining a copy of this software           */
/* and associated documentation files (the "Software"),   */
/* to deal in the Software without restriction, including without limitation the rights           */
/* to use, copy, modify, merge, publish, distribute,                 */
/* sublicense, and/or sell copies of the Software, and to permit persons              */
/* to whom the Software is furnished to do so, subject to the following conditions:       */
/*                                                                                                 */
/*                                                                                                 */
/* The above copyright notice and this permission notice shall be included in all copies or substantial         */
/* portions of the Software.                                                         */
/*                                                                                                 */
/* THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS       */
/* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   */
/* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR     */
/* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       */
/* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR    */
/* IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER      */
/* DEALINGS IN THE SOFTWARE.                                                          */
/* =============================================================================================== */

//+------------------------------------------------------------------+
//|                                                      Trading.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, TheXpert"
#property link      "theforexpert@gmail.com"

#include <DragTrade_v_1.0/DragTrade_Logical.mqh>

void WaitForContext()
{
   while (IsTradeContextBusy())
   {
      Sleep(20);
   }
}

int OpenBuy(int MN, int Target, int Loss, double Lot, string comment = "")
{
   if (MN == -1) MN = 0;
   
   int err;
   int count = 0;
   while (count < TimesToRepeat)
   {
      WaitForContext();
      RefreshRates();
   
      double TP = DoubleIf(Target > 0, Ask + Target*Point, 0);
      double SL = DoubleIf(Loss > 0, Ask - Loss*Point, 0);
   
      double LotsToBid = DoubleIf(Lot == 0, GetLotsToBid(RiskPercentage), Lot);
   
      int res = OrderSend(Symbol(), OP_BUY, LotsToBid, Ask, Slippage, SL, TP, comment, MN, 0, Blue);
      
      if (res > 0) return (res);
      err = GetLastError();
      if (!NeedToRetry(err)) return (-err);

      count++;
   }
   return (-err);
}

int OpenSell(int MN, int Target, int Loss, double Lot, string comment = "")
{
   if (MN == -1) MN = 0;

   int err;
   int count = 0;
   while (count < TimesToRepeat)
   {
      WaitForContext();
      RefreshRates();
   
      double TP = DoubleIf(Target > 0, Bid - Target*Point, 0);
      double SL = DoubleIf(Loss > 0, Bid + Loss*Point, 0);
   
      double LotsToBid = DoubleIf(Lot == 0, GetLotsToBid(RiskPercentage), Lot);
   
      int res = OrderSend(Symbol(), OP_SELL, LotsToBid, Bid, Slippage, SL, TP, comment, MN, 0, Red);
      
      if (res > 0) return (res);
      err = GetLastError();
      if (!NeedToRetry(err)) return (-err);

      count++;
   }
   return (-err);
}

int OpenBuyStop(int MN, double Price, int Target, int Loss, double Lot, string comment = "")
{
   if (MN == -1) MN = 0;

   double TP = DoubleIf(Target > 0, Price + Target*Point, 0);
   double SL = DoubleIf(Loss > 0, Price - Loss*Point, 0);
   
   double LotsToBid = DoubleIf(Lot == 0, GetLotsToBid(RiskPercentage), Lot);
   
   WaitForContext();
   
   int res = OrderSend(Symbol(), OP_BUYSTOP, LotsToBid, Price, Slippage, SL, TP, comment, MN, 0, Blue);
   
   if (res > 0) return (res);
   return (-GetLastError());
}

int OpenSellStop(int MN, double Price, int Target, int Loss, double Lot, string comment = "")
{
   if (MN == -1) MN = 0;

   double TP = DoubleIf(Target > 0, Price - Target*Point, 0);
   double SL = DoubleIf(Loss > 0, Price + Loss*Point, 0);
   
   double LotsToBid = DoubleIf(Lot == 0, GetLotsToBid(RiskPercentage), Lot);
   
   WaitForContext();
   
   int res = OrderSend(Symbol(), OP_SELLSTOP, LotsToBid, Price, Slippage, SL, TP, comment, MN, 0, Red);

   if (res > 0) return (res);
   return (-GetLastError());
}

int OpenBuyLimit(int MN, double Price, int Target, int Loss, double Lot, string comment = "")
{
   if (MN == -1) MN = 0;

   double TP = DoubleIf(Target > 0, Price + Target*Point, 0);
   double SL = DoubleIf(Loss > 0, Price - Loss*Point, 0);
   
   double LotsToBid = DoubleIf(Lot == 0, GetLotsToBid(RiskPercentage), Lot);
   
   WaitForContext();
   
   int res = OrderSend(Symbol(), OP_BUYLIMIT, LotsToBid, Price, Slippage, SL, TP, comment, MN, 0, Blue);
   
   if (res > 0) return (res);
   return (-GetLastError());
}

int OpenSellLimit(int MN, double Price, int Target, int Loss, double Lot, string comment = "")
{
   if (MN == -1) MN = 0;

   double TP = DoubleIf(Target > 0, Price - Target*Point, 0);
   double SL = DoubleIf(Loss > 0, Price + Loss*Point, 0);
   
   double LotsToBid = DoubleIf(Lot == 0, GetLotsToBid(RiskPercentage), Lot);
   
   WaitForContext();
   
   int res = OrderSend(Symbol(), OP_SELLLIMIT, LotsToBid, Price, Slippage, SL, TP, comment, MN, 0, Red);

   if (res > 0) return (res);
   return (-GetLastError());
}

double GetLotsToBid(double RiskPercentage)
{
   if (RiskPercentage < 0) RiskPercentage = 0;
   
   double margin  = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   double minLot  = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot  = MarketInfo(Symbol(), MODE_MAXLOT);
   double step    = MarketInfo(Symbol(), MODE_LOTSTEP);
   double account = AccountEquity();
   
   double percentage = account*RiskPercentage/100;
   
   if (margin*step == 0) return(minLot);
   double lots = MathRound(percentage/margin/step)*step;
   
   if(lots < minLot)
   {
      lots = minLot;
   }
   
   if(lots > maxLot)
   {
      lots = maxLot;
   }

   return (lots);
}

bool NeedToRetry(int errorCode)
{
   switch (errorCode)
   {
      case 1   : return (true);
      case 129 : return (true);
      case 135 : return (true);
      case 136 : return (true);
      case 138 : return (true);
      
      default: return (false);
   }
}

int GetOrdersCount(int MagicNumber = -1, int Type = -1, string symb = "")
{
   int count = 0;
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      // already closed
      if(OrderSelect(i, SELECT_BY_POS) == false) continue;
      // not current symbol
      if(OrderSymbol() != Symbol() && symb == "") continue;
      // not specified symbol
      if(OrderSymbol() != symb && symb != "" && symb != "all") continue;
      // order was opened in another way
      if(OrderMagicNumber() != MagicNumber && MagicNumber != -1) continue;
      
      if(OrderType() == Type || Type == -1)
      {
         count++;
      }
   }
   
   return (count);
}

double GetLotsCount(int MagicNumber = -1, int Type = -1, string symb = "")
{
   double count = 0;
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      // already closed
      if(OrderSelect(i, SELECT_BY_POS) == false) continue;
      // not current symbol
      if(OrderSymbol() != Symbol() && symb == "") continue;
      // not specified symbol
      if(OrderSymbol() != symb && symb != "" && symb != "all") continue;
      // order was opened in another way
      if(OrderMagicNumber() != MagicNumber && MagicNumber != -1) continue;
      
      if(OrderType() == Type || Type == -1)
      {
         count += OrderLots();
      }
   }
   
   return (count);
}

double GetProfitCount(int MagicNumber = -1, int Type = -1, string symb = "")
{
   double count = 0;
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      // already closed
      if(OrderSelect(i, SELECT_BY_POS) == false) continue;
      // not current symbol
      if(OrderSymbol() != Symbol() && symb == "") continue;
      // not specified symbol
      if(OrderSymbol() != symb && symb != "" && symb != "all") continue;
      // order was opened in another way
      if(OrderMagicNumber() != MagicNumber && MagicNumber != -1) continue;
      
      if(OrderType() == Type || Type == -1)
      {
         count += OrderProfit();
      }
   }
   
   return (count);
}

void CloseSells(int MagicNumber, int Slippage)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      // already closed
      if(OrderSelect(i, SELECT_BY_POS) == false) continue;
      // not current symbol
      if(OrderSymbol() != Symbol()) continue;
      // order was opened in another way
      if(OrderMagicNumber() != MagicNumber && MagicNumber != -1) continue;
      
      if(OrderType() == OP_SELL)
      {
         int count = 0;
         while (count < TimesToRepeat)
         {
            WaitForContext();
         
            RefreshRates();
            if (OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, Red))
            {
               break;
            }
            
            if (!NeedToRetry(GetLastError())) break;
            count++;
         }
      }
   }
}

void CloseBuys(int MagicNumber, int Slippage)
{
   for(int i = OrdersTotal(); i >= 0; i--)
   {
      // already closed
      if(OrderSelect(i, SELECT_BY_POS) == false) continue;
      // not current symbol
      if(OrderSymbol() != Symbol()) continue;
      // order was opened in another way
      if(OrderMagicNumber() != MagicNumber && MagicNumber != -1) continue;
      
      if(OrderType() == OP_BUY)
      {
         int count = 0;
         while (count < TimesToRepeat)
         {
            WaitForContext();
         
            RefreshRates();
            if (OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, Blue))
            {
               break;
            }

            if (!NeedToRetry(GetLastError())) break;
            count++;
         }
      }
   }
}

void DeletePending(int MagicNumber = -1)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      // already closed
      if(OrderSelect(i, SELECT_BY_POS) == false) continue;
      // not current symbol
      if(OrderSymbol() != Symbol()) continue;
      // order was opened in another way
      if(OrderMagicNumber() != MagicNumber && MagicNumber != -1) continue;
      
      if(OrderType() != OP_SELL && OrderType() != OP_BUY)
      {
         WaitForContext();
         
         OrderDelete(OrderTicket());
      }
   }
}