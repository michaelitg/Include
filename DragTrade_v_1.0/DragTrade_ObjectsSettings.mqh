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
//|                                              ObjectsSettings.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, TheXpert"
#property link      "theforexpert@gmail.com"

void SetLabel(string name, int window, int x, int y, string text, string font = "Arial Black", color clr = Gold, int size = 10)
{
   ObjectCreate(name, OBJ_LABEL, window, 0, 0);
   
   ObjectSet(name, OBJPROP_CORNER, 1);
   ObjectSet(name, OBJPROP_XDISTANCE, x);
   ObjectSet(name, OBJPROP_YDISTANCE, y);
   ObjectSetText(name, text, size, font, clr);
}

void SetLeftLabel(string name, int window, int x, int y, string text, string font = "Arial Black", color clr = Gold, int size = 10)
{
   ObjectCreate(name, OBJ_LABEL, window, 0, 0);
   
   ObjectSet(name, OBJPROP_CORNER, 0);
   ObjectSet(name, OBJPROP_XDISTANCE, x);
   ObjectSet(name, OBJPROP_YDISTANCE, y);
   ObjectSetText(name, text, size, font, clr);
}

void ModifyLabelPos(string name, int x, int y)
{
   ObjectSet(name, OBJPROP_XDISTANCE, x);
   ObjectSet(name, OBJPROP_YDISTANCE, y);
}

bool GetLabel(string name, int& x, int& y)
{
   if (ObjectFind(name) != -1)
   {
      x = ObjectGet(name, OBJPROP_XDISTANCE);
      y = ObjectGet(name, OBJPROP_YDISTANCE);
      return (true);
   }
   return (false);
}

void SetArrow(string name, datetime time, double price, int arrowCode = SYMBOL_RIGHTPRICE, int size = 3, color clr = White)
{
   ObjectCreate(name, OBJ_ARROW, 0, time, price); 
   
   ObjectSet(name, OBJPROP_ARROWCODE, arrowCode);
   ObjectSet(name, OBJPROP_PRICE1, price);
   ObjectSet(name, OBJPROP_TIME1, time);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_WIDTH, size);
}

void ModifyArrow(string name, datetime time, double price)
{
   ObjectSet(name, OBJPROP_PRICE1, price);
   ObjectSet(name, OBJPROP_TIME1, time);
}

bool GetArrow(string name, datetime& time, double& price)
{
   if (ObjectFind(name) != -1)
   {
      price = ObjectGet(name, OBJPROP_PRICE1);
      time = ObjectGet(name, OBJPROP_TIME1);
      return (true);
   }
   return (false);
}

void SetHLine(string name, double price, color clr = Green, int style = 2, int width = 0)
{
   ObjectCreate(name, OBJ_HLINE, 0, 0, price); 
   
   ObjectSet(name, OBJPROP_PRICE1, price);
   ObjectSet(name, OBJPROP_STYLE, style);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_WIDTH, width);
}

void ModifyHLine(string name, double price)
{
   ObjectSet(name, OBJPROP_PRICE1, price);
}

bool GetHLine(string name, double& price)
{
   if (ObjectFind(name) != -1)
   {
      price = ObjectGet(name, OBJPROP_PRICE1);
      return (true);
   }
   return (false);
}