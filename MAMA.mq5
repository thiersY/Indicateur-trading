//+------------------------------------------------------------------+
//|                                                    MAMA_True.mq5 |
//|              MQL5 Code:     Copyright © 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.10"
//--- отрисовка индикатора в основном окне
#property indicator_chart_window
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки индикатора FAMA         |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color1  Lime
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение бычей метки индикатора
#property indicator_label1  "MAMA"
//+----------------------------------------------+
//|  Параметры отрисовки  индикатора MAMA        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color2  Red
//--- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение медвежьей метки индикатора
#property indicator_label2  "FAMA"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double FastLimit = 0.5;
input double SlowLimit = 0.05;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double MAMABuffer[];
double FAMABuffer[];
//--- объявление целочисленных переменных начала отсчета данных
int StartBar;
//+------------------------------------------------------------------+
//| CountVelue() function                                            |
//+------------------------------------------------------------------+
double CountVelue(double  &Array1[],double  &Array2[])
  {
//---
   double Resalt=
                 (0.0962*Array1[0]
                 +0.5769*Array1[2]
                 -0.5769*Array1[4]
                 -0.0962*Array1[6])
                 *(0.075*Array2[1]+0.54);
//---
   return(Resalt);
  }
//+------------------------------------------------------------------+
//| ReCountArray() function                                          |
//+------------------------------------------------------------------+
void ReCountArray(double  &Array[])
  {
//---
   Array[6]=Array[5];
   Array[5]=Array[4];
   Array[4]=Array[3];
   Array[3]=Array[2];
   Array[2]=Array[1];
   Array[1]=Array[0];
//---
   return;
  }
//+------------------------------------------------------------------+
//| SmoothVelue() function                                           |
//+------------------------------------------------------------------+
double SmoothVelue(double  &Array[])
  {
//---
   return(0.2*Array[0]+0.8*Array[1]);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- инициализация констант
   StartBar=7+1;
//--- превращение динамического массива MAMABuffer в индикаторный буфер
   SetIndexBuffer(0,MAMABuffer,INDICATOR_DATA);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"MAMA");
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBar);
//--- превращение динамического массива FAMABuffer в индикаторный буфер
   SetIndexBuffer(1,FAMABuffer,INDICATOR_DATA);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"FAMA");
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBar+1);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"The MESA Adaptive Moving Average(",FastLimit,", ",SlowLimit,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const int begin,          // номер начала достоверного отсчета баров
                const double &price[])    // ценовой массив для расчета индикатора
  {
//--- проверка количества баров на достаточность для расчета
   if(rates_total<StartBar+begin) return(0);
//--- введение переменных памяти  
   static double smooth[7],detrender[7],Q1[7],I1[7],I2[7];
   static double Q2[7],jI[7],jQ[7],Re[7],Im[7],period[7],Phase[7];
//--- объявления локальных переменных 
   int first,bar;
   double DeltaPhase,alpha;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated==0) // проверка на первый старт расчета индикатора
     {
      first=StartBar+begin; // стартовый номер для расчета всех баров
      //---
      ArrayInitialize(smooth,0.0);
      ArrayInitialize(detrender,0.0);
      ArrayInitialize(period,0.0);
      ArrayInitialize(Phase,0.0);
      ArrayInitialize(Q1,0.0);
      ArrayInitialize(I1,0.0);
      ArrayInitialize(I2,0.0);
      ArrayInitialize(Q2,0.0);
      ArrayInitialize(jI,0.0);
      ArrayInitialize(jQ,0.0);
      ArrayInitialize(Re,0.0);
      ArrayInitialize(Im,0.0);
      //---
      MAMABuffer[first-1] = price[first-1];
      FAMABuffer[first-1] = price[first-1];
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      smooth[0]=(4*price[bar-0]+3*price[bar-1]+2*price[bar-2]+1*price[bar-3])/10.0;
      //---
      detrender[0]=CountVelue(smooth,period);
      Q1[0] = CountVelue(detrender,period);
      I1[0] = detrender[3];
      jI[0] = CountVelue(I1, I1);
      jQ[0] = CountVelue(Q1, Q1);
      I2[0] = I1[0] - jQ[0];
      Q2[0] = Q1[0] + jI[0];
      I2[0] = SmoothVelue(I2);
      Q2[0] = SmoothVelue(Q2);
      Re[0] = I2[0]*I2[1] + Q2[0]*Q2[1];
      Im[0] = I2[0]*Q2[1] - Q2[0]*I2[1];
      Re[0] = SmoothVelue(Re);
      Im[0] = SmoothVelue(Im);
      //---
      if(Im[0] && Re[0])
        {
         double res=MathArctan(Im[0]/Re[0]);
         if(res) period[0]=6.285714/res;
         else period[0]=6.285714;
        }
      else period[0]=6.285714;
      //---
      if(period[0]>1.50*period[1]) period[0]=1.50*period[1];
      if(period[0]<0.67*period[1]) period[0]=0.67*period[1];
      if(period[0]<6.00) period[0]=6.00;
      if(period[0]>50.0) period[0]=50.0;
      //---
      period[0]=0.2*period[0]+0.8*period[1];
      //---
      if(I1[0]) Phase[0]=57.27272987*MathArctan(Q1[0]/I1[0]);
      else Phase[0]=57.27272987;
      //---
      DeltaPhase=Phase[1]-Phase[0];
      if(DeltaPhase<1) DeltaPhase=1.0;
      //---
      alpha=FastLimit/DeltaPhase;
      if(alpha<SlowLimit)alpha=SlowLimit;
      //---
      MAMABuffer[bar]=alpha*price[bar]+(1.0-alpha)*MAMABuffer[bar-1];
      FAMABuffer[bar]=0.5*alpha*MAMABuffer[bar]+(1.0-0.5*alpha)*FAMABuffer[bar-1];
      //---
      if(bar<rates_total-1)
        {
         ReCountArray(smooth);
         ReCountArray(detrender);
         ReCountArray(period);
         ReCountArray(Phase);
         ReCountArray(Q1);
         ReCountArray(I1);
         ReCountArray(I2);
         ReCountArray(Q2);
         ReCountArray(jI);
         ReCountArray(jQ);
         ReCountArray(Re);
         ReCountArray(Im);
        }
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
