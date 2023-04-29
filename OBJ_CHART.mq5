﻿//+------------------------------------------------------------------+
//|                                                    OBJ_CHART.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#property indicator_chart_window

input string           InpSymbol="EURUSD";          // Symbol
input ENUM_TIMEFRAMES  InpPeriod=PERIOD_CURRENT;    // Period

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  if(!ObjectCreate(0,"Chart",OBJ_CHART,0,0,0))
     {
           return(false);
     } 
ObjectSetInteger(0,"Chart",OBJPROP_XDISTANCE,10);
ObjectSetInteger(0,"Chart",OBJPROP_YDISTANCE,20);  
ObjectSetInteger(0,"Chart",OBJPROP_XSIZE,300);
ObjectSetInteger(0,"Chart",OBJPROP_YSIZE,200);  
ObjectSetString(0,"Chart",OBJPROP_SYMBOL,InpSymbol);
ObjectSetInteger(0,"Chart",OBJPROP_PERIOD,InpPeriod);
ObjectSetInteger(0,"Chart",OBJPROP_DATE_SCALE,true);
ObjectSetInteger(0,"Chart",OBJPROP_WIDTH,1);
ObjectSetInteger(0,"Chart",OBJPROP_PRICE_SCALE,true);
ObjectSetInteger(0,"Chart",OBJPROP_SELECTABLE,true);
ObjectSetInteger(0,"Chart",OBJPROP_SELECTED,true);
ObjectSetInteger(0,"Chart",OBJPROP_COLOR,clrBlue);

long chartId=ObjectGetInteger(0,"Chart",OBJPROP_CHART_ID);
ChartApplyTemplate(chartId,"my.tpl");  
ChartRedraw(chartId);
     
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void  OnDeinit(const int reason){
ObjectsDeleteAll(0,-1,-1);
}  
