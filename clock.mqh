// -----------------------------------------------------------------------------------------------------------------------------    
/////////////////////////////////////////////////////////////////////|
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GMT_Offset(string region,datetime dt1)
{
  int r1=0;
  if (region=="LONDON")    
    r1=GMT0(dt1);
  else if (region=="US")        
    r1=GMT_5(dt1);     
  else if (region=="FRANKFURT")        
    r1=GMT1(dt1);
  else if (region=="HONGKONG")        
    r1=GMT8(dt1);        
  else if (region=="TOKYO")        
    r1=GMT9(dt1);      
  else if (region=="SYDNEY")        
    r1=GMT11(dt1);          
  else if (region=="AUCKLAND")        
    r1=GMT12(dt1);   
      
    return (r1);
}


//+------------------------------------------------------------------+
//| London     DST ===  Standard and Summertime setting              |
//+------------------------------------------------------------------+
int GMT0(datetime dt1)
{
//UK Standard Time = GMT
//UK Summer Time = BST (British Summer time) = GMT+1
//For 2003-2007 inclusive, the summer-time periods begin and end respectively on 
//the following dates at 1.00am Greenwich Mean Time:
//2003: the Sundays of 30 March and 26 October
//2004: the Sundays of 28 March and 31 October
//2005: the Sundays of 27 March and 30 October
//2006: the Sundays of 26 March and 29 October
//2007: the Sundays of 25 March and 28 October
  if ((dt1>last_sunday(TimeYear(dt1),3))&&(dt1<last_sunday(TimeYear(dt1),10)))
   return(1);//summer
  else
   return(0); 
}

//+------------------------------------------------------------------+
//| Frankfurt     DST ===  Standard and Summertime setting           |
//+------------------------------------------------------------------+
int GMT1(datetime dt1)
{
//Standard Time = GMT +1
//Summer Time = GMT+2
//For 2003-2007 inclusive, the summer-time periods begin and end respectively on 
//the following dates at 1.00am Greenwich Mean Time:
//2003: the Sundays of 30 March and 26 October
//2004: the Sundays of 28 March and 31 October
//2005: the Sundays of 27 March and 30 October
//2006: the Sundays of 26 March and 29 October
//2007: the Sundays of 25 March and 28 October
  if ((dt1>last_sunday(TimeYear(dt1),3))&&(dt1<last_sunday(TimeYear(dt1),10)))
   return(2);//summer
  else
   return(1); 
}

//+------------------------------------------------------------------+
//| New York   US times                                              |
//+------------------------------------------------------------------+
int GMT_5(datetime dt1)
{
/*US
//-------------------------------------------------------------------
//Eastern Standard Time (EST) = GMT-5
//-------------------------------------------------------------------
//Eastern Daylight Time (EDT) = GMT-4
//-----+--------------------------+----------------------------------
//Year | 	DST Begins 2 a.m.     |     DST Ends 2 a.m.
//1990-|                          |
//2006 |  (First Sunday in April) |	(Last Sunday in October)
//-----+--------------------------+----------------------------------                                  
//-----+--------------------------+----------------------------------
//Year | 	DST Begins 2 a.m.     |     DST Ends 2 a.m.
//2007-|  (Second Sunday in March)|	(First Sunday in November)
//-----+--------------------------+----------------------------------
year     DST begins                 DST ends
2000     zondag, 2 april, 02:00     zondag, 29 oktober, 02:00
2001     zondag, 1 april, 02:00     zondag, 28 oktober, 02:00
2002     zondag, 7 april, 02:00     zondag, 27 oktober, 02:00
2003     zondag, 6 april, 02:00     zondag, 26 oktober, 02:00
2004     zondag, 4 april, 02:00     zondag, 31 oktober, 02:00
2005     zondag, 3 april, 02:00     zondag, 30 oktober, 02:00
2006     zondag, 2 april, 02:00     zondag, 29 oktober, 02:00

2007     zondag, 11 maart, 02:00    zondag, 4 november, 02:00
2008     zondag, 9 maart, 02:00     zondag, 2 november, 02:00
2009     zondag, 8 maart, 02:00     zondag, 1 november, 02:00
2010     zondag, 14 maart, 02:00    zondag, 7 november, 02:00
2011     zondag, 13 maart, 02:00    zondag, 6 november, 02:00
2012     zondag, 11 maart, 02:00    zondag, 4 november, 02:00
2013     zondag, 10 maart, 02:00    zondag, 3 november, 02:00
2014     zondag, 9 maart, 02:00     zondag, 2 november, 02:00
2015     zondag, 8 maart, 02:00     zondag, 1 november, 02:00
2016     zondag, 13 maart, 02:00    zondag, 6 november, 02:00
2017     zondag, 12 maart, 02:00    zondag, 5 november, 02:00
2018     zondag, 11 maart, 02:00    zondag, 4 november, 02:00
2019     zondag, 10 maart, 02:00    zondag, 3 november, 02:00
                                  
*/
 if(TimeYear(dt1)<2007)
   if ((dt1>sunday_number(TimeYear(dt1),4,1))&&(dt1<last_sunday(TimeYear(dt1),10)))
     return(-4);
    else
     return(-5); 
 else
 if(TimeYear(dt1)>=2007) 
   if ((dt1>sunday_number(TimeYear(dt1),3,2))&&(dt1<sunday_number(TimeYear(dt1),11,1)))
     return(-4);
    else
     return(-5); 
return(-5);
   
}
//+------------------------------------------------------------------+
//|  Hong Kong  CNY                                                  |
//+------------------------------------------------------------------+
int GMT8(datetime dt1)
{
   return(8);//standard NO DST =summer=+8
}

//+------------------------------------------------------------------+
//|  Tokyo  JPY                                                      |
//+------------------------------------------------------------------+
int GMT9(datetime dt1)
{
   return(9);//standard NO DST =summer=+9
}

//+------------------------------------------------------------------+
int GMT11(datetime dt1)
{
/*+------------------------------------------------------------------+
//|   Sydney    AUD                                                  |
//+------------------------------------------------------------------+
//|   Eastern Standard Time (EST) = GMT+10   No DST                  |
//|   Eastern Daylight Time (EDT) = GMT+11   DST                     |
//+-----+--------------------------+---------------------------------+
year     enddate                       startdate
2000     zondag, 26 maart, 03:00       zondag, 27 augustus, 02:00
2001     zondag, 25 maart, 03:00       zondag, 28 oktober, 02:00
2002     zondag, 31 maart, 03:00       zondag, 27 oktober, 02:00
2003     zondag, 30 maart, 03:00       zondag, 26 oktober, 02:00
2004     zondag, 28 maart, 03:00       zondag, 31 oktober, 02:00
2005     zondag, 27 maart, 03:00       zondag, 30 oktober, 02:00

2006     zondag, 2 april, 03:00        zondag, 29 oktober, 02:00

2007     zondag, 25 maart, 03:00       zondag, 28 oktober, 02:00

2008     zondag, 6 april, 03:00        zondag, 5 oktober, 02:00
2009     zondag, 5 april, 03:00        zondag, 4 oktober, 02:00
2010     zondag, 4 april, 03:00        zondag, 3 oktober, 02:00
2011     zondag, 3 april, 03:00        zondag, 2 oktober, 02:00
2012     zondag, 1 april, 03:00        zondag, 7 oktober, 02:00
2013     zondag, 7 april, 03:00        zondag, 6 oktober, 02:00
2014     zondag, 6 april, 03:00        zondag, 5 oktober, 02:00
2015     zondag, 5 april, 03:00        zondag, 4 oktober, 02:00
2016     zondag, 3 april, 03:00        zondag, 2 oktober, 02:00
2017     zondag, 2 april, 03:00        zondag, 1 oktober, 02:00
2018     zondag, 1 april, 03:00        zondag, 7 oktober, 02:00
2019     zondag, 7 april, 03:00        zondag, 6 oktober, 02:00

//-----+--------------------------+----------------------------------         
*/
 if(TimeYear(dt1)<1996)
   if ((dt1>sunday_number(TimeYear(dt1),3,1))&&(dt1<last_sunday(TimeYear(dt1),10)))
     return(10);
    else
     return(11); 
 else
 if((TimeYear(dt1)>=1996 && TimeYear(dt1)<2008)&&(TimeYear(dt1)!= 2006))
   if ((dt1>last_sunday(TimeYear(dt1),3))&&(dt1<last_sunday(TimeYear(dt1),10)))
     return(10);
    else
     return(11); 
 else
 if(TimeYear(dt1)== 2006)
   if ((dt1>sunday_number(TimeYear(dt1),4,1))&&(dt1<last_sunday(TimeYear(dt1),10)))
     return(10);
    else
     return(11); 
 else
 if(TimeYear(dt1)>=2008)
   if ((dt1>sunday_number(TimeYear(dt1),4,1))&&(dt1<sunday_number(TimeYear(dt1),10,1)))
     return(10);
    else
     return(11); 
return(11); 
}

//+------------------------------------------------------------------+
int GMT12(datetime dt1)
{
/*+------------------------------------------------------------------+
//|   New Zealand  Auckland   NZD                                    |
//+------------------------------------------------------------------+
//|   Eastern Standard Time (EST) = GMT+12   No DST                  |
//|   Eastern Daylight Time (EDT) = GMT+13   DST                     |
//+-----+--------------------------+---------------------------------+
year     enddate                       startdate
2000     zondag, 19 maart, 03:00       zondag, 1 oktober, 02:00
2001     zondag, 18 maart, 03:00       zondag, 7 oktober, 02:00
2002     zondag, 17 maart, 03:00       zondag, 6 oktober, 02:00
2003     zondag, 16 maart, 03:00       zondag, 5 oktober, 02:00
2004     zondag, 21 maart, 03:00       zondag, 3 oktober, 02:00
2005     zondag, 20 maart, 03:00       zondag, 2 oktober, 02:00
2006     zondag, 19 maart, 03:00       zondag, 1 oktober, 02:00

2007     zondag, 18 maart, 03:00       zondag, 30 september, 02:00
2008     zondag, 6 april, 03:00        zondag, 28 september, 02:00
2009     zondag, 5 april, 03:00        zondag, 27 september, 02:00
2010     zondag, 4 april, 03:00        zondag, 26 september, 02:00
2011     zondag, 3 april, 03:00        zondag, 25 september, 02:00
2012     zondag, 1 april, 03:00        zondag, 30 september, 02:00
2013     zondag, 7 april, 03:00        zondag, 29 september, 02:00
2014     zondag, 6 april, 03:00        zondag, 28 september, 02:00
2015     zondag, 5 april, 03:00        zondag, 27 september, 02:00
2016     zondag, 3 april, 03:00        zondag, 25 september, 02:00
2017     zondag, 2 april, 03:00        zondag, 24 september, 02:00
2018     zondag, 1 april, 03:00        zondag, 30 september, 02:00
2019     zondag, 7 april, 03:00        zondag, 29 september, 02:00

//-----+--------------------------+----------------------------------         
*/
 if(TimeYear(dt1)<2007)
   if ((dt1>sunday_number(TimeYear(dt1),3,3))&&(dt1<sunday_number(TimeYear(dt1),10,1)))
     return(12);
    else
     return(13); 
 else
 if(TimeYear(dt1)==2007)
   if ((dt1>sunday_number(TimeYear(dt1),3,3))&&(dt1<last_sunday(TimeYear(dt1),9)))
     return(12);
    else
     return(13); 
 else
 if(TimeYear(dt1)> 2007)
   if ((dt1>sunday_number(TimeYear(dt1),4,1))&&(dt1<last_sunday(TimeYear(dt1),10)))
     return(12);
    else
     return(13); 
     
   return(13);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_leap_year(int year1)
{
 
  if ((MathMod(year1,100)==0) && (MathMod(year1,400)==0))
    return(true);
  else if ((MathMod(year1,100)!=0) && (MathMod(year1,4)==0))  
    return(true);
  else 
    return (false); 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int n_days(int year1,int month1)
{
  int ndays1 = 0;
  if (month1==1)
    ndays1=31;
  else if(month1==2)
  {
    if (is_leap_year(year1))
      ndays1=29;      
    else
      ndays1=28;  
  }    
  else if(month1==3)
    ndays1=31;  
  else if(month1==4)
    ndays1=30;  
  else if(month1==5)//mai
    ndays1=31;  
  else if(month1==6)//iun          
    ndays1=30;  
  else if(month1==7)//iul          
    ndays1=31;  
  else if(month1==8)//aug          
    ndays1=31;  
  else if(month1==9)//sep          
    ndays1=30;  
  else if(month1==10)//oct          
    ndays1=31;  
  else if(month1==11)//nov          
    ndays1=30;  
  else if(month1==12)          
    ndays1=31;  
  
  return(ndays1);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int n_sdays(int year1,int month1)
{
  datetime ddt2;
  int ndays2=n_days(year1,month1);
  int i,nsun1=0;  
  for (i=1;i<=ndays2;i++) 
  {
    ddt2= StrToTime(DoubleToStr(year1,0)+"."+DoubleToStr(month1,0)+"."+DoubleToStr(i,0)+" 00:00");            
    if(TimeDayOfWeek(ddt2)==0)
      nsun1=nsun1+1; 
  }   
  return(nsun1);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime last_sunday(int year1,int month1)
{
  int i,ndays2,nsun1,nsun2;
  datetime dt2,dt3 = 0;
  ndays2=n_days(year1,month1);
  nsun2=n_sdays(year1,month1);
  nsun1=0;
  for (i=1;i<=ndays2;i++) 
  {
    dt2= StrToTime(DoubleToStr(year1,0)+"."+DoubleToStr(month1,0)+"."+DoubleToStr(i,0)+" 00:00");                    
    if(TimeDayOfWeek(dt2)==0)
    {       
      nsun1=nsun1+1; 
    }  
    if (nsun1==nsun2) 
    {
      dt3=dt2;  
      break;        
    }  
  }   
  return(dt3);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

datetime sunday_number(int year1,int month1,int sundaycount)
{
  int i,ndays2,nsun1,nsun2;
  datetime dt2,dt3=0;
  ndays2=n_days(year1,month1);
  nsun2=sundaycount;//n_sdays(year1,month1);
  nsun1=0;
  for (i=1;i<=ndays2;i++) 
  {
    dt2= StrToTime(DoubleToStr(year1,0)+"."+DoubleToStr(month1,0)+"."+DoubleToStr(i,0)+" 00:00");                    
    if(TimeDayOfWeek(dt2)==0)
    {       
      nsun1=nsun1+1; 
    }  
    if (nsun1==nsun2) 
    {
      dt3=dt2;  
      break;        
    }  
  }   
  return(dt3);
}