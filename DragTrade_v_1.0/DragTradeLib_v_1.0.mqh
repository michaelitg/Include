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
//|                                           DragTradeLib_v_071.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, TheXpert"
#property link      "theforexpert@gmail.com"

#import "DragTradeLib_v_1.0.ex4"
   void DragTrade_Init(int magic, int eaMagic, int timesToRepeat, int slippage, string ordersComment = "");
   void DragTrade_Start();
   void DragTrade_Deinit();
   
   void Comment_(string comment);
   
   int OpenBuy(int MN, int Target, int Loss, double Lot, string comment = "");
   int OpenSell(int MN, int Target, int Loss, double Lot, string comment = "");

   void CloseSells(int MagicNumber, int Slippage);
   void CloseBuys(int MagicNumber, int Slippage);

   int OpenBuyStop(int MN, double Price, int Target, int Loss, double Lot, string comment = "");
   int OpenSellStop(int MN, double Price, int Target, int Loss, double Lot, string comment = "");

   int OpenBuyLimit(int MN, double Price, int Target, int Loss, double Lot, string comment = "");
   int OpenSellLimit(int MN, double Price, int Target, int Loss, double Lot, string comment = "");

   void DeletePending(int MagicNumber = -1);

   double GetLotsToBid(double RiskPercentage);
   int GetOrdersCount(int MagicNumber = -1, int Type = -1, string symb = "");
   double GetLotsCount(int MagicNumber = -1, int Type = -1, string symb = "");
   
#import

int DT_OpenBuy(int MN, int Target, int Loss, double Lot, string comment = "")
{
   return (OpenBuy(MN, Target, Loss, Lot, comment));
}

int DT_OpenSell(int MN, int Target, int Loss, double Lot, string comment = "")
{
   return (OpenSell(MN, Target, Loss, Lot, comment));
}

void DT_CloseSells(int MagicNumber, int Slippage)
{
   CloseSells(MagicNumber, Slippage);
}

void DT_CloseBuys(int MagicNumber, int Slippage)
{
   CloseBuys(MagicNumber, Slippage);
}

int DT_OpenBuyStop(int MN, double Price, int Target, int Loss, double Lot, string comment = "")
{
   return (OpenBuyStop(MN, Price, Target, Loss, Lot, comment));
}

int DT_OpenSellStop(int MN, double Price, int Target, int Loss, double Lot, string comment = "")
{
   return (OpenSellStop(MN, Price, Target, Loss, Lot, comment));
}

int DT_OpenBuyLimit(int MN, double Price, int Target, int Loss, double Lot, string comment = "")
{
   return (OpenBuyLimit(MN, Price, Target, Loss, Lot, comment));
}

int DT_OpenSellLimit(int MN, double Price, int Target, int Loss, double Lot, string comment = "")
{
   return (OpenSellLimit(MN, Price, Target, Loss, Lot, comment));
}

void DT_DeletePending(int MagicNumber = -1)
{
   DeletePending(MagicNumber);
}

double DT_GetLotsToBid(double RiskPercentage)
{
   return (GetLotsToBid(RiskPercentage));
}

int DT_GetOrdersCount(int MagicNumber = -1, int Type = -1, string symb = "")
{
   return (GetOrdersCount(MagicNumber, Type, symb));
}

double DT_GetLotsCount(int MagicNumber = -1, int Type = -1, string symb = "")
{
   return (GetLotsCount(MagicNumber, Type, symb));
}