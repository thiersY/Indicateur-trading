//+------------------------------------------------------------------+
//|                                                  LeManSignal.mq5 |
//|                                         Copyright © 2009, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2009, LeMan."
//---- link to the website of the author
#property link      "b-market@mail.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- magenta color is used for the indicator bearish arrow
#property indicator_color1  Magenta
//---- thickness of the indicator 1 line is equal to 4
#property indicator_width1  4
//---- displaying the indicator label
#property indicator_label1  "LeManSell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//---- lime color is used for the indicator bullish arrow
#property indicator_color2  Lime
//---- thickness of the indicator 2 line is equal to 4
#property indicator_width2  4
//---- displaying the indicator label
#property indicator_label2 "LeManBuy"

//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int LPeriod=12; // Indicator period 

//+----------------------------------------------+
//---- declaration of dynamic arrays that
// will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//----
int StartBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   StartBars=LPeriod+LPeriod+2+1;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"LeManSell");
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(SellBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- create a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"LeManBuy");
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,108);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(BuyBuffer,true);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="LeManSignal";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<StartBars) return(0);

//---- declarations of local variables 
   int limit,bar,bar1,bar2,bar1p,bar2p;
   double H1,H2,H3,H4,L1,L2,L3,L4;

//---- indexing elements in arrays as timeseries
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      limit=rates_total-1-StartBars;                     // starting index for calculation of all bars
   else limit=rates_total-prev_calculated;               // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      bar1=bar+1;
      bar2=bar+2;
      bar1p=bar1+LPeriod;
      bar2p=bar2+LPeriod;
      //----
      H1 = high[ArrayMaximum(high,bar1, LPeriod)];
      H2 = high[ArrayMaximum(high,bar1p,LPeriod)];
      H3 = high[ArrayMaximum(high,bar2, LPeriod)];
      H4 = high[ArrayMaximum(high,bar2p,LPeriod)];
      L1 = low [ArrayMinimum(low, bar1, LPeriod)];
      L2 = low [ArrayMinimum(low, bar1p,LPeriod)];
      L3 = low [ArrayMinimum(low, bar2, LPeriod)];
      L4 = low [ArrayMinimum(low, bar2p,LPeriod)];
      //----
      BuyBuffer[bar]=EMPTY_VALUE;
      SellBuffer[bar]=EMPTY_VALUE;

      //---- buying conditions                       
      if(H3<=H4 && H1>H2) BuyBuffer[bar]=high[bar+1]+_Point;
      //---- selling conditions      
      if(L3>=L4 && L1<L2) SellBuffer[bar]=low[bar+1]-_Point;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
