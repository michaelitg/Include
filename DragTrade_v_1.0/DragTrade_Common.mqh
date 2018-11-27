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
//|                                                       Common.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, TheXpert"
#property link      "theforexpert@gmail.com"

string PeriodAsString()
{
   static string period;
   
   if (StringLen(period) == 0)
   {
      switch (Period()) 
      {
         case 60:     period = "H1"; break;
         case 240:    period = "H4"; break;
         case 1440:   period = "D1"; break;
         case 10080:  period = "W1"; break;
         case 43200:  period = "MN1";break;

         default:     period = "M" + Period();
      }
   }

   return (period);
}

string OrderTypeAsString(int type)
{
   switch (type) 
   {
      case OP_BUY      : return ("Buy");
      case OP_SELL     : return ("Sell");
      case OP_BUYLIMIT : return ("Buy Limit");
      case OP_SELLLIMIT: return ("Sell Limit");
      case OP_BUYSTOP  : return ("Buy Stop");
      case OP_SELLSTOP : return ("Sell Stop");
   }
   
   return ("Unknown Operation");
}

int ArraySearchInt(int array[], int value) 
{
  int size = ArraySize(array);
  
  for (int i = 0; i < size; i++)
  {
    if (array[i] == value) return (i);
  }
  return (-1);
}

int ArraySearchString(string array[], string value) 
{
  int size = ArraySize(array);
  
  for (int i = 0; i < size; i++)
  {
    if (array[i] == value) return (i);
  }
  return (-1);
}

void PushBackInt(int& array[], int value)
{
   int size = ArraySize(array);
   ArrayResize(array, size + 1);
   array[size] = value;
}

void PushBackString(string& array[], string value)
{
   int size = ArraySize(array);
   ArrayResize(array, size + 1);
   array[size] = value;
}

void PushBackDouble(double& array[], double value)
{
   int size = ArraySize(array);
   ArrayResize(array, size + 1);
   array[size] = value;
}