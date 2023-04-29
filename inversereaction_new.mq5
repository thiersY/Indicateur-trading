//+------------------------------------------------------------------+
//|                                              InverseReaction 1.3 |
//|                                              2013-2014 Erdem SEN |
//|                         http://login.mql5.com/en/users/erdogenes |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013-2015, Erdem Sen"
#property version   "1.3"
#property link      "http://login.mql5.com/en/users/erdogenes"
//---
#property description "This indicator is based on the idea of that an unusual impact"
#property description "in price changes will be adjusted by an inverse reaction."
#property description "The signal comes out when the price-change exceeds the possible"
#property description "volatility limits, then you can expect an inverse reaction."
//--- 
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   2
//--- 
#property indicator_label1  "Changes" 
#property indicator_label2  "Confidence"   
#property indicator_type1   DRAW_COLOR_CANDLES  
#property indicator_type2   DRAW_COLOR_ARROW    
#property indicator_color1  clrGreen,clrRed,clrMagenta// candles color array
#property indicator_color2  clrGold,clrBlueViolet     // signal color array  
//--- input parameters
input double            Coef        = 1.618;          // DCL Coefficient
input int               MaPeriod    = 3;              // DCL Period
//--- Indicator buffers
double         o[];                                   // zero price (it's here only to draw candles)
double         h[];                                   // highest change (high price minus open price)
double         l[];                                   // lowest change (low price minus open price)
double         c[];                                   // main change (close price minus open price)
double         clr1[];                                // color buffer for bear and bull
double         m[];                                   // confidence level
double         clr2[];                                // color buffer for levels
//---
int            calcstart;
string         name;
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- verify the confidence coefficient
   bool validation=(Coef>1 && Coef<=3);
   if(!validation)
     {
      printf("Invalid value is determined for DCL Coefficient,\nit sould be in (1,3] interval. Error Code: %d",GetLastError());
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- mapping
   SetIndexBuffer(0,o,INDICATOR_DATA);
   SetIndexBuffer(1,h,INDICATOR_DATA);
   SetIndexBuffer(2,l,INDICATOR_DATA);
   SetIndexBuffer(3,c,INDICATOR_DATA);
   SetIndexBuffer(4,clr1,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,m,INDICATOR_DATA);
   SetIndexBuffer(6,clr2,INDICATOR_COLOR_INDEX);
//--- shortname
   name=StringFormat("IR(%d, %.2f)",MaPeriod,Coef);
   IndicatorSetString(INDICATOR_SHORTNAME,name);
//--- arrow symbol
   PlotIndexSetInteger(5,PLOT_ARROW,159);
//--- digits for vertical axis
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Calculation                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],const double &close[],
                const long &tick_volume[],const long &volume[],const int &spread[])
  {
//--- prevent the recalculation
   if(prev_calculated>rates_total || prev_calculated<=0) calcstart=0;
   else calcstart=prev_calculated-1;
//--- calculate the buffers
   for(int i=calcstart;i<rates_total;i++)
     {
      o[i] = 0.0;
      h[i] = high[i] - open[i];
      l[i] = low[i] - open[i];
      c[i] = close[i] - open[i];
      //--- 
      if(open[i]>close[i])
        {
         clr1[i]=1;
         m[i]=-DCL(i,MaPeriod,Coef,c);
        }
      else if(open[i]<close[i])
        {
         clr1[i]=0;
         m[i]=DCL(i,MaPeriod,Coef,c);
        }
      else  clr1[i]=2;
      clr2[i]=(fabs(m[i])>fabs(c[i]));
     }
   return(rates_total);
  }
/*---Dynamic Confidence Level (DCL)----------------------------------+

   For stationary series with zero mean (like price changes) DCL can be calculated as
      
         DCL = Multiplier * MovingAverage(AbsoluteChanges)

   Just for example, when we use Golden Ratio as multiplier, with the perfect 
   conditions of normality, it gives us nearly 80% confidence levels:

         StandardDeviation = Sqrt(Pi/2) * Mean(Abs(Changes))
         GoldenRatio ~= z_%80 * Sqrt(Pi/2)
         DCL(z_%80) ~= GoldenRatio * MovingAverage(Abs(Price Changes))
   
   With large numbers of MovingAverage period, DCL aproximates to a static confidence 
   level. However, the system is dynamic and memory is very short for such economic 
   behaviors, so it is set with a small number (3 as default). Plus, considering the 
   HEAVY-TAIL problem, small period values will relatively response better!!!!

*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DCL(const int position,const int period,const double coef,const double &price[])
  {
   double result=0.0;
   if(position>=period-1 && period>0)
     {
      for(int i=0;i<period;i++) result+=fabs(price[position-i]);
      result /= period;
      result *= coef;
     }
   return(result);
  }
//+------------------------------------------------------------------+
