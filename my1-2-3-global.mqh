
// -----------------------------------------------------------------------------------------------------------------------------    
/////////////////////////////////////////////////////////////////////|
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern string version = "1.262 07/03/2019";
extern int   Lots = 1;
extern int   EnableInd = 0;
extern int   EnableKReverse = 0;
extern int   EnableDayClose = 0;

extern double TP_Equity  = 3000;
extern int    MaxLots = 6;
extern int    RunPeriod = 60;
extern double StopLoss = 20;  //M15 - 70
extern double TkRate = 1;  //general : 120 and 4
extern int    TradeMode = 2;  //-1: no trade 0: buy 1: sell 2:buy/sell
extern int    breakTradeEnabled = 0;
extern int    MATrade = -1;
extern int    MAPeriod = 100;
extern int    MASpace = 15;
extern int    BandsSpace = 270;
extern int    BandsGap = 5;
extern int    PriceSpace = 60;
extern int    ReverseSpace = 30;
//extern int    KTradeMode = -1;
//extern bool   Immediate = false;
extern int    MagSpecial = 0;
extern int    TestFlag = 0;
//extern int    TestSignal = 100;
extern int    KSpace = 10;
extern int    MaxGap = 50;

int     TradeDirection = 0;
bool    Immediate = false;
int     KTradeMode = -1;
datetime KTradeModeTime = 0;
string KTradeModeStr[3] = {"No","Buy","Sell"};

string  msg = "";
int     command = -1;

string ss[2] = {"buy","sell"};
#define MAGICMA  2016012100
#define MAGICMB  2016011000

double signalPrice = 0;
int    CloseSignal = 0;
string trendLineName = "";
string indName = "";

datetime mainTimer = 0, pt, st;
datetime dt = 0, dt2 = 0, at = 0;
datetime dtime1 = 0, dtime3 = 0, dtime4 = 0, dtime5 = 0;