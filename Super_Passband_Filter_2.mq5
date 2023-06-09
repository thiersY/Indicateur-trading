//------------------------------------------------------------------
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, www.mql5.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   5

#property indicator_label1  "super passband fill"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'209,243,209',C'255,230,183'
#property indicator_label2  "super passband level up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_DOT
#property indicator_label3  "super passband middle level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DOT
#property indicator_label4  "super passband level down"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrange
#property indicator_style4  STYLE_DOT
#property indicator_label5  "supper passband"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrSilver,clrLimeGreen,clrOrange
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2

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
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};
enum enColorOn
{
   cc_onSlope,   // Change color on slope change
   cc_onMiddle,  // Change color on middle line cross
   cc_onLevels   // Change color on outer levels cross
};

input ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT; // Time frame
input double          Period1         = 40;             // Period 1
input double          Period2         = 60;             // Period 2
input int             RmsCount        = 50;             // Calculation count
input enPrices        Price           = pr_close;       // Price to use
input enColorOn       ColorOn         = cc_onLevels;    // Color change :
input bool            alertsOn        = false;          // Turn alerts on?
input bool            alertsOnCurrent = true;           // Alert on current bar?
input bool            alertsMessage   = true;           // Display messageas on alerts?
input bool            alertsSound     = false;          // Play sound on alerts?
input bool            alertsEmail     = false;          // Send email on alerts?
input bool            alertsNotify    = false;          // Send push notification on alerts?
input bool            Interpolate     = true;           // Interpolate mtf data ?

double buffer[],levelup[],levelmi[],leveldn[],fill1[],fill2[],trend[],prices[],count[];
ENUM_TIMEFRAMES timeFrame;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,fill1  ,INDICATOR_DATA);
   SetIndexBuffer(1,fill2  ,INDICATOR_DATA);
   SetIndexBuffer(2,levelup,INDICATOR_DATA);
   SetIndexBuffer(3,levelmi,INDICATOR_DATA);
   SetIndexBuffer(4,leveldn,INDICATOR_DATA);
   SetIndexBuffer(5,buffer ,INDICATOR_DATA);
   SetIndexBuffer(6,trend  ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(7,prices ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,count  ,INDICATOR_CALCULATIONS);
      for (int i=0; i<4; i++) PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
         timeFrame = MathMax(_Period,TimeFrame);
         IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(timeFrame)+" Supper passband filter ("+(string)Period1+","+(string)Period2+","+(string)RmsCount+")");
   return(0);
}

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
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   
      //
      //
      //
      //
      //
      
      if (timeFrame!=_Period)
      {
         double result[]; datetime currTime[],nextTime[]; 
         static int indHandle =-1;
                if (indHandle==-1) indHandle = iCustom(_Symbol,timeFrame,getIndicatorName(),PERIOD_CURRENT,Period1,Period2,RmsCount,Price,ColorOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify);
                if (indHandle==-1)                          return(0);
                if (CopyBuffer(indHandle,8,0,1,result)==-1) return(0); 
             
                //
                //
                //
                //
                //
              
                #define _processed EMPTY_VALUE-1
                int i,limit = rates_total-(int)MathMin(result[0]*PeriodSeconds(timeFrame)/PeriodSeconds(_Period),rates_total); 
                for (limit=MathMax(limit,0); limit>0 && !IsStopped(); limit--) if (count[limit]==_processed) break;
                for (i=MathMin(limit,MathMax(prev_calculated-1,0)); i<rates_total && !IsStopped(); i++    )
                {
                   if (CopyBuffer(indHandle,0,time[i],1,result)==-1) break; fill1[i]   = result[0];
                   if (CopyBuffer(indHandle,1,time[i],1,result)==-1) break; fill2[i]   = result[0];
                   if (CopyBuffer(indHandle,2,time[i],1,result)==-1) break; levelup[i] = result[0];
                   if (CopyBuffer(indHandle,3,time[i],1,result)==-1) break; levelmi[i] = result[0];
                   if (CopyBuffer(indHandle,4,time[i],1,result)==-1) break; leveldn[i] = result[0];
                   if (CopyBuffer(indHandle,5,time[i],1,result)==-1) break; buffer[i]  = result[0];
                   if (CopyBuffer(indHandle,6,time[i],1,result)==-1) break; trend[i]   = result[0];
                                                                            count[i]   = _processed;
                   
                   //
                   //
                   //
                   //
                   //
                   
                   if (!Interpolate) continue; CopyTime(_Symbol,TimeFrame,time[i  ],1,currTime); 
                      if (i<(rates_total-1)) { CopyTime(_Symbol,TimeFrame,time[i+1],1,nextTime); if (currTime[0]==nextTime[0]) continue; }
                      int n,k;
                         for(n=1; (i-n)> 0 && time[i-n] >= currTime[0]; n++) continue;	
                         for(k=1; (i-k)>=0 && k<n; k++)
                         {
                            fill1[i-k]   = fill1[i]   + (fill1[i-n]  -fill1[i]  )*k/n;
                            fill2[i-k]   = fill2[i]   + (fill2[i-n]  -fill2[i]  )*k/n;
                            levelup[i-k] = levelup[i] + (levelup[i-n]-levelup[i])*k/n;
                            leveldn[i-k] = leveldn[i] + (leveldn[i-n]-leveldn[i])*k/n;
                            levelmi[i-k] = levelmi[i] + (levelmi[i-n]-levelmi[i])*k/n;
                            buffer[i-k]  = buffer[i]  + (buffer[i-n] -buffer[i] )*k/n;
                         }                            
                }     
                if (i!=rates_total) return(0); return(rates_total);
      }

   //
   //
   //
   //
   //

   double a1 = 5.0 / Period1 ;
   double a2 = 5.0 / Period2 ;
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
         prices[i] = getPrice(Price,open,close,high,low,i,rates_total);
            if (i<2) { buffer[i] = prices[i]; continue; }
            buffer[i]  = (a1-a2)*prices[i] + (a2*(1-a1)-a1*(1-a2))*prices[i-1] + ((1-a1)+(1-a2))*buffer[i-1]-(1-a1)*(1-a2)*buffer[i-2];
            double rms = 0; for (int k=0; k<RmsCount && (i-k)>=0; k++) rms += buffer[i-k]*buffer[i-k];
                   rms = MathSqrt(rms/RmsCount);
            
            levelup[i] = rms;
            levelmi[i] = 0;
            leveldn[i] = -rms;
            switch(ColorOn)
            {
               case cc_onLevels: trend[i] = (buffer[i]>levelup[i])  ? 1 : (buffer[i]<leveldn[i])  ? 2 : 0; break;
               case cc_onMiddle: trend[i] = (buffer[i]>levelmi[i])  ? 1 : (buffer[i]<levelmi[i])  ? 2 : 0; break;
               default : trend[i] = (i>0) ? (buffer[i]>buffer[i-1]) ? 1 : (buffer[i]<buffer[i-1]) ? 2 : 0 : 0;
            }                  
         fill1[i] =  buffer[i];
         fill2[i] = (buffer[i]>levelup[i]) ? levelup[i] : (buffer[i]<leveldn[i]) ? leveldn[i] : buffer[i];
   }      
   count[rates_total-1] = MathMax(rates_total-prev_calculated+1,1);
   manageAlerts(time,trend,rates_total);
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

void manageAlerts(const datetime& time[], double& ttrend[], int bars)
{
   if (!alertsOn) return;
      int whichBar = bars-1; if (!alertsOnCurrent) whichBar = bars-2; datetime time1 = time[whichBar];
      if (ttrend[whichBar] != ttrend[whichBar-1])
      {
         if (ttrend[whichBar] == 1) doAlert(time1,"up");
         if (ttrend[whichBar] == 2) doAlert(time1,"down");
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

      message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToString(TimeLocal(),TIME_SECONDS)+" super passband filter state changed to "+doWhat;
         if (alertsMessage) Alert(message);
         if (alertsEmail)   SendMail(_Symbol+" super passband filter",message);
         if (alertsNotify)  SendNotification(message);
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
//

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); instanceNo*=4;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (i>0)
                haOpen  = (workHa[i-1][instanceNo+2] + workHa[i-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[i][instanceNo+0] = haLow;  workHa[i][instanceNo+1] = haHigh; } 
         else                 { workHa[i][instanceNo+0] = haHigh; workHa[i][instanceNo+1] = haLow;  } 
                                workHa[i][instanceNo+2] = haOpen;
                                workHa[i][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

string getIndicatorName()
{
   string progPath = MQL5InfoString(MQL5_PROGRAM_PATH); int start=-1;
   while (true)
   {
      int foundAt = StringFind(progPath,"\\",start+1);
      if (foundAt>=0) 
               start = foundAt;
      else  break;     
   }
   
   string indicatorName = StringSubstr(progPath,start+1);
          indicatorName = StringSubstr(indicatorName,0,StringLen(indicatorName)-4);
   return(indicatorName);
}

//
//
//
//
//

int    _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};
string timeFrameToString(int period)
{
   if (period==PERIOD_CURRENT) 
       period = _Period;   
         int i; for(i=ArraySize(_tfsPer)-1;i>=0;i--) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);   
}