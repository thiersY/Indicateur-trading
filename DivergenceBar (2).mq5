//+------------------------------------------------------------------+
//|                                                DivergenceBar.mq5 |
//|                      Copyright � 2010, Dmitry Zhebrak aka Necron | 
//|                                                  www.mqlcoder.ru | 
//+------------------------------------------------------------------+
//--- ��������� ����������
#property copyright "Copyright � 2010, Dmitry Zhebrak aka Necron"
//--- ������ �� ���� ������
#property link      "www.mqlcoder.ru"
//--- ����� ������ ����������
#property version   "1.00"
//--- ��������� ���������� � ������� ����
#property indicator_chart_window 
//--- ��� ������� � ��������� ���������� ������������ ��� ������
#property indicator_buffers 3
//--- ������������ ����� ���� ����������� ����������
#property indicator_plots   2
//+----------------------------------------------+
//|  ��������� ��������� ����������              |
//+----------------------------------------------+
//---- ��������� ���������� � ���� ������������ �����������
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- � �������� ������ ���������� ����� ������������
#property indicator_color1  clrLime,clrRed
//---- ����� ���������� - ����������� ������
#property indicator_style1  STYLE_SOLID
//---- ������� ����� ���������� ����� 2
#property indicator_width1  2
//---- ����������� ����� ����������
#property indicator_label1  "DivergenceBar"
//+----------------------------------------------+
//|  ���������� ��������                         |
//+----------------------------------------------+
#define RESET  0 // ��������� ��� �������� ��������� ������� �� �������� ����������
//+----------------------------------------------+
//| ������� ��������� ����������                 |
//+----------------------------------------------+
input ENUM_MA_METHOD SmoothMethod=MODE_SMMA; //����� ���������� ����
input ENUM_APPLIED_PRICE IPC=PRICE_MEDIAN; //������� ���������
//+----------------------------------------------+
//--- ���������� ������������ ��������, ������� � ����������
//--- ����� ������������ � �������� ������������ �������
double DnBuffer[],UpBuffer[],ColorBuffer[];
//---
int Ind_Handle,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- ������������� ���������� ���������� 
   min_rates_total=int(MathMax(13+8,MathMax(8+5,5+3)))+1;
//--- ��������� ������ ���������� iAlligator
   Ind_Handle=iAlligator(Symbol(),Period(),13,8,8,5,5,3,SmoothMethod,IPC);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" �� ������� �������� ����� ���������� iAlligator");
      return(INIT_FAILED);
     }

//--- ����������� ������������� ������� � ������������ �����
   SetIndexBuffer(0,DnBuffer,INDICATOR_DATA);
//--- ���������� ��������� � ������ ��� � ���������
   ArraySetAsSeries(DnBuffer,true);
//--- ����������� ������������� ������� � ������������ �����
   SetIndexBuffer(1,UpBuffer,INDICATOR_DATA);
//--- ���������� ��������� � ������ ��� � ���������
   ArraySetAsSeries(UpBuffer,true);
//--- ����������� ������������� ������� � ������������ �����
   SetIndexBuffer(2,ColorBuffer,INDICATOR_DATA);
//--- ���������� ��������� � ������ ��� � ���������
   ArraySetAsSeries(ColorBuffer,true);

//--- ������������� ������ ������ ������� ��������� ���������� 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- ��������� ������� �������� ����������� ����������
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- ��� ��� ���� ������ � ����� ��� ������� 
   string short_name="DivergenceBar";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
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
//--- �������� ���������� ����� �� ������������� ��� �������
   if(BarsCalculated(Ind_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//--- ���������� ��������� ���������� 
   int to_copy,limit,bar,clr=0;
   double Ind1[],Ind2[],Ind3[];
   double lips,teeth,jaw,up,dn;

//--- ������� ������������ ���������� ���������� ������ �
//���������� ������ limit ��� ����� ��������� �����
   if(prev_calculated>rates_total || prev_calculated<=0)// �������� �� ������ ����� ������� ����������
     {
      limit=rates_total-min_rates_total; // ��������� ����� ��� ������� ���� �����
     }
   else
     {
      limit=rates_total-prev_calculated; // ��������� ����� ��� ������� ����� �����
     }
   to_copy=limit+1;
//--- �������� ����� ����������� ������ � �������
   if(CopyBuffer(Ind_Handle,GATORLIPS_LINE,0,to_copy,Ind1)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,GATORTEETH_LINE,0,to_copy,Ind2)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,GATORJAW_LINE,0,to_copy,Ind3)<=0) return(RESET);
//--- ���������� ��������� � �������� ��� � ����������  
   ArraySetAsSeries(Ind1,true);
   ArraySetAsSeries(Ind2,true);
   ArraySetAsSeries(Ind3,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//--- �������� ���� ������� ����������
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      lips=Ind1[bar];
      teeth=Ind2[bar];
      jaw=Ind3[bar];
      //---
      up=MathMax(lips,MathMax(teeth,jaw));
      dn=MathMin(lips,MathMin(teeth,jaw));
      //---
      UpBuffer[bar]=low[bar]+(high[bar]-low[bar])/2+(high[bar]-low[bar])/10;
      DnBuffer[bar]=low[bar]+(high[bar]-low[bar])/2-(high[bar]-low[bar])/10;
      //---
      if(high[bar]>high[bar+1] && close[bar]<high[bar]-0.5*(high[bar]-low[bar]) && low[bar]>up) clr=0;
      else if(low[bar]<low[bar+1] && close[bar]>low[bar]+0.5*(high[bar]-low[bar]) && high[bar]<dn) clr=1;
      ColorBuffer[bar]=clr;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
