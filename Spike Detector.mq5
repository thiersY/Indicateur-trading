#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

// Définir les seuils de détection de spike
input double SpikeThreshold = 1.5;

// Initialiser les tableaux pour stocker les données de prix et de temps
double PriceArray[];
datetime TimeArray[];

// Définir les tampons pour stocker les signaux de spike détectés
double SignalBuffer[];
double NoSignalBuffer[];

// Définir la fonction de détection de spike
int SpikeDetect()
{
   // Récupérer les données de prix et de temps
   int total = CopyRates(_Symbol, _Period, 0, Bars, PriceArray);
   ArraySetAsSeries(PriceArray, true);

   int time_total = CopyTime(_Symbol, _Period, 0, Bars, TimeArray);
   ArraySetAsSeries(TimeArray, true);

   // Initialiser les variables de détection de spike
   double current_price, previous_price;
   datetime current_time, previous_time;
   double price_difference;
   bool is_spike;

   // Parcourir les données de prix pour détecter les spikes
   for (int i = 1; i < total; i++)
   {
      // Récupérer les prix et temps actuels et précédents
      current_price = PriceArray[i];
      previous_price = PriceArray[i-1];
      current_time = TimeArray[i];
      previous_time = TimeArray[i-1];

      // Calculer la différence de prix
      price_difference = MathAbs(current_price - previous_price);

      // Vérifier si le seuil de spike est dépassé
      if (price_difference > SpikeThreshold)
      {
         is_spike = true;
      }
      else
      {
         is_spike = false;
      }

      // Stocker le signal de spike détecté
      if (is_spike)
      {
         SignalBuffer[i] = current_price;
         NoSignalBuffer[i] = EMPTY_VALUE;
      }
      else
      {
         SignalBuffer[i] = EMPTY_VALUE;
         NoSignalBuffer[i] = current_price;
      }
   }

   return(0);
}

// Définir la fonction d'initialisation de l'indicateur
int OnInit()
{
   // Définir les propriétés de l'indicateur
   IndicatorShortName("Spike Detector");
   SetIndexBuffer(0, SignalBuffer);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 159);
   SetIndexBuffer(1, NoSignalBuffer);
   SetIndexStyle(1, DRAW_LINE);

   return(INIT_SUCCEEDED);
}

// Définir la fonction de mise à jour de l'indicateur
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
   // Appeler la fonction de détection de spike
   SpikeDetect();

   return(rates_total);
}