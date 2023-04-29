//+------------------------------------------------------------------+
//|                                                         Laguerre |
//|                                      Copyright © 2009, EarnForex |
//|                                        http://www.earnforex.com/ |
//|                            Based on Laguerre.mq4 by Emerald King |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, EarnForex"
#property link      "http://www.earnforex.com"
#property version   "1.01"
#property description "Laguerre - shows weighted trend-line in a separate indicator window."

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_type1 DRAW_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_color1 Magenta
#property indicator_level1 0.80
#property indicator_level2 0.50
#property indicator_level3 0.20

//---- input parameters
input double gamma =  0.7;
input int CountBars = 950;

double L0 = 0;
double L1 = 0;
double L2 = 0;
double L3 = 0;
double L0A = 0;
double L1A = 0;
double L2A = 0;
double L3A = 0;
double LRSI = 0;
double CU = 0;
double CD = 0;

double val1[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "Laguerre");
   SetIndexBuffer(0, val1, INDICATOR_DATA);
}

//+------------------------------------------------------------------+
//| Data Calculation Function for Indicator                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &Close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int limit = CountBars;
   if (CountBars > rates_total) limit = rates_total;
   
   ArraySetAsSeries(Close, true);
   
   int i = limit - 1;
   while(i >= 0)
   {
      L0A = L0;
      L1A = L1;
      L2A = L2;
      L3A = L3;
      L0 = (1 - gamma) * Close[i] + gamma * L0A;
      L1 = - gamma * L0 + L0A + gamma * L1A;
      L2 = - gamma * L1 + L1A + gamma * L2A;
      L3 = - gamma * L2 + L2A + gamma * L3A;

      CU = 0;
      CD = 0;
      
      if (L0 >= L1) CU = L0 - L1; else CD = L1 - L0;
      if (L1 >= L2) CU = CU + L1 - L2; else CD = CD + L2 - L1;
      if (L2 >= L3) CU = CU + L2 - L3; else CD = CD + L3 - L2;

      if (CU + CD != 0) LRSI = CU / (CU + CD);

      val1[rates_total - i - 1] = LRSI;
	   i--;
	}

   return(rates_total);
}
//+------------------------------------------------------------------+
