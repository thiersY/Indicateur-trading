//
// Trade Manager.mq4/mq5
// getYourNet.ch
//

#property copyright "Copyright 2021, getYourNet.ch"
#property link "http://shop.getyournet.ch/trademanager"

#ifdef __MQL4__
   #include <..\Libraries\stdlib.mq4>
#endif
#ifdef __MQL5__
   #include <Trade\Trade.mqh>
   #include <errordescription.mqh>

   enum OrderType
   {
      OP_BUY,
      OP_SELL
   };
#endif

#include <CurrencyStrength.mqh>
#include <MultiPivots.mqh>
#ifdef __MQL5__
   //#include <CurrencyStrengthReadDB.mqh>
#endif

enum TypeAutomation
{
   NoAutomation, // None
   Dredging // Dredging System
};

enum TypeInstance
{
   Instance1=1,
   Instance2=2,
   Instance3=3,
   Instance4=4,
   Instance5=5,
   Instance6=6,
   Instance7=7,
   Instance8=8,
   Instance9=9
};

enum TypeStopLossPercentTradingCapitalAction
{
   CloseWorstTrade,
   CloseAllTrades
};

enum TypeLipStickMode
{
   LipStickNone,
   LipStickMode1,
   LipStickMode2
};

input TypeInstance Instance = 1;
input TypeAutomation Automation = NoAutomation;
input double BreakEvenAfterPips = 5;
input double AboveBEPips = 1;
input double StartTrailingPips = 7;
input double TakeProfitPips = 0;
input double StopLossPips = 0;
input bool HedgeAtStopLoss = false;
input double HedgeVolumeFactor = 1;
input double HedgeFlatAtLevel = 5;
input double TakeProfitPercentTradingCapital = 0;
input double StopLossPercentTradingCapital = 0;
input double MaxDailyLoss = 0;
input TypeStopLossPercentTradingCapitalAction StopLossPercentTradingCapitalAction = CloseAllTrades;
input bool CloseTradesBeforeMidnight = false;
input int CloseTradesBeforeMidnightHour = 23; 
input int CloseTradesBeforeMidnightMinute = 00; 
input bool ActivateTrailing = false;
input double TrailingFactor = 0.6;
input double OpenLots = 0.01;
input bool ShowInfo = true;
input color TextColor = Gray;
input color TextColorBold = Black;
input color TextColorInfo = DodgerBlue;
input color TextColorPlus = MediumSeaGreen;
input color TextColorMinus = DeepPink;
input color Color_USD = MediumSeaGreen; // USD color
input color Color_EUR = DodgerBlue; // EUR color
input color Color_GBP = DeepPink; // GBP color
input color Color_CHF = Black; // CHF color
input color Color_JPY = Chocolate; // JPY color
input color Color_AUD = DarkOrange; // AUD color
input color Color_CAD = MediumVioletRed; // CAD color
input color Color_NZD = Silver; // NZD color
input string FontName = "Arial";
input int FontSize = 9;
input int TextGap = 16;
input bool ManageOwnTradesOnly = true;
input int ManageMagicNumberOnly = 0;
input int ManageOrderNumberOnly = 0;
input bool SwitchSymbolClickAllCharts = true;
input bool DrawLevelsAllCharts = true;
input bool DrawBackgroundPanel = true;
input int BackgroundPanelWidth = 250;
input color BackgroundPanelColor = clrNONE;
input bool MT5CommissionPerDeal = true;
input int AvailableTradingCapital = 0;
input int PendingOrdersSplit = 3;
input double PendingOrdersRiskFactor = 3;
input double PendingOrdersFirstTPStep = 5;
input double PendingOrdersNextTPSteps = 1;
input int StartHour = 0;
input int StartMinute = 0;
input int MinPoints1 = 0;
input group "Harvesters";
input bool Harvester_CSGBPReversal = false;
input bool Harvester_CSGBP45MinStrength = false;
input bool Harvester_CSFollow = false;
input bool Harvester_GBPWeek = false;
input bool Harvester_CSEmergingTrends = false;
input bool UseCurrencyStrengthDatabase = false;
input group "Trading Hours";
input bool Hour0 = true;
input bool Hour1 = true;
input bool Hour2 = true;
input bool Hour3 = true;
input bool Hour4 = true;
input bool Hour5 = true;
input bool Hour6 = true;
input bool Hour7 = true;
input bool Hour8 = true;
input bool Hour9 = true;
input bool Hour10 = true;
input bool Hour11 = true;
input bool Hour12 = true;
input bool Hour13 = true;
input bool Hour14 = true;
input bool Hour15 = true;
input bool Hour16 = true;
input bool Hour17 = true;
input bool Hour18 = true;
input bool Hour19 = true;
input bool Hour20 = true;
input bool Hour21 = true;
input bool Hour22 = true;
input bool Hour23 = true;
input group "Trading Weekdays";
input bool Sunday = true;
input bool Monday = true;
input bool Tuesday = true;
input bool Wednesday = true;
input bool Thursday = true;
input bool Friday = true;
input bool Saturday = true;
input group "General Parameters";
input double P1 = 0;
input double P2 = 0;
input double P3 = 0;
input double P4 = 0;
input double P5 = 0;
input double P6 = 0;
input double P7 = 0;
input double P8 = 0;
input double P9 = 0;
input double P10 = 0;
input double P11 = 0;
input double P12 = 0;
input double P13 = 0;
input double P14 = 0;
input double P15 = 0;
input double P16 = 0;
input double P17 = 0;
input double P18 = 0;
input double P19 = 0;
input double P20 = 0;

string appname="Trade Manager";
string appnamespace="";
bool appinit=false;
bool working=false;
double pipsfactor;
datetime lasttick;
datetime lasterrortime;
string lasterrorstring;
bool istesting;
bool initerror;
string SymbolExtraChars="";
double SymbolCommission;
string tickchar="";
int magicnumberfloor=0;
int basemagicnumber=0;
int hedgeoffsetmagicnumber=10000;
double _BreakEvenAfterPips;
double _AboveBEPips;
double _StartTrailingPips;
double _TakeProfitPips;
double _StopLossPips;
double _OpenLots;
bool _TradingHours[24];
bool _TradingWeekdays[7];
bool ctrlon;
bool crosshairon;
bool leftmousebutton;
int lipstickmode;
int currentlipstickmode;
double startdragprice;
double enddragprice;
bool tradelevelsvisible;
int selectedtradeindex;
uint repeatlasttick=0;
int repeatcount=0;
double atr;
int atrday;
int InstrumentSelected;
int TradesViewSelected;
const double DISABLEDPOINTS=1000000;
bool _ShowInfo;
int chartheight;
bool arrowdown=false;
int listshift=0;
string currencies[8]={"USD","EUR","GBP","JPY","CHF","CAD","AUD","NZD"};
string pairs[8][7]={
   {"EURUSD","GBPUSD","USDJPY","USDCHF","USDCAD","AUDUSD","NZDUSD"},
   {"EURUSD","EURGBP","EURJPY","EURCHF","EURCAD","EURAUD","EURNZD"},
   {"GBPUSD","EURGBP","GBPJPY","GBPCHF","GBPCAD","GBPAUD","GBPNZD"},
   {"USDJPY","EURJPY","GBPJPY","CHFJPY","CADJPY","AUDJPY","NZDJPY"},
   {"USDCHF","EURCHF","GBPCHF","CHFJPY","CADCHF","AUDCHF","NZDCHF"},
   {"USDCAD","EURCAD","GBPCAD","CADJPY","CADCHF","AUDCAD","NZDCAD"},
   {"AUDUSD","EURAUD","GBPAUD","AUDJPY","AUDCHF","AUDCAD","AUDNZD"},
   {"NZDUSD","EURNZD","GBPNZD","NZDJPY","NZDCHF","NZDCAD","AUDNZD"}
   };
color currencycolor[8];

struct TypeTextObjects
{
   string objects[];
   void AddObject(string name)
   {
      bool found=false;
      int size=ArraySize(objects);
      for(int i=0; i<size; i++)
      {
         if(objects[i]==name)
         {
            found=true;
            break;
         }
      }
      if(!found)
      {
         ArrayResize(objects,size+1);
         objects[size]=name;
      }
   }
   void HideAll()
   {
      int size=ArraySize(objects);
      for(int i=0; i<size; i++)
         ObjectSetInteger(0,objects[i],OBJPROP_XDISTANCE,-1000);
   }
};

enum BEStopModes
{
   None=1,
   HardSingle=2,
   SoftBasket=3
};

enum Instruments
{
   CurrentPair=-1,
   USD=0,
   EUR=1,
   GBP=2,
   JPY=3,
   CHF=4,
   CAD=5,
   AUD=6,
   NZD=7,
};

enum TradesView
{
   ByPairs,
   ByCurrencies,
   ByCurrenciesGrouped
};

struct TypeTradeInfo
{
   int orderindex;
   int type;
   double volume;
   double openprice;
   datetime opentime;
   double points;
   double commissionpoints;
   double gain;
   double tickvalue;
   long magicnumber;
   long orderticket;
   TypeTradeInfo()
   {
      orderindex=-1;
      type=NULL;
      volume=0;
      openprice=0;
      opentime=0;
      points=0;
      commissionpoints=0;
      gain=0;
      tickvalue=0;
      magicnumber=0;
      orderticket=0;
   }
};

struct TypeTradeReference
{
   long magicnumber;
   double points;
   double gain;
   double tickvalue;
   double stoplosspips;
   double stoplosslevel;
   double takeprofitpips;
   double takeprofitlevel;
   double commissionpoints;
   double openprice;
   string pair;
   int type;
   double volume;
   datetime lastupdate;
   TypeTradeReference()
   {
      magicnumber=0;
      points=0;
      gain=0;
      tickvalue=0;
      stoplosspips=DISABLEDPOINTS;
      stoplosslevel=0;
      takeprofitpips=DISABLEDPOINTS;
      takeprofitlevel=0;
      commissionpoints=0;
      openprice=0;
      pair="";
      type=NULL;
      volume=0;
      lastupdate=0;
   }
};

struct TypeCloseCommand
{
   string filter;
   bool executed;
   TypeCloseCommand()
   {
      filter="";
      executed=false;
   }
};

struct TypeCloseCommands
{
   TypeCloseCommand commands[];
   void Init()
   {
      ArrayResize(commands,0);
   }
   void Add(string filter="")
   {
      int size=ArraySize(commands);
      ArrayResize(commands,size+1);
      commands[size].filter=filter;
   }
   int GetNextCommandIndex()
   {
      int index=-1;
      for(int i=ArraySize(commands)-1; i>=0; i--)
      {
         if(!commands[i].executed)
         {
            index=i;
            break;
         }
      }
      return index;
   }
};

struct TypePendingOrder
{
   int ordertype;
   double entryprice;
   double stopprice;
   double stoppoints;
   double volume;
};

struct TypeWorkingState
{
   BEStopModes StopMode;
   bool closebasketatBE;
   bool ManualBEStopLocked;
   bool SoftBEStopLocked;
   double peakgain;
   double peakpips;
   bool TrailingActivated;
   long currentbasemagicnumber;
   TypeTradeReference tradereference[];
   double globalgain;
   datetime lastorderexecution;
   TypeCloseCommands closecommands;
   TypePendingOrder pendingorders[];
   void Init()
   {
      closebasketatBE=false;
      ManualBEStopLocked=false;
      SoftBEStopLocked=false;
      StopMode=SoftBasket;
      peakgain=0;
      peakpips=0;
      TrailingActivated=false;
      currentbasemagicnumber=basemagicnumber;
      ArrayResize(tradereference,0);
      globalgain=0;
      lastorderexecution=0;
      closecommands.Init();
      ArrayResize(pendingorders,0);
   };
   void Reset()
   {
      closebasketatBE=false;
      ManualBEStopLocked=false;
      SoftBEStopLocked=false;
      peakgain=0;
      peakpips=0;
      TrailingActivated=false;
      currentbasemagicnumber=basemagicnumber;
      ArrayResize(tradereference,0);
      globalgain=0;
      ToggleTradeLevels(true);
      closecommands.Init();
   };
   void ResetLocks()
   {
      ManualBEStopLocked=false;
      SoftBEStopLocked=false;
   };
   bool IsOrderPending()
   {
      int lastordertimediff = (int)TimeLocal()-(int)lastorderexecution;
      return (lastordertimediff<=5);
   };
};

struct TypeCurrenciesTradesGroupsInfo
{
   int type;
   double volume;
   double gain;
   long magicfrom;
   long magicto;
   string containspairs;
   TypeCurrenciesTradesGroupsInfo()
   {
      type=0;
      volume=0;
      gain=0;
      magicfrom=LONG_MAX;
      magicto=LONG_MIN;
      containspairs="";
   }
};

struct TypeCurrenciesTradesInfo
{
   double buyvolume;
   double sellvolume;
   double buygain;
   double sellgain;
   TypeCurrenciesTradesGroupsInfo tg[];
   TypeCurrenciesTradesInfo()
   {
      buyvolume=0;
      sellvolume=0;
      buygain=0;
      sellgain=0;
      ArrayResize(tg,0);
   }
};

struct TypePairsTradesInfo
{
   string pair;
   double buyvolume;
   double sellvolume;
   double buygain;
   double sellgain;
   double gain;
   double gainpips;
   TypeTradeInfo tradeinfo[];
   TypePairsTradesInfo()
   {
      pair="";
      buyvolume=0;
      sellvolume=0;
      buygain=0;
      sellgain=0;
      gain=0;
      gainpips=0;
      ArrayResize(tradeinfo,0);
   }
};

struct TypeBasketInfo
{
   double gain;
   double gainpips;
   double gainpipsglobal;
   double gainpipsplus;
   double gainpipsminus;
   double volumeplus;
   double volumeminus;
   int buys;
   int sells;
   double buyvolume;
   double sellvolume;
   int managedorders;
   TypePairsTradesInfo pairsintrades[];
   TypeCurrenciesTradesInfo currenciesintrades[];
   int largestlossindex;
   double largestloss;
   double globalprofitloss;
   void Init()
   {
      gain=0;
      gainpips=0;
      gainpipsglobal=0;
      gainpipsplus=0;
      gainpipsminus=0;
      volumeplus=0;
      volumeminus=0;
      buys=0;
      sells=0;
      buyvolume=0;
      sellvolume=0;
      managedorders=0;
      ArrayResize(pairsintrades,0);
      ArrayResize(currenciesintrades,0);
      ArrayResize(currenciesintrades,8);
      largestlossindex=-1;
      largestloss=0;
      globalprofitloss=0;
   };
};

TypeTextObjects TextObjects;
TypeWorkingState WS;
TypeBasketInfo BI;


void OnInit()
{
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1);
   
   atr=0;
   atrday=-1;
   
   InstrumentSelected=CurrentPair;

   TradesViewSelected=ByPairs;

   ctrlon=false;
   crosshairon=false;
   leftmousebutton=false;
   lipstickmode=LipStickNone;
   currentlipstickmode=LipStickNone;
   startdragprice=0;
   enddragprice=0;
   tradelevelsvisible=false;

   initerror=false;
   
   appnamespace=appname+" "+IntegerToString(Instance)+" ";

   magicnumberfloor=10000000*Instance;

   basemagicnumber=magicnumberfloor+1;

   istesting=MQLInfoInteger(MQL_TESTER);
   
   _ShowInfo=ShowInfo;
   if(istesting&&MQLInfoInteger(MQL_VISUAL_MODE))
      _ShowInfo=true;

   SymbolExtraChars = StringSubstr(Symbol(), 6);

   lasttick=TimeLocal();

   pipsfactor=1;
   if(Digits()==5||Digits()==3)
      pipsfactor=10;

   _BreakEvenAfterPips=BreakEvenAfterPips*pipsfactor;
   _AboveBEPips=AboveBEPips*pipsfactor;
   _TakeProfitPips=TakeProfitPips*pipsfactor;
   if(_TakeProfitPips==0)
      _TakeProfitPips=DISABLEDPOINTS;
   _StopLossPips=StopLossPips*pipsfactor;
   if(_StopLossPips==0)
      _StopLossPips=DISABLEDPOINTS;
   _StartTrailingPips=StartTrailingPips*pipsfactor;
   _OpenLots=OpenLots;

   _TradingHours[0]=Hour0;
   _TradingHours[1]=Hour1;
   _TradingHours[2]=Hour2;
   _TradingHours[3]=Hour3;
   _TradingHours[4]=Hour4;
   _TradingHours[5]=Hour5;
   _TradingHours[6]=Hour6;
   _TradingHours[7]=Hour7;
   _TradingHours[8]=Hour8;
   _TradingHours[9]=Hour9;
   _TradingHours[10]=Hour10;
   _TradingHours[11]=Hour11;
   _TradingHours[12]=Hour12;
   _TradingHours[13]=Hour13;
   _TradingHours[14]=Hour14;
   _TradingHours[15]=Hour15;
   _TradingHours[16]=Hour16;
   _TradingHours[17]=Hour17;
   _TradingHours[18]=Hour18;
   _TradingHours[19]=Hour19;
   _TradingHours[20]=Hour20;
   _TradingHours[21]=Hour21;
   _TradingHours[22]=Hour22;
   _TradingHours[23]=Hour23;

   _TradingWeekdays[0]=Sunday;
   _TradingWeekdays[1]=Monday;
   _TradingWeekdays[2]=Tuesday;
   _TradingWeekdays[3]=Wednesday;
   _TradingWeekdays[4]=Thursday;
   _TradingWeekdays[5]=Friday;
   _TradingWeekdays[6]=Saturday;

   currencycolor[0]=Color_USD;
   currencycolor[1]=Color_EUR;
   currencycolor[2]=Color_GBP;
   currencycolor[3]=Color_JPY;
   currencycolor[4]=Color_CHF;
   currencycolor[5]=Color_CAD;
   currencycolor[6]=Color_AUD;
   currencycolor[7]=Color_NZD;

   WS.Init();
   
   if(!istesting)
      GetGlobalVariables();

   chartheight=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);

   if(DrawBackgroundPanel&&_ShowInfo)
   {
      string objname=appnamespace+"Panel";
      ObjectCreate(0,objname,OBJ_RECTANGLE_LABEL,0,0,0,0,0);
      ObjectSetInteger(0,objname,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,objname,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,objname,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,objname,OBJPROP_XDISTANCE,BackgroundPanelWidth);
      ObjectSetInteger(0,objname,OBJPROP_YDISTANCE,0);
      ObjectSetInteger(0,objname,OBJPROP_XSIZE,BackgroundPanelWidth);
      ObjectSetInteger(0,objname,OBJPROP_YSIZE,10000);
      color c=(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND);
      if(BackgroundPanelColor!=clrNONE)
         c=BackgroundPanelColor;
      ObjectSetInteger(0,objname,OBJPROP_COLOR,c);
      ObjectSetInteger(0,objname,OBJPROP_BGCOLOR,c);
   }

   InitStrategies();
   
   InitTesting();

   if(!istesting)
   {
      if(!EventSetMillisecondTimer(200))
         initerror=true;
   }
}


void AppInit()
{
   if(appinit)
      return;

   SymbolCommission=0;
   HistorySelect(0,TimeCurrent());
   int total=HistoryDealsTotal();
   ulong ticket=0;
   for(int i=total-1;i>=0;i--)
   {
      if((ticket=HistoryDealGetTicket(i))>0)
      {
         if(HistoryDealGetString(ticket,DEAL_SYMBOL)==Symbol())
         {
            SymbolCommission=MathAbs(NormalizeDouble(HistoryDealGetDouble(ticket,DEAL_COMMISSION)/HistoryDealGetDouble(ticket,DEAL_VOLUME),2)*2);
            break;
         }
      }
   }
   appinit=true;
}


void InitTesting()
{
   if(!istesting)
      return;

   //WS.StopMode=None;
   //_OpenLots=0.1;
   //ctrlon=true;
   //TradesViewSelected=ByCurrencies;

   //OpenBuy("GBPUSD");
   //OpenSell("EURGBP");
   //OpenBuy("GBPJPY");
   //OpenBuy("GBPCHF");
   //OpenBuy("GBPCAD");
   //OpenBuy("GBPAUD");
   //OpenBuy("GBPNZD");

   //OpenSell("GBPUSD");
   //OpenBuy("EURGBP");
   //OpenSell("GBPJPY");
   //OpenSell("GBPCHF");
   //OpenSell("GBPCAD");
   //OpenSell("GBPAUD");
   //OpenSell("GBPNZD");

   //WS.closecommands.Add();

   //ArrayResize(strats,1);
   //strats[0]=new StrategyCSGBPBaskets;
   //strats[0]=new StrategyOutOfTheBox;
   //strats[0]=new StrategyLittleDD;
   //strats[0]=new StrategyPivotsH4FibonacciR1S1Reversal;

#ifdef __MQL5__
   //OpenDBConnection();
   //CloseDBConnection();
#endif
}


void InitStrategies()
{
   ArrayResize(strats,0);
   int i=0;

   if(Harvester_CSGBPReversal)
   {
      ArrayResize(strats,i+1);
      strats[i]=new StrategyCSGBPReversal;
      i++;
   }
   if(Harvester_CSGBP45MinStrength)
   {
      ArrayResize(strats,i+1);
      strats[i]=new StrategyCSGBP45MinStrength;
      i++;
   }
   if(Harvester_CSFollow)
   {
      ArrayResize(strats,i+1);
      strats[i]=new StrategyCSFollow;
      i++;
   }
   if(Harvester_GBPWeek)
   {
      ArrayResize(strats,i+1);
      strats[i]=new StrategyGBPWeek;
      i++;
   }
   if(Harvester_CSEmergingTrends)
   {
      ArrayResize(strats,i+1);
      strats[i]=new StrategyCSEmergingTrends;
      i++;
   }
}


void OnDeinit(const int reason)
{
   for(int i=ArraySize(strats)-1; i>=0; i--)
      delete strats[i];

   EventKillTimer();
#ifdef __MQL5__
   if(istesting)
   {
      //CloseDBConnection();
   //if(!MQL5InfoInteger(MQL5_OPTIMIZATION))
   }
#endif
   if(!istesting)
   {
      DeleteAllObjects();
      SetGlobalVariables();
      ToggleCtrl(true);
      ToggleTradeLevels(true);
   }
}


void OnTick()
{
   lasttick=TimeLocal();

   if(ctrlon)
      DrawLevels();

   CheckPendingOrders();
   Manage();
}


void OnTimer()
{
   Manage();
}


void Manage()
{
   if(working||initerror||!TerminalInfoInteger(TERMINAL_CONNECTED))
      return;
   working=true;

   AppInit();

   int closecommandindex=WS.closecommands.GetNextCommandIndex();
   while(closecommandindex>-1)
   {
      CloseAllInternal(WS.closecommands.commands[closecommandindex].filter);
      WS.closecommands.commands[closecommandindex].executed=true;
      closecommandindex=WS.closecommands.GetNextCommandIndex();
   }

   if(currentlipstickmode!=lipstickmode)
   {
      if(lipstickmode==LipStickNone)
         DeleteLipstick();
      else
         CreateLipstick();
      currentlipstickmode=lipstickmode;
   }

   if(ManageOrders())
   {
      ManageBasket();
      DisplayText();
   }

   for(int i=ArraySize(strats)-1; i>=0; i--)
      strats[i].Calculate();

   working=false;
}


void SetBEClose()
{
   if(WS.globalgain<0)
   {
      WS.closebasketatBE=!WS.closebasketatBE;
   }
   if(WS.globalgain>=0)
   {
      WS.ManualBEStopLocked=!WS.ManualBEStopLocked;
   }
}


void SetSoftStopMode()
{
   if(WS.StopMode==None)
      WS.StopMode=SoftBasket;
   else if(WS.StopMode==HardSingle)
      WS.StopMode=None;
   else
      WS.StopMode=None;

   WS.ResetLocks();
      
   SetGlobalVariables();
}


void SetHardStopMode()
{
   if(WS.StopMode==None)
      WS.StopMode=HardSingle;
   else if(WS.StopMode==SoftBasket)
      WS.StopMode=None;
   else
      WS.StopMode=None;

   WS.ResetLocks();
      
   SetGlobalVariables();
}


void SetGlobalVariables()
{
   string varname;
   GlobalVariableSet(appnamespace+"StopMode",WS.StopMode);
   GlobalVariableSet(appnamespace+"peakgain",WS.peakgain);
   GlobalVariableSet(appnamespace+"peakpips",WS.peakpips);
   GlobalVariableSet(appnamespace+"OpenLots",_OpenLots);
   GlobalVariableSet(appnamespace+"StopLossPips",_StopLossPips);
   GlobalVariableSet(appnamespace+"TakeProfitPips",_TakeProfitPips);
   GlobalVariableSet(appnamespace+"currentbasemagicnumber",WS.currentbasemagicnumber);
   varname=appnamespace+"ManualBEStopLocked";
   if(WS.ManualBEStopLocked)
      GlobalVariableSet(varname,0);
   else
      GlobalVariableDel(varname);
   varname=appnamespace+"closebasketatBE";
   if(WS.closebasketatBE)
      GlobalVariableSet(varname,0);
   else
      GlobalVariableDel(varname);

   GlobalVariableSet(appnamespace+"lipstickmode",lipstickmode);

   GlobalVariableSet(appnamespace+"InstrumentSelected",InstrumentSelected);

   GlobalVariableSet(appnamespace+"TradesViewSelected",TradesViewSelected);

   int asize=ArraySize(WS.tradereference);
   for(int i=0; i<asize; i++)
   {
      GlobalVariableSet(appnamespace+"TradeReference.gain"+IntegerToString(WS.tradereference[i].magicnumber),WS.tradereference[i].gain);
      GlobalVariableSet(appnamespace+"TradeReference.stoplosspips"+IntegerToString(WS.tradereference[i].magicnumber),WS.tradereference[i].stoplosspips);
      GlobalVariableSet(appnamespace+"TradeReference.stoplosslevel"+IntegerToString(WS.tradereference[i].magicnumber),WS.tradereference[i].stoplosslevel);
      GlobalVariableSet(appnamespace+"TradeReference.takeprofitpips"+IntegerToString(WS.tradereference[i].magicnumber),WS.tradereference[i].takeprofitpips);
      GlobalVariableSet(appnamespace+"TradeReference.takeprofitlevel"+IntegerToString(WS.tradereference[i].magicnumber),WS.tradereference[i].takeprofitlevel);
   }
}


void GetGlobalVariables()
{
   string varname=appnamespace+"StopMode";
   if(GlobalVariableCheck(varname))
      WS.StopMode=(BEStopModes)GlobalVariableGet(varname);
   varname=appnamespace+"peakgain";
   if(GlobalVariableCheck(varname))
      WS.peakgain=GlobalVariableGet(varname);
   varname=appnamespace+"peakpips";
   if(GlobalVariableCheck(varname))
      WS.peakpips=GlobalVariableGet(varname);
   varname=appnamespace+"OpenLots";
   if(GlobalVariableCheck(varname))
      _OpenLots=GlobalVariableGet(varname);
   varname=appnamespace+"StopLossPips";
   if(GlobalVariableCheck(varname))
      _StopLossPips=GlobalVariableGet(varname);
   varname=appnamespace+"TakeProfitPips";
   if(GlobalVariableCheck(varname))
      _TakeProfitPips=GlobalVariableGet(varname);
   varname=appnamespace+"currentbasemagicnumber";
   if(GlobalVariableCheck(varname))
      WS.currentbasemagicnumber=(int)GlobalVariableGet(varname);
   varname=appnamespace+"ManualBEStopLocked";
   if(GlobalVariableCheck(varname))
      WS.ManualBEStopLocked=true;
   varname=appnamespace+"closebasketatBE";
   if(GlobalVariableCheck(varname))
      WS.closebasketatBE=true;
   varname=appnamespace+"lipstickmode";
   if(GlobalVariableCheck(varname))
      lipstickmode=(int)GlobalVariableGet(varname);
   varname=appnamespace+"InstrumentSelected";
   if(GlobalVariableCheck(varname))
      InstrumentSelected=(int)GlobalVariableGet(varname);
   varname=appnamespace+"TradesViewSelected";
   if(GlobalVariableCheck(varname))
      TradesViewSelected=(int)GlobalVariableGet(varname);
      
   int varcount=GlobalVariablesTotal();
   for(int i=0; i<varcount; i++)
   {
      string n=GlobalVariableName(i);
      string s;
      long magicnumber;
      int p;

      s=appnamespace+"TradeReference.gain";
      p=StringFind(n,s);
      if(p==0)
      {
         magicnumber=StringToInteger(StringSubstr(n,StringLen(s)));
         UpdateTradeReference(magicnumber,GlobalVariableGet(n));
      }

      s=appnamespace+"TradeReference.stoplosspips";
      p=StringFind(n,s);
      if(p==0)
      {
         magicnumber=StringToInteger(StringSubstr(n,StringLen(s)));
         UpdateTradeReference(magicnumber,NULL,GlobalVariableGet(n));
      }

      s=appnamespace+"TradeReference.stoplosslevel";
      p=StringFind(n,s);
      if(p==0)
      {
         magicnumber=StringToInteger(StringSubstr(n,StringLen(s)));
         UpdateTradeReference(magicnumber,NULL,NULL,NULL,GlobalVariableGet(n));
      }

      s=appnamespace+"TradeReference.takeprofitpips";
      p=StringFind(n,s);
      if(p==0)
      {
         magicnumber=StringToInteger(StringSubstr(n,StringLen(s)));
         UpdateTradeReference(magicnumber,NULL,NULL,GlobalVariableGet(n));
      }

      s=appnamespace+"TradeReference.takeprofitlevel";
      p=StringFind(n,s);
      if(p==0)
      {
         magicnumber=StringToInteger(StringSubstr(n,StringLen(s)));
         UpdateTradeReference(magicnumber,NULL,NULL,NULL,NULL,GlobalVariableGet(n));
      }
   }
}


double GetGlobalReferencesGain()
{
   double gain=0;
   int asize=ArraySize(WS.tradereference);
   for(int i=0; i<asize; i++)
      gain+=WS.tradereference[i].gain;
   return gain;
}


void ClearGlobalReferences()
{
   GlobalVariablesDeleteAll(appnamespace+"TradeReference");
   GlobalVariablesDeleteAll(appnamespace+"currentbasemagicnumber");
}


bool IsOrderToManage()
{
   bool manage=true,
   ismagicnumber=(OrderMagicNumberX()==ManageMagicNumberOnly),
   isinternalmagicnumber=(OrderMagicNumberX()>=basemagicnumber)&&(OrderMagicNumberX()<=basemagicnumber+(hedgeoffsetmagicnumber*100)),
   isordernumber=(OrderTicketX()==ManageOrderNumberOnly);
   
   if((ManageMagicNumberOnly>0&&!ismagicnumber)||(ManageOwnTradesOnly&&ManageMagicNumberOnly==0&&!isinternalmagicnumber))
      manage=false;
   
   if(ManageOrderNumberOnly>0&&!isordernumber)
      manage=false;
   return manage;
}


bool ManageOrders()
{
   int cnt, ordertotal=OrdersTotalX();

   BI.Init();
   
   BI.globalprofitloss=GetDayProfitLossClosed();

   for(cnt=0;cnt<ordertotal;cnt++)
   {
      if(OrderSelectX(cnt))
      {
         double gain=OrderProfitNet();

         BI.globalprofitloss+=gain;

         if(IsOrderToManage())
         {
            double tickvalue=OrderSymbolTickValue();
            if(tickvalue==0)
               return false;
            double gainpips=(gain/OrderLotsX())/tickvalue;

            TypeTradeInfo ti;
            ti.orderindex=cnt;

            BI.managedorders++;
            int pidx=GetPairsInTradesIndex(OrderSymbolX());

            BI.pairsintrades[pidx].gainpips+=gainpips/pipsfactor;

            double BESL=0;
            bool NeedSetSL=false;
            int hedgeordertype=0;
            if(OrderTypeSell())
            {
               ti.type=OP_SELL;
               hedgeordertype=OP_BUY;
               BESL=OrderOpenPriceX()-(_AboveBEPips*SymbolInfoDouble(OrderSymbolX(),SYMBOL_POINT));
               BI.sells++;
               BI.sellvolume+=OrderLotsX();
               BI.pairsintrades[pidx].sellvolume+=OrderLotsX();
               BI.pairsintrades[pidx].sellgain+=gain;
               if(OrderStopLossX()==0||OrderStopLossX()>BESL)
                  NeedSetSL=true;
            }
            if(OrderTypeBuy())
            {
               ti.type=OP_BUY;
               hedgeordertype=OP_SELL;
               BESL=OrderOpenPriceX()+(_AboveBEPips*SymbolInfoDouble(OrderSymbolX(),SYMBOL_POINT));
               BI.buys++;
               BI.buyvolume+=OrderLotsX();
               BI.pairsintrades[pidx].buyvolume+=OrderLotsX();
               BI.pairsintrades[pidx].buygain+=gain;
               if(OrderStopLossX()==0||OrderStopLossX()<BESL)
                  NeedSetSL=true;
            }

            BI.pairsintrades[pidx].gain+=gain;
            if(gain<0&&gain<BI.largestloss)
            {
               BI.largestlossindex=cnt;
               BI.largestloss=gain;
            }
            BI.gain+=gain;

            if(gainpips<0)
            {
               BI.gainpipsminus+=gainpips*OrderLotsX()*tickvalue;
               BI.volumeminus+=OrderLotsX()*tickvalue;
            }
            else
            {
               BI.gainpipsplus+=gainpips*OrderLotsX()*tickvalue;
               BI.volumeplus+=OrderLotsX()*tickvalue;
            }
            
            if(WS.StopMode==HardSingle&&gainpips>=_BreakEvenAfterPips&&NeedSetSL)
               SetOrderSL(BESL);

            ti.volume=OrderLotsX();
            ti.openprice=OrderOpenPriceX();
            ti.opentime=(int)PositionGetInteger(POSITION_TIME);
            ti.points=gainpips;
            ti.commissionpoints=NormalizeDouble((OrderCommissionSwap()/ti.volume)/tickvalue,0);
            ti.gain=gain;
            ti.tickvalue=tickvalue;
            ti.magicnumber=OrderMagicNumberX();
            ti.orderticket=OrderTicketX();
            AddTrade(BI.pairsintrades[pidx],BI.pairsintrades[pidx].tradeinfo,ti);
         }
      }
   }
   return true;
}


void ManageBasket()
{
   if(BI.managedorders==0&&WS.IsOrderPending())
      return;

   if(BI.managedorders==0)
   {
      WS.Reset();
      ClearGlobalReferences();
      
      for(int i=ArraySize(strats)-1; i>=0; i--)
         strats[i].IdleCalculate();

#ifdef __MQL5__
      //#include <TradeManagerEntryTesting1.mqh>
      
      // Dredging Test
      //OpenBuy();
      //OpenSell();
#endif

      return;
   }
   
   bool closeall=false;
   
   WS.globalgain=GetGlobalReferencesGain();

   BI.gainpips=(BI.gainpipsplus+BI.gainpipsminus)/(BI.volumeplus+BI.volumeminus);
   
   BI.gainpipsglobal=0;
   if(BI.gain!=0)
      BI.gainpipsglobal=(BI.gainpips/BI.gain)*WS.globalgain;

   WS.peakpips=MathMax(BI.gainpipsglobal,WS.peakpips);
   
   WS.peakgain=MathMax(WS.globalgain,WS.peakgain);

   int size1=ArraySize(BI.pairsintrades);
   for(int i=0; i<size1; i++)
   {
      int size2=ArraySize(BI.pairsintrades[i].tradeinfo);
      for(int j=0; j<size2; j++)
      {
         TypeTradeInfo ti=BI.pairsintrades[i].tradeinfo[j];
         TypeTradeReference tr=WS.tradereference[TradeReferenceIndex(ti.magicnumber)];

         if(OrderSelectX(ti.orderindex)&&IsAutoTradingEnabled())
         {
         
            double bid=BidX(tr.pair);

            if((tr.takeprofitpips!=DISABLEDPOINTS&&(ti.points-tr.takeprofitpips)>=0)
            ||(tr.takeprofitlevel!=0&&bid!=0&&((ti.type==OP_SELL&&bid<=tr.takeprofitlevel)||(ti.type==OP_BUY&&bid>=tr.takeprofitlevel))))
            {
               if(CloseSelectedOrder())
               {

// EXPERIMENTAL
                  if(Automation==Dredging)
                  {
                     if(j==size2-1||j==size2-2)
                     {
                        OpenBuy(BI.pairsintrades[i].pair);
                        OpenSell(BI.pairsintrades[i].pair);
                     }
                  }


               }
            }

            if((tr.stoplosspips!=DISABLEDPOINTS&&(ti.points+tr.stoplosspips)<=0)
            ||(tr.stoplosslevel!=0&&bid!=0&&((ti.type==OP_SELL&&bid>=tr.stoplosslevel)||(ti.type==OP_BUY&&bid<=tr.stoplosslevel))))
            {
               if(HedgeAtStopLoss)
               {
                  long hedgemagicnumber=GetHedgeMagicNumber(BI.pairsintrades[i].tradeinfo,ti);
                  double hedgevolume=GetHedgeVolume(BI.pairsintrades[i].tradeinfo,ti);
                  if(hedgemagicnumber>-1&&hedgevolume>0)
                  {
                     if(OpenOrder(HedgeType(ti.type),BI.pairsintrades[i].pair+SymbolExtraChars,hedgevolume,hedgemagicnumber))
                     {
                     }
                  }
               }
               else
               {
                  if(CloseSelectedOrder())
                  {
                  }
               }
            }
            
         }
      }
   }

   if(MaxDailyLoss>0)
      if(BI.globalprofitloss<=(0-MaxDailyLoss))
         closeall=true;

   if(StopLossPercentTradingCapital>0)
   {
      if((WS.globalgain)+((AccountBalanceNet()/100)*StopLossPercentTradingCapital)<=0)
      {
         if(StopLossPercentTradingCapitalAction==CloseWorstTrade)
         {
            if(OrderSelectX(BI.largestlossindex)&&IsAutoTradingEnabled())
            {
               if(CloseSelectedOrder())
               {
               }
            }
         }
         else if(StopLossPercentTradingCapitalAction==CloseAllTrades)
         {
            closeall=true;
         }
      }
   }

   if(ActivateTrailing&&_StartTrailingPips>0&&BI.gainpipsglobal>=_StartTrailingPips)
      WS.TrailingActivated=true;

   if(TakeProfitPercentTradingCapital>0&&WS.globalgain/(AccountBalanceNet()/100)>=TakeProfitPercentTradingCapital)
      closeall=true;

   if(WS.TrailingActivated&&WS.globalgain<=GetTrailingLimit())
      closeall=true;
   
   if(WS.closebasketatBE&&WS.globalgain>=0)
      closeall=true;

   if(WS.ManualBEStopLocked&&WS.globalgain<=0)
      closeall=true;
   
   if(WS.StopMode==SoftBasket&&_BreakEvenAfterPips>0&&WS.peakpips>=_BreakEvenAfterPips)
      WS.SoftBEStopLocked=true;   
   
   if(WS.SoftBEStopLocked&&BI.gainpipsglobal<_AboveBEPips)
      closeall=true;

   if(CloseTradesBeforeMidnight)
   {
      MqlDateTime tc;
      TimeCurrent(tc);
      if(tc.hour==CloseTradesBeforeMidnightHour&&tc.min==CloseTradesBeforeMidnightMinute)
         closeall=true;
   }

   if(closeall)
      CloseAllInternal();
      
   if(tradelevelsvisible)
   {
      if(TimeLocal()-WS.tradereference[selectedtradeindex].lastupdate>1)
         ToggleTradeLevels(false);
   }
}


double GetDayProfitLossClosed()
{
   double profits=0;
   MqlDateTime s;
   TimeCurrent(s);
   s.hour=0;
   s.min=0;
   s.sec=0;
   HistorySelect(StructToTime(s),TimeCurrent());
   int total=HistoryDealsTotal();
   ulong ticket=0;
   for(int i=total-1;i>=0;i--)
   {
      if((ticket=HistoryDealGetTicket(i))>0)
      {
         if(HistoryDealGetInteger(ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
         {
            double commission=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
            if(MT5CommissionPerDeal)
               commission=commission*2;
            profits+=commission;
            profits+=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         }
      }
   }
   return profits;
}


void CheckPendingOrders()
{
   if(ArraySize(WS.pendingorders)>0)
   {
      double ask=AskX();
      double bid=BidX();
      TypePendingOrder p=WS.pendingorders[0];
      int openorder=-1;
   
      if(p.ordertype==ORDER_TYPE_BUY_STOP && ask>=p.entryprice)
         openorder=OP_BUY;

      if(p.ordertype==ORDER_TYPE_BUY_LIMIT && ask<=p.entryprice)
         openorder=OP_BUY;

      if(p.ordertype==ORDER_TYPE_SELL_STOP && bid<=p.entryprice)
         openorder=OP_SELL;

      if(p.ordertype==ORDER_TYPE_SELL_LIMIT && bid>=p.entryprice)
         openorder=OP_SELL;

      double minvolume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
      double volumestep=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
      int volumesplit=MathMax(PendingOrdersSplit,1);
      volumesplit=(int)MathMin(MathFloor(p.volume/minvolume),volumesplit);
      
      for(int i=1;i<=volumesplit;i++)
      {
         double v=MathRound((p.volume/volumesplit)/volumestep)*volumestep;
         if(i==volumesplit)
            v=p.volume-(v*(i-1));
            
         double takeprofitpoints=(p.stoppoints*PendingOrdersFirstTPStep)+((p.stoppoints*PendingOrdersNextTPSteps)*(i-1));

         if(openorder==OP_BUY)
            OpenBuy(NULL,v,0,p.stoppoints,takeprofitpoints);
   
         if(openorder==OP_SELL)
            OpenSell(NULL,v,0,p.stoppoints,takeprofitpoints);
      }

      if(openorder!=-1)
      {
         ArrayResize(WS.pendingorders,0);
         ObjectsDeleteAll(0,appnamespace+"PendingLevel");
      }
   }
}


double GetTrailingLimit()
{
   return WS.peakgain*TrailingFactor;
}


void DisplayText()
{
   if(!_ShowInfo)
      return;

   DeleteText();

   if(tickchar=="")
      tickchar="\x2022 ";
   else
      tickchar="";

   int rowindex=0;

   if(!IsAutoTradingEnabled())
   {
      CreateLabel(rowindex,FontSize,TextColorMinus,tickchar+" Autotrading Disabled");
      rowindex++;
   }
   else
   {
      if(TimeLocal()-lasttick>60)
         CreateLabel(rowindex,FontSize,TextColorMinus,tickchar+" No Market Activity");
      else
         CreateLabel(rowindex,FontSize,TextColorPlus,tickchar+" Running");
      rowindex++;
   }
   
   for(int i=ArraySize(strats)-1; i>=0; i--)
   {
      color c=TextColorPlus;

      MqlDateTime tc;
      TimeCurrent(tc);
      if(!_TradingHours[tc.hour]||!_TradingWeekdays[tc.day_of_week])
         c=TextColorMinus;
   
      CreateLabel(rowindex,FontSize,c,strats[i].GetName());
      rowindex++;
   }

   string stopmodetext="";
   if(WS.StopMode==None)
      stopmodetext="No Break Even Mode";
   if(WS.StopMode==HardSingle)
      stopmodetext="Hard Single Break Even Mode";
   if(WS.StopMode==SoftBasket)
      stopmodetext="Soft Basket Break Even Mode";
   CreateLabel(rowindex,FontSize,TextColor,stopmodetext);
   rowindex++;

   if(CloseTradesBeforeMidnight)
   {
      CreateLabel(rowindex,FontSize,TextColor,"Closing all Trades at "+IntegerToString(CloseTradesBeforeMidnightHour)+":"+IntegerToString(CloseTradesBeforeMidnightMinute,2,'0'));
      rowindex++;
   }

   string moretradingcapital="";
   if(AvailableTradingCapital>0)
      moretradingcapital=" | "+IntegerToString(AvailableTradingCapital);
   CreateLabel(rowindex,FontSize,TextColor,"Balance: "+DoubleToString(AccountBalanceX(),0)+moretradingcapital);
   rowindex++;

   CreateLabel(rowindex,FontSize,TextColor,"Free Margin: "+DoubleToString(AccountFreeMarginX(),1));
   rowindex++;

   CreateLabel(rowindex,FontSize,TextColor,"Leverage: "+IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE)));
   rowindex++;

   if(StopLossPercentTradingCapital>0)
   {
      CreateLabel(rowindex,FontSize,TextColor,"General Stop Loss: "+DoubleToString(StopLossPercentTradingCapital,1)+"%");
      rowindex++;
   }

   if(MaxDailyLoss>0)
   {
      CreateLabel(rowindex,FontSize,TextColor,"Max Daily Loss: "+DoubleToString(MaxDailyLoss,0));
      rowindex++;
   }
   
   CreateLabel(rowindex,FontSize,TextColor,"Profit/Loss Today: "+DoubleToString(BI.globalprofitloss,2));
   rowindex++;

   if(TakeProfitPercentTradingCapital>0)
   {
      CreateLabel(rowindex,FontSize,TextColor,"General Take Profit: "+DoubleToString(TakeProfitPercentTradingCapital,1)+"%");
      rowindex++;
   }

   if(ctrlon)
   {
      CreateLabel(rowindex,FontSize,TextColorInfo,"Open Volume: "+DoubleToString(_OpenLots,2));
      rowindex++;
      
      if(InstrumentSelected!=CurrentPair)
      {
         CreateLabel(rowindex,FontSize,TextColorInfo,"Open all "+currencies[InstrumentSelected]+" Pairs");
         rowindex++;
      }
   }

   double tickvalue=CurrentSymbolTickValue();
   int spreadpoints=(int)MathRound((AskX()-BidX())/Point());
   if((_StopLossPips!=DISABLEDPOINTS&&ctrlon)||tradelevelsvisible)
   {
      color c=TextColorInfo;
      double risk=_StopLossPips*_OpenLots*tickvalue;
      double riskpercent=risk/(AccountBalanceX()/100);
      double atrfactor=_StopLossPips/(ATR()/Point());
      if(tradelevelsvisible)
      {
         c=TextColorInfo;
         risk=0;
         if(WS.tradereference[selectedtradeindex].stoplosspips!=DISABLEDPOINTS)
         {
            risk=WS.tradereference[selectedtradeindex].stoplosspips*WS.tradereference[selectedtradeindex].volume*tickvalue;
            riskpercent=risk/(AccountBalanceX()/100);
            atrfactor=WS.tradereference[selectedtradeindex].stoplosspips/(ATR()/Point());
         }
      }
      if(risk!=0)
      {
         string riskpercenttradingcapital="";
         if(AvailableTradingCapital>0)
            riskpercenttradingcapital=" | "+DoubleToString(risk/(AvailableTradingCapital/100),2)+"%";
         CreateLabel(rowindex,FontSize,c,"Risk: "+DoubleToString(risk,2)+" | "+DoubleToString(riskpercent,2)+"%"+riskpercenttradingcapital+" | "+DoubleToString(atrfactor*100,1)+"%ATR");
         rowindex++;
      }
   }
   if((_TakeProfitPips!=DISABLEDPOINTS&&ctrlon)||tradelevelsvisible)
   {
      color c=TextColorInfo;
      double reward=_TakeProfitPips*_OpenLots*tickvalue;
      double rewardpercent=reward/(AccountBalanceX()/100);
      if(tradelevelsvisible)
      {
         c=TextColorInfo;
         reward=0;
         if(WS.tradereference[selectedtradeindex].takeprofitpips!=DISABLEDPOINTS)
         {
            reward=WS.tradereference[selectedtradeindex].takeprofitpips*WS.tradereference[selectedtradeindex].volume*tickvalue;
            rewardpercent=reward/(AccountBalanceX()/100);
         }
      }
      if(reward!=0)
      {
         string rewardpercenttradingcapital="";
         if(AvailableTradingCapital>0)
            rewardpercenttradingcapital=" | "+DoubleToString(reward/(AvailableTradingCapital/100),2)+"%";
         CreateLabel(rowindex,FontSize,c,"Reward: "+DoubleToString(reward,2)+" | "+DoubleToString(rewardpercent,2)+"%"+rewardpercenttradingcapital);
         rowindex++;
      }
   }

   if(BI.managedorders!=0)
   {
      if(BI.buyvolume>0)
      {      
         CreateLabel(rowindex,FontSize,TextColor,IntegerToString(BI.buys)+" Buy: "+DoubleToString(BI.buyvolume,2));
         rowindex++;
      }
   
      if(BI.sellvolume>0)
      {
         CreateLabel(rowindex,FontSize,TextColor,IntegerToString(BI.sells)+" Sell: "+DoubleToString(BI.sellvolume,2));
         rowindex++;
      }
   
      CreateLabel(rowindex,FontSize,TextColor,"Pips: "+DoubleToString(BI.gainpipsglobal/pipsfactor,1));
      rowindex++;
   
      string performancepercenttradingcapital="";
      if(AvailableTradingCapital>0)
         performancepercenttradingcapital=" | "+DoubleToString(WS.globalgain/(AvailableTradingCapital/100),2)+"%";
      CreateLabel(rowindex,FontSize,TextColor,"Performance: "+DoubleToString(WS.globalgain/(AccountBalanceX()/100),2)+"%"+performancepercenttradingcapital);
      rowindex++;

      if(!WS.TrailingActivated&&!WS.ManualBEStopLocked&&!WS.SoftBEStopLocked)
      {
         double totalrisk=0;
         int asize=ArraySize(WS.tradereference);
         for(int i=0; i<asize; i++)
         {
            if(TimeLocal()-WS.tradereference[i].lastupdate<2)
            {
               if(WS.tradereference[i].stoplosspips!=DISABLEDPOINTS)
                  totalrisk+=WS.tradereference[i].stoplosspips*WS.tradereference[i].volume*WS.tradereference[i].tickvalue;
               else
               {
                  totalrisk=DBL_MAX;
                  break;
               }
            }
         }
         if(totalrisk!=DBL_MAX)
            totalrisk-=(WS.globalgain-BI.gain);

         if(StopLossPercentTradingCapital>0)
         {
            double ptcrisk=(AccountBalanceNet()/100)*StopLossPercentTradingCapital;
            totalrisk=MathMin(ptcrisk,totalrisk);
         }

         if(MaxDailyLoss>0)
         {
            double dayriskleft=MaxDailyLoss+BI.globalprofitloss-BI.gain;
            totalrisk=MathMin(dayriskleft,totalrisk);
         }

         color c=TextColorMinus;
         string risktext="Risk Unlimited";
         if(totalrisk!=DBL_MAX)
         {
            risktext="At Risk: ";
            if(totalrisk<=0)
            {
               totalrisk=0-totalrisk;
               c=TextColorPlus;
               risktext="Locked: ";
            }
            string riskpercenttradingcapital="";
            if(AvailableTradingCapital>0)
               riskpercenttradingcapital=" | "+DoubleToString(totalrisk/(AvailableTradingCapital/100),2)+"%";
            risktext+=DoubleToString(totalrisk,2)+" | "+DoubleToString(totalrisk/(AccountBalanceX()/100),2)+"%"+riskpercenttradingcapital;
         }
         CreateLabel(rowindex,FontSize,c,risktext);
         rowindex++;
      }
   
      if(WS.closebasketatBE)
      {
         CreateLabel(rowindex,FontSize,TextColorMinus,"Close Basket at Break Even");
         rowindex++;
      }
   
      if(WS.TrailingActivated)
      {
         CreateLabel(rowindex,FontSize,TextColorPlus,"Trailing Activ, Current Limit: "+DoubleToString(GetTrailingLimit(),2));
         rowindex++;
      }
      else
      {
         if(WS.ManualBEStopLocked)
         {
            CreateLabel(rowindex,FontSize,TextColorPlus,"Manual Break Even Stop Locked");
            rowindex++;
         }
      
         if(WS.SoftBEStopLocked)
         {
            CreateLabel(rowindex,FontSize,TextColorPlus,"Basket Break Even Stop Locked");
            rowindex++;
         }
      }

      color gaincolor=TextColorPlus;
      double gain=BI.gain;
      if(tradelevelsvisible)
         gain=WS.tradereference[selectedtradeindex].gain;
      if(gain<0)
         gaincolor=TextColorMinus;
      CreateLabel(rowindex,(int)MathFloor(FontSize*2.3),gaincolor,DoubleToString(gain,2));
      rowindex++;
      rowindex++;
      
      double globalgain=NormalizeDouble(WS.globalgain,2);
      if(globalgain!=NormalizeDouble(BI.gain,2))
      {
         color closedlossescolor=TextColorPlus;
         double gaintotal=globalgain;
         if(gaintotal<0)
            closedlossescolor=TextColorMinus;
         CreateLabel(rowindex,FontSize,closedlossescolor,DoubleToString(gaintotal,2));
         rowindex++;
      }
   
      int asize=ArraySize(BI.pairsintrades);

      if(listshift>0)
         CreateArrowUp(rowindex);

      string tooltip="";
      if(ctrlon)
         tooltip="Click to Close";

      if(TradesViewSelected==ByPairs)
      {
         if(asize>0)
         {
            CreateLabel(rowindex,FontSize,TextColor,"Sells","1",65);
            CreateLabel(rowindex,FontSize,TextColor,"Buys","2",140);
            rowindex++;
         }

         for(int i=0; i<asize; i++)
         {
            color paircolor=TextColor;
            if(BI.pairsintrades[i].pair+SymbolExtraChars==Symbol())
               paircolor=TextColorBold;
            CreateLabel(rowindex,FontSize,paircolor,BI.pairsintrades[i].pair,"-TMSymbolButton",0,"",i);
   
            int hshift=60;
            if(BI.pairsintrades[i].buyvolume>0)
            {
               color pcolor=TextColorPlus;
               if(BI.pairsintrades[i].buygain<0)
                  pcolor=TextColorMinus;
               CreateLabel(rowindex,FontSize,pcolor,DoubleToString(BI.pairsintrades[i].buyvolume,2)+" "+DoubleToString(BI.pairsintrades[i].buygain,2),"-TMCC-Buys-"+BI.pairsintrades[i].pair,140,tooltip,i);
               hshift+=90;
            }
            if(BI.pairsintrades[i].sellvolume>0)
            {
               color pcolor=TextColorPlus;
               if(BI.pairsintrades[i].sellgain<0)
                  pcolor=TextColorMinus;
               CreateLabel(rowindex,FontSize,pcolor,DoubleToString(BI.pairsintrades[i].sellvolume,2)+" "+DoubleToString(BI.pairsintrades[i].sellgain,2),"-TMCC-Sells"+BI.pairsintrades[i].pair,65,tooltip,i);
            }
            rowindex++;
         }
      }
      
      int liststartrowindex=0;

      if(TradesViewSelected==ByCurrencies)
      {
         bool headercreated=false;

         for(int i=0; i<8; i++)
         {
            TypeCurrenciesTradesInfo ct=BI.currenciesintrades[i];
            
            if(ct.buyvolume>0||ct.sellvolume>0)
            {
               if(!headercreated)
               {
                  CreateLabel(rowindex,FontSize,TextColor,"Sells","1",35);
                  CreateLabel(rowindex,FontSize,TextColor,"Buys","2",110);
                  headercreated=true;
                  rowindex++;
                  liststartrowindex=rowindex;
               }

               CreateLabel(rowindex,FontSize,currencycolor[i],currencies[i],"-TMCurrency",0,"",rowindex-liststartrowindex);
               
               if(ct.buyvolume>0)
               {
                  color pcolor=TextColorPlus;
                  if(ct.buygain<0)
                     pcolor=TextColorMinus;
                  CreateLabel(rowindex,FontSize,pcolor,DoubleToString(ct.buyvolume,2)+" "+DoubleToString(ct.buygain,2),"-TMCC-Buys-"+currencies[i],110,tooltip,rowindex-liststartrowindex);
               }
               if(ct.sellvolume>0)
               {
                  color pcolor=TextColorPlus;
                  if(ct.sellgain<0)
                     pcolor=TextColorMinus;
                  CreateLabel(rowindex,FontSize,pcolor,DoubleToString(ct.sellvolume,2)+" "+DoubleToString(ct.sellgain,2),"-TMCC-Sells"+currencies[i],35,tooltip,rowindex-liststartrowindex);
               }
               rowindex++;
            }
         }
      }

      if(TradesViewSelected==ByCurrenciesGrouped)
      {
         bool headercreated=false;

         for(int i=0; i<8; i++)
         {
            TypeCurrenciesTradesInfo ct=BI.currenciesintrades[i];
            
            if(ct.buyvolume>0||ct.sellvolume>0)
            {
               if(!headercreated)
               {
                  CreateLabel(rowindex,FontSize,TextColor,"Sells","1",35);
                  CreateLabel(rowindex,FontSize,TextColor,"Buys","2",110);
                  headercreated=true;
                  rowindex++;
                  liststartrowindex=rowindex;
               }

               CreateLabel(rowindex,FontSize,currencycolor[i],currencies[i],"-TMCurrency",0,"",rowindex-liststartrowindex);

               int ysize=ArraySize(ct.tg);
               for(int y=0; y<ysize; y++)
               {
                  color pcolor=TextColorPlus;
                  if(ct.tg[y].gain<0)
                     pcolor=TextColorMinus;
                  
                  if(ct.tg[y].type==OP_BUY)
                  {
                     CreateLabel(rowindex,FontSize,pcolor,DoubleToString(ct.tg[y].volume,2)+" "+DoubleToString(ct.tg[y].gain,2),"-TMCC-"+IntegerToString(ct.tg[y].magicfrom,12,'0')+IntegerToString(ct.tg[y].magicto,12,'0'),110,tooltip,rowindex-liststartrowindex);
                  }
                  if(ct.tg[y].type==OP_SELL)
                  {
                     CreateLabel(rowindex,FontSize,pcolor,DoubleToString(ct.tg[y].volume,2)+" "+DoubleToString(ct.tg[y].gain,2),"-TMCC-"+IntegerToString(ct.tg[y].magicfrom,12,'0')+IntegerToString(ct.tg[y].magicto,12,'0'),35,tooltip,rowindex-liststartrowindex);
                  }
                  rowindex++;
               }
               rowindex++;
            }
         }
      }
   }

   if(TimeLocal()-lasterrortime<3)
   {
      CreateLabel(rowindex,FontSize,TextColorMinus,lasterrorstring);
      rowindex++;
   }
   ChartRedraw();
}


void CreateArrowUp(int RI)
{
   string objname=appnamespace+"TextArrowUp";
   ObjectCreate(0,objname,OBJ_LABEL,0,0,0,0,0);
   ObjectSetInteger(0,objname,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,objname,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,objname,OBJPROP_XDISTANCE,BackgroundPanelWidth-20);
   ObjectSetInteger(0,objname,OBJPROP_YDISTANCE,3+(TextGap*RI));
   ObjectSetInteger(0,objname,OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,objname,OBJPROP_FONTSIZE,FontSize);
   ObjectSetString(0,objname,OBJPROP_FONT,FontName);
   ObjectSetString(0,objname,OBJPROP_TEXT,"\x25b2");
   TextObjects.AddObject(objname);
}


void CreateArrowDown()
{
   if(arrowdown)
      return;

   string objname=appnamespace+"TextArrowDown";
   ObjectCreate(0,objname,OBJ_LABEL,0,0,0,0,0);
   ObjectSetInteger(0,objname,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,objname,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,objname,OBJPROP_XDISTANCE,BackgroundPanelWidth-20);
   ObjectSetInteger(0,objname,OBJPROP_YDISTANCE,chartheight-20);
   ObjectSetInteger(0,objname,OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,objname,OBJPROP_FONTSIZE,FontSize);
   ObjectSetString(0,objname,OBJPROP_FONT,FontName);
   ObjectSetString(0,objname,OBJPROP_TEXT,"\x25bc");
   TextObjects.AddObject(objname);

   arrowdown=true;
}


void CreateLabel(int RI, int fontsize, color c, string text, string group="", int xshift=0, string tooltip="", int listindex=-1)
{
   int rowpos=RI;
   if(listindex>-1)
   {
      rowpos-=listshift;
      if(listindex-listshift<0)
         return;
   }
   
   if(chartheight<3+(TextGap*(rowpos+1)))
   {
      CreateArrowDown();
      return;
   }

   string objname=appnamespace+"Text"+IntegerToString(rowpos+1)+group;
   ObjectCreate(0,objname,OBJ_LABEL,0,0,0,0,0);
   ObjectSetInteger(0,objname,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,objname,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,objname,OBJPROP_XDISTANCE,7+xshift);
   ObjectSetInteger(0,objname,OBJPROP_YDISTANCE,3+(TextGap*rowpos));
   ObjectSetInteger(0,objname,OBJPROP_COLOR,c);
   ObjectSetInteger(0,objname,OBJPROP_FONTSIZE,fontsize);
   ObjectSetString(0,objname,OBJPROP_FONT,FontName);
   ObjectSetString(0,objname,OBJPROP_TEXT,text);
   if(StringLen(tooltip)>0)
      ObjectSetString(0,objname,OBJPROP_TOOLTIP,tooltip);
   TextObjects.AddObject(objname);
}


void NextTradeLevels(bool backward=false)
{
   int indexes[];
   int count=0;
   int currentpositionindex=-1;
   int asize=ArraySize(WS.tradereference);
   for(int i=0; i<asize; i++)
   {
      if(WS.tradereference[i].pair+SymbolExtraChars==Symbol() && TimeLocal()-WS.tradereference[i].lastupdate<2)
      {
         ArrayResize(indexes,count+1);
         indexes[count]=i;
         if(selectedtradeindex==i)
            currentpositionindex=count;
         count++;
      }
   }
   if(count>1)
   {
      DeleteSelectedTradeLevels();
      if(backward)
         currentpositionindex--;
      else
         currentpositionindex++;
      if(currentpositionindex>(count-1))
         currentpositionindex=0;
      if(currentpositionindex<0)
         currentpositionindex=(count-1);
      selectedtradeindex=indexes[currentpositionindex];
      DrawSelectedTradeLevels();
   }
}


void ToggleTradeLevels(bool disable=false)
{
   selectedtradeindex=-1;

   if(!tradelevelsvisible && !disable)
   {
      ToggleCtrl(true);

      int asize=ArraySize(WS.tradereference);
      for(int i=0; i<asize; i++)
      {
         if(WS.tradereference[i].pair+SymbolExtraChars==Symbol() && TimeLocal()-WS.tradereference[i].lastupdate<2)
         {
            selectedtradeindex=i;
            break;
         }
      }
      if(selectedtradeindex>-1)
      {
         tradelevelsvisible=true;
         DrawSelectedTradeLevels();
      }
   }
   else if(tradelevelsvisible)
   {
      DeleteSelectedTradeLevels();
      tradelevelsvisible=false;
   }
}


void DeleteSelectedTradeLevels()
{
   if(DrawLevelsAllCharts)
   {
      long chartid=ChartFirst();
      while(chartid>-1)
      {
         if(ChartSymbol(chartid)==Symbol())
            ObjectsDeleteAll(chartid,appnamespace+"TradeLevel");
   
         chartid=ChartNext(chartid);
      }
   }
   else
      ObjectsDeleteAll(0,appnamespace+"TradeLevel");
}


void DrawSelectedTradeLevels()
{
   if(DrawLevelsAllCharts)
   {
      long chartid=ChartFirst();
      while(chartid>-1)
      {
         if(ChartSymbol(chartid)==Symbol())
            DrawTradeLevels(chartid,selectedtradeindex);
   
         chartid=ChartNext(chartid);
      }
   }
   else
      DrawTradeLevels(0,selectedtradeindex);
}


void DrawTradeLevels(long chartid, int i)
{
   CreateLevel(chartid,appnamespace+"TradeLevelOpen"+IntegerToString(i),DodgerBlue,WS.tradereference[i].openprice);

   double stopprice=0;
   double commissionpoints=MathAbs(WS.tradereference[i].commissionpoints);
   if(WS.tradereference[i].stoplosspips!=DISABLEDPOINTS)
   {
      if(WS.tradereference[i].type==OP_BUY)
         stopprice=WS.tradereference[i].openprice-((WS.tradereference[i].stoplosspips-commissionpoints)*Point());
      if(WS.tradereference[i].type==OP_SELL)
         stopprice=WS.tradereference[i].openprice+((WS.tradereference[i].stoplosspips-commissionpoints)*Point());
      CreateLevel(chartid,appnamespace+"TradeLevelStop"+IntegerToString(i),DeepPink,stopprice);
   }
   if(WS.tradereference[i].takeprofitpips!=DISABLEDPOINTS)
   {
      double takeprice=0;
      if(WS.tradereference[i].type==OP_BUY)
         takeprice=WS.tradereference[i].openprice+((WS.tradereference[i].takeprofitpips+commissionpoints)*Point());
      if(WS.tradereference[i].type==OP_SELL)
         takeprice=WS.tradereference[i].openprice-((WS.tradereference[i].takeprofitpips+commissionpoints)*Point());
      CreateLevel(chartid,appnamespace+"TradeLevelTake"+IntegerToString(i),SeaGreen,takeprice);
   }

   ChartRedraw(chartid);
}


void ToggleCtrl(bool disable=false)
{
   if(!ctrlon && !disable)
   {
      ToggleTradeLevels(true);
      DrawLevels();
      //DisplayLegend();
      ctrlon=true;
   }
   else if(ctrlon)
   {
      DeleteLevels();
      //DeleteLegend();

      ArrayResize(WS.pendingorders,0);
      ObjectsDeleteAll(0,appnamespace+"PendingLevel");

      ctrlon=false;
   }
}


void CreateLipstick()
{
   datetime dt[1];
   if(CopyTime(_Symbol,_Period,(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR)-((int)ChartGetInteger(0,CHART_VISIBLE_BARS)-1),1,dt)<1)
      return;

   MqlRates r[600];
   if(CopyRates(_Symbol,PERIOD_M5,dt[0],600,r)<600)
      return;

   datetime asiastart=0, asiaend=0, nymidnight=0;
   double asiahigh=DBL_MIN, asialow=DBL_MAX, nyopen=0, drhigh=DBL_MIN, drlow=DBL_MAX, idrhigh=DBL_MIN, idrlow=DBL_MAX;
   int lasthour=6;

   for(int i=599;i>=0;i--)
   {
      MqlDateTime t;
      TimeToStruct(r[i].time,t);

      if((t.hour==17 && t.min==25) || drhigh!=DBL_MIN)
      {
         drhigh=MathMax(drhigh,r[i].high);
         drlow=MathMin(drlow,r[i].low);
         idrhigh=MathMax(idrhigh,MathMax(r[i].open,r[i].close));
         idrlow=MathMin(idrlow,MathMin(r[i].open,r[i].close));
      }

      if(t.hour==16 && t.min==30)
      {
         CreateTrendline(0,appnamespace+"LipstickNYOpen",Tomato,1,STYLE_SOLID,r[i].open,r[i].open,r[i].time,r[i].time+3600);
         if(drhigh!=0)
         {
            double half=(drhigh-drlow)/2;
            CreateRectangle(0,appnamespace+"LipstickDRRect",AliceBlue,drhigh,drlow,r[i].time,r[i].time+3540);
            CreateTrendline(0,appnamespace+"LipstickIDRHigh",LightGray,1,STYLE_DOT,idrhigh,idrhigh,r[i].time,r[i].time+3600);
            CreateTrendline(0,appnamespace+"LipstickIDRLow",LightGray,1,STYLE_DOT,idrlow,idrlow,r[i].time,r[i].time+3600);
            for(int j=5; j>=-5; j--)
            {
               double l=drhigh-half+(half*j);
               CreateTrendline(0,appnamespace+"LipstickDR-"+IntegerToString(j),LightSkyBlue,1,STYLE_DOT,l,l,r[i].time,r[i].time+3600);
            }
         }
      }

      if(t.hour==15 && t.min==30)
         CreateTrendline(0,appnamespace+"LipstickNYPreOpen",Tomato,1,STYLE_DOT,r[i].open,r[i].open,r[i].time,r[i].time+3600);

      if(nymidnight==0)
      {
         if(t.hour==7 && t.min==0)
         {
            nymidnight=r[i].time;
            nyopen=r[i].open;
         }
      }

      if(nymidnight!=0 && asiaend==0)
      {
         if(t.hour==6)
            asiaend=r[i].time+(PeriodSeconds(PERIOD_M5)-1);
      }

      if(asiaend!=0)
      {
         if(t.hour>lasthour)
            break;
         asiahigh=MathMax(asiahigh,r[i].high);
         asialow=MathMin(asialow,r[i].low);
         asiastart=r[i].time;
         lasthour=t.hour;
      }
   }

   CreateRectangle(0,appnamespace+"LipstickAsiaRect",WhiteSmoke,asiahigh,asialow,asiastart,asiaend);
   CreateTrendline(0,appnamespace+"LipstickAsiaHigh",CornflowerBlue,1,STYLE_DASH,asiahigh,asiahigh,asiastart,asiaend);
   CreateTrendline(0,appnamespace+"LipstickAsiaLow",CornflowerBlue,1,STYLE_DASH,asialow,asialow,asiastart,asiaend);
   CreateTrendline(0,appnamespace+"LipstickNYMidnight",CornflowerBlue,1,STYLE_SOLID,nyopen,nyopen,nymidnight,nymidnight+3600);

   if(lipstickmode<LipStickMode2)
      return;

   MqlRates r2[20];
   if(CopyRates(_Symbol,PERIOD_W1,0,20,r2)<20)
      return;
   
   for(int i=10;i<=19;i++)
   {
      //CreateTrendline(0,appnamespace+"LipstickNWOGO"+IntegerToString(i),DimGray,2,STYLE_SOLID,r2[i].open,r2[i].open,r2[i].time,r2[i].time+(86400*3));
      //CreateTrendline(0,appnamespace+"LipstickNWOGC"+IntegerToString(i),DimGray,2,STYLE_SOLID,r2[i-1].close,r2[i-1].close,r2[i].time,r2[i].time+(86400*3));

      int cv=250-(i*5);
      //cv=248;
      //if(i>=16)
         //cv=180;
      CreateRectangle(0,appnamespace+"LipstickNWOGRect"+IntegerToString(i),(cv<<16)+(cv<<8)+(cv),r2[i].open,r2[i-1].close,r2[i].time,r2[19].time+PeriodSeconds(PERIOD_W1));
      double middle=r2[i].open-((r2[i].open-r2[i-1].close)/2);
      CreateTrendline(0,appnamespace+"LipstickNWOGM"+IntegerToString(i),White,1,STYLE_DOT,middle,middle,r2[i].time,r2[i].time+(86400*3));
   }
}


void DeleteLipstick()
{
   ObjectsDeleteAll(0,appnamespace+"Lipstick");
}


void DrawLevels()
{
   if(DrawLevelsAllCharts)
   {
      long chartid=ChartFirst();
      while(chartid>-1)
      {
         if(ChartSymbol(chartid)==Symbol())
            DrawLevels(chartid);
         chartid=ChartNext(chartid);
      }
   }
   else
      DrawLevels(0);
}


void DrawLevels(long chartid)
{
   //CreateLevel(chartid,appnamespace+"Level1",MediumSeaGreen,Bid-(AboveBEPips*Point));
   //CreateLevel(chartid,appnamespace+"Level2",DeepPink,Bid-(BreakEvenAfterPips*Point));
   //CreateLevel(chartid,appnamespace+"Level3",MediumSeaGreen,Ask+(AboveBEPips*Point));
   //CreateLevel(chartid,appnamespace+"Level4",DeepPink,Ask+(BreakEvenAfterPips*Point));

   int cp=SymbolCommissionPoints();

   if(_StopLossPips!=DISABLEDPOINTS)
   {
      CreateLevel(chartid,appnamespace+"Level1",DeepPink,BidX()+((_StopLossPips-cp)*Point()));
      CreateLevel(chartid,appnamespace+"Level2",DeepPink,AskX()-((_StopLossPips-cp)*Point()));
   }
   if(_TakeProfitPips!=DISABLEDPOINTS)
   {
      CreateLevel(chartid,appnamespace+"Level3",SeaGreen,BidX()+((_TakeProfitPips+cp)*Point()));
      CreateLevel(chartid,appnamespace+"Level4",SeaGreen,AskX()-((_TakeProfitPips+cp)*Point()));
   }

   CreateRectangle(chartid,appnamespace+"Rectangle10",WhiteSmoke,AskX()+((_BreakEvenAfterPips+cp)*Point()),BidX()-((_BreakEvenAfterPips+cp)*Point()));
   CreateRectangle(chartid,appnamespace+"Rectangle11",WhiteSmoke,AskX()+((_AboveBEPips+cp)*Point()),BidX()-((_AboveBEPips+cp)*Point()));

   ChartRedraw(chartid);
}


void CreateLevel(long chartid, string objname, color c, double price, int width=2)
{
   if(ObjectFind(chartid,objname)<0)
   {
      ObjectCreate(chartid,objname,OBJ_HLINE,0,0,0);
      ObjectSetInteger(chartid,objname,OBJPROP_COLOR,c);
      ObjectSetInteger(chartid,objname,OBJPROP_WIDTH,width);
      ObjectSetInteger(chartid,objname,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(chartid,objname,OBJPROP_BACK,true);
   }
   ObjectSetDouble(chartid,objname,OBJPROP_PRICE,price);
}


void CreateRectangle(long chartid, string objname, color c, double price1, double price2, datetime time1=NULL, datetime time2=NULL)
{
   if(time1==NULL)
      time1=TimeCurrent()-4000000;
   if(time2==NULL)
      time2=TimeCurrent();
   if(ObjectFind(chartid,objname)<0)
   {
      ObjectCreate(chartid,objname,OBJ_RECTANGLE,0,0,0);
      ObjectSetInteger(chartid,objname,OBJPROP_FILL,true);
      ObjectSetInteger(chartid,objname,OBJPROP_COLOR,c);
      ObjectSetInteger(chartid,objname,OBJPROP_BGCOLOR,c);
      ObjectSetInteger(chartid,objname,OBJPROP_BACK,true);
   }
   ObjectSetDouble(chartid,objname,OBJPROP_PRICE,0,price1);
   ObjectSetInteger(chartid,objname,OBJPROP_TIME,0,time1);
   ObjectSetDouble(chartid,objname,OBJPROP_PRICE,1,price2);
   ObjectSetInteger(chartid,objname,OBJPROP_TIME,1,time2);
}


void CreateTrendline(long chartid, string objname, color c, int width, int style, double price1, double price2, datetime time1, datetime time2)
{
   if(ObjectFind(chartid,objname)<0)
   {
      ObjectCreate(chartid,objname,OBJ_TREND,0,0,0);
      ObjectSetInteger(chartid,objname,OBJPROP_COLOR,c);
      ObjectSetInteger(chartid,objname,OBJPROP_WIDTH,width);
      ObjectSetInteger(chartid,objname,OBJPROP_STYLE,style);
      ObjectSetInteger(chartid,objname,OBJPROP_RAY_RIGHT,true);
      ObjectSetInteger(chartid,objname,OBJPROP_BACK,true);
   }
   ObjectSetDouble(chartid,objname,OBJPROP_PRICE,0,price1);
   ObjectSetInteger(chartid,objname,OBJPROP_TIME,0,time1);
   ObjectSetDouble(chartid,objname,OBJPROP_PRICE,1,price2);
   ObjectSetInteger(chartid,objname,OBJPROP_TIME,1,time2);
}


void DisplayLegend()
{
   CreateLegend(appnamespace+"Legend1",5+(int)MathFloor(TextGap*2.4),"Hotkeys: Press Ctrl plus");
   CreateLegend(appnamespace+"Legend2",5+(int)MathFloor(TextGap*1.6),"1 Open Buy | 3 Open Sell | 0 Close All");
   CreateLegend(appnamespace+"Legend3",5+(int)MathFloor(TextGap*0.8),"5 Hard SL | 6 Soft SL | 8 Close at BE");
   CreateLegend(appnamespace+"Legend4",5+(int)MathFloor(TextGap*0),"; Decrease Volume | : Increase Volume");
}


void CreateLegend(string objname, int y, string text)
{
   ObjectCreate(0,objname,OBJ_LABEL,0,0,0,0,0);
   ObjectSetInteger(0,objname,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,objname,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0,objname,OBJPROP_XDISTANCE,5);
   ObjectSetInteger(0,objname,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,objname,OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,objname,OBJPROP_FONTSIZE,(int)MathFloor(FontSize*0.8));
   ObjectSetString(0,objname,OBJPROP_FONT,FontName);
   ObjectSetString(0,objname,OBJPROP_TEXT,text);
}


void DeleteLegend()
{
   ObjectsDeleteAll(0,appnamespace+"Legend");
}


void DeleteLevels()
{
   if(DrawLevelsAllCharts)
   {
      long chartid=ChartFirst();
      while(chartid>-1)
      {
         if(ChartSymbol(chartid)==Symbol())
         {
            ObjectsDeleteAll(chartid,appnamespace+"Level");
            ObjectsDeleteAll(chartid,appnamespace+"Rectangle");
            ChartRedraw(chartid);
         }
         chartid=ChartNext(chartid);
      }
   }
   else
      ObjectsDeleteAll(0,appnamespace+"Level");
}


void DeleteText()
{
   //ObjectsDeleteAll(0,appnamespace+"Text");
   // Workaround: We move objects out of view, because if we delete it, click events can get lost
   TextObjects.HideAll();
   arrowdown=false;
}


void DeleteAllObjects()
{
   ObjectsDeleteAll(0,appnamespace);
}


long GetHedgeLevel(long mn)
{
   long t1=mn-magicnumberfloor;
   return (long)MathFloor(t1/hedgeoffsetmagicnumber);
}


long GetMagicNumberFraction(long mn)
{
   long t1=mn-magicnumberfloor;
   long t2=(long)MathFloor(t1/hedgeoffsetmagicnumber);
   long t3=t1-(hedgeoffsetmagicnumber*t2);
   if(t3<0)
      t3=0;
   return t3;
}


double GetHedgeVolume(TypeTradeInfo& tradeinfo[], TypeTradeInfo& tiin)
{
   double ret=0;
   long mn=GetMagicNumberFraction(tiin.magicnumber);
   double sells=0, buys=0, factor=HedgeVolumeFactor;
   long hedgelevel=GetHedgeLevel(tiin.magicnumber);
   if(hedgelevel>=(HedgeFlatAtLevel-1))
      factor=1;
   int size=ArraySize(tradeinfo);
   for(int i=0; i<size; i++)
   {
      if(GetMagicNumberFraction(tradeinfo[i].magicnumber)==mn)
      {
         if(tradeinfo[i].type==OP_BUY)
            buys+=tradeinfo[i].volume;
         if(tradeinfo[i].type==OP_SELL)
            sells+=tradeinfo[i].volume;
      }
   }
   if(tiin.type==OP_BUY)
      ret=(buys*factor)-sells;
   if(tiin.type==OP_SELL)
      ret=(sells*factor)-buys;
   return NormalizeDouble(ret,2);
}


long GetHedgeMagicNumber(TypeTradeInfo& tradeinfo[], TypeTradeInfo& tiin)
{
   long r=tiin.magicnumber+hedgeoffsetmagicnumber;
   if(TradeReferenceIndex(r)>-1)
      r=-1;
   return r;
}


int HedgeType(int type)
{
   if(type==OP_BUY)
      return OP_SELL;
   if(type==OP_SELL)
      return OP_BUY;
   return -1;
}


bool OpenOrder(int type, string symbol=NULL, double volume=NULL, long magicnumber=NULL)
{
   if(type==OP_BUY)
      return OpenBuy(symbol,volume,magicnumber);
   if(type==OP_SELL)
      return OpenSell(symbol,volume,magicnumber);
   return false;
}


bool OpenBuy(string symbol=NULL, double volume=NULL, long magicnumber=NULL, double sl=NULL, double tp=NULL, double sll=NULL, double tpl=NULL)
{
   double v=_OpenLots;
   if(volume!=NULL)
      v=volume;
   long m=WS.currentbasemagicnumber;
   if(magicnumber!=NULL)
      m=magicnumber;
   string s=Symbol();
   if(symbol!=NULL)
      s=symbol;
   string c=appnamespace+IntegerToString(m);
   WS.lastorderexecution=TimeLocal();
#ifdef __MQL4__
   int ret=OrderSend(s,OP_BUY,v,AskX(s),5,0,0,c,m);
   if(ret>-1)
      NewTradeReference(m,true,sl,tp,sll,tpl);
   if(ret>-1&&magicnumber==NULL)
      WS.currentbasemagicnumber++;
   SetLastError(ret);
   return (ret>-1);
#endif
#ifdef __MQL5__
   CTrade trade;
   trade.SetExpertMagicNumber(m);
   //bool ret=trade.PositionOpen(s,ORDER_TYPE_BUY,v,AskX(s),NULL,NULL,c);
   bool ret=trade.PositionOpen(s,ORDER_TYPE_BUY,v,0,NULL,NULL,c);
   if(ret)
      NewTradeReference(m,true,sl,tp,sll,tpl);
   if(ret&&magicnumber==NULL)
      WS.currentbasemagicnumber++;
   SetLastErrorBool(ret);
   return ret;
#endif
}


bool OpenSell(string symbol=NULL, double volume=NULL, long magicnumber=NULL, double sl=NULL, double tp=NULL, double sll=NULL, double tpl=NULL)
{
   double v=_OpenLots;
   if(volume!=NULL)
      v=volume;
   long m=WS.currentbasemagicnumber;
   if(magicnumber!=NULL)
      m=magicnumber;
   string s=Symbol();
   if(symbol!=NULL)
      s=symbol;
   string c=appnamespace+IntegerToString(m);
   WS.lastorderexecution=TimeLocal();
#ifdef __MQL4__
   int ret=OrderSend(s,OP_SELL,v,BidX(s),5,0,0,c,m);
   if(ret>-1)
      NewTradeReference(m,true,sl,tp,sll,tpl);
   if(ret>-1&&magicnumber==NULL)
      WS.currentbasemagicnumber++;
   SetLastError(ret);
   return (ret>-1);
#endif
#ifdef __MQL5__
   CTrade trade;
   trade.SetExpertMagicNumber(m);
   //bool ret=trade.PositionOpen(s,ORDER_TYPE_SELL,v,BidX(s),NULL,NULL,c);
   bool ret=trade.PositionOpen(s,ORDER_TYPE_SELL,v,0,NULL,NULL,c);
   if(ret)
      NewTradeReference(m,true,sl,tp,sll,tpl);
   if(ret&&magicnumber==NULL)
      WS.currentbasemagicnumber++;
   SetLastErrorBool(ret);
   return ret;
#endif
}


int NewTradeReference(long magicnumber, bool InitWithCurrentSettings, double sl=NULL, double tp=NULL, double sll=NULL, double tpl=NULL)
{
   int asize=ArraySize(WS.tradereference);
   ArrayResize(WS.tradereference,asize+1);
   WS.tradereference[asize].magicnumber=magicnumber;
   if(InitWithCurrentSettings)
   {
      WS.tradereference[asize].stoplosspips=_StopLossPips;
      WS.tradereference[asize].takeprofitpips=_TakeProfitPips;
   }
   if(sl!=NULL)
      WS.tradereference[asize].stoplosspips=sl;
   if(sll!=NULL)
      WS.tradereference[asize].stoplosslevel=sll;
   if(tp!=NULL)
      WS.tradereference[asize].takeprofitpips=tp;
   if(tpl!=NULL)
      WS.tradereference[asize].takeprofitlevel=tpl;
   return asize;
}


void UpdateTradeReference(TypePairsTradesInfo& piti, TypeTradeInfo& tiin)
{
   int index=TradeReferenceIndex(tiin.magicnumber);
   if(index==-1)
      index=NewTradeReference(tiin.magicnumber,false);
   WS.tradereference[index].gain=tiin.gain;
   WS.tradereference[index].tickvalue=tiin.tickvalue;
   WS.tradereference[index].points=tiin.points;
   WS.tradereference[index].openprice=tiin.openprice;
   WS.tradereference[index].pair=piti.pair;
   WS.tradereference[index].type=tiin.type;
   WS.tradereference[index].volume=tiin.volume;
   WS.tradereference[index].commissionpoints=tiin.commissionpoints;
   WS.tradereference[index].lastupdate=TimeLocal();
}


void UpdateTradeReference(long magicnumber, double gain=NULL, double stoplosspips=NULL, double takeprofitpips=NULL, double stoplosslevel=NULL, double takeprofitlevel=NULL)
{
   int index=TradeReferenceIndex(magicnumber);
   if(index==-1)
      index=NewTradeReference(magicnumber,false);
   if(gain!=NULL)
      WS.tradereference[index].gain=gain;
   if(stoplosspips!=NULL)
      WS.tradereference[index].stoplosspips=stoplosspips;
   if(stoplosslevel!=NULL)
      WS.tradereference[index].stoplosslevel=stoplosslevel;
   if(takeprofitpips!=NULL)
      WS.tradereference[index].takeprofitpips=takeprofitpips;
   if(takeprofitlevel!=NULL)
      WS.tradereference[index].takeprofitlevel=takeprofitlevel;
}


int TradeReferenceIndex(long magicnumber)
{
   int asize=ArraySize(WS.tradereference);
   int index=-1;
   for(int i=0; i<asize; i++)
   {
      if(WS.tradereference[i].magicnumber==magicnumber)
      {
         index=i;
         break;
      }
   }
   return index;
}


void UpdateCurrencyGroupInfo(TypeCurrenciesTradesGroupsInfo& tg[], TypeTradeInfo& tiin, TypePairsTradesInfo& piti, int type, int currency)
{
   int a=ArraySize(tg), i=a-1;

   if(a==0 || tg[i].type!=type || GetPairIndexOfCurrency(piti.pair,currency)<=GetPairIndexOfCurrency(tg[i].containspairs,currency))
   {
      ArrayResize(tg,a+1);
      i+=1;
   }

   tg[i].containspairs=piti.pair;
   tg[i].type=type;
   tg[i].magicfrom=(long)MathMin(tg[i].magicfrom,tiin.magicnumber);
   tg[i].magicto=(long)MathMax(tg[i].magicto,tiin.magicnumber);
   tg[i].gain+=tiin.gain;
   tg[i].volume+=tiin.volume;
}


void UpdateCurrencyInfo(TypePairsTradesInfo& piti, TypeTradeInfo& tiin)
{
   int baseindex=CurrenciesBaseIndex(piti.pair);
   int quoteindex=CurrenciesQuoteIndex(piti.pair);
   if(baseindex>-1)
   {
      if(tiin.type==OP_BUY)
      {
         BI.currenciesintrades[baseindex].buygain+=tiin.gain;
         BI.currenciesintrades[baseindex].buyvolume+=tiin.volume;
         UpdateCurrencyGroupInfo(BI.currenciesintrades[baseindex].tg,tiin,piti,OP_BUY,baseindex);
      }
      if(tiin.type==OP_SELL)
      {
         BI.currenciesintrades[baseindex].sellgain+=tiin.gain;
         BI.currenciesintrades[baseindex].sellvolume+=tiin.volume;
         UpdateCurrencyGroupInfo(BI.currenciesintrades[baseindex].tg,tiin,piti,OP_SELL,baseindex);
      }
   }
   if(quoteindex>-1)
   {
      if(tiin.type==OP_BUY)
      {
         BI.currenciesintrades[quoteindex].sellgain+=tiin.gain;
         BI.currenciesintrades[quoteindex].sellvolume+=tiin.volume;
         UpdateCurrencyGroupInfo(BI.currenciesintrades[quoteindex].tg,tiin,piti,OP_SELL,quoteindex);
      }
      if(tiin.type==OP_SELL)
      {
         BI.currenciesintrades[quoteindex].buygain+=tiin.gain;
         BI.currenciesintrades[quoteindex].buyvolume+=tiin.volume;
         UpdateCurrencyGroupInfo(BI.currenciesintrades[quoteindex].tg,tiin,piti,OP_BUY,quoteindex);
      }
   }
}


void AddTrade(TypePairsTradesInfo& piti, TypeTradeInfo& ti[], TypeTradeInfo& tiin)
{
   UpdateTradeReference(piti,tiin);

   UpdateCurrencyInfo(piti,tiin);

   int asize=ArraySize(ti);
   ArrayResize(ti,asize+1);
   ti[asize].orderindex=tiin.orderindex;
   ti[asize].type=tiin.type;
   ti[asize].volume=tiin.volume;
   ti[asize].openprice=tiin.openprice;
   ti[asize].opentime=tiin.opentime;
   ti[asize].points=tiin.points;
   ti[asize].gain=tiin.gain;
   ti[asize].tickvalue=tiin.tickvalue;
   ti[asize].magicnumber=tiin.magicnumber;
   ti[asize].orderticket=tiin.orderticket;
}


int GetPairsInTradesIndex(string tradedsymbol)
{
   int asize=ArraySize(BI.pairsintrades), idx=-1;
   string symbol=StringSubstr(tradedsymbol,0,6);
   bool found=false;
   for(int i=0; i<asize; i++)
   {
      if(BI.pairsintrades[i].pair==symbol)
      {
         found=true;
         idx=i;
         break;
      }
   }
   if(!found)
   {
      ArrayResize(BI.pairsintrades,asize+1);
      BI.pairsintrades[asize].pair=symbol;
      idx=asize;
   }
   return idx;
}


int CurrenciesGetIndexAtPos(string pair, int pos)
{
   int index=-1;
   for(int i=0; i<8; i++)
   {
      if(StringFind(pair,currencies[i])==pos)
      {
         index=i;
         break;
      }
   }
   return index;
}


int CurrenciesBaseIndex(string pair)
{
   return CurrenciesGetIndexAtPos(pair,0);
}


int CurrenciesQuoteIndex(string pair)
{
   return CurrenciesGetIndexAtPos(pair,3);
}


int GetPairIndexOfCurrency(string pair, int currency)
{
   int index=-1;
   for(int i=0; i<7; i++)
   {
      if(StringFind(pairs[currency][i],pair)==0)
      {
         index=i;
         break;
      }
   }
   return index;
}


void WriteToClose()
{
#ifdef __MQL5__
   if(istesting)
   {
      int total=OrdersTotalX();
      int cnt=0;
      for(cnt=total-1;cnt>=0;cnt--)
      {
         if(OrderSelectX(cnt))
         {
            if(IsOrderToManage())
            {
               datetime os=(datetime)PositionGetInteger(POSITION_TIME);
               MqlDateTime dt;
               TimeToStruct(os,dt);
               if(dt.min==1)
               {
                  string wstr="";
                  wstr+=PositionGetString(POSITION_SYMBOL);
                  wstr+=" ";
                  wstr+=IntegerToString(dt.min);
                  wstr+=" ";
                  wstr+=DoubleToString(OrderOpenPriceX(),5);
                  int file_handle=FileOpen("Order-Log.txt",FILE_WRITE|FILE_READ|FILE_TXT);
                  FileSeek(file_handle,0,SEEK_END);
                  FileWriteString(file_handle,wstr+"\r\n");
                  FileClose(file_handle);
               }            
            }
         }
      }
   }
#endif
}


void CloseAllInternal(string filter="")
{
   bool closeall=StringLen(filter)==0;
   bool buys=StringFind(filter,"Buys")==0;
   string asset="";
   if(!closeall)
      asset=StringSubstr(filter,5);
   long magicstart=0;
   long magicend=0;
   if(StringLen(filter)==24)
   {
      magicstart=StringToInteger(StringSubstr(filter,0,12));
      magicend=StringToInteger(StringSubstr(filter,12));
   }

   int total=OrdersTotalX();
   int cnt=0, delcnt=0;
#ifdef __MQL4__
   RefreshRates();
#endif
   for(cnt=total-1;cnt>=0;cnt--)
   {
      if(OrderSelectX(cnt))
         if(IsOrderToManage())
            if(closeall 
                  || (((((OrderTypeBuy()&&buys) || (!OrderTypeBuy()&&!buys)) && OrderSymbolX()==asset) 
                        || (((OrderTypeBuy()&&buys) || (!OrderTypeBuy()&&!buys)) && StringFind(OrderSymbolX(),asset)==0 ) 
                        || (((OrderTypeBuy()&&!buys) || (!OrderTypeBuy()&&buys)) && StringFind(OrderSymbolX(),asset)==3 )) 
                     && magicstart==0 )
                  || (magicstart>0 && (PositionGetInteger(POSITION_MAGIC)>=magicstart && PositionGetInteger(POSITION_MAGIC)<=magicend))
               )
               if(CloseSelectedOrder())
                  delcnt++;
   }
   if(delcnt>0)
      DeleteText();
}


bool CloseSelectedOrder()
{
   bool ret;
#ifdef __MQL4__
   if(OrderType()==OP_BUY)
      ret=OrderClose(OrderTicketX(),OrderLotsX(),MarketInfo(OrderSymbolX(),MODE_BID),5);
   if(OrderType()==OP_SELL) 
      ret=OrderClose(OrderTicketX(),OrderLotsX(),MarketInfo(OrderSymbolX(),MODE_ASK),5);
   if(OrderType()>OP_SELL)
      ret=OrderDelete(OrderTicketX());
   SetLastErrorBool(ret);
#endif
#ifdef __MQL5__
   CTrade trade;
   ret=trade.PositionClose(OrderTicketX());
   SetLastErrorBool(ret);
#endif
   return ret;
}


bool IsAutoTradingEnabled()
{
   return AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)
         &&AccountInfoInteger(ACCOUNT_TRADE_EXPERT)
         &&TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)
         &&MQLInfoInteger(MQL_TRADE_ALLOWED);
}


int ExtendedRepeatingFactor()
{
   int factor=1;
   if(GetTickCount()-repeatlasttick<=200)
      repeatcount++;
   else
      repeatcount=0;
   factor=1+(int)MathFloor(repeatcount/4);
   repeatlasttick=GetTickCount();
   return factor;
}


void BuildPendingLevels(double price, datetime time)
{
   if(MathAbs(startdragprice-price)>ATR()/500)
   {
      enddragprice=price;
      CreateLevel(0,appnamespace+"PendingLevelOpen",DodgerBlue,startdragprice);
      CreateLevel(0,appnamespace+"PendingLevelStop",DeepPink,enddragprice);
      //CreateRectangle(0,appnamespace+"PendingLevelRect",WhiteSmoke,startdragprice,enddragprice);
      BuildPendingLevelsText(time);
   }
   else
   {
      enddragprice=0;
      ObjectsDeleteAll(0,appnamespace+"PendingLevel");
   }
   
   ChartRedraw();
}


void BuildPendingLevelsText(datetime time=NULL)
{
      string objname=appnamespace+"PendingLevelText";
      string text="";

      if(time!=NULL)
         ObjectCreate(0,objname,OBJ_TEXT,0,time,startdragprice);

      if(startdragprice<enddragprice)
      {
         text="Sell";
         ObjectSetInteger(0,objname,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
      }
      else
      {
         text="Buy";
         ObjectSetInteger(0,objname,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      }

      double volume=CalculatePendingLevelsVolume();
      double tickvalue=CurrentSymbolTickValue();
      int cp=SymbolCommissionPoints();
      double stoppoints=MathAbs(startdragprice-enddragprice)/Point()+cp;

      text+=" "+DoubleToString(volume,2);

      double risk=stoppoints*volume*tickvalue;
      double riskpercent=risk/(AccountBalanceX()/100);
      double atrfactor=stoppoints/(ATR()/Point());

      string riskpercenttradingcapital="";
      if(AvailableTradingCapital>0)
         riskpercenttradingcapital=" | "+DoubleToString(risk/(AvailableTradingCapital/100),2)+"%";
      
      text+=" / Risk: "+DoubleToString(risk,2)+" | "+DoubleToString(riskpercent,2)+"%"+riskpercenttradingcapital+" | "+DoubleToString(atrfactor*100,1)+"%ATR";

      ObjectSetInteger(0,objname,OBJPROP_COLOR,TextColorInfo);
      ObjectSetInteger(0,objname,OBJPROP_FONTSIZE,FontSize);
      ObjectSetString(0,objname,OBJPROP_FONT,FontName);
      ObjectSetString(0,objname,OBJPROP_TEXT,text);
}


double CalculatePendingLevelsVolume()
{
   double volume=_OpenLots;
   if(_StopLossPips!=DISABLEDPOINTS)
   {
      double tickvalue=CurrentSymbolTickValue();
      int cp=SymbolCommissionPoints();
      double stoppoints=MathAbs(startdragprice-enddragprice)/Point()+cp;
      double baserisk=(_StopLossPips*_OpenLots*tickvalue)*PendingOrdersRiskFactor;
      double volumestep=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
      volume=MathFloor((baserisk/(stoppoints*tickvalue))/volumestep)*volumestep;
      volume=MathMax(volume,SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN));
      volume=MathMin(volume,SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX));
   }
   return volume;
}


void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   if(id==CHARTEVENT_MOUSE_MOVE)
   {
      uint state=(uint)sparam;
      if((state&16)==16)
         crosshairon=true;
      if((state&2)==2)
         crosshairon=false;
      if((state&1)==1)
      {
         leftmousebutton=true;
      }
      else
      {
         if(leftmousebutton&&crosshairon)
         {
            if(enddragprice!=0)
            {
               ArrayResize(WS.pendingorders,1);
               WS.pendingorders[0].entryprice=startdragprice;
               WS.pendingorders[0].stopprice=enddragprice;
               WS.pendingorders[0].stoppoints=MathAbs(startdragprice-enddragprice)/Point()+SymbolCommissionPoints();
               WS.pendingorders[0].volume=CalculatePendingLevelsVolume();
               if(startdragprice>enddragprice)
               {
                  if(AskX()>startdragprice)
                     WS.pendingorders[0].ordertype=ORDER_TYPE_BUY_LIMIT;
                  else
                     WS.pendingorders[0].ordertype=ORDER_TYPE_BUY_STOP;
               }
               else
               {
                  if(BidX()>startdragprice)
                     WS.pendingorders[0].ordertype=ORDER_TYPE_SELL_STOP;
                  else
                     WS.pendingorders[0].ordertype=ORDER_TYPE_SELL_LIMIT;
               }
            }
         
            startdragprice=0;
            enddragprice=0;
            crosshairon=false;
         }
         leftmousebutton=false;
      }

      if(ctrlon)
      {
         if(crosshairon&&leftmousebutton)
         {
            int x=(int)lparam; 
            int y=(int)dparam; 
            datetime time=0;
            double price=0;
            int window=0;
         
            if(ChartXYToTimePrice(0,x,y,window,time,price))
            {
               if(window==0)
               {
                  ArrayResize(WS.pendingorders,0);
               
                  if(startdragprice==0)
                     startdragprice=price;
                     
                  BuildPendingLevels(price,time);
               }
            }
         }
      }
   }

   if(id==CHARTEVENT_CHART_CHANGE)
   {
      chartheight=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   }

   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      //Print("CHARTEVENT_OBJECT_CLICK "+sparam);

      if(StringFind(sparam,"TextArrowDown")>-1)
         listshift++;

      if(StringFind(sparam,"TextArrowUp")>-1)
         listshift--;

      if(StringFind(sparam,"-TMSymbolButton")>-1)
         SwitchSymbol(ObjectGetString(0,sparam,OBJPROP_TEXT));

      if(ctrlon)
      {
         int f1=StringFind(sparam,"-TMCC-");
         if(f1>-1)
            WS.closecommands.Add(StringSubstr(sparam,f1+6));
      }
   }
   
   if(id==CHARTEVENT_KEYDOWN)
   {
      //Print(lparam);

      if(lparam==17)
         ToggleCtrl();

      double step=ATR()/1000/Point();
      step=MathFloor(step);
      step=MathMax(step,1);
      step*=ExtendedRepeatingFactor();

      double margin=(20*step)+(int)MathRound((AskX()-BidX())/Point());
      double marginsmall=(5*step)+(int)MathRound((AskX()-BidX())/Point());

      //if(TimeLocal()-lastctrl<2)
      if(ctrlon)
      {
         //lastctrl=TimeLocal();
         
         double vstep=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

         if(lparam==49||lparam==51)
         {
            if(InstrumentSelected==CurrentPair)
            {
               if(lparam==49)
                  OpenBuy();
               else
                  OpenSell();
            }
            else
            {
               for(int i=0; i<7; i++)
               {
                  bool isbase=(StringFind(pairs[InstrumentSelected][i],currencies[InstrumentSelected])==0);
                  if((isbase&&lparam==49) || (!isbase&&lparam==51))
                     OpenBuy(pairs[InstrumentSelected][i]);
                  else
                     OpenSell(pairs[InstrumentSelected][i]);
               }
            }
         }

         if (lparam == 38)
         {
            // Up Arrow

         }
         if (lparam == 40)
         {
            // Down Arrow

         }

         if (lparam == 48)
             WS.closecommands.Add();
         if (lparam == 56)
            SetBEClose();
         if (lparam == 54)
            SetSoftStopMode();
         if (lparam == 53)
            SetHardStopMode();
         if (lparam == 188)
         {
            _OpenLots=MathRound(MathMax(_OpenLots-(vstep*ExtendedRepeatingFactor()),SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN))/vstep)*vstep;
            if(crosshairon&&leftmousebutton)
               BuildPendingLevelsText();
         }
         if (lparam == 190)
         {
            _OpenLots=MathRound(MathMin(_OpenLots+(vstep*ExtendedRepeatingFactor()),SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX))/vstep)*vstep;
            if(crosshairon&&leftmousebutton)
               BuildPendingLevelsText();
         }
         if (lparam == 65)
         {
            double breach=0+(SymbolCommissionPoints()+marginsmall);
            if(_StopLossPips==DISABLEDPOINTS)
               return;
            _StopLossPips=MathMax(_StopLossPips-step,breach);
            if(_StopLossPips==breach)
            {
               _StopLossPips=DISABLEDPOINTS;
               DeleteLevels();
            }
            DrawLevels();
            if(crosshairon&&leftmousebutton)
               BuildPendingLevelsText();
         }
         if (lparam == 83)
         {
            double breach=0+(SymbolCommissionPoints()+marginsmall);
            if(_StopLossPips==DISABLEDPOINTS)
               _StopLossPips=breach;
            _StopLossPips+=step;
            DrawLevels();
            if(crosshairon&&leftmousebutton)
               BuildPendingLevelsText();
         }
         if (lparam == 68)
         {
            double breach=0-(SymbolCommissionPoints()-marginsmall);
            if(_TakeProfitPips==DISABLEDPOINTS)
               return;
            _TakeProfitPips=MathMax(_TakeProfitPips-step,breach);
            if(_TakeProfitPips==breach)
            {
               _TakeProfitPips=DISABLEDPOINTS;
               DeleteLevels();
            }
            DrawLevels();
         }
         if (lparam == 70)
         {
            double breach=0-(SymbolCommissionPoints()-marginsmall);
            if(_TakeProfitPips==DISABLEDPOINTS)
               _TakeProfitPips=breach;
            _TakeProfitPips+=step;
            DrawLevels();
         }

         if (lparam == 88)
         {
            InstrumentSelected+=1;
            if(InstrumentSelected>NZD)
               InstrumentSelected=USD;
         }
         if (lparam == 89)
         {
            InstrumentSelected=-1;
         }

         if (lparam == 86)
         {
            TradesViewSelected+=1;
            if(TradesViewSelected>ByCurrenciesGrouped)
               TradesViewSelected=ByPairs;
            listshift=0;
         }
         
         if (lparam == 76)
         {
            lipstickmode++;
            if(lipstickmode>LipStickMode2)
               lipstickmode=LipStickNone;
         }
      }

      if (lparam == 16)
         ToggleTradeLevels();

      if(tradelevelsvisible)
      {
         if (lparam == 48)
         {
            string magic=IntegerToString(WS.tradereference[selectedtradeindex].magicnumber,12,'0');
             WS.closecommands.Add(magic+magic);
         }
         if (lparam == 65)
         {
            double breach=0-(WS.tradereference[selectedtradeindex].points-(margin));
            if(WS.tradereference[selectedtradeindex].stoplosspips==DISABLEDPOINTS)
               return;
            WS.tradereference[selectedtradeindex].stoplosspips=MathMax(WS.tradereference[selectedtradeindex].stoplosspips-step,breach);
            if(WS.tradereference[selectedtradeindex].stoplosspips==breach)
            {
               WS.tradereference[selectedtradeindex].stoplosspips=DISABLEDPOINTS;
               DeleteSelectedTradeLevels();
            }
            DrawSelectedTradeLevels();
         }
         if (lparam == 83)
         {
            double breach=0-(WS.tradereference[selectedtradeindex].points-(margin));
            if(WS.tradereference[selectedtradeindex].stoplosspips==DISABLEDPOINTS)
               WS.tradereference[selectedtradeindex].stoplosspips=breach;
            WS.tradereference[selectedtradeindex].stoplosspips+=step;
            DrawSelectedTradeLevels();
         }
         if (lparam == 68)
         {
            double breach=WS.tradereference[selectedtradeindex].points+(margin);
            if(WS.tradereference[selectedtradeindex].takeprofitpips==DISABLEDPOINTS)
               return;
            WS.tradereference[selectedtradeindex].takeprofitpips=MathMax(WS.tradereference[selectedtradeindex].takeprofitpips-step,breach);
            if(WS.tradereference[selectedtradeindex].takeprofitpips==breach)
            {
               WS.tradereference[selectedtradeindex].takeprofitpips=DISABLEDPOINTS;
               DeleteSelectedTradeLevels();
            }
            DrawSelectedTradeLevels();
         }
         if (lparam == 70)
         {
            double breach=WS.tradereference[selectedtradeindex].points+(margin);
            if(WS.tradereference[selectedtradeindex].takeprofitpips==DISABLEDPOINTS)
               WS.tradereference[selectedtradeindex].takeprofitpips=breach;
            WS.tradereference[selectedtradeindex].takeprofitpips+=step;
            DrawSelectedTradeLevels();
         }
         if (lparam == 71)
            NextTradeLevels(true);
         if (lparam == 72)
            NextTradeLevels();

      }

   }
}


void SwitchSymbol(string tosymbol)
{
   if(istesting)
      return;
   string currentsymbol=StringSubstr(ChartSymbol(),0,6);
   if(currentsymbol!=tosymbol)
   {
      if(SwitchSymbolClickAllCharts)
      {
         long chartid=ChartFirst();
         while(chartid>-1)
         {
            if(chartid!=ChartID())
               ChartSetSymbolPeriod(chartid,tosymbol+SymbolExtraChars,ChartPeriod(chartid));
            chartid=ChartNext(chartid);
         }
      }
      ChartSetSymbolPeriod(0,tosymbol+SymbolExtraChars,0);
   }
}


void SetLastErrorBool(bool result)
{
   if(!result)
      SetLastError(-1);
}


void SetLastError(int result)
{
   if(result>-1)
      return;
   lasterrortime=TimeLocal();
   lasterrorstring="Went wrong, "+ErrorDescription(GetLastError());
}


int SymbolCommissionPoints()
{
   double tickvalue=CurrentSymbolTickValue();
   return (int)NormalizeDouble(SymbolCommission/tickvalue,0);
}


long OrderMagicNumberX()
{
#ifdef __MQL4__
   return OrderMagicNumber();
#endif
#ifdef __MQL5__
   return PositionGetInteger(POSITION_MAGIC);
#endif
}


long OrderTicketX()
{
#ifdef __MQL4__
   return OrderTicket();
#endif
#ifdef __MQL5__
   return PositionGetInteger(POSITION_TICKET);
#endif
}


int OrdersTotalX()
{
#ifdef __MQL4__
   return OrdersTotal();
#endif
#ifdef __MQL5__
   return PositionsTotal();
#endif
}


bool OrderSelectX(int index)
{
#ifdef __MQL4__
   return OrderSelect(index, SELECT_BY_POS, MODE_TRADES);
#endif
#ifdef __MQL5__
   return (StringLen(PositionGetSymbol(index))>0);
#endif
}


string OrderSymbolX()
{
#ifdef __MQL4__
   return OrderSymbol();
#endif
#ifdef __MQL5__
   return PositionGetString(POSITION_SYMBOL);
#endif
}


double CurrentSymbolTickValue()
{
#ifdef __MQL4__
   return MarketInfo(Symbol(),MODE_TICKVALUE);
#endif
#ifdef __MQL5__
   return SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE);
#endif
}


double OrderSymbolTickValue()
{
#ifdef __MQL4__
   return MarketInfo(OrderSymbolX(),MODE_TICKVALUE);
#endif
#ifdef __MQL5__
   return SymbolInfoDouble(OrderSymbolX(),SYMBOL_TRADE_TICK_VALUE);
#endif
}


double OrderCommissionSwap()
{
#ifdef __MQL4__
   return OrderCommission()+OrderSwap();
#endif
#ifdef __MQL5__
   double commission=0;
   if(HistorySelectByPosition(PositionGetInteger(POSITION_IDENTIFIER)))
   {
      ulong Ticket=0;
      int dealscount=HistoryDealsTotal();
      for(int i=0;i<dealscount;i++)
      {
         ulong TicketDeal=HistoryDealGetTicket(i);
         if(TicketDeal>0)
         {
            if(HistoryDealGetInteger(TicketDeal,DEAL_ENTRY)==DEAL_ENTRY_IN)
            {
               Ticket=TicketDeal;
               break;
            }
         }
      }
      if(Ticket>0)
      {
         double LotsIn=HistoryDealGetDouble(Ticket,DEAL_VOLUME);
         if(LotsIn>0)
            commission=HistoryDealGetDouble(Ticket,DEAL_COMMISSION)*PositionGetDouble(POSITION_VOLUME)/LotsIn;
         if(MT5CommissionPerDeal)
            commission=commission*2;
      }
   }
   return PositionGetDouble(POSITION_SWAP)+commission;
#endif
}


double OrderProfitNet()
{
#ifdef __MQL4__
   return OrderProfit()+OrderCommissionSwap();
#endif
#ifdef __MQL5__
   return PositionGetDouble(POSITION_PROFIT)+OrderCommissionSwap();
#endif
}


double OrderLotsX()
{
#ifdef __MQL4__
   return OrderLots();
#endif
#ifdef __MQL5__
   return PositionGetDouble(POSITION_VOLUME);
#endif
}


bool OrderTypeBuy()
{
#ifdef __MQL4__
   return (OrderType()==OP_BUY);
#endif
#ifdef __MQL5__
   return (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY);
#endif
}


bool OrderTypeSell()
{
#ifdef __MQL4__
   return (OrderType()==OP_SELL);
#endif
#ifdef __MQL5__
   return (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL);
#endif
}


double OrderOpenPriceX()
{
#ifdef __MQL4__
   return OrderOpenPrice();
#endif
#ifdef __MQL5__
   return PositionGetDouble(POSITION_PRICE_OPEN);
#endif
}


double OrderStopLossX()
{
#ifdef __MQL4__
   return OrderStopLoss();
#endif
#ifdef __MQL5__
   return PositionGetDouble(POSITION_SL);
#endif
}


double OrderTakeProfitX()
{
#ifdef __MQL4__
   return OrderTakeProfit();
#endif
#ifdef __MQL5__
   return PositionGetDouble(POSITION_TP);
#endif
}


double AccountBalanceNet()
{
   if(AvailableTradingCapital>0)
      return AvailableTradingCapital;
   return AccountBalanceX();
}


double AccountBalanceX()
{
#ifdef __MQL4__
   return AccountBalance();
#endif
#ifdef __MQL5__
   return AccountInfoDouble(ACCOUNT_BALANCE);
#endif
}


double AccountFreeMarginX()
{
#ifdef __MQL4__
   return AccountFreeMargin();
#endif
#ifdef __MQL5__
   return AccountInfoDouble(ACCOUNT_MARGIN_FREE);
#endif
}


double AskX(string symbol=NULL)
{
   string s=Symbol();
   if(symbol!=NULL)
      s=symbol;
//#ifdef __MQL4__
//   return Ask;
//#endif
//#ifdef __MQL5__
   MqlTick last_tick;
   if(SymbolInfoTick(s,last_tick))
      return last_tick.ask;
   else
      return 0;
//#endif
}


double BidX(string symbol=NULL)
{
   string s=Symbol();
   if(symbol!=NULL)
      s=symbol;
//#ifdef __MQL4__
//   return Bid;
//#endif
//#ifdef __MQL5__
   MqlTick last_tick;
   if(SymbolInfoTick(s,last_tick))
      return last_tick.bid;
   else
      return 0;
//#endif
}


void SetOrderSL(double sl)
{
#ifdef __MQL4__
   SetLastErrorBool(OrderModify(OrderTicketX(),OrderOpenPriceX(),sl,OrderTakeProfitX(),0));
#endif
#ifdef __MQL5__
   CTrade trade;
   SetLastErrorBool(trade.PositionModify(OrderTicketX(),sl,OrderTakeProfitX()));
#endif
}


double ATR()
{
   MqlDateTime dtcurrent;
   TimeCurrent(dtcurrent);
   if(dtcurrent.day!=atrday)
   {
      MqlRates rates[];
      int bars=16;
      int copied=CopyRates(Symbol(),PERIOD_D1,0,bars,rates);
      if(copied==bars)
      {
         atr=0;
         for(int k=1; k<=14; k++)
            atr += MathMax(rates[k].high,rates[k-1].close)-MathMin(rates[k].low,rates[k-1].close);
         atr/=(double)14;
         atrday=dtcurrent.day;
      }
   }
   return atr;
}


















////////////////////////////////////////////////////////////////////////////////////
// STRATEGIES
////////////////////////////////////////////////////////////////////////////////////


interface Strategy 
{
public:
   string GetName();
   void IdleCalculate();
   void Calculate();
};


class StrategyOutOfTheBox : public Strategy
{
public:

   datetime lastsignal;

   StrategyOutOfTheBox()
   {
      lastsignal=0;
   }
   
   void Calculate()
   {
   
   }

   void IdleCalculate()
   {
      int startboxhour=9;
      int endboxhour=12;

      MqlDateTime dtcurrent;
      TimeCurrent(dtcurrent);
      if(dtcurrent.min!=0 ||
         (dtcurrent.hour<=endboxhour && dtcurrent.hour>=startboxhour)
      )
         return;

      MqlRates rates[];
      ArraySetAsSeries(rates,true);
      int bars=20;
      int copied=CopyRates(Symbol(),PERIOD_H1,0,bars,rates); 
      if(copied==bars)
      {
         double boxhigh=0;
         double boxlow=DBL_MAX;
         double maxgapclose=0;
         double mingapclose=DBL_MAX;
         
         bool boxfound=false;

         for(int i=2; i<bars; i++)
         {
            if(rates[i].time<=lastsignal)
               break;

            MqlDateTime dtbar;
            TimeToStruct(rates[i].time,dtbar);
            
            if(dtbar.hour<=endboxhour&&dtbar.hour>=startboxhour)
            {
               boxhigh=MathMax(boxhigh,rates[i].high);
               boxlow=MathMin(boxlow,rates[i].low);
            }
            else
            {
               maxgapclose=MathMax(maxgapclose,rates[i].close);
               mingapclose=MathMin(mingapclose,rates[i].close);
            }

            if(dtbar.hour==startboxhour)
            {
               boxfound=true;
               break;
            }
         }
         
         if(boxfound &&
            rates[1].close>boxhigh &&
            maxgapclose<boxhigh
         )
         {
            lastsignal=rates[0].time;
            OpenBuy(NULL,0.01,0,NULL,NULL,boxlow,NormalizeDouble(boxhigh+((boxhigh-boxlow)/2),Digits()));
         }
         
      }

   }
};


class StrategyLittleDD : public Strategy
{
public:

   StrategyLittleDD()
   {
   
   }

   void Calculate()
   {
   
   }

   void IdleCalculate()
   {
      MqlRates rates[];
      ArraySetAsSeries(rates,true);
      int bars=20;
      int copied=CopyRates(Symbol(),Period(),0,bars,rates); 
      if(copied==bars)
      {
         //MqlDateTime dtcurrent;
         //TimeToStruct(rates[0].time,dtcurrent);
         //if(dtcurrent.hour<8||dtcurrent.hour>18)
         //   return;
         
         double pipsize=SymbolInfoDouble(Symbol(),SYMBOL_POINT)*pipsfactor;
         
         double highest=DBL_MIN;
         double lowest=DBL_MAX;

         for(int i=1; i<bars-3; i++)
         {
            if(i>1)
            {
               highest=MathMax(highest,rates[i-1].high);
               lowest=MathMin(lowest,rates[i-1].low);
            }
            if(rates[i].close<rates[i+1].open && rates[i+1].close>rates[i+1].open && rates[i+2].close>rates[i+2].open && highest<rates[i+1].open && rates[0].close>=rates[i+1].open && rates[0].high<=(rates[i+1].open+pipsize))
               OpenSell(NULL,0.1,0,200,200);
         }
      
      }
   }
};


class StrategyPivotsDay : public Strategy
{
public:
   TypePivotsData pivotsdata;
   datetime lastdaysignal;

   StrategyPivotsDay()
   {
      pivotsdata.Settings.draw=true;
      pivotsdata.Settings.PivotTypeHour=PIVOT_FIBONACCI;
      pivotsdata.Settings.PivotTypeFourHour=PIVOT_FIBONACCI;
      pivotsdata.Settings.PivotTypeDay=PIVOT_FIBONACCI;
      pivotsdata.Settings.PivotTypeWeek=PIVOT_FIBONACCI;
      lastdaysignal=0;
   }

   void Calculate()
   {

   }

   void IdleCalculate()
   {
      MqlDateTime dtcurrent;
      TimeCurrent(dtcurrent);
      //if(dtcurrent.hour!=16)
      //   return;

      MqlRates rates[];
      ArraySetAsSeries(rates,true);
      int copied=CopyRates(Symbol(),PERIOD_M1,0,1,rates); 
      if(copied==1)
      {
         if(!pivotsdata.Calculate(rates[0].time))
            return;
         
         datetime starttime=rates[0].time;

         copied=CopyRates(Symbol(),PERIOD_D1,0,1,rates);
         if(copied==-1)
            return;

         datetime endtime=rates[0].time;
         if(lastdaysignal==endtime)
            return;

         //copied=CopyRates(Symbol(),PERIOD_M1,starttime,endtime,rates);
         int copycount=500;
         copied=CopyRates(Symbol(),PERIOD_M1,0,copycount,rates);
         if(copied<copycount)
            return;
            
         //Print(IntegerToString(rates[0].time));
         
         double tickvalue=CurrentSymbolTickValue();
         if(tickvalue==0)
            return;
         
         double upperlevel=pivotsdata.PivotsDay.R1;
         double lowerlevel=pivotsdata.PivotsDay.S1;
         double centerlevel=pivotsdata.PivotsDay.P;
         double upperrange=NormalizeDouble((upperlevel-centerlevel)/Point(),0);
         double lowerrange=NormalizeDouble((centerlevel-lowerlevel)/Point(),0);

         double percentbalance=2;
         double uppervolume=NormalizeDouble(((AccountBalanceX()/100)*percentbalance)/(tickvalue*upperrange),2);
         double lowervolume=NormalizeDouble(((AccountBalanceX()/100)*percentbalance)/(tickvalue*lowerrange),2);

         //if(rates[0].close>=upperlevel&&uppervolume>=0.01&&upperrange>=100)
         if(rates[0].close>=upperlevel   &&   rates[0].close<=upperlevel+(Point()*10)   /*&&   upperrange>=50*/   &&   uppervolume>=0.01)
         {
            //Print("Range: "+upperrange+" | Volume: "+uppervolume);
            lastdaysignal=endtime;
            OpenSell(NULL,uppervolume,0,upperrange+10,upperrange-10);
         }

         //if(rates[0].close<=lowerlevel&&lowervolume>=0.01)
         //{
         //   lasth4signal=endtime;
         //   OpenBuy(NULL,lowervolume,0,lowerrange,lowerrange);
         //}

      }
   }
};


class StrategyPivotsH4FibonacciR1S1Reversal : public Strategy
{
public:
   TypePivotsData pivotsdata;
   datetime lasth4signal;

   StrategyPivotsH4FibonacciR1S1Reversal()
   {
      pivotsdata.Settings.draw=true;
      pivotsdata.Settings.PivotTypeHour=NONE;
      pivotsdata.Settings.PivotTypeFourHour=PIVOT_FIBONACCI;
      pivotsdata.Settings.PivotTypeDay=NONE;
      pivotsdata.Settings.PivotTypeWeek=NONE;
      pivotsdata.Settings.PivotTypeMonth=NONE;
      pivotsdata.Settings.PivotTypeYear=NONE;
      lasth4signal=0;
   }

   void Calculate()
   {

   }

   void IdleCalculate()
   {
      MqlDateTime t;
      TimeCurrent(t);
      if(!_TradingHours[t.hour])
         return;

      MqlRates rates[];
      ArraySetAsSeries(rates,true);
      int copied=CopyRates(Symbol(),PERIOD_M1,0,1,rates); 
      if(copied==1)
      {
         if(!pivotsdata.Calculate(rates[0].time))
            return;
         
         datetime starttime=rates[0].time;

         copied=CopyRates(Symbol(),PERIOD_H4,0,1,rates);
         if(copied==-1)
            return;

         datetime endtime=rates[0].time;
         if(lasth4signal==endtime)
            return;

         //copied=CopyRates(Symbol(),PERIOD_M1,starttime,endtime,rates);
         int copycount=500;
         copied=CopyRates(Symbol(),PERIOD_M1,0,copycount,rates);
         if(copied<copycount)
            return;
            
         //Print(IntegerToString(rates[0].time));
         
         double tickvalue=CurrentSymbolTickValue();
         if(tickvalue==0)
            return;
         
         double upperlevel=pivotsdata.PivotsFourHour.R1;
         double lowerlevel=pivotsdata.PivotsFourHour.S1;
         double centerlevel=pivotsdata.PivotsFourHour.P;
         double upperrange=NormalizeDouble((upperlevel-centerlevel)/Point(),0);
         double lowerrange=NormalizeDouble((centerlevel-lowerlevel)/Point(),0);

         double percentbalance=2;
         double uppervolume=NormalizeDouble(((AccountBalanceX()/100)*percentbalance)/(tickvalue*upperrange),2);
         double lowervolume=NormalizeDouble(((AccountBalanceX()/100)*percentbalance)/(tickvalue*lowerrange),2);

         bool BaerishRelation=pivotsdata.PivotsFourHourList[1].P<pivotsdata.PivotsFourHourList[2].P;
         bool BullishRelation=pivotsdata.PivotsFourHourList[1].P>pivotsdata.PivotsFourHourList[2].P;

         bool Inside=pivotsdata.PivotsFourHourList[1].TC<pivotsdata.PivotsFourHourList[2].TC&&pivotsdata.PivotsFourHourList[1].BC>pivotsdata.PivotsFourHourList[2].BC;

         bool Engulfing=pivotsdata.PivotsFourHourList[1].TC>pivotsdata.PivotsFourHourList[2].TC&&pivotsdata.PivotsFourHourList[1].BC<pivotsdata.PivotsFourHourList[2].BC;

         bool LargerRange=(pivotsdata.PivotsFourHourList[1].TC-pivotsdata.PivotsFourHourList[1].BC)>(pivotsdata.PivotsFourHourList[2].TC-pivotsdata.PivotsFourHourList[2].BC);

         if(rates[0].close>=upperlevel&&uppervolume>=0.01&&upperrange>=100)
         //if(Inside  &&  rates[0].close>=upperlevel   &&   rates[0].close<=upperlevel+(Point()*10)   /*&&   upperrange>=50*/   &&   uppervolume>=0.01   &&   upperrange>=MinPoints1)
         {
            //Print("Range: "+upperrange+" | Volume: "+uppervolume);
            lasth4signal=endtime;
            OpenSell(NULL,uppervolume,0,NULL,NULL,upperlevel+(upperlevel-centerlevel),centerlevel);
         }

         //if(rates[0].close<=lowerlevel&&lowervolume>=0.01)
         //{
         //   lasth4signal=endtime;
         //   OpenBuy(NULL,lowervolume,0,lowerrange,lowerrange);
         //}

      }
   }
};


class StrategyCSH4Reversal : public Strategy
{
public:
   TypeCurrencyStrength CS[1];
   bool tradesstarted;

   StrategyCSH4Reversal()
   {
      CS[0].Init(
         10,
         10,
         StringSubstr(Symbol(),6),
         PERIOD_H4,
         false,
         pr_close
         );
   }

   void Calculate()
   {
      MqlDateTime dtcurrent;
      TimeCurrent(dtcurrent);
      //if((dtcurrent.hour==3||dtcurrent.hour==7||dtcurrent.hour==11||dtcurrent.hour==15||dtcurrent.hour==19)&&dtcurrent.min==59)
      if(dtcurrent.hour==11&&dtcurrent.min==59)
      //if((dtcurrent.hour==11||dtcurrent.hour==15)&&dtcurrent.min==59)
      //if(dtcurrent.min==59||dtcurrent.min==29)
      //if(dtcurrent.min==59)
      {
         bool csok=CS_CalculateIndex(CS[0]);
         if(dtcurrent.sec>=50&&csok&&!tradesstarted)
         {
            tradesstarted=true;
            for(int z=0; z<4; z++)
            {
               if(CS[0].Currencies.Trade[z].buy)
                  OpenSell(CS[0].Currencies.Trade[z].name);
               else
                  OpenBuy(CS[0].Currencies.Trade[z].name);
            }
         }
      }
      else
         tradesstarted=false;
   }

   void IdleCalculate() {}
};


class StrategyTest1 : public Strategy
{
public:
   void Calculate() {}

   void IdleCalculate()
   {
       OpenBuy(NULL,0.01,0,0,400);
       OpenSell(NULL,0.01,0,0,400);
       return;

      MqlRates rates[];
      ArraySetAsSeries(rates,true); 
      int copied=CopyRates(Symbol(),0,0,10,rates); 
      if(copied==10)
      {
         MqlDateTime dtcurrent;
         TimeToStruct(rates[0].time,dtcurrent);
         if(dtcurrent.hour<8||dtcurrent.hour>18)
            return;
      
         //if(rates[1].close>rates[1].open && rates[1].close>rates[2].open && rates[2].close<rates[2].open && rates[3].close<rates[3].open && rates[0].close<=rates[2].open)
         //if(rates[1].close>rates[1].open && rates[1].close>rates[2].open && rates[2].close<rates[2].open && rates[3].close<rates[3].open)
         double lastcandlehight=(rates[1].close-rates[1].open)/Point();
         //if(rates[1].close>rates[1].open && rates[2].close<rates[2].open && rates[3].close<rates[3].open && lastcandlehight>=30)
         if(rates[1].close>rates[2].open && rates[2].close<rates[2].open && rates[3].close<rates[3].open)
            OpenBuy(NULL,0.01,0,0,400);
         if(rates[1].close<rates[2].open && rates[2].close>rates[2].open && rates[3].close>rates[3].open)
            OpenSell(NULL,0.01,0,0,400);
      }
   }
};


class StrategyCSBase : public Strategy
{
public:

   string Name;
   string Namespace;

   string GetName() {return Name;}

   int db;
   int request;
   TypeCurrencyStrength CS[];

   datetime lastminute;
   int lastday;
   int daytrend;

   struct TypeTimes
   {
      datetime t1;
      MqlDateTime t2;
   };
   TypeTimes times;

   struct TypeOscillatorInfo
   {
      int Currency;
      int Level;
      int Change;
      int HighLevel;
      int HighBar;
      int LastHighTurnLevel;
      int LastHighTurnBar;
      int LowLevel;
      int LowBar;
      int LastLowTurnLevel;
      int LastLowTurnBar;
   };

   struct TypeCrossInfo
   {
      int UpCurrency;
      int DownCurrency;
   };

   struct TypePairs
   {
      string Pair[28];
      TypePairs()
      {
         Pair[0]="EURUSD";
         Pair[1]="GBPUSD";
         Pair[2]="USDCHF";
         Pair[3]="USDJPY";
         Pair[4]="USDCAD";
         Pair[5]="AUDUSD";
         Pair[6]="NZDUSD";
         Pair[7]="EURNZD";
         Pair[8]="EURCAD";
         Pair[9]="EURAUD";
         Pair[10]="EURJPY";
         Pair[11]="EURCHF";
         Pair[12]="EURGBP";
         Pair[13]="GBPNZD";
         Pair[14]="GBPAUD";
         Pair[15]="GBPCAD";
         Pair[16]="GBPJPY";
         Pair[17]="GBPCHF";
         Pair[18]="CADJPY";
         Pair[19]="CADCHF";
         Pair[20]="AUDCAD";
         Pair[21]="NZDCAD";
         Pair[22]="AUDCHF";
         Pair[23]="AUDJPY";
         Pair[24]="AUDNZD";
         Pair[25]="NZDJPY";
         Pair[26]="NZDCHF";
         Pair[27]="CHFJPY";
      }
      string NormalizePairing(string pair)
      {
         string p=pair;
         for(int i=0; i<28; i++)
         {
            if(StringSubstr(p,3,3)+StringSubstr(p,0,3)==Pair[i])
            {
               p=Pair[i];
               break;
            }
         }
         return p;
      }
   };
   TypePairs Pairs;

   struct TypeRow
   {
      int TIME;
      int YEAR;
      int MONTH;
      int DAY;
      int DAYOFWEEK;
      int HOUR;
      int MINUTE;
      int C1;
      int C2;
      int C3;
      int C4;
      int C5;
      int C6;
      int C7;
      int C8;
      int D1;
      int D2;
      int D3;
      int D4;
      int D5;
      int D6;
      int D7;
      int D8;
      int DD1;
      int DD2;
      int DD3;
      int DD4;
      int DD5;
      int DD6;
      int DD7;
      int DD8;
      int DDD1;
      int DDD2;
      int DDD3;
      int DDD4;
      int DDD5;
      int DDD6;
      int DDD7;
      int DDD8;
      int O1;
      int O2;
      int O3;
      int O4;
      int O5;
      int O6;
      int O7;
      int O8;
      int MA1;
      int MA2;
      int MA3;
      int MA4;
      int MA5;
      int MA6;
      int MA7;
      int MA8;
      int MAL1;
      int MAL2;
      int MAL3;
      int MAL4;
      int MAL5;
      int MAL6;
      int MAL7;
      int MAL8;
      int OL1;
      int OL2;
      int OL3;
      int OL4;
      int OL5;
      int OL6;
      int OL7;
      int OL8;
      int L1;
      int L2;
      int L3;
      int L4;
      int L5;
      int L6;
      int L7;
      int L8;
      TypeRow()
      {
         TIME=0;
      }
   };
   TypeRow u;
   int r[100][9][8];

   void UtoR(int i)
   {
      r[i][1][0]=u.D1;
      r[i][1][1]=u.D2;
      r[i][1][2]=u.D3;
      r[i][1][3]=u.D4;
      r[i][1][4]=u.D5;
      r[i][1][5]=u.D6;
      r[i][1][6]=u.D7;
      r[i][1][7]=u.D8;
      r[i][2][0]=u.DD1;
      r[i][2][1]=u.DD2;
      r[i][2][2]=u.DD3;
      r[i][2][3]=u.DD4;
      r[i][2][4]=u.DD5;
      r[i][2][5]=u.DD6;
      r[i][2][6]=u.DD7;
      r[i][2][7]=u.DD8;
      r[i][3][0]=u.DDD1;
      r[i][3][1]=u.DDD2;
      r[i][3][2]=u.DDD3;
      r[i][3][3]=u.DDD4;
      r[i][3][4]=u.DDD5;
      r[i][3][5]=u.DDD6;
      r[i][3][6]=u.DDD7;
      r[i][3][7]=u.DDD8;
      r[i][4][0]=u.O1;
      r[i][4][1]=u.O2;
      r[i][4][2]=u.O3;
      r[i][4][3]=u.O4;
      r[i][4][4]=u.O5;
      r[i][4][5]=u.O6;
      r[i][4][6]=u.O7;
      r[i][4][7]=u.O8;
      r[i][5][0]=u.MA1;
      r[i][5][1]=u.MA2;
      r[i][5][2]=u.MA3;
      r[i][5][3]=u.MA4;
      r[i][5][4]=u.MA5;
      r[i][5][5]=u.MA6;
      r[i][5][6]=u.MA7;
      r[i][5][7]=u.MA8;
   }

   void UtoR2(int i)
   {
      r[i][6][0]=u.MAL1;
      r[i][6][1]=u.MAL2;
      r[i][6][2]=u.MAL3;
      r[i][6][3]=u.MAL4;
      r[i][6][4]=u.MAL5;
      r[i][6][5]=u.MAL6;
      r[i][6][6]=u.MAL7;
      r[i][6][7]=u.MAL8;
      r[i][7][0]=u.OL1;
      r[i][7][1]=u.OL2;
      r[i][7][2]=u.OL3;
      r[i][7][3]=u.OL4;
      r[i][7][4]=u.OL5;
      r[i][7][5]=u.OL6;
      r[i][7][6]=u.OL7;
      r[i][7][7]=u.OL8;
      r[i][8][0]=u.L1;
      r[i][8][1]=u.L2;
      r[i][8][2]=u.L3;
      r[i][8][3]=u.L4;
      r[i][8][4]=u.L5;
      r[i][8][5]=u.L6;
      r[i][8][6]=u.L7;
      r[i][8][7]=u.L8;
   }

   void UtoR3(int i)
   {
      r[i][0][0]=u.D1;
      r[i][0][1]=u.D2;
      r[i][0][2]=u.D3;
      r[i][0][3]=u.D4;
      r[i][0][4]=u.D5;
      r[i][0][5]=u.D6;
      r[i][0][6]=u.D7;
      r[i][0][7]=u.D8;
   }
  
   void Init()
   {
      lastminute=0;
      lastday=0;
      daytrend=-1;

      string s=appnamespace+Namespace+" ";
      string varname=s+"lastminute";
      if(GlobalVariableCheck(varname))
         lastminute=(int)GlobalVariableGet(varname);
      varname=s+"lastday";
      if(GlobalVariableCheck(varname))
         lastday=(int)GlobalVariableGet(varname);
      varname=s+"daytrend";
      if(GlobalVariableCheck(varname))
         daytrend=(int)GlobalVariableGet(varname);
      
      if(UseCurrencyStrengthDatabase)
      {
         db=DatabaseOpen("CS.sqlite", DATABASE_OPEN_READONLY | DATABASE_OPEN_COMMON);
         request=DatabasePrepare(db, "SELECT * FROM MinutesCS WHERE TIME=?");
      }
      else
      {
         ArrayResize(CS,7);

         M15DayInit();

         CS[6].Init(
            60,
            60,
            StringSubstr(Symbol(),6),
            PERIOD_M1,
            false,
            pr_close,
            0,
            0,
            true
            );
      }
   }

   ~StrategyCSBase()
   {
      string s=appnamespace+Namespace+" ";
      GlobalVariableSet(s+"lastminute",lastminute);
      GlobalVariableSet(s+"lastday",lastday);
      GlobalVariableSet(s+"daytrend",daytrend);

      if(UseCurrencyStrengthDatabase)
         DatabaseClose(db);
   }

   void M15DayInit()
   {
      int zeropoint=100;
   
      datetime Arr[];
      if(CopyTime(Symbol(),PERIOD_M15,0,100,Arr)==100)
      {
         for(int i=100-2; i>=0; i--)
         {
            MqlDateTime dt;
            MqlDateTime dtp;
            TimeToStruct(Arr[i],dt);
            TimeToStruct(Arr[i+1],dtp);
            zeropoint=100-1-i;
            if(dt.day!=dtp.day)
               break;
         }
      }
   
      CS[0].Init(
         100,
         zeropoint,
         StringSubstr(Symbol(),6),
         PERIOD_M15,
         false,
         pr_close,
         //pr_haaverage,
         19,
         5,
         true
         );
      CS[0].recalculate=true;
   
      CS[1].Init(
         100,
         zeropoint,
         StringSubstr(Symbol(),6),
         PERIOD_M15,
         false,
         pr_close,
         //pr_haaverage,
         6,
         0,
         true
         );
      CS[1].recalculate=true;

      CS[2].Init(
         100,
         zeropoint,
         StringSubstr(Symbol(),6),
         PERIOD_M15,
         false,
         pr_close,
         0,
         0,
         true
         );
      CS[2].recalculate=true;

      CS[3].Init(
         70,
         70,
         StringSubstr(Symbol(),6),
         PERIOD_H3,
         false,
         pr_close,
         6,
         0,
         true
         );
      CS[3].recalculate=true;

      CS[4].Init(
         70,
         70,
         StringSubstr(Symbol(),6),
         PERIOD_H3,
         false,
         pr_close,
         19,
         5,
         true
         );
      CS[4].recalculate=true;

      CS[5].Init(
         70,
         70,
         StringSubstr(Symbol(),6),
         PERIOD_H3,
         false,
         pr_close,
         0,
         0,
         true
         );
      CS[5].recalculate=true;
   }

   bool GetM1Time()
   {
      datetime time[];
      int copied=CopyTime(Symbol(),PERIOD_M1,0,1,time); 
      if(copied==1)
      {
         times.t1=time[0];
         TimeToStruct(time[0],times.t2);
         return true;
      }
      return false;
   }
   
   bool IsM15NewBar()
   {
      if(MathMod(times.t2.min,15)!=0)
      {
         if(!UseCurrencyStrengthDatabase)
         {
            CS_CalculateIndex(CS[0]);
            CS_CalculateIndex(CS[1]);
            CS_CalculateIndex(CS[2]);
            CS_CalculateIndex(CS[3]);
            CS_CalculateIndex(CS[4]);
            CS_CalculateIndex(CS[5]);
         }
         return false;
      }
      else
      {
         if(!UseCurrencyStrengthDatabase)
            M15DayInit();
      }
      return true;
   }

   bool IsTradingTime()
   {
      if(!_TradingHours[times.t2.hour])
         return false;
      if(!_TradingWeekdays[times.t2.day_of_week])
         return false;
      return true;
   }

   void GetIndexDataM15()
   {
      if(UseCurrencyStrengthDatabase)
      {
         datetime Arr[100];
         CopyTime(Symbol(),PERIOD_M15,0,100,Arr);
         for(int i=0; i<100; i++)
         {
            int t=(int)Arr[99-i]-60;
            DatabaseReset(request);
            DatabaseBind(request,0,t);
            if(!DatabaseReadBind(request,u))
               break;
            UtoR(i);
         }
         datetime Arr2[70];
         CopyTime(Symbol(),PERIOD_H3,0,70,Arr2);
         for(int i=0; i<70; i++)
         {
            int t=(int)Arr2[69-i]-60;
            DatabaseReset(request);
            DatabaseBind(request,0,t);
            if(!DatabaseReadBind(request,u))
               break;
            UtoR2(i);
         }
         datetime Arr3[60];
         CopyTime(Symbol(),PERIOD_M1,0,60,Arr3);
         for(int i=0; i<60; i++)
         {
            int t=(int)Arr3[59-i]-60;
            DatabaseReset(request);
            DatabaseBind(request,0,t);
            if(!DatabaseReadBind(request,u))
               break;
            UtoR3(i);
         }
         for(int i=0; i<60; i++)
            for(int ii=0; ii<8; ii++)
               r[i][0][ii]=r[i][0][ii]-r[59][0][ii];
      }
      else
      {
         CS[6].recalculate=true;
         CS_CalculateIndex(CS[6],1);
      
         for(int i=0; i<100; i++)
         {
            for(int z=0; z<8; z++)
            {
               r[i][4][z]=(int)MathRound(CS[0].Currencies.Currency[z].index[CS[0].bars-1-i].laging.value1*100000);
               r[i][5][z]=(int)MathRound(CS[1].Currencies.Currency[z].index[CS[1].bars-1-i].laging.value1*100000);
               r[i][1][z]=(int)MathRound(CS[2].Currencies.Currency[z].index[CS[2].bars-1-i].laging.value1*100000);
               if(i<70)
               {
                  r[i][6][z]=(int)MathRound(CS[3].Currencies.Currency[z].index[CS[3].bars-1-i].laging.value1*100000);
                  r[i][7][z]=(int)MathRound(CS[4].Currencies.Currency[z].index[CS[4].bars-1-i].laging.value1*100000);
                  r[i][8][z]=(int)MathRound(CS[5].Currencies.Currency[z].index[CS[5].bars-1-i].laging.value1*100000);
               }
               if(i<60)
                  r[i][0][z]=(int)MathRound(CS[6].Currencies.Currency[z].index[CS[6].bars-1-i].laging.value1*100000);
            }
         }
      }
   }

   void IdleCalculate() {}

   void Calculate() {}

   string IndexToCurrency(int index)
   {
      if(index==0) return "USD";
      if(index==1) return "EUR";
      if(index==2) return "GBP";
      if(index==3) return "JPY";
      if(index==4) return "CHF";
      if(index==5) return "CAD";
      if(index==6) return "AUD";
      if(index==7) return "NZD";
      return "";
   }

   void Trade(int buy, int sell, double openlots)
   {
      string pair=IndexToCurrency(buy)+IndexToCurrency(sell);
      string pairN=Pairs.NormalizePairing(pair);
      if(pair==pairN)
         OpenBuy(pair,openlots);
      else
         OpenSell(pairN,openlots);
   }
   
   bool BreakOutUp(int currency, int level)
   {
      int daystartindex=MathAbs((times.t2.hour*4)+(times.t2.min/15));
      int maxlevel=0;
      for(int i=daystartindex; i>0; i--)
         maxlevel=MathMax(maxlevel,r[i][5][currency]);
      return
      r[0][5][currency]>level &&
      maxlevel<=level &&
      true;
   }

   bool BreakOutDown(int currency, int level)
   {
      int daystartindex=MathAbs((times.t2.hour*4)+(times.t2.min/15));
      int minlevel=0;
      for(int i=daystartindex; i>0; i--)
         minlevel=MathMin(minlevel,r[i][5][currency]);
      return
      r[0][5][currency]<level &&
      minlevel>=level &&
      true;
   }
   
   int StrengthAtPos(int pos, int mode) // pos=7=strongest, pos=0=weakest, mode=0=60Min, mode=5=DayMA, ...
   {
      int a[8][2];
      for(int z=0; z<8; z++)
      {
         a[z][1]=z;
         a[z][0]=r[0][mode][z];
      }
      ArraySort(a);
      return a[pos][1];
   }
   
   void Oscillators(TypeOscillatorInfo& oi[], bool olong=false)
   {
      int typeindex=4;
      int itemcount=100;
      if(olong)
      {
         typeindex=7;
         itemcount=70;
      }
   
      for(int z=0; z<8; z++)
      {
         ArrayResize(oi,z+1);

         oi[z].Currency=z;
         oi[z].Change=r[0][typeindex][z]-r[1][typeindex][z];
         oi[z].Level=r[0][typeindex][z];
         oi[z].HighLevel=INT_MIN;
         oi[z].HighBar=-1;
         oi[z].LastHighTurnLevel=INT_MIN;
         oi[z].LastHighTurnBar=-1;
         oi[z].LowLevel=INT_MAX;
         oi[z].LowBar=-1;
         oi[z].LastLowTurnLevel=INT_MAX;
         oi[z].LastLowTurnBar=-1;

         for(int i=0; i<itemcount; i++)
         {
            int c=r[i][typeindex][z];

            if(c>oi[z].HighLevel)
            {
               oi[z].HighBar=i;
               oi[z].HighLevel=c;
            }
            else if(oi[z].HighLevel>0 && oi[z].LastHighTurnBar==-1)
            {
               oi[z].LastHighTurnBar=oi[z].HighBar;
               oi[z].LastHighTurnLevel=oi[z].HighLevel;
            }

            if(c<oi[z].LowLevel)
            {
               oi[z].LowBar=i;
               oi[z].LowLevel=c;
            }
            else if(oi[z].LowLevel<0 && oi[z].LastLowTurnBar==-1)
            {
               oi[z].LastLowTurnBar=oi[z].LowBar;
               oi[z].LastLowTurnLevel=oi[z].LowLevel;
            }
         }
      }
   }
   
   int MACrosses(TypeCrossInfo& CrossInfo[])
   {
      int count=0;
      for(int z=0; z<8; z++)
      {
         for(int y=0; y<8; y++)
         {
            if(
               r[0][5][z]>r[0][5][y] &&
               r[1][5][z]<r[1][5][y] &&
               r[0][5][z]>r[1][5][z] &&
               r[0][5][y]<r[1][5][y] &&
               true)
            {
               count++;
               ArrayResize(CrossInfo,count);
               CrossInfo[count-1].UpCurrency=z;
               CrossInfo[count-1].DownCurrency=y;
            }
         }
      }
      return count;
   }
   
   bool PictureOfPower(int currency)
   {
      bool power=false;
      bool isstrongest=StrengthAtPos(7,0)==currency;
      double maxnoise=0;
      
      if(isstrongest)
      {
         for(int i=1; i<=58; i++)
         {
            double ref=((double)r[0][0][currency]/59)*(59-i);
            double dev=MathAbs(r[i][0][currency]-ref);
            maxnoise=MathMax(maxnoise,dev);
         }
         maxnoise=maxnoise/r[0][0][currency]*100;
         if(maxnoise<=20)
            power=true;
      }
      
      return power;
   }

   void OpenBasket(int currency, double openlots, int direction)
   {
      for(int z=0; z<8; z++)
      {
         if(z!=currency)
         {
            string pair=IndexToCurrency(currency)+IndexToCurrency(z);
            string pairN=Pairs.NormalizePairing(pair);
            if((pair==pairN && direction==OP_BUY) || (pair!=pairN && direction==OP_SELL))
               OpenBuy(pairN,openlots);
            else
               OpenSell(pairN,openlots);
         }
      }
   }

};


class StrategyCSFollow : public StrategyCSBase
{
public:

   StrategyCSFollow()
   {
      Name="Harvester CSFollow";
      if(UseCurrencyStrengthDatabase)
         Name+=" DB";
      Namespace="HARVCSFollow";
      Init();
   }

   void Calculate()
   {
      if(!GetM1Time())
         return;

      if(!IsM15NewBar())
         return;

      if(!IsTradingTime())
         return;

      if(times.t1==lastminute)
         return;

      GetIndexDataM15();
      
      bool isnewday=lastday!=times.t2.day_of_year;
      if(isnewday)
         daytrend=-1;

      double openlots=NormalizeDouble((AccountBalanceX()/10000)*_OpenLots,2);
      //openlots=_OpenLots;

      //if(times.t2.hour!=7)
      //   return;

      TypeCrossInfo CrossInfo[];
      int s=MACrosses(CrossInfo);
      for(int z=0; z<s; z++)
      {
         //Trade(CrossInfo[z].UpCurrency,CrossInfo[z].DownCurrency,openlots);
      }

      bool a[8][2];
      for(int z=0; z<8; z++)
      {
         a[z][0]=BreakOutUp(z,MinPoints1);
         a[z][1]=BreakOutDown(z,(MinPoints1*-1));
      }
      for(int z=0; z<8; z++)
      {
         if(a[z][0])
         {
            Trade(z,StrengthAtPos(0,5),openlots);
         }
         if(a[z][1])
         {
            Trade(StrengthAtPos(7,5),z,openlots);
         }
      }

      lastminute=times.t1;
   }
};


class StrategyCSGBPReversal : public StrategyCSBase
{
public:

   StrategyCSGBPReversal()
   {
      Name="Harvester CSGBPReversal";
      if(UseCurrencyStrengthDatabase)
         Name+=" DB";
      Namespace="HARVCSGBPReversal";
      Init();
   }

   void Calculate()
   {
      if(!GetM1Time())
         return;

      if(!IsM15NewBar())
         return;

      if(!IsTradingTime())
         return;

      if(times.t1==lastminute)
         return;

      GetIndexDataM15();
      
      bool isnewday=lastday!=times.t2.day_of_year;
      if(isnewday)
         daytrend=-1;

      double openlots=NormalizeDouble((AccountBalanceX()/10000)*_OpenLots,2);
      //openlots=_OpenLots;

      //if((daytrend==OP_BUY && row.D3<0) || (daytrend==OP_SELL && row.D3>0))
      //   CloseAllInternal();

      //if(dtcurrent.hour==22)
      //{
      //   CloseAllInternal();
      //   return;
      //}

      TypeOscillatorInfo oi[];
      Oscillators(oi);

      if(
         //r[0][1][2]>=MinPoints1 &&
         r[0][1][2]>=50 &&
         oi[2].LastHighTurnBar==1 &&
         oi[2].LastHighTurnLevel>=105 &&
         isnewday &&
         true
      )
      {
         OpenBasket(2,openlots,OP_SELL);
         lastday=times.t2.day_of_year;
         daytrend=OP_SELL;
      }
      if(
         //r[0][1][2]<=(MinPoints1*-1) &&
         r[0][1][2]<=-50 &&
         oi[2].LastLowTurnBar==1 &&
         oi[2].LastLowTurnLevel<=-105 &&
         isnewday &&
         true
      )
      {
         OpenBasket(2,openlots,OP_BUY);
         lastday=times.t2.day_of_year;
         daytrend=OP_BUY;
      }

      lastminute=times.t1;
   }
};


class StrategyCSEmergingTrends : public StrategyCSBase
{
public:

   StrategyCSEmergingTrends()
   {
      Name="Harvester CSEmergingTrends";
      if(UseCurrencyStrengthDatabase)
         Name+=" DB";
      Namespace="HARVCSEmergingTrends";
      Init();
   }

   void Calculate()
   {
      if(!GetM1Time())
         return;

      if(!IsM15NewBar())
         return;

      if(!IsTradingTime())
         return;

      if(times.t1==lastminute)
         return;

      GetIndexDataM15();
      
      bool isnewday=lastday!=times.t2.day_of_year;
      if(isnewday)
         daytrend=-1;

      double openlots=NormalizeDouble((AccountBalanceX()/10000)*_OpenLots,2);
      //openlots=_OpenLots;

      //if((daytrend==OP_BUY && row.D3<0) || (daytrend==OP_SELL && row.D3>0))
      //   CloseAllInternal();

      //if(dtcurrent.hour==22)
      //{
      //   CloseAllInternal();
      //   return;
      //}

      if(false)
      {
         TypeOscillatorInfo oi[];
         Oscillators(oi,true);
   
         for(int z=0; z<8; z++)
         {
            //if(oi[z].LastHighTurnBar==1 &&
            //   oi[z].LastHighTurnLevel>125 &&
            //   false
            //)
            //   CloseAllInternal("Buys-"+IndexToCurrency(z));
            //if(oi[z].LastLowTurnBar==1 &&
            //   oi[z].LastLowTurnLevel<-125 &&
            //   false
            //)
            //   CloseAllInternal("Sells"+IndexToCurrency(z));
   
            for(int y=0; y<8; y++)
            {
               if(y!=z)
               {
                  if(
                     oi[z].LastHighTurnBar==1 &&
                     oi[z].LastHighTurnLevel>125 &&
                     oi[y].LastLowTurnBar==1 &&
                     oi[y].LastLowTurnLevel<-125 &&
                     isnewday &&
                     true
                  )
                  {
                     Trade(y,z,openlots);
                     lastday=times.t2.day_of_year;
                  }
               }
            }
         }
      }

      lastminute=times.t1;
   }
};


class StrategyGBPWeek : public StrategyCSBase
{
public:

   StrategyGBPWeek()
   {
      Name="Harvester GBPWeek";
      if(UseCurrencyStrengthDatabase)
         Name+=" DB";
      Namespace="HARVGBPWeek";
      Init();
   }

   void Calculate()
   {
      if(!GetM1Time())
         return;

      IsM15NewBar();
      //if(!IsM15NewBar())
      //   return;

      //if(!IsTradingTime())
      //   return;

      if(times.t1==lastminute)
         return;

      GetIndexDataM15();
      
      bool isnewday=lastday!=times.t2.day_of_year;
      if(isnewday)
         daytrend=-1;

      double openlots=NormalizeDouble((AccountBalanceX()/10000)*_OpenLots,2);
      //openlots=_OpenLots;

      if(
         times.t2.day_of_week==3 &&
         times.t2.hour>=22 &&
         //isnewday &&
         true
      )
      {
         CloseAllInternal();
         lastday=times.t2.day_of_year;
      }

      if(
         BI.managedorders>0 &&
         times.t2.day_of_week==2 &&
         times.t2.hour>2 &&
         (r[0][2][2]>=250 || r[0][2][2]<=-250) &&
         isnewday &&
         true
      )
      {
         if(r[0][2][2]>=250)
         {
            CloseAllInternal("Buys-"+IndexToCurrency(2));
            OpenBasket(2,openlots,OP_SELL);
         }
         else
         {
            CloseAllInternal("Sells"+IndexToCurrency(2));
            OpenBasket(2,openlots,OP_BUY);
         }
         
         //OpenBasket(2,openlots,OP_BUY);
         //OpenBasket(2,openlots,OP_SELL);
         lastday=times.t2.day_of_year;
      }

      if(
         times.t2.day_of_week==1 &&
         times.t2.hour>2 &&
         r[0][1][2]<10 &&
         r[0][1][2]>-10 &&
         isnewday &&
         true
      )
      {
         OpenBasket(2,openlots,OP_BUY);
         OpenBasket(2,openlots,OP_SELL);
         lastday=times.t2.day_of_year;
      }

      lastminute=times.t1;
   }
};


class StrategyCSGBP45MinStrength : public StrategyCSBase
{
public:
   bool hedged1;
   bool hedged2;

   StrategyCSGBP45MinStrength()
   {
      Name="Harvester CSGBP45MinStrength";
      if(UseCurrencyStrengthDatabase)
         Name+=" DB";
      Namespace="HARVCSGBP45MinStrength";
      Init();
      
      if(istesting)
         TradesViewSelected=ByCurrenciesGrouped;
   }

   void Calculate()
   {
      int currency=2;

      if(!GetM1Time())
         return;
         
      IsM15NewBar();

      if(times.t1==lastminute)
         return;
      
      if(!UseCurrencyStrengthDatabase)
         GetIndexDataM15();

      if(BI.managedorders!=0)
      {
         double gainpercent=WS.globalgain/AccountBalanceNet()*100;

         TypeCurrenciesTradesInfo ct=BI.currenciesintrades[currency];
 
         if(gainpercent<=P1 && !hedged1 && false)
         {
            double openlots=NormalizeDouble((AccountBalanceNet()/10000)*(_OpenLots*P2),2);
            
            if(ct.sellvolume>0)
            {
               OpenBasket(currency,openlots,OP_BUY);
            }
            else
            {
               OpenBasket(currency,openlots,OP_SELL);
            }
            hedged1=true;
         }

         if(gainpercent<=-2 && hedged1 && !hedged2 && false)
         {
            double openlots=NormalizeDouble((AccountBalanceNet()/10000)*(_OpenLots*1),2);
            
            if(ct.sellvolume>ct.buyvolume)
            {
               OpenBasket(currency,openlots,OP_SELL);
            }
            else
            {
               OpenBasket(currency,openlots,OP_BUY);
            }
            hedged2=true;
         }
      }
      else
      {
         hedged1=false;
         hedged2=false;

         if(!IsTradingTime())
            return;
   
         if(UseCurrencyStrengthDatabase)
            GetIndexDataM15();
   
         double openlots=NormalizeDouble((AccountBalanceNet()/10000)*_OpenLots,2);
   
         //TypeOscillatorInfo oi[];
         //Oscillators(oi,false);
   
         if(
            StrengthAtPos(7,0)==currency &&
            //times.t2.min==StartMinute &&
            //oi[2].LastHighTurnBar<=5 &&
            true
         )
         {
            OpenBasket(currency,openlots,OP_SELL);
         }
         if(
            StrengthAtPos(0,0)==currency &&
            //times.t2.min==StartMinute &&
            //oi[2].LastLowTurnBar<=5 &&
            //PictureOfPower(currency) &&
            true
         )
         {
            OpenBasket(currency,openlots,OP_BUY);
         }
      }

      lastminute=times.t1;
   }
};


Strategy* strats[];