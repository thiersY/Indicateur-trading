﻿//+------------------------------------------------------------------+
//|                                               Impulse keeper.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 8
#property indicator_plots 2
#property indicator_color1 clrGreen, clrBlack
#property indicator_type1 DRAW_COLOR_ARROW
#property indicator_color2 clrRed, clrBlack
#property indicator_type2 DRAW_COLOR_ARROW

double IKBuyBuffer[];
double ColorIKBuyBuffer[];
double IKSellBuffer[];
double ColorIKSellBuffer[];
double EMA34HBuffer[];
double EMA34LBuffer[];
double EMA125Buffer[];
double PSARBuffer[];

int EMA34HHandle;
int EMA34LHandle;
int EMA125Handle;
int PSARHandle;

int bars_calculated=0; 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
PlotIndexSetInteger(0,PLOT_ARROW,233);    
PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
  
PlotIndexSetInteger(1,PLOT_ARROW,234);    
PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);  
//--- indicator buffers mapping
SetIndexBuffer(0,IKBuyBuffer,INDICATOR_DATA);
SetIndexBuffer(1,ColorIKBuyBuffer,INDICATOR_COLOR_INDEX);
   
SetIndexBuffer(2,IKSellBuffer,INDICATOR_DATA);
SetIndexBuffer(3,ColorIKSellBuffer,INDICATOR_COLOR_INDEX);
 
SetIndexBuffer(4,EMA34HBuffer,INDICATOR_CALCULATIONS);
SetIndexBuffer(5,EMA34LBuffer,INDICATOR_CALCULATIONS);
SetIndexBuffer(6,EMA125Buffer,INDICATOR_CALCULATIONS);
SetIndexBuffer(7,PSARBuffer,INDICATOR_CALCULATIONS);

EMA34HHandle=iMA(NULL,0,34,0,MODE_EMA,PRICE_HIGH);
EMA34LHandle=iMA(NULL,0,34,0,MODE_EMA,PRICE_LOW);
EMA125Handle=iMA(NULL,0,125,0,MODE_EMA,PRICE_CLOSE);
PSARHandle=iSAR(NULL,0,0.02, 0.2);

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
   int values_to_copy;
   int start;
   int calculated=BarsCalculated(EMA34HHandle);
   if(calculated<=0)
     {      
      return(0);
     }
   if(prev_calculated==0 || calculated!=bars_calculated)
     {
      start=1;
      if(calculated>rates_total) values_to_copy=rates_total;
      else                       values_to_copy=calculated;
     }
   else
     {
     start=rates_total-1;
     values_to_copy=1;
     }
     
if(!FillArrayFromMABuffer(EMA34HBuffer,0,EMA34HHandle,values_to_copy)) return(0);  
   
if(!FillArrayFromMABuffer(EMA34LBuffer,0,EMA34LHandle,values_to_copy)) return(0); 
    
if(!FillArrayFromMABuffer(EMA125Buffer,0,EMA125Handle,values_to_copy)) return(0); 
    
if(!FillArrayFromPSARBuffer(PSARBuffer,PSARHandle,values_to_copy)) return(0);
    
 for(int i=start;i<rates_total && !IsStopped();i++)
     {
     IKBuyBuffer[i-1]=0;
     ColorIKBuyBuffer[i-1]=1;
     
     IKSellBuffer[i-1]=0;
     ColorIKSellBuffer[i-1]=1;
     
if(close[i-1]>open[i-1]&&close[i-1]>EMA34HBuffer[i-1]&&close[i-1]>EMA34LBuffer[i-1]
&&low[i-1]>EMA125Buffer[i-1]&&low[i-1]>PSARBuffer[i-1]&&EMA125Buffer[i-1]<EMA34LBuffer[i-1]
&&EMA125Buffer[i-1]<EMA34HBuffer[i-1]){
     IKBuyBuffer[i-1]=high[i-1];
     ColorIKBuyBuffer[i-1]=0;      
     }
     
if(close[i-1]<open[i-1]&&close[i-1]<EMA34HBuffer[i-1]&&close[i-1]<EMA34LBuffer[i-1]
&&high[i-1]<EMA125Buffer[i-1]&&high[i-1]<PSARBuffer[i-1]&&EMA125Buffer[i-1]>EMA34LBuffer[i-1]
&&EMA125Buffer[i-1]>EMA34HBuffer[i-1]){
     IKSellBuffer[i-1]=low[i-1];
     ColorIKSellBuffer[i-1]=0;       
     }     
     }   
    
Print(calculated+" "+bars_calculated);

bars_calculated=calculated;
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
bool FillArrayFromPSARBuffer(
double &sar_buffer[],  // Parabolic SAR indicator's value buffer
int ind_handle,        // iSAR indicator's handle
int amount             // number of values to be copied
                         )
  {
   ResetLastError();
   if(CopyBuffer(ind_handle,0,0,amount,sar_buffer)<0)
     {
          return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
bool FillArrayFromMABuffer(
double &values[],   // indicator's buffer of Moving Average values
int shift,          // shift
int ind_handle,     // iMA indicator's handle
int amount          // number of values to be copied
                         )
  {
   ResetLastError();
   if(CopyBuffer(ind_handle,0,-shift,amount,values)<0)
     {
         return(false);
     }
   return(true);
  }  
