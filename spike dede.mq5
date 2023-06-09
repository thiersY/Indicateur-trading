#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

double ExtMapBuffer[];

int OnInit()
{
   // Création du buffer d'indicateur
   SetIndexBuffer(0, ExtMapBuffer, INDICATOR_DATA);

   // Définition des paramètres de l'indicateur
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(0, PLOT_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(0, PLOT_COLOR, clrGreen);

   return(INIT_SUCCEEDED);
}

void OnCalculate(const int rates_total,
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
   int counted_bars = IndicatorCounted();
   int limit = rates_total - counted_bars;

   for(int i = 0; i < limit; i++)
   {
      if(close[i] > 2 * iMA(NULL, 0, 14, 0, MODE_EMA, PRICE_CLOSE, i) - iLowest(NULL, 0, MODE_LOW, 5, i))
      {
         ExtMapBuffer[i] = 1.0;
      }
      else
      {
         ExtMapBuffer[i] = 0.0;
      }
   }
}
