//+------------------------------------------------------------------+
//| Spike Detector EA                                                 |
//| Expert Advisor for MetaTrader 5                                   |
//|                                                                  |
//| Copyright (c) 2023 ChatGPT                                       |
//| https://github.com/ChatGPT                                       |
//+------------------------------------------------------------------+

//---- paramètres d'entrée
input double SpikeSize = 5.0;  // Taille minimale du spike en pips
input int SpikeDuration = 10;  // Durée minimale du spike en bars

//---- variables globales
int SpikeStartBar = 0;
int SpikeEndBar = 0;
double SpikeStartPrice = 0;
double SpikeEndPrice = 0;

//+------------------------------------------------------------------+
//| Fonction de vérification des spikes                               |
//+------------------------------------------------------------------+
void CheckForSpikes()
{
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

    if (SpikeStartBar == 0)  // Pas de pic en cours
    {
        SpikeStartBar = Bars-1;
        SpikeStartPrice = currentPrice;
    }
    else  // Un pic est en cours
    {
         SpikeEndBar = Bars-1;
        SpikeEndPrice = currentPrice;

        double spikeSize = MathAbs(SpikeStartPrice - SpikeEndPrice) / _Point;
        int spikeDuration = SpikeEndBar - SpikeStartBar;

        if (spikeSize >= SpikeSize && spikeDuration >= SpikeDuration)
        {
            // Spike détecté !
            Print("Spike détecté : Taille = ", spikeSize, " pips, Durée = ", spikeDuration, " bars");
        }

        // Réinitialisation des variables
        SpikeStartBar = 0;
        SpikeEndBar = 0;
        SpikeStartPrice = 0.0;
        SpikeEndPrice = 0.0;
    }
}

//+------------------------------------------------------------------+
//| Fonction de gestion des événements                                |
//+------------------------------------------------------------------+
void OnTick()
{
    CheckForSpikes();
}

//+------------------------------------------------------------------+
//| Fonction d'initialisation                                         |
//+------------------------------------------------------------------+
