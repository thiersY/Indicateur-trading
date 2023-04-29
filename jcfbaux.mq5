//+------------------------------------------------------------------+
//|                                                      JCFBaux.mq5 |
//|                                  JCFBaux: Copyright © 2005, Weld | 
//|                                          http://weld.torguem.net |   
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, Weld"
//---- author of the indicator
#property link      "http://weld.torguem.net"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- one buffer is used for calculation and drawing the indicator
#property indicator_buffers 1
//---- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//| Indicator drawing parameters                 |
//+----------------------------------------------+
//---- drawing the indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- Magenta color is used for the indicator line
#property indicator_color1  Magenta
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "JCFBaux"
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Declaration of enumerations                 |
//+----------------------------------------------+
enum Applied_price_      // Type of constant
  {
   PRICE_CLOSE_ = 1,     // PRICE_CLOSE
   PRICE_OPEN_,          // PRICE_OPEN
   PRICE_HIGH_,          // PRICE_HIGH
   PRICE_LOW_,           // PRICE_LOW
   PRICE_MEDIAN_,        // PRICE_MEDIAN
   PRICE_TYPICAL_,       // PRICE_TYPICAL
   PRICE_WEIGHTED_,      // PRICE_WEIGHTED
   PRICE_SIMPLE,         // PRICE_SIMPLE
   PRICE_QUARTER_,       // PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  // PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_   // PRICE_TRENDFOLLOW1_
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int Depth=15;                    // Indicator smoothing period
input Applied_price_ IPC=PRICE_CLOSE_; // Applied price
input int Shift=0;                     // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double IndBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of global variables
int Count[];
double Series[];
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// return the current value of the price series by the link
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=Depth*2+1;

//---- memory distribution for variables' arrays  
   ArrayResize(Count,min_rates_total);
   ArrayResize(Series,min_rates_total);

//---- set IndBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"JCFBaux(",Depth,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declarations of local variables 
   int first,bar;
   double jrc04,jrc05,jrc06,jrc08,jrc03,jrc13;
   static double JRC04,JRC05,JRC06;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0;                   // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- restore values of the variables
   jrc04=JRC04;
   jrc05=JRC05;
   jrc06=JRC06;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==rates_total-1)
        {
         JRC04 = jrc04;
         JRC05 = jrc05;
         JRC06 = jrc06;
        }

      Series[Count[0]]=PriceSeries(IPC,bar,open,low,high,close);

      if(bar<Depth)
        {
         if(bar<rates_total-1) Recount_ArrayZeroPos(Count,min_rates_total);
         continue;
        }

      if(bar>=min_rates_total)
        {
         jrc04 = 0.0;
         jrc05 = 0.0;
         jrc06 = 0.0;

         for(int iii=Depth-1; iii>=0; iii--)
           {
            jrc03=MathAbs(Series[Count[iii]]-Series[Count[iii+1]]);
            jrc04 += jrc03;
            jrc05 += (Depth + iii) * jrc03;
            jrc06 += Series[Count[iii+1]];
           }
        }
      else
        {
         jrc03 = MathAbs(Series[Count[0]] - Series[Count[1]]);
         jrc13 = MathAbs(Series[Count[Depth]]-Series[Count[Depth+1]]);
         jrc04 += jrc03-jrc13;
         jrc05 += jrc03 * Depth - jrc04;
         jrc06 += Series[Count[1]] - Series[Count[Depth+1]];
        }

      jrc08=MathAbs(Depth*Series[Count[0]]-jrc06);

      if(!jrc05) IndBuffer[bar]=EMPTY_VALUE;
      else       IndBuffer[bar]=jrc08/jrc05;

      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,min_rates_total);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Getting values of a price series                                 |
//+------------------------------------------------------------------+ 
double PriceSeries(uint applied_price,   // Applied price
                   uint   bar,           // Index of shift relative to the current bar for a specified number of periods back or forward
                   const double &Open[],
                   const double &Low[],
                   const double &High[],
                   const double &Close[])
  {
//----
   switch(applied_price)
     {
      //---- price constants from the ENUM_APPLIED_PRICE enumeration
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);

      //----                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //----                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //----         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //----
      default: return(Close[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+
