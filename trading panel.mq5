//+------------------------------------------------------------------+
//|                                            Discretion Helper.mq5 |
//|             Copyright 2018, Kashu Yamazaki, All Rights Reserved. |
//|                                      https://Kashu7100.github.io |
//+------------------------------------------------------------------+
#define VERSION "2.20"
#property copyright "Copyright 2018, Kashu Yamazaki, All Rights Reserved."
#property version   VERSION
#property description "The trading helper tool for MT5 traders."
#property description "The robot can run on any instruments and timeframe and will greatly reduce your tedious tasks."
#property icon "logo.ico";
#property strict

#include <TradingPanel.mqh>

long AccountNumber = NULL;

input string                  OrderSettings; //Order Settings
input double                  risk = 100; //Risk [%]
input double                  SL = 15; // Stop Loss (SL) [pips]
input double                  TP = 30; // Take Profit (TP) [pips]

input string                  TrailingSettings;//Trailing Settings
input double                  startSL = 15; //Start Trailing Level (STL) [pips]
input double                  widthSL = 15; //Trailing Width (TW) [pips]
input ENUM_POSITION_HANDLING  position_handling = LONG_SHORT; //Position Handling 

TradingPanel Panel(AccountNumber,position_handling,false,startSL*10,widthSL*10,risk, SL, TP);

int OnInit(){
   if(!Panel.Init(AccountNumber,position_handling,false,startSL*10,widthSL*10,risk, SL, TP)){
      Alert("Invalid Account Number!");
      return(INIT_FAILED);
   }
   Panel.Create("Trading Panel ver "+VERSION);
   Panel.Run();
   
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason){
   ObjectsDeleteAll(0,0,-1);
   Panel.Destroy(reason);
}

void OnTick(){
   Panel.Update();
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam){
   if(Panel.OnEvent(id, lparam, dparam, sparam))
      ChartRedraw();
}