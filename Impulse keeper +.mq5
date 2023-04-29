﻿//+------------------------------------------------------------------+
//|                                               Impulse keeper.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 4

double EMA34HBuffer[];
double EMA34LBuffer[];
double EMA125Buffer[];
double PSARBuffer[];

int EMA34HHandle;
int EMA34LHandle;
int EMA125Handle;
int PSARHandle;

int    bars_calculated=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,EMA34HBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(1,EMA34LBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,EMA125Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,PSARBuffer,INDICATOR_CALCULATIONS);
   
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
if(close[i-1]>open[i-1]&&close[i-1]>EMA34HBuffer[i-1]&&close[i-1]>EMA34LBuffer[i-1]
&&low[i-1]>EMA125Buffer[i-1]&&low[i-1]>PSARBuffer[i-1]&&EMA125Buffer[i-1]<EMA34LBuffer[i-1]
&&EMA125Buffer[i-1]<EMA34HBuffer[i-1]){

     if(!ObjectCreate(0,"Buy"+i,OBJ_ARROW,0,time[i-1],high[i-1]))
     {      
      return(false);
     }     
      ObjectSetInteger(0,"Buy"+i,OBJPROP_COLOR,clrGreen);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_ARROWCODE,233);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_WIDTH,2);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_ANCHOR,ANCHOR_UPPER);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_HIDDEN,true);
      ObjectSetString(0,"Buy"+i,OBJPROP_TOOLTIP,""+close[i-1]);    
     }     
if(close[i-1]<open[i-1]&&close[i-1]<EMA34HBuffer[i-1]&&close[i-1]<EMA34LBuffer[i-1]
&&high[i-1]<EMA125Buffer[i-1]&&high[i-1]<PSARBuffer[i-1]&&EMA125Buffer[i-1]>EMA34LBuffer[i-1]
&&EMA125Buffer[i-1]>EMA34HBuffer[i-1]){

     if(!ObjectCreate(0,"Sell"+i,OBJ_ARROW,0,time[i-1],low[i-1]))
     {      
      return(false);
     }     
      ObjectSetInteger(0,"Sell"+i,OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_ARROWCODE,234);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_WIDTH,2);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_ANCHOR,ANCHOR_LOWER);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_HIDDEN,true);
      ObjectSetString(0,"Sell"+i,OBJPROP_TOOLTIP,""+close[i-1]);
     }     
     }     
     bars_calculated=calculated;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
  
void  OnDeinit(const int reason){
ObjectsDeleteAll(0,-1,-1);
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
