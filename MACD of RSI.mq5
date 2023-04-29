//------------------------------------------------------------------
#property copyright   "www.forex-tsd.com"
#property link        "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  PaleVioletRed
#property indicator_width1  2
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  Gold

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted    // Weighted
};

input enPrices InpAppliedPrice = pr_close; // Price to use for RSI
input int      InpRsiPeriod    = 14;       // RSI period
input int      InpFastEMA      = 12;       // NACD fast EMA period
input int      InpSlowEMA      = 26;       // NACD slow EMA period
input int      InpSignalEMA    =  9;       // NACD signal EMA period
input int      InpBarsToCalc   =  0;       // NACD bars to calculate

//
//
//
//
//

double  macd[];
double  signal[];


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void OnInit()
{
   SetIndexBuffer(0,macd  ,INDICATOR_DATA);
   SetIndexBuffer(1,signal,INDICATOR_DATA);
      IndicatorSetString(INDICATOR_SHORTNAME,"MACD original("+string(InpFastEMA)+","+string(InpSlowEMA)+","+string(InpSignalEMA)+")");
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{                
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      double price = getPrice(InpAppliedPrice,open,close,high,low,i,rates_total);
      double tmacd,tsign;
         if (InpBarsToCalc>0)
               iMacd(iRsi(price,InpRsiPeriod,i,rates_total,0),InpFastEMA,InpSlowEMA,InpSignalEMA,tmacd,tsign,i,rates_total,MathMin(rates_total,InpBarsToCalc),0);
         else  iMacd(iRsi(price,InpRsiPeriod,i,rates_total,0),InpFastEMA,InpSlowEMA,InpSignalEMA,tmacd,tsign,i,rates_total,rates_total                       ,0);
      macd[i]   = tmacd;
      signal[i] = tsign;
   }         
   return(rates_total);
}


//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//
//

double workRsi[][3];
#define _price  0
#define _change 1
#define _changa 2

//
//
//
//

double iRsi(double price, double period, int i, int bars, int forInstance=0)
{
   if (ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars);
   int z = forInstance*3; double alpha = 1.0 /(double)period; 

   //
   //
   //
   //
   //
   
      workRsi[i][_price+z] = price;
      if (i<period)
      {
         int k; double sum = 0; for (k=0; k<period && (i-k-1)>=0; k++) sum += MathAbs(workRsi[i-k][_price+z]-workRsi[i-k-1][_price+z]);
            workRsi[i][_change+z] = (workRsi[i][_price+z]-workRsi[0][_price+z])/MathMax(k,1);
            workRsi[i][_changa+z] =                                         sum/MathMax(k,1);
      }
      else
      {
         double change = workRsi[i][_price+z]-workRsi[i-1][_price+z];
            workRsi[i][_change+z] = workRsi[i-1][_change+z] + alpha*(        change  - workRsi[i-1][_change+z]);
            workRsi[i][_changa+z] = workRsi[i-1][_changa+z] + alpha*(MathAbs(change) - workRsi[i-1][_changa+z]);
      }
      if (workRsi[i][_changa+z] != 0)
            return(50.0*(workRsi[i][_change+z]/workRsi[i][_changa+z]+1));
      else  return(0);
}


//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//    for each new instance of macd calculation 
//    totalBuffers should be calculated as totalBuffers = totalInstances*3
//
//
//

#define totalIBuffers 3
double  emas[][totalIBuffers];
#define _fast  0
#define _slow  1
#define _sign  2

void iMacd(double price, double fastEma, double slowEma, double signalEma, double& pmacd, double& psignal, int i, int totalBars, int barsToCalculate, int instanceNo=0)
{
   int inst = instanceNo*3; if (ArrayRange(emas,0)!=totalBars) ArrayResize(emas,totalBars);

      //
      //
      //
      //
      //
      
      if (i<(totalBars-barsToCalculate) || i==0)
      {
         emas[i][_fast+inst]  = price;
         emas[i][_slow+inst]  = price;
         emas[i][_sign+inst]  = 0;
                      pmacd   = EMPTY_VALUE;
                      psignal = EMPTY_VALUE;
                      return;      
      }

      //
      //
      //
      //
      //
      
      double alphafa = 2.0 / (1.0 +fastEma);
      double alphasl = 2.0 / (1.0 +slowEma);
      double alphasi = 2.0 / (1.0 +signalEma);

         emas[i][_fast+inst] = emas[i-1][_fast+inst]+alphafa*(price-emas[i-1][_fast+inst]);            
         emas[i][_slow+inst] = emas[i-1][_slow+inst]+alphasl*(price-emas[i-1][_slow+inst]);            
         pmacd               = emas[i][_fast+inst]-emas[i][_slow+inst];
         emas[i][_sign+inst] = emas[i-1][_sign+inst]+alphasi*(pmacd-emas[i-1][_sign+inst]);
         psignal             = emas[i][_sign+inst];
      return;
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double getPrice(enPrices pricet, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars)
{
   switch (pricet)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
   }
   return(0);
}