//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "MA crosses"
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrLimeGreen,clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

//
//
//
//
//

enum enAvgType
{
   avgSma,    // Simple moving average
   avgEma,    // Exponential moving average
   avgSmma,   // Smoothed MA
   avgLwma,   // Linear weighted MA
   avgLsma    // Linear regression value (LSMA)
};
enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average     // Average (high+low+oprn+close)/4
};

input int       FastMA           = 12;          // MA fast period
input enAvgType FastMaMethod     = avgEma;      // Fast MA method
input enPrices  FastPrice        = pr_close;    // Fast price
input int       SlowMA           = 26;          // MA slow period
input enAvgType SlowMaMethod     = avgEma;      // Slow MA method
input enPrices  SlowPrice        = pr_close;    // Slow price
input bool      alertsOn         = false;       // Alert on or off
input bool      alertsOnCurrent  = true;        // Alert on current bar
input bool      alertsMessage    = true;        // Display messageas on alerts
input bool      alertsSound      = false;       // Play sound on alerts
input bool      alertsEmail      = false;       // Send email on alerts

//
//
//
//
//

double arrow[];
double arrowc[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,arrow ,INDICATOR_DATA); PlotIndexSetInteger(0,PLOT_ARROW,159);
   SetIndexBuffer(1,arrowc,INDICATOR_COLOR_INDEX);
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int totalBars;
double trend[];
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
   totalBars = rates_total;
      if (ArraySize(trend) !=rates_total) ArrayResize(trend ,rates_total);
   
   //
   //
   //
   //
   //

   for (int i=(int)MathMax(prev_calculated-1,1); i<rates_total; i++)
   {
      double fastMa = iCustomMa(FastMaMethod,getPrice(FastPrice,open,close,high,low,rates_total,i),FastMA,i,0);
      double slowMa = iCustomMa(SlowMaMethod,getPrice(SlowPrice,open,close,high,low,rates_total,i),SlowMA,i,1);
      
         //
         //
         //
         //
         //
         
         arrow[i]=EMPTY_VALUE;
         trend[i]=trend[i-1];
            if (fastMa>slowMa) trend[i] =  1;
            if (fastMa<slowMa) trend[i] = -1;
            if (trend[i]!=trend[i-1])
            {
               double range = MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]);
               for (int k=1; k<20 && i-k>0; k++)
                  range += MathMax(high[i-k],close[i-k-1])-MathMin(low[i-k],close[i-k-1]);
                  range /= 20;
                  if (trend[i]==1)
                        { arrow[i] = low[i] -range; arrowc[i] = 0; }
                  else  { arrow[i] = high[i]+range; arrowc[i] = 1; }
            }                  
   }      
   manageAlerts(time[rates_total-1],time[rates_total-2],trend,rates_total);
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

void manageAlerts(datetime currTime, datetime prevTime, double& trendt[], int bars)
{
   if (alertsOn)
   {
      datetime time     = currTime;
      int      whichBar = bars-1; if (!alertsOnCurrent) { whichBar = bars-2; time = prevTime; }
         
      //
      //
      //
      //
      //
         
      if (trendt[whichBar] != trendt[whichBar-1])
      {
         if (trendt[whichBar] ==  1) doAlert(time,"up");
         if (trendt[whichBar] == -1) doAlert(time,"down");
      }         
   }
}   

//
//
//
//
//

void doAlert(datetime forTime, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != forTime) 
   {
      previousAlert  = doWhat;
      previousTime   = forTime;

      //
      //
      //
      //
      //

      message = TimeToString(TimeLocal(),TIME_SECONDS)+" "+_Symbol+" fast ma crossed slow ma "+doWhat;
         if (alertsMessage) Alert(message);
         if (alertsEmail)   SendMail(_Symbol+" ma crosses",message);
         if (alertsSound)   PlaySound("alert2.wav");
   }
}

  
//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maWorkBufferx1 2
#define _maWorkBufferx2 4
#define _maWorkBufferx3 6

double iCustomMa(int mode, double price, double length, int r, int instanceNo=0)
{
   switch (mode)
   {
      case avgSma   : return(iSma(price,(int)length,r,instanceNo));
      case avgEma   : return(iEma(price,length,r,instanceNo));
      case avgSmma  : return(iSmma(price,(int)length,r,instanceNo));
      case avgLwma  : return(iLwma(price,(int)length,r,instanceNo));
      case avgLsma  : return(iLinr(price,(int)length,r,instanceNo));
      default       : return(price);
   }
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= totalBars) ArrayResize(workSma,totalBars); instanceNo *= 2;

   //
   //
   //
   //
   //

   int k;      
      workSma[r][instanceNo]    = price;
      workSma[r][instanceNo+1]  = 0; for(k=0; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo];  
      workSma[r][instanceNo+1] /= (double)k;
   return(workSma[r][instanceNo+1]);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= totalBars) ArrayResize(workEma,totalBars);

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= totalBars) ArrayResize(workSmma,totalBars);

   //
   //
   //
   //
   //

   if (r<period)
         workSmma[r][instanceNo] = price;
   else  workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= totalBars) ArrayResize(workLwma,totalBars);
   
   //
   //
   //
   //
   //
   
   workLwma[r][instanceNo] = price;
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workLinr[][_maWorkBufferx1];
double iLinr(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= totalBars) ArrayResize(workLinr,totalBars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workLinr[r][instanceNo] = price;
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
   return(3.0*lwma/lwmw-2.0*sma/period);
}


//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double getPrice(enPrices price, const double& open[], const double& close[], const double& high[], const double& low[], int bars, int i)
{
   switch (price)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
   }
   return(0);
}