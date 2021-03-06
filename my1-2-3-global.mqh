
// -----------------------------------------------------------------------------------------------------------------------------    
/////////////////////////////////////////////////////////////////////|
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern int   EnableInd = 0;
extern int   EnableKReverse = 0;
extern int   EnableDayClose = 0;
extern string sep0="*******Trend,Equity,Lots********";
extern double Lots = 1;
extern double DisableAll = 0;
extern int    MaxLots = 6;
extern int    TrendPattern = -1;
extern double TP_Equity  = 0;
extern double SL_Equity  = 0;
extern int    RunPeriod = 60;
extern double StopLoss = 200;  //M15 - 70
extern double TkRate = 1;  //general : 120 and 4
extern int    TradeMode = 2;  //-1: no trade 0: buy 1: sell 2:buy/sell
extern int    breakTradeEnabled = 0;
extern int    ma97TradeEnabled = 0;
extern int    ReverseSpace = 30;
extern string sep1="*******Boller Trader Begin********";
extern string bollerex0 = "0 - buy / 1 sell / 2 - all";
extern int    BollerTrade = -1;
extern int    Band = 100; //40 for M15 20 for H1
extern string bollerex1 = "0 - buy at mid, 1 - sell at mid ";
extern int    UseMidAsUporDown = -1;
extern int    Boller_TakeProfit = 0;
extern int    Boller_StopLoss = 500;
extern double PriceChange = 10;
extern int    StepUpper = 4;
extern int    StepLower = 4;
extern string sep2="*******Booler Trader End***********";
extern int    MagSpecial = 0;
extern int    TestFlag = 0;
//extern int    TestSignal = 100;
extern int    KSpace = 10;
extern int    MaxGap = 50;

extern string sep3="*********ma97 Begin*****************";
extern int  tradeTime = 360;
//M15: GER30 800 sl 100 tk 300 start capital: 1500 from 2018-1-1 - 2018-12-17
//4550.03	43	3.35	105.81	1236.36	58.75%	0.00000000	TradeMAPeriod=800	Enable_MM1=1 	Enable_MM3=0 	MaxLots=5 	TakeProfit=300 	Lots=1 	StopLoss=100 	ReversePercent=0.1 	AddPercent=1.2 	AddRate=0.1 	PlanRate=0.1 	LimitRate=0.2 	manOrder=0 	manOrderOp=0 	CBarsFrac=26 	AddPercentMM3=0.1 	manTrend=-1 	autoTrendMethod=-1 	autoTrendRange=24 	autoTrendPeriod=12 	autoTrendLevel=2.2 	RunPeriod=15 	updownLevel=11 	updowncount=3 	shortma=7 	shortmashift=3
//M15: US30 start capital: 1500 from 2018-1-1 - 2018-12-18
//63603.10	130	2.91	489.25	12931.80	38.71%	0.00000000	TakeProfit=500 	StopLoss=160 	ReversePercent=0.2 	AddRate=0.1 	PlanRate=0	Enable_MM1=1 	Enable_MM3=0 	MaxLots=5 	TradeMAPeriod=800 	Lots=1 	AddPercent=1.2 	LimitRate=0.2 	manOrder=0 	manOrderOp=0 	CBarsFrac=26 	AddPercentMM3=0.1 	manTrend=-1 	autoTrendMethod=-1 	autoTrendRange=24 	autoTrendPeriod=12 	autoTrendLevel=2.2 	RunPeriod=15 	updownLevel=11 	updowncount=3 	shortma=7 	shortmashift=3
//good data:	63689.60	174	2.35	366.03	16188.00	64.16%	0.00000000	TradeMAPeriod=500 	TakeProfit=700 	StopLoss=300	Enable_MM1=1 	Enable_MM3=0 	MaxLots=5 	tradeTime=360 	Lots=1 	ReversePercent=0.2 	AddPercent=1.2 	AddRate=0.1 	PlanRate=0 	LimitRate=0.2 	manOrder=0 	manOrderOp=0 	CBarsFrac=26 	AddPercentMM3=0.1 	manTrend=-1 	autoTrendMethod=-1 	autoTrendRange=24 	autoTrendPeriod=12 	autoTrendLevel=2.2 	RunPeriod=15 	updownLevel=11 	updowncount=3 	shortma=7 	shortmashift=3
//add order mixed position start 2000:
//71087.60	187	2.33	380.15	17831.10	61.24%	0.00000000	TakeProfit=700 	StopLoss=200	Enable_MM1=1 	Enable_MM3=0 	MaxLots=5 	tradeTime=360 	TradeMAPeriod=500 	Lots=1 	ReversePercent=0.2 	AddPercent=1.2 	AddRate=0.1 	PlanRate=0 	LimitRate=0.2 	manOrder=0 	manOrderOp=0 	CBarsFrac=26 	AddPercentMM3=0.1 	manTrend=-1 	autoTrendMethod=-1 	autoTrendRange=24 	autoTrendPeriod=12 	autoTrendLevel=2.2 	RunPeriod=15 	updownLevel=11 	updowncount=3 	shortma=7 	shortmashift=3
extern int TradeMAPeriod = 500;
extern double TakeProfit = 700;
extern double ma97_StopLoss = 200;
//extern double StopLossMM3 = 120;
extern double ReversePercent = 0.2;  //don't reverse for GER30 1H/M15
extern double AddPercent = 1.2; //Add Plan trade lots percent 0.2=>1.2
extern double AddRate = 0.1;   //Add Plan mark position 0.4=>0.1 0.6 is also better
extern double PlanRate = 0;  //Add Plan trade position 0.2 => 0, since GER30很少会再回测
extern double LimitRate = 0.2;  //Add Plan trade position up limit
extern string comment1 = "manOrder=1:immediate buy/sell 2:immediate reverse trade 0: normal";
extern int    manOrder = 0;   //
extern string comment11 = "manOrderOp=0-Buy 1-Sell";
extern int    manOrderOp = 0;  //

extern int CBarsFrac    = 26;   //MM3
extern double AddPercentMM3 = 0.1; //Add Plan trade lots percent
extern string comment2 = "manTrend=-1: auto calculate 0: no trend 1: has trend";
extern int    manTrend = -1;   //

//extern int    noTrendTrade = 0;
//extern int    noTrendSignal = 0;
extern int    autoTrendMethod = -1;  //0 - iATR 1 - 006-myATR
extern int    autoTrendRange = 24;
extern int    autoTrendPeriod = 12;
extern double autoTrendLevel = 2.2;  //for sfa 2.00 fxcm 1.99 every platform should be different
extern double updownLevel = 11;
extern int    updowncount = 3;
extern int    shortma = 7;
extern int    shortmashift = 3;
extern int    cbars = 1;
extern string sep4="***************************ma97 End*****************";


int     TradeDirection = 0;
bool    Immediate = false;
int     KTradeMode = -1;
datetime KTradeModeTime = 0;
string KTradeModeStr[3] = {"No","Buy","Sell"};

string  msg = "";
int     command = -1;

string ss[6] = {"buy","sell","buylimit","selllimit","buystop","sellstop"};
#define MAGICMA  2016012100
#define MAGICMB  2016011000
#define MAGICMC  2019031700

double signalPrice = 0;
int    CloseSignal = 0;
string trendLineName = "";
string indName = "";

datetime mainTimer = 0, pt, st;
datetime dt = 0, dt2 = 0, at = 0;
datetime dtime1 = 0, dtime3 = 0, dtime4 = 0, dtime5 = 0;