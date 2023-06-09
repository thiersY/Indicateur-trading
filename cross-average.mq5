//+------------------------------------------------------------------+
//|                                   Copyright 2017, Erlon F. Souza |
//|                                       https://github.com/erlonfs |
//+------------------------------------------------------------------+

#define   robot_name       "CROSS AVERAGE" 
#define   robot_version    "1.0.2"

#property copyright        "Copyright 2017, Bad Robot"
#property link             "https://github.com/erlonfs"
#property version       	robot_version
#property description   	"Verifica o cruzamento de duas médias.\n\n\nBons trades!\n\nEquipe BAD ROBOT.\nerlon.efs@gmail.com"
#property icon             "cross-average.ico" 

#include <..\Experts\mt5-cross-average-robot\src\CrossAverage.mqh>
#include <Framework\Enum.mqh>

input string          Secao1 = "###############";//### Definições Básicas ###
input string          HoraInicio="00:00";//Hora de início de execução da estratégia
input string          HoraFim="00:00";//Hora de término de execução da estratégia
input string          HoraInicioIntervalo="00:00";//Hora de início intervalo de execução da estratégia
input string          HoraFimIntervalo="00:00";//Hora de término intervalo de execução da estratégia

input string          Secao2 = "###############";//### Notificações ###
input ENUM_LOGIC      IsNotificacoesApp=0;//Ativar notificações no app do metatrader 5?

input string          Secao3 = "###############";//### Config de Estratégia ###
input int             MediaLonga=0;//Média longa
input int             MediaCurta=0;//Média curta
input ENUM_MA_METHOD  MediaMethod=MODE_EMA;//Tipo da média

//variaveis
CrossAverage _ea;

int OnInit()
  {  
           
   printf("Bem Vindo ao "+robot_name+"!");
     
   //Definições Básicas  
   _ea.SetSymbol(_Symbol);
   _ea.SetHoraInicio(HoraInicio);
   _ea.SetHoraFim(HoraFim);
   _ea.SetHoraInicioIntervalo(HoraInicioIntervalo);
   _ea.SetHoraFimIntervalo(HoraFimIntervalo);  
   
   //Expert Control
   _ea.SetRobotName(robot_name);
   _ea.SetRobotVersion(robot_version);
   
   //Notificacoes
   _ea.SetIsNotificacoesApp(IsNotificacoesApp);
       
   //Estrategia
   _ea.SetPeriod(PERIOD_CURRENT);
   _ea.SetIsAlertMode(true);
   _ea.SetEMALongPeriod(MediaLonga);
   _ea.SetEMAShortPeriod(MediaCurta);   
   _ea.SetEMAMethod(MediaMethod); 
      
   //Load Expert
 	_ea.Load();
 	 	  
   return(INIT_SUCCEEDED);

}

void OnDeinit(const int reason){
   printf("Obrigado por utilizar o "+robot_name+"!");
}

void OnTick(){                                                             
   _ea.Execute();      
}

void OnTrade(){
   _ea.ExecuteOnTrade();
}