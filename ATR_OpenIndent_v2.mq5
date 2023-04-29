//+------------------------------------------------------------------+
//|                                            ATR_OpenIndent_v2.mq5 |
//|                                             Copyright 2012, Rone |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Rone"
#property link      "rone.sergey@gmail.com"
#property version   "2.00"
#property description "The indicator shows the opening price of the senior time frame (e.g., 1-day time frame) "
#property description "and draws line indents to the opening price, thus forming a range. "
#property description "Depending on the parameters the indicator can be used in the trading system to trade range breakouts "
#property description "or vice versa - to trade within the range."
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot DayOpen
#property indicator_label1  "Frame Open"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- UpperIndent
#property indicator_label2  "Upper Indent"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- LowerIndent
#property indicator_label3  "Lower Indent"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input ENUM_TIMEFRAMES   InpTimeFrame=PERIOD_D1; // Base time frame for calculation
input int               InpFrameAtrPeriod=5;    // Base time frame ATR period
input double            InpAtrCoef=0.25;        // Indent ATR coefficient
input bool              InpUsePipsIndent=false; // Use indent in pips (instead of ATR)
input int               InpPipsIndent=30;       // Indent in pips (for 4 or 2 digits)
//--- indicator buffers
double         FrameOpenBuffer[];
double         UpperIndentBuffer[];
double         LowerIndentBuffer[];
//--- global variables
int            ExtAtrFrameHandle;               // ATR indicator handle
int            ExtPipsIndent;                   // Variable to control the indent in pips
int            minRequiredBars;                 // Minimum required number of bars for calculation
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() 
  {
//---
   if(InpTimeFrame<_Period) 
     {
      Print("Base time frame must be longer than the current time frame!");
      return(-1);
     }
//---
   minRequiredBars=InpFrameAtrPeriod *(PeriodSeconds(InpTimeFrame)/PeriodSeconds(_Period));
//---
   if(_Digits==5 || _Digits==3) 
     {
      ExtPipsIndent*=10;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,FrameOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,UpperIndentBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LowerIndentBuffer,INDICATOR_DATA);
//---
   for(int i=0; i<3; i++) 
     {
      PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,0.0);
      PlotIndexSetInteger(i,PLOT_SHIFT,0);
     }
//---
   ExtAtrFrameHandle=iATR(_Symbol,InpTimeFrame,InpFrameAtrPeriod);
   if(ExtAtrFrameHandle<0) 
     {
      Print("Error when creating the ATR indicator #",GetLastError());
      return(-1);
     }
//---
   return(0);
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
   int frameBars,startBar,calculated;
   double mod,indent;
//--- checking for the sufficiency of data for calculation on the senior and current time frames
   frameBars=Bars(_Symbol,InpTimeFrame);
   if(frameBars<InpFrameAtrPeriod || rates_total<minRequiredBars) 
     {
      return(0);
     }
//--- not all data may be calculated
   calculated=BarsCalculated(ExtAtrFrameHandle);
   if(calculated<frameBars) 
     {
      Print("Not all ATR data calculated. Error #",GetLastError());
      return(0);
     }
//---
   if(prev_calculated>rates_total || prev_calculated<=0) 
     {
      startBar=minRequiredBars;
      for(int bar=0; bar<minRequiredBars; bar++) 
        {
         FrameOpenBuffer[bar]=0.0;
         UpperIndentBuffer[bar] = 0.0;
         LowerIndentBuffer[bar] = 0.0;
        }
        } else {
      startBar=prev_calculated-1;
     }
//---   
   for(int bar=startBar; bar<rates_total && !IsStopped(); bar++) 
     {
      mod=MathMod(time[bar],PeriodSeconds(InpTimeFrame));
      if(mod==0) 
        {             // if there is a new bar on the senior time frame
         FrameOpenBuffer[bar]=open[bar];

         //--- calculate the indent value
         indent=0.0;
         if(!InpUsePipsIndent) 
           {
            //--- get Frame ATR value
            double FrameAtrArray[1];

            if(CopyBuffer(ExtAtrFrameHandle,0,time[bar],1,FrameAtrArray)<=0) 
              {
               Print("Getting ATR data failed. Error #",GetLastError());
               return(0);
                 } else {
               indent=NormalizeDouble(FrameAtrArray[0]*InpAtrCoef,_Digits);
              }
              } else {
            indent=ExtPipsIndent*_Point;
           }
         //---
         UpperIndentBuffer[bar] = FrameOpenBuffer[bar] + indent;
         LowerIndentBuffer[bar] = FrameOpenBuffer[bar] - indent;
           } else {
         int prevBar=bar-1;

         FrameOpenBuffer[bar]=FrameOpenBuffer[prevBar];
         UpperIndentBuffer[bar] = UpperIndentBuffer[prevBar];
         LowerIndentBuffer[bar] = LowerIndentBuffer[prevBar];
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
