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
//|                                     DragTrade_Identification.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, TheXpert"
#property link      "theforexpert@gmail.com"

#include <DragTrade_v_1.0/DragTrade_Common.mqh>

string Symbol_()
{
   static string result;
   if (StringLen(result) == 0) result = StringSubstr(Symbol() + "_________", 0, 9);
   
   return (result);
}

string ToolbarName()
{
   static string name;
   
   if (StringLen(name) == 0)
   {
      name = "DragTrade Toolbar " + Symbol() + " " + PeriodAsString();
   }
   
   return (name);
}

string InfobarName()
{
   static string name;
   
   if (StringLen(name) == 0)
   {
      name = "DragTrade Infobar " + Symbol() + " " + PeriodAsString();
   }
   
   return (name);
}

string OrdersbarName()
{
   static string name;
   
   if (StringLen(name) == 0)
   {
      name = "DragTrade Ordersbar " + Symbol() + " " + PeriodAsString();
   }
   
   return (name);
}

int GetToolWindow()
{
   return (WindowFind(ToolbarName()));
}

int GetInfoWindow()
{
   return (WindowFind(InfobarName()));
}

int GetOrdersWindow()
{
   return (WindowFind(OrdersbarName()));
}

string ID()
{
   static string result;
   if (StringLen(result) == 0) result = "DragTrade " + Symbol_() + " ";
   
   return (result);
}

int IDLen()
{
   static int size = -1;
   if (size == -1) size = StringLen(ID());
   
   return (size);
}