
// -----------------------------------------------------------------------------------------------------------------------------    
/////////////////////////////////////////////////////////////////////|
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void maTrade(int mag)
{
   if( MATrade >= 0)
   {
      double point = getPoint();
      double p;
      if( MAPeriod < 1000) p = NormalizeDouble(iMA(Symbol(), 0, MAPeriod, 0, MODE_SMA,PRICE_CLOSE, 0), Digits);
      else{
         string name = "Trendline "+MAPeriod;
         if(ObjectFind(name) == 0)
         {
            int factor = 1;
            if( MATrade == 1) factor = -1;
            string tname = "_trade " + MAPeriod;
            SetObject(tname,
                 ObjectGet(name, OBJPROP_TIME1),
                 ObjectGet(name, OBJPROP_PRICE1) + factor*MASpace*point,
                 ObjectGet(name, OBJPROP_TIME2),
                 ObjectGet(name, OBJPROP_PRICE2) + factor*MASpace*point,
                 ObjectGet(name, OBJPROP_COLOR));
            p = NormalizeDouble(ObjectGetValueByShift(tname,0),Digits);          
         }
      }
      int t = GetOrder(mag, OP_SELLSTOP);
      double lot = Lots;
      if( Ask < 500) lot *= 0.1;
      if( MATrade == 0)
         {
            double rsl = NormalizeDouble(iBands(Symbol(),0,MAPeriod,2,0,PRICE_CLOSE,MODE_LOWER,1),Digits); //p - sl * point;
            double rtp = NormalizeDouble(iBands(Symbol(),0,MAPeriod,2,0,PRICE_CLOSE,MODE_UPPER,1),Digits); //p + tp * point;
            if( t == -1 && p < Bid )
            {
               //if(OrderSend(Symbol(), OP_BUYLIMIT, lot, p, 5, rsl, rtp, comment+"Ma"+MAPeriod+"(M"+Period()+")"+MagSpecial, mag, 0, Green) < 0)
               //   Print("OpenMa Err (", GetLastError(), ") Open Price= ", p, " SL= ", rsl," TP= ", rtp, ",matrade=", MATrade);
            }
         }
      if(MATrade == 1)
         {
            //rsl = p + sl * point;
            //rtp = p - tp * point;
            rsl = NormalizeDouble(iBands(Symbol(),0,MAPeriod,2,0,PRICE_CLOSE,MODE_UPPER,1),Digits); 
            rtp = NormalizeDouble(iBands(Symbol(),0,MAPeriod,2,0,PRICE_CLOSE,MODE_LOWER,1),Digits); //p + tp * point;
            if( t == -1 && p > Ask )
            {
               //if(OrderSend(Symbol(), OP_SELLLIMIT, lot, p, 5, rsl, rtp, comment+"Ma"+MAPeriod+"(M"+Period()+")"+MagSpecial, mag, 0, Red) < 0)
               //   Print("OpenMa Err (", GetLastError(), ") Open Price= ", p, " SL= ", rsl," TP= ", rtp, "matrade=", MATrade);
             }
         }
      if( t != -1 && OrderType() > 1)
      {
             if(MathAbs( p - OrderOpenPrice()) > 0*point && MathAbs( p - (Ask+Bid)/2) > 0*point)
             {
                  //if(OrderModify(t, p, rsl, rtp, 0, Blue) == false)
                  //  Print("Modify Ma Err (", GetLastError(), ") Price= ", p,"OrderOpenPrice=",OrderOpenPrice(),"SL ", rsl," TP= ", rtp, "t=", t);           
             }  
      }
   }
   else
      ClosePendingOrder(mag);
}