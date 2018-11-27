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
//|                                                 SmartGlobals.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, TheXpert"
#property link      "theforexpert@gmail.com"

#include <DragTrade_v_1.0/DragTrade_Common.mqh>

bool Testing = false;

void SetTesting(bool testing = true)
{
   Testing = testing;
}

string GetGlobalFullName(string name)
{
   if (Testing || IsTesting())
   {
      static string postfix1;
   
      if (StringLen(postfix1) == 0)
      {
         postfix1 = "t " + AccountNumber() + " " + Symbol() + " " + PeriodAsString();
      }
      return (name + postfix1);
   }

   static string postfix2;

   if (StringLen(postfix2) == 0)
   {
      postfix2 = " " + AccountNumber() + " " + Symbol() + " " + PeriodAsString();
   }
   
   return (name + postfix2);
}

void SetGlobal(string name, double value)
{
   string finalName = GetGlobalFullName(name);
   GlobalVariableSet(finalName, value);
}

double GetGlobal(string name)
{
   string finalName = GetGlobalFullName(name);
   return (GlobalVariableGet(finalName));
   
   return (0);
}

bool GetGlobalSafe(string name, double& value)
{
   bool res = false;

   string finalName = GetGlobalFullName(name);
   res = GlobalVariableCheck(finalName);
   
   if (res) 
   {
      value = GlobalVariableGet(finalName);
   }
   
   return (res);
}