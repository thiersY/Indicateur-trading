//+------------------------------------------------------------------+
//|                                              AutoTrendLinien.mq5 |
//|                           Copyright © 2006, ANG3110@latchess.com |
//|                                             ANG3110@latchess.com |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2006, ANG3110@latchess.com"
//---- link to the website of the author
#property link      "ANG3110@latchess.com"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int Hours=24;                    // Channel period in hours
input color UpChannelColor=DodgerBlue; // Upper line color
input color MdChannelColor=Gray;       // Middle line color
input color DnChannelColor=Magenta;    // Lower line color
//+----------------------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;

double lr,lr0,lrp;
double sx,sy,sxy,sx2,aa,bb;
double hai,lai,dhi,dli,dhm,dlm,ha0,hap,la0,lap;
double price_p1,price_p0,price_p2,price_01,price_00,price_02;
double dh,dl,dh_1,dl_1,dh_2,dl_2;

int f,f0,f1,p;
int ai_1,ai_2,bi_1,bi_2;
int p1,p0,p2,fp;
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateTline(long     chart_id,  // chart ID
                 string   name,      // object name
                 int      nwin,      // window index
                 datetime time1,     // price level time 1
                 double   price1,    // price level 1
                 datetime time2,     // price level time 2
                 double   price2,    // price level 2
                 color    Color,     // line color
                 int      style,     // line style
                 int      width,     // line width
                 string   text)      // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Trend line reinstallation                                       |
//+------------------------------------------------------------------+
void SetTline(long     chart_id,  // chart ID
              string   name,      // object name
              int      nwin,      // window index
              datetime time1,     // price level time 1
              double   price1,    // price level 1
              datetime time2,     // price level time 2
              double   price2,    // price level 2
              color    Color,     // line color
              int      style,     // line style
              int      width,     // line width
              string   text)      // text
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
//----
  }
//+------------------------------------------------------------------+   
//| iBarShift() function                                             |
//+------------------------------------------------------------------+  
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time)
  {
//----+
   if(time<0) return(-1);
   datetime Arr[],time1;

   time1=(datetime)SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE);

   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
//----+
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables
   p=Hours*60*60/PeriodSeconds();
   min_rates_total=p+1;
//---- initializations of a variable for the indicator short name
   string shortname="SAutoTrendLinien";
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,"Upper Line");
   ObjectDelete(0,"Middle Line");
   ObjectDelete(0,"Lower Line");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
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
   if(rates_total<min_rates_total) return(0);
//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   int i,n;
//----
   if(f==1)
     {
      if(prev_calculated<=0)
        {
         p1 = iBarShift(Symbol(), _Period, ObjectGetInteger(0,"Upper Line", OBJPROP_TIME,0));
         p0 = iBarShift(Symbol(), _Period, ObjectGetInteger(0,"Middle Line",OBJPROP_TIME,0));
         p2 = iBarShift(Symbol(), _Period, ObjectGetInteger(0,"Lower Line", OBJPROP_TIME,0));
        }
      else
        {
         p1 = p;
         p0 = p;
         p2 = p;
        }

      if(fp==0 && p!=p1)
        {
         p=p1;
         fp=1;
        }
      if(fp==0 && p!=p0)
        {
         p=p0;
         fp=1;
        }
      if(fp==0 && p!=p2)
        {
         p=p2;
         fp=1;
        }
     }
   sx=0; sy=0; sxy=0; sx2=0;
//----
   for(n=0; n<=p; n++)
     {
      sx += n;
      sy += int(time[n]);
      sxy += n*close[n];
      sx2 += MathPow(n, 2);
     }
   aa = (sx*sy - (p + 1)*sxy) / (MathPow(sx, 2) - (p + 1)*sx2);
   bb = (sy - aa*sx) / (p + 1);
//----
   for(i=0; i<=p; i++)
     {
      lr = bb + aa*i;
      dh = high[i] - lr;
      dl = low[i] - lr;
      //----
      if(i<p/2)
        {
         if(i==0)
           {
            dh_1 = 0.0;
            dl_1 = 0.0;
            ai_1 = i;
            bi_1 = i;
           }
         //----
         if(dh>=dh_1)
           {
            dh_1 = dh;
            ai_1 = i;
           }
         //----
         if(dl<=dl_1)
           {
            dl_1 = dl;
            bi_1 = i;
           }
        }
      //----
      if(i>=p/2)
        {
         if(i==p/2)
           {
            dh_2 = 0.0;
            dl_2 = 0.0;
            ai_2 = i;
            bi_2 = i;
           }
         if(dh>=dh_2)
           {
            dh_2 = dh;
            ai_2 = i;
           }
         if(dl<=dl_2)
           {
            dl_2 = dl;
            bi_2 = i;
           }
        }
     }
   lr0 = bb;
   lrp = bb + aa*(i + p);
//----
   if(MathAbs(ai_1-ai_2)>MathAbs(bi_1-bi_2))
      f=1;
//----
   if(MathAbs(ai_1-ai_2)<MathAbs(bi_1-bi_2))
      f=2;
//----
   if(MathAbs(ai_1-ai_2)==MathAbs(bi_1-bi_2))
     {
      if(MathAbs(dh_1-dh_2)<MathAbs(dl_1-dl_2))
         f=1;
      //----
      if(MathAbs(dh_1-dh_2)>=MathAbs(dl_1-dl_2))
         f=2;
     }
//----
   if(f==1)
     {
      for(n=0; n<=20; n++)
        {
         f1=0;
         //----
         for(i=0; i<=p; i++)
           {
            hai=high[ai_1]*(i-ai_2)/(ai_1-ai_2)+high[ai_2]*(i-ai_1)/
                (ai_2-ai_1);
            //----
            if(i==0 || i==p/2)
               dhm=0.0;
            //----
            if(high[i]-hai>dhm && i<p/2)
              {
               ai_1=i;
               f1=1;
              }
            //----
            if(high[i]-hai>dhm && i>=p/2)
              {
               ai_2=i;
               f1=1;
              }
           }
         //----
         if(f==0)
            break;
        }
      //----
      for(i=0; i<=p; i++)
        {
         hai=high[ai_1]*(i-ai_2)/(ai_1-ai_2)+high[ai_2]*(i-ai_1)/
             (ai_2-ai_1);
         dli=low[i]-hai;
         if(i==0)
            dlm=0.0;
         if(dli<dlm)
            dlm=dli;
        }
      ha0 = high[ai_1]*(0 - ai_2) / (ai_1 - ai_2) + high[ai_2]*(0 - ai_1) / (ai_2 - ai_1);
      hap = high[ai_1]*(p - ai_2) / (ai_1 - ai_2) + high[ai_2]*(p - ai_1) / (ai_2 - ai_1);
      price_p1 = hap;
      price_p0 = hap + dlm / 2;
      price_p2 = hap + dlm;
      price_01 = ha0;
      price_00 = ha0 + dlm / 2;
      price_02 = ha0 + dlm;
     }
   if(f==2)
     {
      for(n=0; n<=20; n++)
        {
         f1=0;
         for(i=0; i<=p; i++)
           {
            lai=low[bi_1]*(i-bi_2)/(bi_1-bi_2)+low[bi_2]*(i-bi_1)/
                (bi_2-bi_1);
            if(i==0 || i==p/2)
               dlm=0.0;
            if(low[i]-lai<dlm && i<p/2)
              {
               bi_1=i;
               f1=1;
              }
            if(low[i]-lai<dlm && i>=p/2)
              {
               bi_2=i;
               f1=1;
              }
           }
         if(f==0)
            break;
        }
      //----
      for(i=0; i<=p; i++)
        {
         lai = low[bi_1]*(i - bi_2) / (bi_1 - bi_2) + low[bi_2]*(i - bi_1) / (bi_2 - bi_1);
         dhi = high[i] - lai;
         if(i== 0)
            dhm=0.0;
         if(dhi>dhm)
            dhm=dhi;
        }
      la0 = low[bi_1]*(0 - bi_2) / (bi_1 - bi_2) + low[bi_2]*(0 - bi_1) / (bi_2 - bi_1);
      lap = low[bi_1]*(p - bi_2) / (bi_1 - bi_2) + low[bi_2]*(p - bi_1) / (bi_2 - bi_1);
      price_p1 = lap;
      price_p0 = lap + dhm / 2;
      price_p2 = lap + dhm;
      price_01 = la0;
      price_00 = la0 + dhm / 2;
      price_02 = la0 + dhm;
     }

   SetTline(0,"Upper Line",0,time[p],price_p1,time[0],price_01,UpChannelColor,STYLE_SOLID,2,"Upper Line");
   SetTline(0,"Middle Line",0,time[p],price_p0,time[0],price_00,MdChannelColor,STYLE_DOT,1,"Middle Line");
   SetTline(0,"Lower Line",0,time[p],price_p2,time[0],price_02,DnChannelColor,STYLE_SOLID,2,"Lower Line");
   f=1; p1=p; p0=p; p2=p; fp=0;
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
