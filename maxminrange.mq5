//+------------------------------------------------------------------+ 
//|                                                  MaxMinRange.mq5 | 
//|                                         Copyright © 2012, jpkfox | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- indicator version number
#property version   "1.01"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers is 4
#property indicator_buffers 4 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a three-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color1 clrMagenta,clrLime,clrDodgerBlue
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "MaxRange"

//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a three-color histogram
#property indicator_type2 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color2 clrMagenta,clrRed,clrDodgerBlue
//---- indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width2 2
//---- displaying the indicator label
#property indicator_label2 "MinRange"

//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrPurple
#property indicator_levelstyle STYLE_SOLID
#property indicator_levelwidth 1

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint GreenLimit=75;             // limit for green bars in histogram
input uint DarkGreenLimitOffset=30;   // Offsetlimit from GreenLimit for darkgreen bars in histogram
                                      // If GreenLimit = 75 and DarkGreenLimitOffset = 20
// then DarkGreenLimit = 95. If <= 0 then not in use.
// including the current bar PaleGreen  LimeGreen
input uint NumbOfBars=15;
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double MaxBuffer[],ColorMaxBuffer[];
double MinBuffer[],ColorMinBuffer[];
//+------------------------------------------------------------------+    
//| MaxRange indicator initialization function                       | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(NumbOfBars);

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,MaxBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorMaxBuffer,INDICATOR_COLOR_INDEX);

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(2,MinBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(3,ColorMinBuffer,INDICATOR_COLOR_INDEX);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   string short_name="MaxMinRange("+string(NumbOfBars)+","+string(GreenLimit);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| MaxRange iteration function                                      | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- Checking if the number of bars is sufficient for the calculation
   if(rates_total<min_rates_total) return(0);

///---- declaration of local variables 
   int first,bar;
   double nMax,nMin,nVal;
   color clr;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=min_rates_total;  // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      nMax=-999999.0;
      nMin=+999999.0;
      MaxBuffer[bar]=0.0;
      MinBuffer[bar]=0.0;

      for(int kkk=0; kkk<int(NumbOfBars); kkk++)
        {
         nVal=high[bar]-low[bar-kkk];
         if(nVal>nMax) nMax=nVal;

         nVal=low[bar]-high[bar-kkk];
         if(nVal<nMin) nMin=nVal;
        }

      if(nMax>0.00)
        {
         MaxBuffer[bar]=nMax/_Point;
         if(10000.0*nMax<GreenLimit) clr=0;
         else if(10000.0*nMax<(GreenLimit+DarkGreenLimitOffset)) clr=2;
         else clr=1;
         ColorMaxBuffer[bar]=clr;
        }
      
      if(nMin<0.00)
        {
         MinBuffer[bar]=nMin/_Point;
         if(10000.0*nMin>-GreenLimit) clr=0;
         else if(10000.0*nMin>(-GreenLimit-DarkGreenLimitOffset)) clr=2;
         else clr=1;
         ColorMinBuffer[bar]=clr;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
