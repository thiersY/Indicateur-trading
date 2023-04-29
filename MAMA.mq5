//+------------------------------------------------------------------+
//|                                                    MAMA_True.mq5 |
//|              MQL5 Code:     Copyright � 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//--- ��������� ����������
#property copyright "Copyright � 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- ����� ������ ����������
#property version   "1.10"
//--- ��������� ���������� � �������� ����
#property indicator_chart_window
//--- ��� ������� � ��������� ���������� ������������ ��� ������
#property indicator_buffers 2
//--- ������������ ��� ����������� ����������
#property indicator_plots   2
//+----------------------------------------------+
//|  ��������� ��������� ���������� FAMA         |
//+----------------------------------------------+
//--- ��������� ���������� 1 � ���� �����
#property indicator_type1   DRAW_LINE
//--- � �������� ����� ����� ����� ���������� ����������� ������� ����
#property indicator_color1  Lime
//--- ����� ���������� 1 - ����������� ������
#property indicator_style1  STYLE_SOLID
//--- ������� ����� ���������� 1 ����� 1
#property indicator_width1  1
//--- ����������� ����� ����� ����������
#property indicator_label1  "MAMA"
//+----------------------------------------------+
//|  ��������� ���������  ���������� MAMA        |
//+----------------------------------------------+
//--- ��������� ���������� 2 � ���� �����
#property indicator_type2   DRAW_LINE
//--- � �������� ����� ��������� ����� ���������� ����������� ������� ����
#property indicator_color2  Red
//--- ����� ���������� 2 - ����������� ������
#property indicator_style2  STYLE_SOLID
//--- ������� ����� ���������� 2 ����� 1
#property indicator_width2  1
//--- ����������� ��������� ����� ����������
#property indicator_label2  "FAMA"
//+----------------------------------------------+
//| ������� ��������� ����������                 |
//+----------------------------------------------+
input double FastLimit = 0.5;
input double SlowLimit = 0.05;
//+----------------------------------------------+
//--- ���������� ������������ ��������, ������� � ����������
//--- ����� ������������ � �������� ������������ �������
double MAMABuffer[];
double FAMABuffer[];
//--- ���������� ������������� ���������� ������ ������� ������
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
//--- ������������� ��������
   StartBar=7+1;
//--- ����������� ������������� ������� MAMABuffer � ������������ �����
   SetIndexBuffer(0,MAMABuffer,INDICATOR_DATA);
//--- �������� ����� ��� ����������� � DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"MAMA");
//--- ������������� ������ ������ ������� ��������� ����������
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBar);
//--- ����������� ������������� ������� FAMABuffer � ������������ �����
   SetIndexBuffer(1,FAMABuffer,INDICATOR_DATA);
//--- �������� ����� ��� ����������� � DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"FAMA");
//--- ������������� ������ ������ ������� ��������� ����������
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBar+1);
//--- ������������� ���������� ��� ��������� ����� ����������
   string shortname;
   StringConcatenate(shortname,"The MESA Adaptive Moving Average(",FastLimit,", ",SlowLimit,")");
//--- �������� ����� ��� ����������� � ��������� ������� � �� ����������� ���������
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- ����������� �������� ����������� �������� ����������
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // ���������� ������� � ����� �� ������� ����
                const int prev_calculated,// ���������� ������� � ����� �� ���������� ����
                const int begin,          // ����� ������ ������������ ������� �����
                const double &price[])    // ������� ������ ��� ������� ����������
  {
//--- �������� ���������� ����� �� ������������� ��� �������
   if(rates_total<StartBar+begin) return(0);
//--- �������� ���������� ������  
   static double smooth[7],detrender[7],Q1[7],I1[7],I2[7];
   static double Q2[7],jI[7],jQ[7],Re[7],Im[7],period[7],Phase[7];
//--- ���������� ��������� ���������� 
   int first,bar;
   double DeltaPhase,alpha;
//--- ������ ���������� ������ first ��� ����� ��������� �����
   if(prev_calculated==0) // �������� �� ������ ����� ������� ����������
     {
      first=StartBar+begin; // ��������� ����� ��� ������� ���� �����
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
   else first=prev_calculated-1; // ��������� ����� ��� ������� ����� �����
//--- �������� ���� ������� ����������
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
