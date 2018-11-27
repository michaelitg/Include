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
//|                                           DragTrade_Property.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2009, TheXpert"
#property link      "theforexpert@gmail.com"

#define PROP_ID " Property "

#include <DragTrade_v_1.0/DragTrade_SmartGlobals.mqh>

string PropertyNames[];
double LastPropertyValues[];

void InitProperties()
{
   ArrayResize(PropertyNames, 0);
   ArrayResize(LastPropertyValues, 0);
}

void SetProperty(string name, double value)
{
   string property = name + PROP_ID;
   SetGlobal(property, value);
   
   int pos = ArraySearchString(PropertyNames, property);
   if (pos != -1)
   {
      LastPropertyValues[pos] = value;
   }
   else
   {
      PushBackDouble(LastPropertyValues, value);
      PushBackString(PropertyNames, property);
   }
}

bool GetProperty(string name, double& value)
{
   string property = name + PROP_ID;
   bool res = GetGlobalSafe(property, value);
   
   if (res)
   {
      int pos = ArraySearchString(PropertyNames, property);
      if (pos == -1)
      {
         PushBackDouble(LastPropertyValues, value);
         PushBackString(PropertyNames, property);
      }
   }
   
   return (res);
}

bool InitProperty(string name, double defaultValue)
{
   double value;
   if (!GetProperty(name, value))
   {
      SetProperty(name, defaultValue);
   }
}

bool IsPropertyActual(string name)
{
   string property = name + PROP_ID;

   double global;
   if (!GetGlobalSafe(property, global)) return (false);
   
   int pos = ArraySearchString(PropertyNames, property);
   if (pos == -1)
   {
      PushBackDouble(LastPropertyValues, global);
      PushBackString(PropertyNames, property);
      return (true);
   }
   
   return (LastPropertyValues[pos] == global);
}

double UpdateProperty(string name)
{
   string property = name + PROP_ID;
   double actual = GetGlobal(property);

   int pos = ArraySearchString(PropertyNames, property);
   if (pos == -1)
   {
      PushBackDouble(LastPropertyValues, actual);
      PushBackString(PropertyNames, property);
   }
   else
   {
      LastPropertyValues[pos] = actual;
   }
   return (actual);
}