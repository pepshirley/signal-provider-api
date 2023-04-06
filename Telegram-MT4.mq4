//+------------------------------------------------------------------+
//|                                                   MT4 Account Manager.mq4 |
//|                                          Copyright 2021, Perpetual Vincent |
//|                                               http://mql5.com|
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Perpetual Vincent"
#property link      "http://mql5.com"
#property version   "1.00"
#property  strict



string file_url = "https://nfs.faireconomy.media/ff_calendar_thisweek.csv";

enum RISK_SOURCE
  {
   balance,
   free_margin
  };

enum LOT_MODE
  {
   fixed,//Fixed lots
   risk//% risk
  };

enum SL_MODE
  {
   custom,//Custom
   signal//Signal
  };

enum TP_MODE
  {
   custom1,//Custom
   signal1//Signal
  };

enum MULTIPLE_TP
  {
   single,//Single order
   multiple,//Multiple orders
  };

enum SHUTDOWN_DAY
  {
   Monday,
   Tuesday,
   Wednesday,
   Thursday,
   Friday,
   Saturday,
   Sunday
  };

enum RESTART_DAY
  {
   Monday1,//Monday
   Tuesday1,//Tuesday
   Wednesday1,//Wednesday
   Thursday1,//Thursday
   Friday1,//Friday
   Saturday1,//Saturday
   Sunday1,//Sunday
  };

string   token = "";//Enter API Token


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   InpExcludedSymbols = "";//Excluded symbols (if multiple, separate by commas)
string   InpIncludedSymbols = "";//Included symbols (if multiple, separate by commas)

input string     InpSep91           = "";//============AUTHENTICATION============
input string     InpLicense        = "";//Enter license code
input string     InpSep40          = "";//============COMMAND SETTINGS============
input string     InpOTCmds         = "buy,sell,buying,selling,buystop,sellstop,buylimit,selllimit";//Ordertype commands (not case sensitive)
input string     InpCloseCmds      = "close,delete";//Close commands
input string     InpBECmds         = "breakeven,sl to entry";//Breakeven commands
input string     InpSLCmds         = "move sl,update sl,change sl";//SL update commands
input string     InpTPCmds         = "move tp,update tp,change tp";//TP update commands
input string     InpPCCmds         = "close half,close partial,secure profits";//Partial close commands

input string     InpSep30            = "";//============SYMBOL OPTIONS============
input    string   InpBrokerSuffix    = "";//Broker symbols suffix (if any)
input    string   InpBrokerName      = "GOLD=XAUUSD,NAS100=USTEC";//Add custom symbol (name on signal=name on broker)

input string     InpSep3           = "";//============TRADE & RISK SETTINGS============
input LOT_MODE InpLotMode = risk;//LOT MODE
input double   InpLotValue         = 0.01;//Lot value
input double   InpRiskPerc   = 1;//Risk Percent
input double   InpMaxDD      = 5;//Maximum drawdown (%)
input bool     InpCloseOnDD  = true;//Close all trades on max drawdown
input bool     InpDynamicSL     = true;//Move SL after each TP is hit


string     InpSep63   = "";//=============NEWS FILTER=================
bool     InpApplyNews   = false;//Apply news filter
bool     InpHighImpact  = true;//Filter high impact news
bool     InpMediumImpact  = false;//Filter medium impact news
bool     InpLowImpact  = false;//Filter low impact news
bool     InpShowNews    = false;//Display news on chart
int      InpPreNewsShutdownTime = 15;//Stop trading X mins before news
int      InpPostNewsResumeTime  = 15;//Resume trading X mins after news
bool     InpCloseMarket         = true;//Close open trades before news
bool     InpClosePending        = true;//Close pending orders before news
bool     InpTurnOffAutotrading  = false;//Turn off autotrading

string     InpSep1           = "";//============SHUTDOWN SETTINGS============
bool     InpActivateShutdown = false;//Activate shutdown
string      InpTimeZoneOffset = "-01:00";//Broker Server Timezone (GMT +/- HH:MM)
SHUTDOWN_DAY InpShutdownDay = Thursday;//EA Close day
string   InpShutdownTime    = "23:59";//EA Close time (Your computer's local time)

RESTART_DAY InpRestartDay  = Monday1;//EA Restart day
string   InpRestartTime    = "00:00";//EA Restart time (Your computer's local time)

int      InpMaxOrderCnt   = 6;//Max Order Count

bool     InpUseShutdown     = true;//Activate Shutdown?
bool     InpUseLimit      = false;//Execute by limit?
int      InpLimitExpiry   = 4;//Limit expiry (hours)
int      InpMaxBlankTradeCnt = 3;//Number of trades (when no SL/TP)

//input double   InpMaxEntryPips  = 1;//Maximum entry slippage (multiples of minimum stop)
RISK_SOURCE InpRiskSource    = balance;//Risk calculation source


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   InpIndicesList     = "";//Indices list (for lot size classification by instrument type)
string   InpCommoditiesList = "";//Commodities list (for lot size classification by instrument type)
string   InpStocksList      = "";//Crypto list (for lot size classification by instrument type)

string   InpLotsPerSymbol    = "EURUSD=0.01,USDJPY=0.01";//Lot size per symbol
string   InpLotsPerTPCurrencies   = "";//Lot size per TP (currency pairs)
string   InpLotsPerTPIndices   = "";//Lot size per TP (indices)
string   InpLotsPerTPCommodities   = "";//Lot size per TP (commodities)
string   InpLotsPerTPStocks   = "";//Lot size per TP (crypto)
bool     InpUseSpread     = true;//Add spread to SL?
bool     InpUseTPSpread   = true;//Add spread to TP?
double   InpDefaultTP     = 100;//Default TP (Currency pairs)
double   InpDefaultSL     = 50;//Default SL (Currency pairs)
string   InpDefTPOthers   = "US30=10000,NAS100=10000,BTCUSD=1000000";//Default TP in points (Other instruments)
string   InpDefSLOthers   = "US30=5000,NAS100=5000,BTCUSD=500000";//Default SL in points (Other instruments)
bool     InpRejectNoSL      = true;//Reject orders without SL
SL_MODE  InpSLMode = signal;//SL MODE
TP_MODE  InpTPMode = signal1;//TP MODE
MULTIPLE_TP InpMultipleTP = multiple;//Multiple TP Handle
string   InpTradesPerTP = "1,1,1,1,1";//Number of trades per TP
bool     InpDivideLot     = false;//Divide lot by TP count




bool   InpUseTrail      = false;//Use trailing stop?
double InpTrailStart    = 30;//Start trail after X pips in profit
double InpTrailPoints   = 10;//Trail price by X pips
int      InpMaxOrderCntPerSymbol   = 5;//Max Order Count Per Symbol
double   InpCloseHalfPerc = 50;//Close Half %
bool     InpShowSender    = true;//Show sender ID on trade ?

string     InpSep4           = "";//============CHANNEL SETTINGS============
bool     InpChannelValid  = true;//Channel Validation
string   InpSupportedChannels = "";//Signal channels (if multiple, separate by commas)






double   InpGoldLot    = 1;//Gold Lot Size
double   InpUS30Lot    = 0.02;//US30 Lot Size
double   InpNAS100Lot  = 0.02;//NAS100 Lot Size



double   InpUS30SL     = 100000;//US30 alternate SL/TP points
double   InpNAS100SL   = 100000;//NAS100 alternate SL/TP points
double   InpGoldSL     = 1000;//Gold alternate SL/TP points

string     InpSep911     = "";//============NEWS FILTER============
bool     InpUseNewsFilter = true;//Use News filter?



string   InpSigGoldName   = "XAUUSD";//Signal Gold name
string   InpSigUS30Name   = "US30";//Signal US30 name
string   InpSigNasName    = "NASDAQ";//Signal NAS100 name

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   InpGoldName   = "XAUUSD";//Your broker's Gold name (If XAUUSD, leave empty)
string   InpUS30Name   = "US30";//Your broker's US30 name (If US30, leave empty)
string   InpNasName    = "NAS100";//Your broker's NAS100 name (If NAS100, leave empty)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   InpBTCName    = "BTCUSD";//Your broker's BTC name (If BTCUSD, leave empty)
double   InpBTCLot     = 0.25;//BTC Lot Size
double   InpUSDTRYLot  = 0.3;//USDTRY Lot Size


double   InpTP1LotSize    = 0.01;//Lot Size
int      InpUpdateInterval = 10;//How often do you want to check for new messages? (seconds)
int      InpConnRetry      = 10;//Maximum of connection retries

string   Hostname = "localhost";    // Server hostname or IP address
ushort   ServerPort = 9999;        // Server port

double   InpTP2LotSize   = 0.01;//TP2 Lot Size
double   InpTP3LotSize   = 0.01;//TP3 Lot Size
int      InpMaxSlippage = 10;//Maximum Slippage
double   InpBEPoints    = 0;//Breakeven points
double   InpPCPerc      = 50;//% for partial close

string   InpSep7       = "";//=========================================
string   InpTitle4      = "";//SYMBOL INPUTS
string   InpSep8       = "";//=========================================
string   InpEthName   = " ";//Your broker's Ethereum name (If ETHUSD, leave empty)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   InpXRPName   = " ";//Your broker's XRP name (If XRPUSD, leave empty)
string   InpSPX500Name   = " ";//Your broker's SPX500 name (If SPX500, leave empty)
string   InpLTCName   = " ";//Your broker's LTC name (If LTCUSD, leave empty)
string   InpSOLName   = " ";//Your broker's SOL name (If SOLUSD, leave empty)

string   InpSep5       = "";//=========================================
string   InpTitle5       = "";//EA INPUTS
string   InpSep66      = "";//=========================================
int      InpMagicNumber = 300922;//EA Magic Number
string   InpTradeComment = "Ilpaulix Telegram  to MT4 EA";//Trade Comment

string        chat_id   = "1380098782";//"1380098782"; //"-1001565908789";
string        message;
string        cookie       = NULL,headers;
char          post[];
char          results[];
int           resu;
string        baseurl      = "https://api.telegram.org";

string PriceChars[] = {"0","1","2","3","4","5","6","7","8","9","."};
string Letters[]    = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"};
string LETTERS[]    = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
string TradeTypes[];
string OtherSymbols[] = {"NAS100","US30","ETHUSD","LTCUSD","XRPUSD","SPX500","SOLUSD","BTCUSD","BITCOIN","XRP","BTC","BITCOIN","NAS","GOLD","ETH","LTC","SOL"};
double TPs[];
double SL;
int Ordertype;
double Entry;
string Symbol_Name;
string QSymbol;
int LastMsgID;
string TicketTPs[];
string TicketTP1;
string TicketTP2;
string TicketTP3;
string TicketTP4;
string TicketTP5;
string TicketTP6;
string TicketTP7;
string TicketTP8;
string TicketTP9;
string TicketTP10;

string sEntry;
string QuotedMsg;

datetime LastMsgTime;

string Message;
string Sender;

bool EAIsOn;

datetime OpenDay;
datetime CloseDay;
int LastNewsUpdateDay;

int TimezoneOffsetSecs;
string BrokerNames[];

string CloseCmds[];
string BECmds[];
string SLCmds[];
string TPCmds[];
string PCCmds[];

string BASE_URL;

datetime LastExpiryCheckTime;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
   
      MessageBox("Please ensure autotrading is allowed and relaunch.");
      return INIT_FAILED;
   }
   
   if(!TerminalInfoInteger(TERMINAL_CONNECTED)){
   
      MessageBox("Please ensure you are connected to the internet and relaunch.");
      return INIT_FAILED;
   }
   
   IsNewMessage();

   BASE_URL = "http://www.mt4-5.telecopierz.com";

   /*if(!IsDllsAllowed())
     {
      MessageBox("Please allow DLL imports for this EA. Go to Tools -> Options -> Expert Advisors");
      return INIT_FAILED;
     }*/

   if(StringLen(InpLicense) == 0)
     {
      MessageBox("Please enter your license code.");
      return INIT_FAILED;
     }


   string data = Request("checklicense/"+InpLicense);

   if(data != "Verification successful")
     {
      //MessageBox("Verification failed. Possible reasons are: 1. Incorrect login details. 2. You already have a session running. 3. You are not registered.");
      MessageBox(data);
      return INIT_FAILED;
     }

   else
     {
      Print(data);
      string terminalAdd = Request("addterminal/"+InpLicense);

      if(terminalAdd=="Max number of terminals added")
        {
         MessageBox("Number of active terminals exceeded for this license. Remove copier for active terminal to free slot.");
         return INIT_FAILED;
        }

      string expiryCheck = Request("checkexpiry/"+InpLicense);

      LastExpiryCheckTime = TimeCurrent();

      if(expiryCheck=="License has expired")
        {
         MessageBox(expiryCheck+"!");
         return INIT_FAILED;
        }

      else
         Print(expiryCheck);
     }

 

   string tzparts[];

   string tzoffset = InpTimeZoneOffset;

   StringReplace(tzoffset,"+","");

   StringSplit(tzoffset,StringGetCharacter(":",0),tzparts);

   if(ArraySize(tzparts)==0)
     {
      Alert("Wrong timezone offset.");
      return INIT_FAILED;
     }

   if(StringLen(InpOTCmds) > 0)
      StringSplit(InpOTCmds,StringGetCharacter(",",0),TradeTypes);

   if(StringLen(InpCloseCmds) > 0)
      StringSplit(InpCloseCmds,StringGetCharacter(",",0),CloseCmds);

   if(StringLen(InpBECmds) > 0)
      StringSplit(InpBECmds,StringGetCharacter(",",0),BECmds);

   if(StringLen(InpSLCmds) > 0)
      StringSplit(InpSLCmds,StringGetCharacter(",",0),SLCmds);

   if(StringLen(InpTPCmds) > 0)
      StringSplit(InpTPCmds,StringGetCharacter(",",0),TPCmds);

   if(StringLen(InpPCCmds) > 0)
      StringSplit(InpPCCmds,StringGetCharacter(",",0),PCCmds);


   if(StringLen(InpBrokerName) > 0)
     {
      StringSplit(InpBrokerName,StringGetCharacter(",",0),BrokerNames);
     }


   TimezoneOffsetSecs = ((int)tzparts[0])*60*60 + ((int)tzparts[1])*60;

// Alert("Server timezone is ",TimezoneOffsetSecs," seconds ahead/behind GMT.");

   LastNewsUpdateDay = -1;

// OpenDay  = TimeCurrent() > GetNearestOpenDay() ? GetNearestOpenDay() + 7*86400 : GetNearestOpenDay();
   OpenDay  = MathAbs(TimeCurrent() - GetNearestOpenDay()) <  MathAbs(TimeCurrent() - GetNearestOpenDay() + 7*86400) ? GetNearestOpenDay() : GetNearestOpenDay() + 7*86400;
   CloseDay = MathAbs(TimeCurrent() - GetNearestCloseDay()) <  MathAbs(TimeCurrent() - GetNearestCloseDay() + 7*86400) ? GetNearestCloseDay() : GetNearestCloseDay() + 7*86400;

   if(TimeCurrent() > CloseDay)
     {
      CloseDay = CloseDay + (7*86400);
      OpenDay = OpenDay + (7*86400);
     }

   if(CloseDay > OpenDay)
     {
      OpenDay = OpenDay + (7*86400);
     }



   /* if(!FileIsExist("ea_status.txt"))
      {
        EAIsOn = true;
      }


    else
      {
       int handle = FileOpen("ea_status.txt",FILE_READ);

       if(handle==INVALID_HANDLE)
         {
          Alert("Failed to get EA status. Please restart.");
          return INIT_FAILED;
         }

       EAIsOn = FileReadBool(handle);

       FileClose(handle);
      }*/

   EAIsOn = true;

   CheckEAStatus();

// Alert(GetToday());
// Alert(InpShutdownDay);

   string path = TerminalInfoString(TERMINAL_DATA_PATH);
   string exe = path+"\\MQL4\\Files\\telegram_reader.exe";

// ShellExecuteW(0,"open",exe,NULL,path+"\\MQL4\\Files",1);



   string endline = "\n";

   ushort sep = StringGetCharacter(endline,0);



   Comment("");



   LastMsgID = 0;

   LastMsgTime = 0;

   IsNewMessage();


   EventSetTimer(1);
   OnTimer();
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   for(int i=ObjectsTotal(0,-1,-1)-1; i>=0; i--)
     {
      string name = ObjectName(0,i);

      if(StringFind(name,"NEWS") >= 0)
         ObjectDelete(0,name);
     }

   string terminalRemove = Request("removeterminal/"+InpLicense);

   Print("Terminal deinit request = ",terminalRemove);

   EventKillTimer();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckEAStatus()
  {

   int today             = GetToday();
   datetime shutdowntime = StringToTime(InpShutdownTime);
   datetime restarttime = StringToTime(InpRestartTime);

   if(today==(InpShutdownDay+1) && TimeCurrent() >= shutdowntime)
     {
      EAIsOn = false;
     }

   if(today==(InpRestartDay+1) && TimeCurrent() >= restarttime)
     {
      EAIsOn = true;
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!TerminalInfoInteger(TERMINAL_CONNECTED)){
   
      Comment("You are disconnected from the internet. Please ensure you are connected for EA to resume!.");
      return;
   }
   
   TradeOnSignal();

   if(TimeCurrent()-LastExpiryCheckTime >= 3600)
     {

      string expiryCheck = Request("checkexpiry/"+InpLicense);

      if(expiryCheck=="License has expired")
        {
         MessageBox(expiryCheck+"!");
         ExpertRemove();
        }

      LastExpiryCheckTime = TimeCurrent();

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeOnSignal()
  {


// if(LastMsgID==0)
// IsNewMessage();


   /* for(int i=0; i<ArraySize(TPs); i++)
      {
       Print("TP"+IntegerToString(i+1)+" is "+DoubleToString(TPs[i]));
      }

    Print("Symbol is "+Symbol_Name);
    Print("SL is "+DoubleToString(SL));
    Print("Ordertype is "+IntegerToString(Ordertype));
    Print("Entry is "+DoubleToString(Entry));*/

   int today = GetToday();


   if(InpActivateShutdown)
     {

      if(TimeCurrent() >= CloseDay && TimeCurrent() <= OpenDay)
        {
         Comment("EA is currently shut down. Will resume ",OpenDay);
         return;
        }

      if(TimeCurrent() > OpenDay)
        {
         CloseDay = CloseDay + (7*86400);
         OpenDay  = OpenDay + (7*86400);
         Comment("EA is currently running. Will shutdown on ",CloseDay);
        }
     }

   if(InpApplyNews)
     {
      if(today > LastNewsUpdateDay || today==1)
        {
         Download();

         if(InpShowNews)
            DisplayNews();

         LastNewsUpdateDay = today;
        }
     }


   if(!IsNewMessage())
      return;

 //  StringReplace(Message,Sender,"");


   if(StringLen(Message)>0)
     {



      string lastMsg = "";
      QuotedMsg = "";

      if(StringFind(Message,"|") >= 0)
        {
         string parts[];

         StringSplit(Message,StringGetCharacter("|",0),parts);

         if(ArraySize(parts)==2)
           {
            lastMsg = parts[1];
            QuotedMsg = parts[0];
           }

        }

      else
        {
         lastMsg = Message;
        }

      if(StringFind(lastMsg,"{") >= 0 && StringFind(lastMsg,"}") >= 0)
       lastMsg = StringSubstr(lastMsg,0,StringFind(lastMsg,"{"));

      string sender = GetSender();

      WriteSignals(lastMsg);

      //  Print("Sender was copied as: ",sender);

      bool IsBE = false;
      bool IsPC = false;
      bool IsSLMod = false;
      bool IsTPMod = false;
      bool IsClose = false;

      string lastMsgCopy = lastMsg;

      StringToUpper(lastMsgCopy);

      //BE
      for(int i=0; i<ArraySize(BECmds); i++)
        {
         string cmd = BECmds[i];

         StringTrimLeft(cmd);
         StringTrimRight(cmd);

         StringToUpper(cmd);

         if(StringFind(lastMsgCopy,cmd) >= 0)
           {
            IsBE = true;
            break;
           }
        }

      //PC
      for(int i=0; i<ArraySize(PCCmds); i++)
        {
         string cmd = PCCmds[i];

         StringTrimLeft(cmd);
         StringTrimRight(cmd);


         StringToUpper(cmd);

         if(StringFind(lastMsgCopy,cmd) >= 0)
           {
            IsPC = true;
            break;
           }
        }

      //SL Mod
      for(int i=0; i<ArraySize(SLCmds); i++)
        {
         string cmd = SLCmds[i];

         StringTrimLeft(cmd);
         StringTrimRight(cmd);


         StringToUpper(cmd);

         if(StringFind(lastMsgCopy,cmd) >= 0)
           {
            IsSLMod = true;
            break;
           }
        }

      //TP Mod
      for(int i=0; i<ArraySize(TPCmds); i++)
        {
         string cmd = TPCmds[i];

         StringTrimLeft(cmd);
         StringTrimRight(cmd);


         StringToUpper(cmd);

         if(StringFind(lastMsgCopy,cmd) >= 0)
           {
            IsTPMod = true;
            break;
           }
        }

      //Close
      for(int i=0; i<ArraySize(CloseCmds); i++)
        {
         string cmd = CloseCmds[i];

         StringTrimLeft(cmd);
         StringTrimRight(cmd);


         StringToUpper(cmd);

         if(StringFind(lastMsgCopy,cmd) >= 0 && StringFind(lastMsgCopy,"HALF") < 0 && StringFind(lastMsgCopy,"PARTIAL") < 0)
           {
            IsClose = true;
            break;
           }
        }

      /* Print("Entry message = ",IsEntryMsg());
       Print("Entry price is ",Entry);
       Print("Orderttype is ",Ordertype);
       Print("Array size of Tradetypes is ",ArraySize(TradeTypes));*/

      if(IsEntryMsg() && StringLen(QuotedMsg)==0)
        {
         Print("Signal was received from ",Sender);
         Print("Entry message received.");
         // if(GetQuotedSymbol() != "")
         //  Print("Quoted symbol is: ",GetQuotedSymbol());


         StringToUpper(lastMsg);

         Comment("LAST MESSAGE RECEIVED @ "+TimeToString(TimeCurrent())+" FROM "+Sender+"\n\n"+lastMsg);

         CheckError();

         if(SymbolTotal(Symbol_Name, sEntry)==0)
            OpenTrade();

         /* if(StringLen(Symbol_Name)>0 && Ordertype>=0 && Entry>0 && SL>0 && ArraySize(TPs)>0)
            {
             Print("All trade parameters met. Trading now!.");
            }*/
        }

      else
         if(!IsEntryMsg())//CLOSE AND TRADE MODIFICATION MESSAGES
           {
            //Print("Other message received.");

            // Print("Quoted symbol is ",QSymbol);
            Print("Signal was received from ",Sender);

            StringToUpper(lastMsg);



            if(QuotedMsg != "")//IF MESSAGE IS IN REPLY TO PREVIOUS MESSAGE
              {

               WriteSignals(QuotedMsg);

               if(Symbol_Name=="")
                 {

                  string prevmsg = "";

                  if(FileIsExist("lastmessage.txt"))
                    {
                     int handle = FileOpen("lastmessage.txt",FILE_READ);

                     if(handle==INVALID_HANDLE)
                        Print("Failed to read last message, ",GetLastError());

                     while(!FileIsEnding(handle))
                       {
                        prevmsg += FileReadString(handle);
                       }

                     FileClose(handle);
                    }

                  WriteSignals(prevmsg);

                 }


               if(Symbol_Name=="")//If Symbol could not be extracted from quoted message and previous message
                 {
                  string ticketgroups = "";

                  datetime opentime = 0;

                  for(int i=0; i<OrdersTotal(); i++)
                    {
                     if(OrderSelect(i,SELECT_BY_POS))
                        if(OrderMagicNumber()==InpMagicNumber)
                           if(OrderOpenTime() > opentime)
                              Symbol_Name = OrderSymbol();
                    }

                  string prevmsg = "";

                  if(FileIsExist(Symbol_Name+"_lasttickets.txt"))
                    {

                     int handle = FileOpen(Symbol_Name+"_lasttickets.txt",FILE_READ);

                     if(handle==INVALID_HANDLE)
                        Print("Failed to read last tickets, ",GetLastError());

                     ticketgroups = FileReadString(handle);

                     FileClose(handle);

                    }


                  string parts[];

                  StringSplit(ticketgroups,StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>0)
                    {
                     int ticket = (int)parts[0];

                     if(OrderSelect(ticket,SELECT_BY_TICKET))
                       {

                        string parts2[];

                        StringSplit(OrderComment(),StringGetCharacter(",",0),parts2);

                        if(ArraySize(parts2) > 1)
                          {
                           sEntry = parts2[1];
                          }
                       }
                    }

                 }

               Print("Quoted symbol is ",Symbol_Name);

               /*    Print("===============================");
                   Print("Symbol: ",Symbol_Name);
                   Print("string Entry: ",sEntry);
                   Print("Stop Loss: ",SL);
                   for(int i=0; i<ArraySize(TPs); i++)
                     {
                      Print("Take Profit: ",TPs[i]);
                     }
                   Print("===============================");*/

               Comment("LAST MESSAGE RECEIVED @ "+TimeToString(TimeCurrent())+" FROM "+Sender+"\n\n"+lastMsg+"\n\nIN REPLY TO "+Symbol_Name+" TRADE");

               if(IsBE)
                  Breakeven(Symbol_Name, sEntry);

               if(StringFind(lastMsg,"REMOVE SL")>=0)
                  RemoveSL(Symbol_Name,sEntry);

               if(IsClose)
                 {
                  Print("Attempted to close ",Symbol_Name);
                  // while(SymbolTotal(Symbol_Name, sEntry) > 0)
                  CloseTrade(Symbol_Name,sEntry);
                 }

               if(IsPC)
                 {
                  // while(SymbolTotal(Symbol_Name) > 0)
                  Print("Attempted partial close.");
                  CloseHalf(Symbol_Name,sEntry);
                 }

               if(GetNewSL(lastMsg,IsSLMod) != 0)
                 {
                  ChangeSL(Symbol_Name,sEntry,GetNewSL(lastMsg,IsSLMod));
                  Print("SL changed to: ",GetNewSL(lastMsg, IsSLMod));
                 }




               if(GetNewTP1(lastMsg, IsTPMod) != 0)
                 {
                  ChangeTP1(Symbol_Name,sEntry,GetNewTP1(lastMsg, IsTPMod),lastMsg);
                  Print("TP1 changed to: ",GetNewTP1(lastMsg, IsTPMod));
                 }




               if(GetNewTP2(lastMsg) != 0)
                 {
                  ChangeTP2(Symbol_Name,sEntry,GetNewTP2(lastMsg));
                  Print("TP2 changed to: ",GetNewTP2(lastMsg));
                 }

               if(GetNewTP3(lastMsg) != 0)
                 {
                  ChangeTP3(Symbol_Name,sEntry,GetNewTP3(lastMsg));
                  Print("TP3 changed to: ",GetNewTP3(lastMsg));
                 }



               // ChangeTP(Symbol_Name,sEntry);

               if(StringFind(lastMsg,"CLOSE TP1")>=0)
                  CloseTP1(Symbol_Name,sEntry);

               if(StringFind(lastMsg,"CLOSE TP2")>=0)
                 {
                  CloseTP2(Symbol_Name,sEntry);
                  //CloseTP3(Symbol_Name,sEntry);
                 }


               if(StringFind(lastMsg,"CLOSE TP3")>=0)
                 {
                  CloseTP3(Symbol_Name,sEntry);
                  //CloseTP2(Symbol_Name,sEntry);
                  //CloseTP1(Symbol_Name, sEntry);
                 }


              }


            else
               if(QuotedMsg=="")//If message is not in reply to any previous message
                 {

                  WriteSignals(lastMsg);

                  if(Symbol_Name=="")//If symbol could not be extracted from last message, symbol is last message symbol
                    {

                     string prevmsg = "";

                     if(FileIsExist("lastmessage.txt"))
                       {
                        int handle = FileOpen("lastmessage.txt",FILE_READ);

                        if(handle==INVALID_HANDLE)
                           Print("Failed to read last message, ",GetLastError());

                        while(!FileIsEnding(handle))
                          {
                           prevmsg += FileReadString(handle);
                          }

                        FileClose(handle);
                       }


                     WriteSignals(prevmsg);

                    }




                  if(Symbol_Name=="")//if symbol could not be extracted from last message text file, symbol is last opened symbol
                    {
                     string ticketgroups = "";

                     datetime opentime = 0;

                     for(int i=0; i<OrdersTotal(); i++)
                       {
                        if(OrderSelect(i,SELECT_BY_POS))
                           if(OrderMagicNumber()==InpMagicNumber)
                              if(OrderOpenTime() > opentime)
                                 Symbol_Name = OrderSymbol();
                       }

                    }


                  //TAKE THE TRADES
                  Comment("LAST MESSAGE RECEIVED @ "+TimeToString(TimeCurrent())+" FROM "+Sender+"\n\n"+lastMsg+"\n\nIN REPLY TO "+Symbol_Name+" TRADE");

                  if(IsBE)
                     Breakeven(Symbol_Name, sEntry);

                  if(StringFind(lastMsg,"REMOVE SL")>=0)
                     RemoveSL(Symbol_Name,sEntry);

                  if(IsClose)
                    {
                     Print("Attempted to close ",Symbol_Name);
                     // while(SymbolTotal(Symbol_Name, sEntry) > 0)
                     CloseTrade(Symbol_Name,sEntry);
                    }

                  if(IsPC)
                    {
                     // while(SymbolTotal(Symbol_Name) > 0)
                     Print("Attempted partial close.");
                     CloseHalf(Symbol_Name,sEntry);
                    }

                  if(GetNewSL(lastMsg, IsSLMod) != 0)
                    {
                     ChangeSL(Symbol_Name,sEntry,GetNewSL(lastMsg,IsSLMod));
                     Print("SL changed to: ",GetNewSL(lastMsg, IsSLMod));
                    }




                  if(GetNewTP1(lastMsg, IsTPMod) != 0)
                    {
                     ChangeTP1(Symbol_Name,sEntry,GetNewTP1(lastMsg, IsTPMod),lastMsg);
                     Print("TP1 changed to: ",GetNewTP1(lastMsg, IsTPMod));
                    }




                  if(GetNewTP2(lastMsg) != 0)
                    {
                     ChangeTP2(Symbol_Name,sEntry,GetNewTP2(lastMsg));
                     Print("TP2 changed to: ",GetNewTP2(lastMsg));
                    }

                  if(GetNewTP3(lastMsg) != 0)
                    {
                     ChangeTP3(Symbol_Name,sEntry,GetNewTP3(lastMsg));
                     Print("TP3 changed to: ",GetNewTP3(lastMsg));
                    }



                  // ChangeTP(Symbol_Name,sEntry);

                  if(StringFind(lastMsg,"CLOSE TP1")>=0)
                     CloseTP1(Symbol_Name,sEntry);

                  if(StringFind(lastMsg,"CLOSE TP2")>=0)
                    {
                     CloseTP2(Symbol_Name,sEntry);
                     //CloseTP3(Symbol_Name,sEntry);
                    }


                  if(StringFind(lastMsg,"CLOSE TP3")>=0)
                    {
                     CloseTP3(Symbol_Name,sEntry);
                     //CloseTP2(Symbol_Name,sEntry);
                     //CloseTP1(Symbol_Name, sEntry);
                    }

                 }




           }


      int handle = FileOpen("lastmessage.txt",FILE_WRITE);

      if(handle==INVALID_HANDLE)
         Print("Failed to write last message, ",GetLastError());

      FileWriteString(handle,lastMsg);
      FileClose(handle);
     }

   if(InpDynamicSL)
      ModifySL();

   if(InpCloseOnDD)
      CloseOnDD();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {



  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetFirstBreak(string text)
  {

   char tta[];

   StringToCharArray(text,tta);

   for(int i=0; i<ArraySize(tta); i++)
     {
      string current = CharToString(tta[i]);
      if(StringGetCharacter(current,0) == StringGetCharacter("\n",0))
         return i;
     }

   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TradesTotal()
  {

   int cnt = 0;

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderMagicNumber()==InpMagicNumber)
            cnt++;
     }

   return cnt;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void savedata()
  {
   int total = ArraySize(TicketTPs);
   if(total>0)
     {
      if(total==1)
         TicketTP1 = TicketTPs[0];

      if(total==2)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
        }

      if(total==3)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
        }

      if(total==4)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
        }

      if(total==5)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
         TicketTP5 = TicketTPs[4];
        }

      if(total==6)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
         TicketTP5 = TicketTPs[4];
         TicketTP6 = TicketTPs[5];

        }

      if(total==7)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
         TicketTP5 = TicketTPs[4];
         TicketTP6 = TicketTPs[5];
         TicketTP7 = TicketTPs[6];

        }

      if(total==8)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
         TicketTP5 = TicketTPs[4];
         TicketTP6 = TicketTPs[5];
         TicketTP7 = TicketTPs[6];
         TicketTP8 = TicketTPs[7];
        }

      if(total==9)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
         TicketTP5 = TicketTPs[4];
         TicketTP6 = TicketTPs[5];
         TicketTP7 = TicketTPs[6];
         TicketTP8 = TicketTPs[7];
         TicketTP9 = TicketTPs[8];
        }

      if(total==10)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
         TicketTP5 = TicketTPs[4];
         TicketTP6 = TicketTPs[5];
         TicketTP7 = TicketTPs[6];
         TicketTP8 = TicketTPs[7];
         TicketTP9 = TicketTPs[8];
         TicketTP10 = TicketTPs[9];
        }


      int handle = FileOpen("donovantps.csv",FILE_WRITE|FILE_CSV);
      if(handle==INVALID_HANDLE)
        {Print("invalid handle"); return;}
      else
        {

         FileWrite(handle,TicketTP1);
         FileWrite(handle,TicketTP2);
         FileWrite(handle,TicketTP3);
         FileWrite(handle,TicketTP4);
         FileWrite(handle,TicketTP5);
         FileWrite(handle,TicketTP6);
         FileWrite(handle,TicketTP7);
         FileWrite(handle,TicketTP8);
         FileWrite(handle,TicketTP9);
         FileWrite(handle,TicketTP10);
         FileClose(handle);

        }
     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getdata()
  {

   int handle = FileOpen("donovantps.csv",FILE_READ|FILE_CSV);
   if(handle==INVALID_HANDLE)
     {Print("invalid handle"); return;}
   else
     {

      TicketTP1 = FileReadString(handle);
      TicketTP2 = FileReadString(handle);
      TicketTP3 = FileReadString(handle);
      TicketTP4 = FileReadString(handle);
      TicketTP5 = FileReadString(handle);
      TicketTP6 = FileReadString(handle);
      TicketTP7 = FileReadString(handle);
      TicketTP8 = FileReadString(handle);
      TicketTP9 = FileReadString(handle);
      TicketTP10 = FileReadString(handle);

      FileClose(handle);
      FileDelete("donovantps.csv");

      ArrayFree(TicketTPs);
      ArrayResize(TicketTPs,10,0);

      TicketTPs[0] = TicketTP1;
      TicketTPs[1] = TicketTP2;
      TicketTPs[2] = TicketTP3;
      TicketTPs[3] = TicketTP4;
      TicketTPs[4] = TicketTP5;
      TicketTPs[5] = TicketTP6;
      TicketTPs[6] = TicketTP7;
      TicketTPs[7] = TicketTP8;
      TicketTPs[8] = TicketTP9;
      TicketTPs[9] = TicketTP10;
      // TicketTPs = {TicketTP1,TicketTP2,TicketTP3,TicketTP4,TicketTP5,TicketTP6,TicketTP7,TicketTP8,TicketTP9,TicketTP10};

     }


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetQuotedSymbol()
  {

   int timeout = 2000;

   string lastMsg = "";

   string url = baseurl+"/bot"+token+"/getUpdates?offset="+(string)LastMsgID;

   resu = WebRequest("GET",url,cookie,NULL,timeout,post,0,results,headers);

   string msg = CharArrayToString(results);

   int text_begin = 0;

   for(int i=ArraySize(results)-1; i>=0; i--)
     {
      if(CharToString(results[i])=="t" && CharToString(results[i+1])=="e" && CharToString(results[i+2])=="x" && CharToString(results[i+3])=="t")
        {
         text_begin = i;
         break;
        }
     }

   for(int i=text_begin-1; i>=0; i--)
     {
      if(CharToString(results[i])=="t" && CharToString(results[i+1])=="e" && CharToString(results[i+2])=="x" && CharToString(results[i+3])=="t")
        {
         lastMsg = StringSubstr(msg,i,(StringLen(msg)-text_begin)-2);

         int rep = StringReplace(lastMsg,"text\":\"","");
         rep     += StringReplace(lastMsg,"]","");
         rep     += StringReplace(lastMsg,"}","");
         rep     += StringReplace(lastMsg,"\"","");
         rep     += StringReplace(lastMsg,"\\"+"n"," ");
         break;
        }
     }


   return GetSymbol(lastMsg);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetLastMessage()
  {
   QuotedMsg = "";

   QSymbol = "";

   int timeout = 2000;

   string lastMsg = "";

   string url = baseurl+"/bot"+token+"/getUpdates?offset="+(string)LastMsgID;

   resu = 0;

   int numOfTries = 0;

   while(resu != 200 && numOfTries < InpConnRetry)
     {
      resu = WebRequest("GET",url,cookie,NULL,timeout,post,0,results,headers);
      numOfTries++;
     }

   if(numOfTries==10 && resu != 200)
     {
      Comment("Failed to get last message due to connection error ",resu);
      return "";
     }

   Print("Connection request for last message succesful, status code = ",resu);


   string msg = CharArrayToString(results);



// Print(StringSubstr(msg,StringLen(msg)-500,StringLen(msg)));

   int text_begin = 0;

   if(StringFind(msg,"\"photo\":") < 0)
     {

      for(int i=ArraySize(results)-5; i>=0; i--)
        {
         if(CharToString(results[i])=="t" && CharToString(results[i+1])=="e" && CharToString(results[i+2])=="x" && CharToString(results[i+3])=="t")
           {
            text_begin = i;
            break;
           }
        }

      lastMsg = StringSubstr(msg,text_begin,StringLen(msg)-1);

      int rep = StringReplace(lastMsg,"text\":\"","");
      rep     += StringReplace(lastMsg,"]","");
      rep     += StringReplace(lastMsg,"}","");
      rep     += StringReplace(lastMsg,"\"","");
      rep     += StringReplace(lastMsg,"\\"+"n"," ");

      for(int i=text_begin-5; i>=0; i--)
        {
         if(CharToString(results[i])=="t" && CharToString(results[i+1])=="e" && CharToString(results[i+2])=="x" && CharToString(results[i+3])=="t")
           {
            string quoted = StringSubstr(msg,i+4,text_begin-i);

            StringToUpper(quoted);

            if(StringLen(QuotedMsg)==0)
              {

               QuotedMsg = quoted;

               rep      = StringReplace(QuotedMsg,"TEXT","");
               rep     += StringReplace(QuotedMsg,"]","");
               rep     += StringReplace(QuotedMsg,"}","");
               rep     += StringReplace(QuotedMsg,"\"","");
               rep     += StringReplace(QuotedMsg,"\\"+"n"," ");


              }


            for(int j=0; j<SymbolsTotal(true); j++)
              {
               string name = SymbolName(j,true);

               for(int k=0; k<StringLen(quoted); k++)
                 {
                  string check = "";
                  string cleanmsg = quoted;
                  StringReplace(cleanmsg,"/","");
                  check = StringSubstr(cleanmsg,k,StringLen(name));

                  for(int l=0; l<ArraySize(OtherSymbols); l++)
                    {
                     if(StringFind(check,OtherSymbols[l])>=0)
                        check = OtherSymbols[l];
                    }

                  if(check==name || VerifiedSymbol(check)==name)
                    {
                     QSymbol = name;
                     break;
                    }

                 }

              }
           }
        }

     }


   else
      if(StringFind(msg,"\"photo\":") >= 0)
        {
         for(int i=ArraySize(results)-5; i>=0; i--)
           {
            if(CharToString(results[i])=="t" && CharToString(results[i+1])=="e" && CharToString(results[i+2])=="x" && CharToString(results[i+3])=="t")
              {
               text_begin = i;
               break;
              }
           }

         QuotedMsg = StringSubstr(msg,text_begin,StringLen(msg)-1);

         int rep = StringReplace(QuotedMsg,"TEXT\":\"","");
         rep     += StringReplace(QuotedMsg,"]","");
         rep     += StringReplace(QuotedMsg,"}","");
         rep     += StringReplace(QuotedMsg,"\"","");
         rep     += StringReplace(QuotedMsg,"\\"+"n"," ");

         StringToUpper(QuotedMsg);

         QuotedMsg = StringSubstr(QuotedMsg,5,StringFind(QuotedMsg,",PHOTO"));

         int handle = FileOpen("msgtest.csv",FILE_WRITE|FILE_CSV);

         FileWriteString(handle,QuotedMsg);
         FileClose(handle);

         int findcaption = StringFind(msg,"\"caption\"");
         int length      = (StringLen(msg)-1)-findcaption;

         lastMsg = StringSubstr(msg,findcaption,length);

         rep = StringReplace(lastMsg,"\"caption\":\"","");
         rep     += StringReplace(lastMsg,"]","");
         rep     += StringReplace(lastMsg,"}","");
         rep     += StringReplace(lastMsg,"\"","");
         rep     += StringReplace(lastMsg,"\\"+"n"," ");
        }


// LastMsgID = GetLastMsgID();

// Comment(LastMsgID);

   return(lastMsg);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetSender()
  {

   QSymbol = "";

   int timeout = 2000;

   string lastMsg = "";

   string url = baseurl+"/bot"+token+"/getUpdates?offset="+(string)LastMsgID;

   resu = WebRequest("GET",url,cookie,NULL,timeout,post,0,results,headers);

   string msg = CharArrayToString(results);

   int begin = StringFind(msg,"forward_from_chat");
   int end = StringFind(msg,"forward_from_message_id");

   string sender = StringSubstr(msg,begin,end-begin);

   int begin2 = StringFind(sender,"title");
   int end2 = StringFind(sender,"username");

   sender = StringSubstr(sender,begin2,end2-begin2);

   int rep = StringReplace(sender,"title\":\"","");
   rep     += StringReplace(sender,"]","");
   rep     += StringReplace(sender,"}","");
   rep     += StringReplace(sender,"\"","");
   rep     += StringReplace(sender,"\\"+"n"," ");
   rep     += StringReplace(sender,","," ");

   int cut = StringFind(sender,"type",0);

   if(cut > 0)
      sender = StringSubstr(sender,0,cut);

//Print("Sender was: ",sender);


   return(msg);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetLastMsgID()
  {

   int timeout = 2000;

   string lastMsg = "";

   string url = baseurl+"/bot"+token+"/getUpdates";

   resu = 0;

   int numOfTries = 0;

   while(resu != 200 && numOfTries < InpConnRetry)
     {
      resu = WebRequest("GET",url,cookie,NULL,timeout,post,0,results,headers);
      numOfTries++;
     }

   if(numOfTries==10 && resu != 200)
     {
      Comment("Failed to get last message due to connection error ",resu);
      return -1;
     }

// Print("Connection request for last message succesful, status code = ",resu);


   string msg = CharArrayToString(results);



   int text_begin = 0;

   for(int i=ArraySize(results)-1; i>=0; i--)
     {
      if(CharToString(results[i])=="u" && CharToString(results[i+1])=="p" && CharToString(results[i+2])=="d" && CharToString(results[i+3])=="a" && CharToString(results[i+4])=="t"
         && CharToString(results[i+5])=="e")
        {
         text_begin = i;
         break;
        }
     }

   lastMsg = StringSubstr(msg,text_begin,20);

   int rep = StringReplace(lastMsg,"update_id\":","");
   StringTrimLeft(lastMsg);
   StringTrimRight(lastMsg);


   return((int)lastMsg);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewMessage()
  {

   string data = Request("getsignal");

//Print(data);

   if(Message != data)
     {
      Print(data);
      string tempmsg = data;
      StringToUpper(tempmsg);

      Message = data;
      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteSignals(string msg)
  {

   Symbol_Name = "";
   sEntry = "";
   Ordertype = -1;
   Entry = 0;
   SL = 0;
   ArrayFree(TPs);

   StringToUpper(msg);

   int repmsg = 0;


   if(StringFind(msg,"TAKEPROFIT",0)>=0)
      repmsg += StringReplace(msg,"TAKEPROFIT","TP");

   if(StringFind(msg,"TAKE PROFIT 1",0)>=0)
      repmsg += StringReplace(msg,"TAKE PROFIT 1","TP");

   if(StringFind(msg,"TAKE PROFIT 2",0)>=0)
      repmsg += StringReplace(msg,"TAKE PROFIT 2","TP");

   if(StringFind(msg,"TAKE PROFIT 3",0)>=0)
      repmsg += StringReplace(msg,"TAKE PROFIT 3","TP");

   if(StringFind(msg,"TAKE PROFIT 4",0)>=0)
      repmsg += StringReplace(msg,"TAKE PROFIT 4","TP");

   if(StringFind(msg,"STOPLOSS",0)>=0)
      repmsg += StringReplace(msg,"STOPLOSS","SL");

   if(StringFind(msg,"STOP LOSS",0)>=0)
      repmsg += StringReplace(msg,"STOP LOSS","SL");

   if(StringFind(msg,"TAKE PROFIT",0)>=0)
      repmsg += StringReplace(msg,"TAKE PROFIT","TP");

   if(StringFind(msg,"TP1",0)>=0)
      repmsg += StringReplace(msg,"TP1","TP");

   if(StringFind(msg,"TP2",0)>=0)
      repmsg += StringReplace(msg,"TP2","TP");

   if(StringFind(msg,"TP3",0)>=0)
      repmsg += StringReplace(msg,"TP3","TP");

   if(StringFind(msg,"TP4",0)>=0)
      repmsg += StringReplace(msg,"TP4","TP");

   if(StringFind(msg,"TP5",0)>=0)
      repmsg += StringReplace(msg,"TP5","TP");

   if(StringFind(msg,"TP6",0)>=0)
      repmsg += StringReplace(msg,"TP6","TP");


   if(StringFind(msg,"TP 1:",0)>=0)
      repmsg += StringReplace(msg,"TP 1:","TP:");

   if(StringFind(msg,"TP 2:",0)>=0)
      repmsg += StringReplace(msg,"TP 2:","TP:");

   if(StringFind(msg,"TP 3:",0)>=0)
      repmsg += StringReplace(msg,"TP 3:","TP:");

   if(StringFind(msg,"TP 4:",0)>=0)
      repmsg += StringReplace(msg,"TP 4:","TP:");

   if(StringFind(msg,"TP 5:",0)>=0)
      repmsg += StringReplace(msg,"TP 5:","TP:");

   if(StringFind(msg,"TP 6:",0)>=0)
      repmsg += StringReplace(msg,"TP 6:","TP:");

   if(StringFind(msg,"TP 1 ",0)>=0)
      repmsg += StringReplace(msg,"TP 1 ","TP");

   if(StringFind(msg,"TP 2 ",0)>=0)
      repmsg += StringReplace(msg,"TP 2 ","TP");

   if(StringFind(msg,"TP 3 ",0)>=0)
      repmsg += StringReplace(msg,"TP 3 ","TP");

   if(StringFind(msg,"TP 4 ",0)>=0)
      repmsg += StringReplace(msg,"TP 4 ","TP");

   if(StringFind(msg,"TP 5 ",0)>=0)
      repmsg += StringReplace(msg,"TP 5 ","TP");

   if(StringFind(msg,"TP 6 ",0)>=0)
      repmsg += StringReplace(msg,"TP 6 ","TP");

// repmsg += StringReplace(msg," ","");

   repmsg += StringReplace(msg,"@","");

   StringReplace(msg,"-","");

// Comment(msg);

// Print("Processed message ",msg);

   int tplocs[];
   int slloc = -1;

   char msgToArray[];

   StringToCharArray(msg,msgToArray,0); //Conver string to char array for easy loop

   for(int i=0; i<ArraySize(msgToArray); i++)
     {
      if(!IsFound(CharToString(msgToArray[i]),PriceChars) && !IsFound(CharToString(msgToArray[i]),Letters) && !IsFound(CharToString(msgToArray[i]),LETTERS))
         repmsg += StringReplace(msg,CharToString(msgToArray[i]),"");
     }


   /*  for(int i=0;i<ArraySize(msgToArray);i++)
       {
         if( !IsFound(CharToString(msgToArray[i]), PriceChars) && !IsFound(CharToString(msgToArray[i]), Letters) && !IsFound(CharToString(msgToArray[i]), LETTERS) && msgToArray[i]!='\n' && msgToArray[i]!=' ')
           StringReplace(msg,CharToString(msgToArray[i]),"");

         Print("Cleaned message: ",msg);
       } */

//Get TP locations
   for(int i=1; i<ArraySize(msgToArray); i++)
     {

      if((CharToString(msgToArray[i])=="P" && CharToString(msgToArray[i-1])=="T"))  //Find any TP strings in message
        {
         ArrayResize(tplocs,ArraySize(tplocs)+1,0);
         tplocs[ArraySize(tplocs)-1] = i-1;//Save all TP string locations into an array
        }

     }

//Get SL Location
   for(int i=1; i<ArraySize(msgToArray); i++)
     {


      if((CharToString(msgToArray[i])=="L" && CharToString(msgToArray[i-1])=="S"))//Find any SL strings in message
        {
         slloc = i-1;
         break;
         // Print(IntegerToString(slloc));
        }


     }

   if(ArraySize(tplocs) > 0)  //Assign only if there is TP in message
     {
      ArrayFree(TPs);

      for(int j=0; j<ArraySize(tplocs); j++)//For each TP location, find the adjacent price value
        {
         string tp = "";

         // Print("========================");

         for(int i=tplocs[j]+2; i<ArraySize(msgToArray); i++)//for a particular TP location, up to the end of the msg string, find the corresponding price
           {
            string this_char = CharToString(msgToArray[i]);

            if(this_char==" " || this_char=="  " || this_char==":")
               continue;

            if(this_char=="." && StringLen(tp)==0)
               continue;

            if(IsFound(this_char,PriceChars))
              {
               tp += this_char;
               // Print("Added ",this_char);
              }

            if(!IsFound(this_char,PriceChars) && StringLen(tp)>0)
               break;
           }

         //   Print("========================");

         if(tp == "")
            tp = "OPEN";

         StringTrimLeft(StringTrimRight(tp));
         // Print("TP",tplocs[j]+1," ",tp

         if(StringToDouble(tp) != 0 && tp != "OPEN")
           {

            ArrayResize(TPs,ArraySize(TPs)+1,0);
            TPs[ArraySize(TPs)-1] = StringToDouble(tp);//Save the TP prices extracted into an array o TP

           }

         else
            if(tp == "OPEN")
              {

               ArrayResize(TPs,ArraySize(TPs)+1,0);
               TPs[ArraySize(TPs)-1] = 0;//Save the TP prices extracted into an array o TP

              }

        }

      for(int i=0; i<ArraySize(TPs); i++)
        {
         Print("TP "+IntegerToString(i)+" is "+DoubleToString(TPs[i]));
        }

     }



//Extract SL
   string sl = "";

   if(slloc >= 0)
     {
      SL = 0;

      for(int i=slloc+2; i<ArraySize(msgToArray); i++)
        {

         string this_char = CharToString(msgToArray[i]);

         if(this_char==" " || this_char=="  " || this_char==":")
            continue;

         if(this_char=="." && StringLen(sl)==0)
            continue;

         if(IsFound(this_char,PriceChars))
            sl += this_char;

         if(!IsFound(this_char,PriceChars) && StringLen(sl)>0)
            break;
        }
      StringTrimLeft(StringTrimRight(sl));
      //Print("SL string was ",sl);
      SL = StringToDouble(sl);
      Print("Stop Loss is "+DoubleToString(SL));
     }





//Extract Symbol
   string tempmsg = msg;


   string symbol = "";




   if(symbol=="")
     {
      for(int j=0; j<SymbolsTotal(true); j++)
        {
         string check = "";
         string name = SymbolName(j,true);

         if(StringLen(name)<3)
            continue;

         string cleanmsg = msg;
         StringReplace(cleanmsg,"/","");

         if(StringFind(cleanmsg,name)>=0)
           {
            StringReplace(tempmsg,name,"");
            symbol = name;
            break;
           }

         else
           {
            StringReplace(name,InpBrokerSuffix,"");

            if(StringFind(cleanmsg,name)>=0)
              {
               StringReplace(tempmsg,name,"");
               symbol = name+InpBrokerSuffix;
               break;
              }
           }
        }
     }

   if(symbol=="")
     {
      for(int i=0; i<ArraySize(BrokerNames); i++)
        {

         string parts[];

         StringSplit(BrokerNames[i],StringGetCharacter("=",0),parts);

         if(ArraySize(parts) == 0)
            continue;

         StringToUpper(parts[0]);

         if(StringFind(msg,parts[0]) >= 0)
           {
            StringReplace(tempmsg,parts[0],"");
            symbol = parts[1];

            break;
           }
        }
     }

   /* if(symbol=="")
      {

       for(int i=0; i<ArraySize(OtherSymbols); i++)
         {
          string cleanmsg = msg;
          StringReplace(cleanmsg,"/","");

          if(StringFind(cleanmsg,OtherSymbols[i])>=0)
            {
             symbol = VerifiedSymbol(OtherSymbols[i]);
             break;
            }
         }

      }

    if(symbol=="")
      {
       string sigsyms[];

       AddToArray(sigsyms,InpSigGoldName);
       AddToArray(sigsyms,InpSigNasName);
       AddToArray(sigsyms,InpSigUS30Name);

       for(int i=0; i<ArraySize(sigsyms); i++)
         {
          string cleanmsg = msg;
          StringReplace(cleanmsg,"/","");

          if(StringFind(cleanmsg,sigsyms[i])>=0)
            {
             symbol = VerifiedSymbol(sigsyms[i]);
             break;
            }
         }
      }*/



   Symbol_Name = symbol;
   Print("Symbol name is: ",Symbol_Name);

//Extract OT
   int symloc = 0;

   string tempmsg2 = msg;
   StringToUpper(tempmsg2);

   for(int i=ArraySize(TradeTypes)-1; i>=0; i--)
     {
      string type = TradeTypes[i];


      StringTrimLeft(type);
      StringTrimRight(type);

      StringToUpper(type);

      if(StringFind(tempmsg2,type,0)>=0)
        {

         Ordertype = StringToOrdertype(type);

         if(Ordertype==0 && StringFind(msg,"LIMIT") >= 0)
            Ordertype = 2;

         if(Ordertype==1 && StringFind(msg,"LIMIT") >= 0)
            Ordertype = 3;

         if(Ordertype==0 && (StringFind(msg,"BUYSTOP") >= 0 || StringFind(msg,"BUY STOP") >= 0))
            Ordertype = 4;

         if(Ordertype==1 && (StringFind(msg,"SELLSTOP") >= 0 || StringFind(msg,"SELL STOP") >= 0))
            Ordertype = 5;

         Print("Ordertype is "+type);
         break;
        }

     }


//Extract Entry
   if(Ordertype >= 0 && StringLen(Symbol_Name)>0)
     {
      Entry = 0;
      Entry = GetEntry(Ordertype,Symbol_Name, sl, tempmsg);
      Print("Entry is "+DoubleToString(Entry));
     }


// Comment(Symbol_Name,"TP1: ",TP1,"TP2: ",TP2,"TP3: ",TP3,"SL: ",SL)

  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ReadSignals()
  {





  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsFound(string value, string &array[])
  {

   for(int i=0; i<ArraySize(array); i++)
     {
      if(value == array[i])
         return(true);
     }

   return(false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsFound(double value, double &array[])
  {

   for(int i=0; i<ArraySize(array); i++)
     {
      if(value == array[i])
         return(true);
     }

   return(false);
  }
//+------------------------------------------------------------------+
int StringToOrdertype(string ot)
  {

   if(ot=="BUY")
      return(OP_BUY);

   if(ot=="SELL")
      return(OP_SELL);

   if(ot=="BUY STOP" || ot=="BUYSTOP" || ot=="STOP BUY" || ot=="STOPBUY")
      return(OP_BUYSTOP);

   if(ot=="BUY LIMIT" || ot=="BUYLIMIT" || ot=="LIMIT BUY" || ot=="LIMITBUY")
      return(OP_BUYLIMIT);

   if(ot=="SELL STOP" || ot=="SELLSTOP" || ot=="STOP SELL" || ot=="STOPSELL")
      return(OP_SELLSTOP);

   if(ot=="SELL LIMIT" || ot=="SELLLIMIT" || ot=="LIMIT SELL" || ot=="LIMITSELL")
      return(OP_SELLLIMIT);

   return(-1);
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetEntry(int ot, string sym, string sl, string msg="")
  {

   sEntry = "";

   double entry = 0;



   StringToUpper(msg);

   StringReplace(msg," ","");

   int repmsg = 0;


   if(StringFind(msg,"TAKEPROFIT",0)>=0)
      repmsg += StringReplace(msg,"TAKEPROFIT","TP");

   if(StringFind(msg,"STOPLOSS",0)>=0)
      repmsg += StringReplace(msg,"STOPLOSS","SL");

   if(StringFind(msg,"STOP LOSS",0)>=0)
      repmsg += StringReplace(msg,"STOP LOSS","SL");

   if(StringFind(msg,"TAKE PROFIT",0)>=0)
      repmsg += StringReplace(msg,"TAKE PROFIT","TP");

   if(StringFind(msg,"TP1",0)>=0)
      repmsg += StringReplace(msg,"TP1","TP");

   if(StringFind(msg,"TP2",0)>=0)
      repmsg += StringReplace(msg,"TP2","TP");

   if(StringFind(msg,"TP3",0)>=0)
      repmsg += StringReplace(msg,"TP3","TP");

   repmsg += StringReplace(msg," ","");

   repmsg += StringReplace(msg,"@","");

   int begin = 0;

   int end   = 0;

   int slbegin = StringFind(msg,"SL");

   int tpbegin = StringFind(msg,"TP");

   end = (int)MathMin(slbegin, tpbegin);

   bool isRelative = StringFind(StringSubstr(msg,0,end),"AREA") >= 0 ? true : false;

   string ent = "";

   char msgToArr[];

   StringToCharArray(msg,msgToArr,0,end);

   for(int i=0; i<ArraySize(msgToArr); i++)
     {
      if(IsFound(CharToString(msgToArr[i]),PriceChars))
         ent += CharToString(msgToArr[i]);
     }




   StringTrimLeft(StringTrimRight(ent));

   string tocut = StringSubstr(ent,0,StringLen(ent)-StringLen(sl));

// Print("String to cut = ",tocut);

   if(StringLen(ent) > StringLen(sl))
      StringReplace(ent, tocut, "");

//  Print("Entry price should be: ",ent);
// Print("SL string should be: ",sl);

   sEntry = ent;

   if(!isRelative)
      entry = StringToDouble(ent);

   else
      if(isRelative)
        {
         StringTrimLeft(StringTrimRight(tocut));
         entry = (StringToDouble(tocut)+StringToDouble(ent))/2;
        }

   if(ot==0)
      return(SymbolInfoDouble(sym,SYMBOL_ASK));

   else
      if(ot==1)
         return(SymbolInfoDouble(sym,SYMBOL_BID));

      else
         return(entry);

   return(0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsSymbolFound(string sym)
  {

   for(int i=0; i<SymbolsTotal(true); i++)
     {
      string name   = SymbolName(i,true);
      string firstletter = StringSubstr(sym,0,1);
      string rest        = StringSubstr(sym,1,StringLen(sym)-1);
      bool firsttoupper = StringToUpper(firstletter);
      bool resttolower  = StringToLower(rest);

      sym = firstletter+rest;
      if(sym==name)
         return(true);


      bool symtoupper = StringToUpper(sym);
      bool nametoupper = StringToUpper(name);

      if(sym==name)
         return(true);
     }
   return(false);
  }


//+------------------------------------------------------------------+
bool IsNews(string symbol)
  {

   string today = TimeToString(TimeCurrent(),TIME_DATE);

   string parts[];

   StringSplit(today,StringGetCharacter(".",0),parts);

   if(ArraySize(parts) == 0)
      return false;

   today = "";

   today += parts[1]+"-"+parts[2]+"-"+parts[0];


   bool check = false;

   string symcopy = symbol;
   int    len     = StringLen(symcopy);

   string curr1 = StringSubstr(symcopy,0,(int)len/2);
   string curr2 = StringSubstr(symcopy,(int)len/2,(int)len/2);

   if(StringFind(symbol,InpUS30Name) >= 0 || StringFind(symbol,InpNasName) >= 0)
     {
      curr1 = "USD";
      curr2 = "USD";
     }

   if(StringFind(symbol,"DAX") >= 0 || StringFind(symbol,"FRA") >= 0)
     {
      curr1 = "EUR";
      curr2 = "EUR";
     }

   if(StringFind(symbol,"JAP") >= 0)
     {
      curr1 = "JPY";
      curr2 = "JPY";
     }

   if(StringFind(symbol,"AUS") >= 0)
     {
      curr1 = "AUD";
      curr2 = "AUD";
     }

//Print("Currency 1 is ",curr1);
//Print("Currency 2 is ",curr2);

   int handle = FileOpen("News.csv",FILE_READ);

   if(handle==INVALID_HANDLE)
     {
      Print("Failed to read news file.");
      return false;
     }

   while(!FileIsEnding(handle))
     {
      string line = FileReadString(handle);

      StringToUpper(line);
      StringToUpper(curr1);
      StringToUpper(curr2);

      string newssplit[];

      StringSplit(line,StringGetCharacter(",",0),newssplit);

      if(ArraySize(newssplit)==0)
         return false;

      string newstime = TimeToString(TimeCurrent(),TIME_DATE)+" "+TimeTo24h(newssplit[3]);

      datetime nt2d = StringToTime(newstime);

      nt2d = nt2d+TimezoneOffsetSecs;

      bool checkhigh   = InpHighImpact==true ? (StringFind(line,"HIGH") >= 0 || StringFind(line,"High") >= 0) : false;
      bool checkmedium = InpMediumImpact==true ? (StringFind(line,"MEDIUM") >= 0 || StringFind(line,"Medium") >= 0) : false;
      bool checklow    = InpLowImpact==true ? (StringFind(line,"LOW") >= 0 || StringFind(line,"Low") >= 0) : false;

      if((StringFind(line,curr1) >= 0 || StringFind(line,curr2) >= 0 || StringFind(line,"ALL") >= 0) && StringFind(line,today) >= 0 && (checkhigh || checklow || checkmedium))
        {
         string curr = StringFind(line,curr1) >= 0 ? curr1 : curr2;

         if(InpUseNewsFilter)
           {
            if(checkhigh)
               Print("High impact news found today for ",curr," = ",newssplit[0]," @ ",nt2d);

            if(checkmedium)
               Print("Medium impact news found today for ",curr," = ",newssplit[0]," @ ",nt2d);

            if(checklow)
               Print("Low impact news found today for ",curr," = ",newssplit[0]," @ ",nt2d);

            Print(Symbol_Name," trades will be paused between ",nt2d-(InpPreNewsShutdownTime*60)," and ",nt2d+(InpPostNewsResumeTime*60));
           }

         if(TimeCurrent() >= nt2d-(InpPreNewsShutdownTime*60) && TimeCurrent() <= nt2d+(InpPostNewsResumeTime*60))
           {
            check = true;
            if(InpUseNewsFilter)
              {
               Alert("No ",Symbol_Name," trades allowed now due to news. Trading will resume @ ",nt2d+(InpPostNewsResumeTime*60));
              }
            break;
           }
        }

     }

   FileClose(handle);

   return check;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTrade()
  {
  

   if(InpUseNewsFilter && IsNews(Symbol_Name))
      return;

   int ticket  = 0;

   double Lots = 0;

   double spread = SymbolInfoDouble(Symbol_Name,SYMBOL_ASK) - SymbolInfoDouble(Symbol_Name,SYMBOL_BID);

// Alert("Current spread for ",Symbol_Name," is ",spread);

   int min = ArraySize(TPs);//(int)MathMin(3,ArraySize(TPs));

   double slpricevalue = MathAbs(SL-Entry);

   string lastticketgroup = "";

//  Print("SL without spread = ",SL);

   if(InpUseSpread)
      SL = Ordertype==OP_BUY || Ordertype==OP_BUYLIMIT || Ordertype==OP_BUYSTOP ? SL-spread : SL+spread;

//  Print("SL with spread = ",SL);

   for(int i=0; i<min; i++)
     {
      double lot = InpLotMode==fixed ? InpLotValue : GetLots(slpricevalue);

      // Lots   = lot > SymbolInfoDouble(Symbol_Name,SYMBOL_VOLUME_MIN) ? lot : SymbolInfoDouble(Symbol_Name,SYMBOL_VOLUME_MIN);
      //  Print("TP without spread = ",TPs[ArraySize(TPs)-1]);

      double tp = TPs[i];//TPs[ArraySize(TPs)-1];

      //if(InpUseSpread)
      //   tp = Ordertype==OP_BUY || Ordertype==OP_BUYLIMIT || Ordertype==OP_BUYSTOP ? TPs[ArraySize(TPs)-1] + spread : TPs[ArraySize(TPs)-1] - spread;

      //   Print("TP with spread = ",tp);

      ticket = OrderSend(Symbol_Name,Ordertype,lot,Entry,InpMaxSlippage,SL,tp,((string)(i+1))+","+Sender,InpMagicNumber,0,clrNONE);



      //  WriteEntry(Symbol_Name+","+(string)ticket+","+(string)(i+1)+","+(string)lot+","+sEntry,(string)(i+1)+","+(string)lot+","+sEntry);

      lastticketgroup = (string)lot+",";

      for(int j=0; j<ArraySize(TPs); j++)
        {
         if(j==3)
            break;

         lastticketgroup += (string)TPs[j]+",";
        }

     }

   lastticketgroup = StringSubstr(lastticketgroup,0,StringLen(lastticketgroup)-1);

   int handle      = FileOpen(Symbol_Name+"_lasttickets.txt",FILE_WRITE);

   if(handle==INVALID_HANDLE)
      Print("Failed to write last set of tickets for, ",Symbol_Name,", ",GetLastError());

   FileWriteString(handle,lastticketgroup);
   FileClose(handle);

   if(ticket>0)
     {
      Symbol_Name = "";
      Ordertype = -1;
      Entry = 0;
      SL = 0;
      ArrayFree(TPs);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIn(string child, string mother)
  {

   if(StringFind(mother,child)>=0)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string VerifiedSymbol(string sym)
  {
   bool symtoupper = StringToUpper(sym);

   if(sym==InpSigGoldName)
     {
      if(IsSymbolFound(sym))
         return sym;

      else
         return(InpGoldName);
     }

   if(sym==InpSigUS30Name)
     {
      if(IsSymbolFound(sym))
         return sym;

      else
         return(InpUS30Name);
     }

   if(sym==InpSigNasName)
     {
      if(IsSymbolFound(sym))
         return sym;

      else
         return(InpNasName);
     }

   if(sym=="ETH" || sym=="ETHEREUM" || sym=="ETHUSD")
     {
      if(IsSymbolFound("ETHUSD"))
         return("ETHUSD");

      else
         return(InpEthName);
     }


   if(sym=="GOLD" || sym=="XAU" || sym=="XAUUSD")
     {
      if(IsSymbolFound("XAUUSD"))
         return("XAUUSD");

      else
         return(InpGoldName);
     }


   if(sym=="US30")
     {
      if(IsSymbolFound("US30"))
         return("US30");

      else
         return(InpUS30Name);
     }

   if(sym=="NAS" || sym=="NAS100")
     {
      if(IsSymbolFound("NAS100"))
         return("NAS100");

      else
         return(InpNasName);
     }

   if(sym=="BTC" || sym=="BITCOIN" || sym=="BTCUSD")
     {
      if(IsSymbolFound("BTCUSD"))
         return("BTCUSD");

      else
         return(InpBTCName);
     }

   if(sym=="XRP" || sym=="XRPUSD")
     {
      if(IsSymbolFound("XRPUSD"))
         return("XRPUSD");

      else
         return(InpXRPName);
     }

   if(sym=="LTC" || sym=="LTCUSD")
     {
      if(IsSymbolFound("LTCUSD"))
         return("LTCUSD");

      else
         return(InpLTCName);
     }

   if(sym=="SOL" || sym=="SOLUSD")
     {
      if(IsSymbolFound("SOLUSD"))
         return("SOLUSD");

      else
         return(InpSOLName);
     }

   if(sym=="SPX500")
     {
      if(IsSymbolFound("SPX500"))
         return("SPX500");

      else
         return(InpSPX500Name);
     }


   return("Unknown Symbol");
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SymbolAlt(string sym, string &array[])
  {
   bool symtoupper = StringToUpper(sym);

   if(sym=="XAUUSD")
     {
      AddToArray(array, "GOLD");
     }

   return("Unknown Symbol");
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTP3()
  {

   for(int j=0; j<SymbolsTotal(true); j++)
     {
      string sym = SymbolName(j,true);

      if(SymbolTotal(sym)==0)
         continue;

      if(SymbolTotal(sym)==2)
        {
         for(int i=0; i<OrdersTotal(); i++)
           {
            if(OrderSelect(i,SELECT_BY_POS))
               if(OrderSymbol()==sym && StringSubstr(OrderComment(),0,1)=="3")
                  if(OrderMagicNumber()==InpMagicNumber)
                    {

                     if(OrderType()==OP_BUY)
                       {
                        if(OrderStopLoss() < OrderOpenPrice() && OrderProfit()>0)
                          {
                           bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
                           // Print("SL on remaining trades on ",OrderSymbol()," now moved to breakeven.");
                          }
                       }

                     else
                        if(OrderType()==OP_SELL)
                          {
                           if(OrderStopLoss() > OrderOpenPrice() && OrderProfit()>0)
                             {
                              bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
                              //  Print("SL on remaining trades on ",OrderSymbol()," now moved to breakeven.");
                             }
                          }
                    }


           }
        }

      if(SymbolTotal(sym)==1)
        {

         double newTP = 0;
         datetime closetime = 0;

         for(int i=0; i<OrdersHistoryTotal(); i++)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
               if(OrderSymbol()==sym && StringSubstr(OrderComment(),0,1)=="3")
                  if(OrderMagicNumber()==InpMagicNumber)
                     if(OrderCloseTime() > closetime)
                       {
                        newTP = OrderTakeProfit();
                       }
           }


         for(int i=0; i<OrdersTotal(); i++)
           {
            if(OrderSelect(i,SELECT_BY_POS))
               if(OrderSymbol()==sym && StringSubstr(OrderComment(),0,1)=="3")
                  if(OrderMagicNumber()==InpMagicNumber)
                    {

                     if(OrderType()==OP_BUY)
                       {
                        if(OrderStopLoss() < newTP && Bid - MarketInfo(OrderSymbol(),MODE_STOPLEVEL) > newTP)
                          {
                           bool isMod = OrderModify(OrderTicket(),OrderOpenPrice(),newTP,OrderTakeProfit(),0,clrNONE);
                           //   Print("SL on remaining trade on ",OrderSymbol()," now moved to TP1.");
                          }
                       }

                     else
                        if(OrderType()==OP_SELL)
                          {
                           if(OrderStopLoss() > newTP && Ask + MarketInfo(OrderSymbol(),MODE_STOPLEVEL) < newTP)
                             {
                              bool isMod = OrderModify(OrderTicket(),OrderOpenPrice(),newTP,OrderTakeProfit(),0,clrNONE);
                              //  Print("SL on remaining trade on ",OrderSymbol()," now moved to TP1.");
                             }
                          }

                    }
           }
        }
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTP2()
  {

   for(int j=0; j<SymbolsTotal(true); j++)
     {
      string sym = SymbolName(j,true);

      if(SymbolTotal(sym)==0)
         continue;

      if(SymbolTotal(sym)==1)
        {
         for(int i=0; i<OrdersTotal(); i++)
           {
            if(OrderSelect(i,SELECT_BY_POS))
               if(OrderSymbol()==sym && StringSubstr(OrderComment(),0,1)=="2")
                  if(OrderMagicNumber()==InpMagicNumber)
                    {

                     if(OrderType()==OP_BUY)
                       {
                        if(OrderStopLoss() < OrderOpenPrice() && OrderProfit()>0)
                          {
                           bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
                           // Print("SL on remaining trades on ",OrderSymbol()," now moved to breakeven.");
                          }
                       }

                     else
                        if(OrderType()==OP_SELL)
                          {
                           if(OrderStopLoss() > OrderOpenPrice() && OrderProfit()>0)
                             {
                              bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
                              //  Print("SL on remaining trades on ",OrderSymbol()," now moved to breakeven.");
                             }
                          }
                    }


           }
        }

     }

  }

//+------------------------------------------------------------------+
void AddToArray(string &array[], string value)
  {

   ArrayResize(array,ArraySize(array)+1,0);
   array[ArraySize(array)-1] = value;
  }
//+------------------------------------------------------------------+
void AddToArray(int &array[], int value)
  {

   ArrayResize(array,ArraySize(array)+1,0);
   array[ArraySize(array)-1] = value;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddToArray(double &array[], double value)
  {
   ArrayResize(array,ArraySize(array)+1,0);
   array[ArraySize(array)-1] = value;
  }
//+------------------------------------------------------------------+
bool IsEntryMsg()
  {

   if(SL==0 && (StringFind(Symbol_Name,InpUS30Name) >= 0 || StringFind(Symbol_Name,InpNasName) >= 0 || StringFind(Symbol_Name,InpGoldName) >= 0) && Ordertype>=0)
     {

      double slpoints = StringFind(Symbol_Name,InpUS30Name) >= 0 ? InpUS30SL : StringFind(Symbol_Name,InpNasName) >= 0 ? InpNAS100SL : InpGoldSL;

      SL = Ordertype==OP_BUY || Ordertype==OP_BUYSTOP || Ordertype==OP_BUYLIMIT ? Entry - slpoints*SymbolInfoDouble(Symbol_Name,SYMBOL_POINT) : Entry + slpoints*SymbolInfoDouble(Symbol_Name,SYMBOL_POINT);
     }

   if(ArraySize(TPs)==0 && (StringFind(Symbol_Name,InpUS30Name) >= 0 || StringFind(Symbol_Name,InpNasName) >= 0 || StringFind(Symbol_Name,InpGoldName) >= 0) && Ordertype>=0)
     {
      double tppoints = StringFind(Symbol_Name,InpUS30Name) >= 0 ? InpUS30SL : StringFind(Symbol_Name,InpNasName) >= 0 ? InpNAS100SL : InpGoldSL;

      double TP = Ordertype==OP_BUY || Ordertype==OP_BUYSTOP || Ordertype==OP_BUYLIMIT ? Entry + tppoints*SymbolInfoDouble(Symbol_Name,SYMBOL_POINT) : Entry - tppoints*SymbolInfoDouble(Symbol_Name,SYMBOL_POINT);
      AddToArray(TPs,TP);
     }

   if(StringLen(Symbol_Name)>0 && Ordertype>=0 && Entry>0 && SL>0 && ArraySize(TPs)>0)
      return true;


   return false;
  }
//+------------------------------------------------------------------+
string GetSymbol(string msg)
  {

   StringToUpper(msg);

   string symbol = "";


   for(int j=0; j<SymbolsTotal(true); j++)
     {
      string check = "";
      string name = SymbolName(j,true);

      for(int i=0; i<StringLen(msg); i++)
        {
         string cleanmsg = msg;
         StringReplace(cleanmsg,"/","");
         check = StringSubstr(cleanmsg,i,StringLen(name));

         if(check==name || VerifiedSymbol(check)==name)
           {
            symbol = name;
            break;
           }

        }

     }



   return symbol;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Breakeven(string symbol, string entry="")
  {

   string msg = "";

   StringToUpper(msg);



   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               double point = SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
               double be_price = OrderType()==OP_BUY ? OrderOpenPrice()+(InpBEPoints*point) : OrderOpenPrice()-(InpBEPoints*point);

               //if( StringFind(OrderComment(),"from #")<0)
               //   continue;

               if(entry=="")
                 {
                  if(OrderProfit() > 0 && OrderStopLoss()!=be_price)
                     bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),be_price,OrderTakeProfit(),0,clrNONE);
                 }

               else
                 {
                  string parts[];

                  string entryprice = "";


                  StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>2)
                     entryprice = parts[2];





                  if(OrderProfit() > 0 && OrderStopLoss()!=be_price)
                     bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),be_price,OrderTakeProfit(),0,clrNONE);
                 }


              }


     }



  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveSL(string symbol, string entry="")
  {

   string msg = "";

   int cnt = 0;

   StringToUpper(msg);




   for(int i=0; i<OrdersTotal(); i++)
     {
      string entryprice = "";

      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               if(entry=="")
                 {
                  bool isRS = OrderModify(OrderTicket(),OrderOpenPrice(),0,OrderTakeProfit(),0,clrNONE);

                  if(isRS)
                     cnt++;
                 }

               else
                 {

                  string parts[];


                  StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>2)
                     entryprice = parts[2];

                  bool isRS = false;

                  if(StringFind(entry,entryprice)>=0)
                     isRS = OrderModify(OrderTicket(),OrderOpenPrice(),0,OrderTakeProfit(),0,clrNONE);

                  if(isRS)
                     cnt++;
                 }

              }

     }



  }
//+------------------------------------------------------------------+
void CloseTrade(string symbol, string entry="")
  {

   string msg = "";

   StringToUpper(msg);




   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               
               

               bool isClosed = false;

               if(entry=="")
                 {
                  if(OrderType() <= 1)
                     isClosed = OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),10,clrNONE);
                  else
                     isClosed = OrderDelete(OrderTicket(),clrNONE);
                 }

               else
                 {
                  string parts[];

                  string entryprice = "";

                  StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>2)
                     entryprice = parts[2];





                  if(OrderType() <= 1)
                     isClosed = OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),10,clrNONE);
                  else
                     isClosed = OrderDelete(OrderTicket(),clrNONE);

                 }



              }

     }



  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseHalf(string symbol, string entry="")
  {

   string msg = "";

   StringToUpper(msg);

   int modtotal = 0;

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
              // if(StringFind(OrderComment(),Sender)<0)
              //    continue;

               double lot = 0;

               if(entry=="")
                 {


                  int pClosed = PartialOrderClose(OrderTicket(),OrderClosePrice(),FormatLot(InpPCPerc*0.01*OrderLots()),InpMagicNumber);
                  modtotal++;

                 }

               else
                 {

                  int pClosed = PartialOrderClose(OrderTicket(),OrderClosePrice(),FormatLot(InpPCPerc*0.01*OrderLots()),InpMagicNumber);

                  /*string entryprice = "";

                  string parts[];

                  StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>1)
                     lot = StringToDouble(parts[1]);

                  if(ArraySize(parts)>2)
                     entryprice = parts[2];

                  if(OrderLots()==lot)
                    {
                     int pClosed = PartialOrderClose(OrderTicket(),OrderClosePrice(),FormatLot(InpPCPerc*0.01*OrderLots()),InpMagicNumber);
                     modtotal++;
                    }*/
                 }


              }

     }





  }
//+------------------------------------------------------------------+
int SymbolTotal(string symbol, string entry="")
  {

   int cnt = 0;

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               string parts[];

               string entryprice = "";

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];

               if(StringFind(entry,entryprice)>=0)
                  cnt++;
              }
     }

   return cnt;
  }
//+------------------------------------------------------------------+
int PartialOrderClose(int TicketID, double ClosePrice, double LotSize, int EA_MagicNumber)
  {
   int before_close[], i = 0, j = 0, array_size = 0;
   bool new_order = false;
   GetLastError();   // clear error flag

   for(i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i, SELECT_BY_POS))
         if(OrderSymbol() == Symbol())                                    // should also include: OrderMagicNumber() == EA_MagicNumber
            if(OrderType() <= 5)
              {
               array_size = ArrayRange(before_close, 0) + 1;
               ArrayResize(before_close, array_size);
               before_close[array_size - 1] = OrderTicket();
              }
   if(OrderClose(TicketID, LotSize, ClosePrice, 10))
     {
      for(i = OrdersTotal() - 1; i >=0; i--)
         if(OrderSelect(i, SELECT_BY_POS))
            if(OrderSymbol() == Symbol())                                 // should also include: OrderMagicNumber() == EA_MagicNumber
               if(OrderType() <= 1)                                       // only open OP_BUY and OP_SELL orders
                 {
                  for(j = 0; j < ArrayRange(before_close, 0); j++)
                    {
                     if(before_close[j] != OrderTicket())
                        new_order = true;
                     else
                       { new_order = false; break; }
                    }
                  if(new_order)
                     return (OrderTicket());
                 }
     }
   else
     {
      Print("An error occurred (Code: ", GetLastError(), ").");
      return (-1);
     }

   return (0);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void CheckError()
  {

   if(StringLen(Symbol_Name)==0)
      Print("Symbol could not be extracted from signal. Please check signal.");

   if(Entry==0)
      Print("Entry price could not be extracted from signal. Please check signal.");

   if(SL==0)
      Print("SL price could not be extracted from signal. Please check signal.");

   if(ArraySize(TPs)==0)
      Print("TP prices could not be extracted from signal. Please check signal.");

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeTP(string symbol, string entry="")
  {
   string msg = "";

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
             //  if( StringFind(OrderComment(),"from #")<0)
             //     continue;

               string parts[];

               string entryprice = "";

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];


               if(StringFind(msg,"CHANGE")>=0 && StringFind(msg,"TP1")>=0)
                  if(OrderTakeProfit()==TPs[0])
                    {

                     Print("TP1 ticket found: ", OrderTakeProfit()," ",TPs[0]);

                     StringReplace(msg,"CHANGE","");
                     StringReplace(msg,"TP1","");

                     char msg2arr[];

                     StringToCharArray(msg,msg2arr);

                     for(int k=0; k<ArraySize(msg2arr); k++)
                       {
                        if(!IsFound(CharToString(msg2arr[k]),PriceChars))
                           StringReplace(msg,CharToString(msg2arr[k]),"");
                       }

                     if(StringSubstr(msg,StringLen(msg)-1,1)==".")
                        msg = StringSubstr(msg,0,StringLen(msg)-2);


                     bool isMod = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),StringToDouble(msg),0,clrNONE);

                    }



              }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeSL(string symbol, string entry, double price=0)
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
              // if( StringFind(OrderComment(),"from #")<0)
              //    continue;

               if(entry=="")
                 {
                  bool isMod = OrderModify(OrderTicket(),OrderOpenPrice(),price,OrderTakeProfit(),0,clrNONE);
                 }

               else
                 {
                  string parts[];

                  string entryprice = "";

                  StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>2)
                     entryprice = parts[2];


                  bool isMod = OrderModify(OrderTicket(),OrderOpenPrice(),price,OrderTakeProfit(),0,clrNONE);

                 }

              }
     }
  }
//+------------------------------------------------------------------+
void GetTickets(string symbol, string entry, int &array[])
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               string parts[];

               string entryprice = "";

               double tp = OrderTakeProfit();

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];

               if(StringFind(entry,entryprice)>=0)
                  AddToArray(array,OrderTicket());
              }
     }



  }
//+------------------------------------------------------------------+
double GetNewSL(string msg, bool cond)
  {

   StringToUpper(msg);

   if(cond)
     {
      string pMsg = msg;

      StringReplace(pMsg,"CHANGE","");
      StringReplace(pMsg,"SL","");
      StringReplace(pMsg,"STOPLOSS","");
      StringReplace(pMsg,"STOP LOSS","");

      double tp1 = 0;
      double tp2 = 0;
      double tp3 = 0;

      if(ArraySize(TPs)>0)
         tp1 = TPs[0];

      if(ArraySize(TPs)>1)
         tp2 = TPs[1];

      if(ArraySize(TPs)>2)
         tp3 = TPs[2];

      if(StringFind(pMsg,"TP1")>=0)
         return tp1;

      else
         if(StringFind(pMsg,"TP2")>=0)
            return tp2;

         else
            if(StringFind(pMsg,"TP3")>=0)
               return tp3;

            else
              {

               string parts[];

               StringSplit(pMsg,StringGetCharacter(" ",0),parts);



               double newSL = 0;

               if(ArraySize(parts)>0)
                 {
                  char pmsg[];

                  StringToCharArray(pMsg,pmsg);

                  for(int k=0; k<ArraySize(pmsg); k++)
                    {
                     if(!IsFound(CharToString(pmsg[k]),PriceChars) && CharToString(pmsg[k])!=" ")
                        StringReplace(pMsg,CharToString(pmsg[k]),"");
                    }

                  pMsg = StringSubstr(pMsg,0,StringFind(pMsg," "));
                  StringTrimLeft(StringTrimRight(pMsg));

                  if(StringToDouble(pMsg)>0)
                     newSL = StringToDouble(pMsg);
                 }

               return StringToDouble(pMsg);

              }
     }

   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//TP1
double GetNewTP1(string msg, bool cond)
  {

   StringToUpper(msg);

   if(cond)
     {

      char msg2arr[];

      string pMsg = msg;

      StringReplace(pMsg,"TP 1 ","TP1 ");
      StringReplace(pMsg,"CHANGE","");
      StringReplace(pMsg,"TP1","");

      StringReplace(pMsg,"TAKEPROFIT 1","");
      StringReplace(pMsg,"TAKE PROFIT 1","");

      StringToCharArray(pMsg,msg2arr);

      string parts[];

      StringTrimLeft(StringTrimRight(pMsg));

      StringSplit(pMsg,StringGetCharacter(" ",0),parts);



      double newTP = 0;

      if(ArraySize(parts)>0)
        {
         char pmsg[];

         StringToCharArray(pMsg,pmsg);

         for(int k=0; k<ArraySize(pmsg); k++)
           {
            if(!IsFound(CharToString(pmsg[k]),PriceChars) && CharToString(pmsg[k])!=" ")
               StringReplace(pMsg,CharToString(pmsg[k]),"");
           }

         pMsg = StringSubstr(pMsg,0,StringFind(pMsg," "));
         StringTrimLeft(StringTrimRight(pMsg));

         if(StringToDouble(pMsg)>0)
            newTP = StringToDouble(pMsg);
        }


      return newTP;
     }

   return 0;
  }
//+------------------------------------------------------------------+
void ChangeTP1(string symbol, string entry="", double newTP=0, string lastMsg="")
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
              // if( StringFind(OrderComment(),"from #")<0)
              //    continue;

               double groupTps[];

               int ticket = OrderTicket();
               double openPrice = OrderOpenPrice();
               double stopLoss = OrderStopLoss();

               datetime opentime = OrderOpenTime();

               string sym = OrderSymbol();
               double tp  = OrderTakeProfit();

               GetGroupTPs(opentime, sym, groupTps);

               ArraySort(groupTps);

               //   Print("Order TP is ",tp);
               //   Print("groupTPs[0] is ",groupTps[0]);
               //   Print("Symbol is ",symbol);


               if(StringFind(lastMsg,"TP1") >= 0 && ArraySize(groupTps)>0)
                 {
                  if(tp==groupTps[0])
                    {
                     bool mod = OrderModify(ticket,openPrice,stopLoss,newTP,0,clrNONE);
                    }
                 }

               else
                  if(StringFind(lastMsg,"TP2") >= 0 && ArraySize(groupTps)>1)
                    {
                     if(tp==groupTps[1])
                       {
                        bool mod = OrderModify(ticket,openPrice,stopLoss,newTP,0,clrNONE);
                       }
                    }

                  else
                     if(StringFind(lastMsg,"TP3") >= 0 && ArraySize(groupTps)>2)
                       {
                        if(tp==groupTps[2])
                          {
                           bool mod = OrderModify(ticket,openPrice,stopLoss,newTP,0,clrNONE);
                          }
                       }

                     else
                        if(StringFind(lastMsg,"TP4") >= 0 && ArraySize(groupTps)>3)
                          {
                           if(tp==groupTps[3])
                             {
                              bool mod = OrderModify(ticket,openPrice,stopLoss,newTP,0,clrNONE);
                             }
                          }

                        else
                           if(StringFind(lastMsg,"TP5") >= 0 && ArraySize(groupTps)>4)
                             {
                              if(tp==groupTps[4])
                                {
                                 bool mod = OrderModify(ticket,openPrice,stopLoss,newTP,0,clrNONE);
                                }
                             }
                           else
                             {
                              if(tp==groupTps[0] && ArraySize(groupTps)>0)
                                {
                                 // Print("Single TP order.");
                                 bool mod = OrderModify(ticket,openPrice,stopLoss,newTP,0,clrNONE);
                                }
                             }


              }
     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseTP1(string symbol, string entry="")
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
              // if( StringFind(OrderComment(),"from #")<0)
              //    continue;

               string parts[];

               string entryprice = "";

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];

               if(parts[0]=="1")
                 {
                  bool closed = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),10,clrNONE);
                 }

              }
     }

  }
//+------------------------------------------------------------------+
//TP2
double GetNewTP2(string msg)
  {

   StringToUpper(msg);

   if(StringFind(msg,"CHANGE TP2")>=0)
     {

      char msg2arr[];

      string pMsg = msg;

      StringReplace(pMsg,"TP 2 ","TP2 ");
      StringReplace(pMsg,"CHANGE","");
      StringReplace(pMsg,"TP2","");

      StringReplace(pMsg,"TAKEPROFIT 2","");
      StringReplace(pMsg,"TAKE PROFIT 2","");

      StringToCharArray(pMsg,msg2arr);

      string parts[];

      StringTrimLeft(StringTrimRight(pMsg));

      StringSplit(pMsg,StringGetCharacter(" ",0),parts);

      double newTP = 0;

      if(ArraySize(parts)>0)
        {
         char pmsg[];

         StringToCharArray(pMsg,pmsg);

         for(int k=0; k<ArraySize(pmsg); k++)
           {
            if(!IsFound(CharToString(pmsg[k]),PriceChars) && CharToString(pmsg[k])!=" ")
               StringReplace(pMsg,CharToString(pmsg[k]),"");
           }

         pMsg = StringSubstr(pMsg,0,StringFind(pMsg," "));
         StringTrimLeft(StringTrimRight(pMsg));

         if(StringToDouble(pMsg)>0)
            newTP = StringToDouble(pMsg);
        }


      return newTP;
     }

   return 0;
  }
//+------------------------------------------------------------------+
void ChangeTP2(string symbol, string entry="", double tp=0)
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
              // if( StringFind(OrderComment(),"from #")<0)
              //    continue;

               string parts[];

               string entryprice = "";

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];

               if(parts[0]=="2")
                 {
                  bool mod = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0,clrNONE);
                 }

              }
     }


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseTP2(string symbol, string entry="")
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
            //   if( StringFind(OrderComment(),"from #")<0)
             //     continue;

               string parts[];

               string entryprice = "";

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];

               if(parts[0]=="2")
                 {
                  bool closed = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),10,clrNONE);
                 }

              }
     }

  }

//TP3
double GetNewTP3(string msg)
  {

   StringToUpper(msg);

   if(StringFind(msg,"CHANGE TP3")>=0)
     {

      char msg2arr[];

      string pMsg = msg;

      StringReplace(pMsg,"TP 3 ","TP3 ");
      StringReplace(pMsg,"CHANGE","");
      StringReplace(pMsg,"TP3","");

      StringReplace(pMsg,"TAKEPROFIT 3","");
      StringReplace(pMsg,"TAKE PROFIT 3","");

      StringToCharArray(pMsg,msg2arr);

      string parts[];

      StringTrimLeft(StringTrimRight(pMsg));

      StringSplit(pMsg,StringGetCharacter(" ",0),parts);

      double newTP = 0;

      if(ArraySize(parts)>0)
        {
         char pmsg[];

         StringToCharArray(pMsg,pmsg);

         for(int k=0; k<ArraySize(pmsg); k++)
           {
            if(!IsFound(CharToString(pmsg[k]),PriceChars) && CharToString(pmsg[k])!=" ")
               StringReplace(pMsg,CharToString(pmsg[k]),"");
           }

         pMsg = StringSubstr(pMsg,0,StringFind(pMsg," "));
         StringTrimLeft(StringTrimRight(pMsg));

         if(StringToDouble(pMsg)>0)
            newTP = StringToDouble(pMsg);
        }


      return newTP;
     }

   return 0;
  }
//+------------------------------------------------------------------+
void ChangeTP3(string symbol, string entry="", double tp=0)
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
            //   if( StringFind(OrderComment(),"from #")<0)
             //     continue;

               string parts[];

               string entryprice = "";

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];

               if(parts[0]=="3")
                 {
                  bool mod = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0,clrNONE);
                 }

              }
     }


  }
//+------------------------------------------------------------------+
void CloseTP3(string symbol, string entry="")
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
             //  if( StringFind(OrderComment(),"from #")<0)
             //     continue;

               string parts[];

               string entryprice = "";

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];

               if(parts[0]=="3")
                 {
                  bool closed = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),10,clrNONE);
                 }

              }
     }

  }
//+------------------------------------------------------------------+
double GetLots(double riskPoints)
  {
   double Balance     = AccountInfoDouble(ACCOUNT_BALANCE);
   double pointValue  = PointValue(Symbol_Name);
   double moneyAtRisk = (InpRiskPerc/100)*Balance;
   riskPoints         = riskPoints/SymbolInfoDouble(Symbol_Name,SYMBOL_POINT);

   double Lots        = moneyAtRisk/(pointValue*riskPoints);

   return FormatLot(Lots);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PriceToPoints(double price, string symbol) //Use info of size of a pip to convert SL and TP to Price
  {
   return(price/_Point);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PointValue(string symbol)
  {

   double tickSize = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
   double point     = SymbolInfoDouble(symbol,SYMBOL_POINT);
   double ticksPerPoint = tickSize/point;
   double pointValue = tickValue/ticksPerPoint;

   return(pointValue);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FormatLot(double dlots)
  {

   double min,max,step,lots;
   int lotdigits = 1;

   step = MarketInfo(Symbol(),MODE_LOTSTEP);

   if(step==0.01)
      lotdigits=2;

   if(step==0.1)
      lotdigits=1;

   lots = StrToDouble(DoubleToStr(dlots,lotdigits));

   min  = MarketInfo(Symbol(),MODE_MINLOT);

   if(lots<min)
      return(min);


   max=MarketInfo(Symbol(),MODE_MAXLOT);

   if(lots>max)
      return(max);

   return(lots);

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PipSize(string symbol) //Get Size of a pip in the selected symbol
  {

   double point  =  MarketInfo(symbol,MODE_POINT);
   int    digits = (int)MarketInfo(symbol,MODE_DIGITS);

   return((digits%2)==1 ? point*10 : point);

  }
//+------------------------------------------------------------------+
double PriceToPips(double price, string symbol) //Use info of size of a pip to convert SL and TP to Price
  {
   int    digits = (int)MarketInfo(symbol,MODE_DIGITS);
   double pips = price / PipSize(symbol);

   return((digits%2)==1 ? pips*10 : PointValue(symbol) != 1 ? pips*PointValue(symbol) : (pips*PointValue(symbol))/10) ;
  }
//+------------------------------------------------------------------+
int GetToday()
  {

   datetime now = TimeCurrent();

   MqlDateTime t2s;

   TimeToStruct(now,t2s);

   return(t2s.day_of_week);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetNearestCloseDay()
  {

   datetime day = TimeCurrent();

   MqlDateTime t2s;

   TimeToStruct(day,t2s);

   int daysToClose = t2s.day_of_week - (InpShutdownDay + 1);

   if(daysToClose < 0)
     {
      return(StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+InpShutdownTime) + -(daysToClose*86400));
     }

   else
      if(daysToClose > 0)
        {
         return(StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+InpShutdownTime) - (daysToClose*86400));
        }

      else
         return(StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+InpShutdownTime));


   return(-1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetNearestOpenDay()
  {

   datetime day = TimeCurrent();

   datetime openday = 0;

   MqlDateTime t2s;

   TimeToStruct(day,t2s);

   int daysToClose = t2s.day_of_week - (InpRestartDay + 1);

   if(daysToClose < 0)
     {
      openday = (StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+InpRestartTime) + -(daysToClose*86400));
     }

   else
      if(daysToClose > 0)
        {
         openday = (StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+InpRestartTime) - (daysToClose*86400));
        }

      else
         openday = (StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+InpRestartTime));

// if(openday < GetNearestCloseDay())
//  openday = openday + (7*86400);

   return(openday);
  }
//+------------------------------------------------------------------+
string DayToString(int day)
  {

   string d2s = "";

   switch(day)
     {
      case 0:
         d2s = "Sunday";
         break;
      case 1:
         d2s = "Monday";
         break;
      case 2:
         d2s = "Tuesday";
         break;
      case 3:
         d2s = "Wednesday";
         break;
      case 4:
         d2s = "Thursday";
         break;
      case 5:
         d2s = "Friday";
         break;
      case 6:
         d2s = "Saturday";
         break;
      default:
         break;
     }

   return d2s;
  }
//+------------------------------------------------------------------+
void ModifySL()
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderMagicNumber()==InpMagicNumber)
            if(OrderType() <= OP_SELL)
              {

               if(FileIsExist(OrderSymbol()+"_lasttickets.txt"))
                 {
                  double open = OrderOpenPrice();

                  string symbol = OrderSymbol();

                  datetime openTime = OrderOpenTime();

                  double tps[];

                  AddToArray(tps,open);

                  int handle      = FileOpen(OrderSymbol()+"_lasttickets.txt",FILE_READ);

                  if(handle==INVALID_HANDLE)
                     Print("Failed to read last set of tickets for, ",OrderSymbol(),", ",GetLastError());

                  string info = FileReadString(handle);

                  string parts[];

                  StringSplit(info,StringGetCharacter(",",0),parts);

                  for(int j=1; j<ArraySize(parts); j++)
                    {
                     AddToArray(tps,(double)(parts[j]));
                    }


                  FileClose(handle);


                  if(OrderType()==OP_BUY)
                    {
                     ArraySort(tps);

                     // Print("TP array is: ",ArrayToString(tps));


                     if(ArraySize(tps) >= 4)
                       {
                        if(IsTicketClosed(symbol,tps[1]))
                           ModifyGroup(symbol,openTime,0);

                        if(IsTicketClosed(symbol,tps[2]))
                           ModifyGroup(symbol,openTime,tps[1]);

                        if(IsTicketClosed(symbol,tps[3]))
                           ModifyGroup(symbol,openTime,tps[2]);

                        if(ArraySize(tps) >= 5 && IsTicketClosed(symbol,tps[4]))
                           ModifyGroup(symbol,openTime,tps[3]);

                        if(ArraySize(tps) >= 6 && IsTicketClosed(symbol,tps[5]))
                           ModifyGroup(symbol,openTime,tps[4]);

                        if(ArraySize(tps) >= 7 && IsTicketClosed(symbol,tps[6]))
                           ModifyGroup(symbol,openTime,tps[5]);
                       }



                    }

                  else
                     if(OrderType()==OP_SELL)
                       {

                        ArraySort(tps,WHOLE_ARRAY,0,MODE_DESCEND);

                        ArraySetItemAsFirst(open,tps);

                        // Print("TP array is: ",ArrayToString(tps));

                        if(ArraySize(tps) >= 4)
                          {
                           if(IsTicketClosed(symbol,tps[1]))
                              ModifyGroup(symbol,openTime,0);

                           if(IsTicketClosed(symbol,tps[2]))
                              ModifyGroup(symbol,openTime,tps[1]);

                           if(IsTicketClosed(symbol,tps[3]))
                              ModifyGroup(symbol,openTime,tps[2]);

                           if(ArraySize(tps) >= 5 && IsTicketClosed(symbol,tps[4]))
                              ModifyGroup(symbol,openTime,tps[3]);

                           if(ArraySize(tps) >= 6 && IsTicketClosed(symbol,tps[5]))
                              ModifyGroup(symbol,openTime,tps[4]);

                           if(ArraySize(tps) >= 7 && IsTicketClosed(symbol,tps[6]))
                              ModifyGroup(symbol,openTime,tps[5]);
                          }

                       }

                 }

              }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderMagicNumber()==InpMagicNumber)
           {
            bool isClosed = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),10,clrNONE);

            if(!isClosed)
               bool isDeleted = OrderDelete(OrderTicket());
           }
     }
  }
//+------------------------------------------------------------------+
void CloseOnDD()
  {

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);

   double maxDD   = InpMaxDD < 0 ? InpMaxDD : -InpMaxDD;

   if(equity - balance <= (maxDD/100)*balance)
     {
      CloseAll();
      Print("Maximum drawdown of -$",InpMaxDD," hit. All trades now closed.");
     }
  }
//+------------------------------------------------------------------+
void WriteEntry(string name, string text)
  {

   int handle = FileOpen(name,FILE_WRITE);

   if(handle==INVALID_HANDLE)
     {
      Print("Failed to write entry ",name,", error=",GetLastError());
      return;
     }

   FileWriteString(handle,text);
   FileClose(handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Download()
  {

   int timeout = 2000;

   string lastMsg = "";

   resu = WebRequest("GET",file_url,cookie,NULL,timeout,post,0,results,headers);

   string msg = CharArrayToString(results);


   if(resu != 200)
      return(-1);

   int handle = FileOpen("News.csv",FILE_WRITE | FILE_BIN);

   if(handle==INVALID_HANDLE)
     {

      int mError = GetLastError();
      PrintFormat("%s error %i opening file %s",__FUNCTION__,mError,"\\Test");
      return(-1);

     }



   FileWriteArray(handle,results,0,ArraySize(results));
   FileFlush(handle);
   FileClose(handle);

// Comment(resu);

   return(resu);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeTo24h(string time)
  {

   string t = time;

   StringToUpper(t);

   if(StringFind(t,"AM") >= 0)
     {
      StringReplace(t,"AM","");

      if(StringFind(t,"12:00") >= 0)
         return "00:00";

      if(StringLen(t) < 5)
         t = "0"+t;

      return t;
     }

   else
      if(StringFind(t,"PM") >= 0)
        {
         string parts[];
         StringSplit(t,StringGetCharacter(":",0),parts);

         if(ArraySize(parts) ==0)
            return "";

         int hour = (int)parts[0]+12 < 24 ? (int)parts[0]+12 : (int)parts[0];


         StringReplace(parts[1],"PM","");

         if(hour < 10 && StringSubstr(t,0,1) != "0")
            return "0"+(string)hour+":"+parts[1];

         else
            return (string)hour+":"+parts[1];
        }

   return "";
  }
//+------------------------------------------------------------------+
void DisplayNews()
  {

   for(int i=ObjectsTotal(0,-1,-1)-1; i>=0; i--)
     {
      string name = ObjectName(0,i);

      if(StringFind(name,"NEWS") >= 0)
         ObjectDelete(0,name);
     }


   string News[];

   int handle = FileOpen("News.csv",FILE_READ);

   if(handle==INVALID_HANDLE)
     {
      int mError = GetLastError();
      PrintFormat("%s error %i opening file %s",__FUNCTION__,mError,"\\Test");
      return;
     }

   while(!FileIsEnding(handle))
     {
      AddToArray(News,FileReadString(handle));
     }

   FileClose(handle);

   int ypos = 290;


   objectCreate(OBJ_LABEL,"NEWS TITLE",50,250,100,100,"NEWS LINEUP FOR "+TimeToString(TimeCurrent(),TIME_DATE),16777215,16777215,White,10);
   objectCreate(OBJ_LABEL,"NEWS BREAK",50,270,100,100,"==============================",16777215,16777215,White,10);

   for(int i=0; i<ArraySize(News); i++)
     {
      bool checkhigh   = InpHighImpact==true ? (StringFind(News[i],"HIGH") >= 0 || StringFind(News[i],"High") >= 0) : false;
      bool checkmedium = InpMediumImpact==true ? (StringFind(News[i],"MEDIUM") >= 0 || StringFind(News[i],"Medium") >= 0) : false;
      bool checklow    = InpLowImpact==true ? (StringFind(News[i],"LOW") >= 0 || StringFind(News[i],"Low") >= 0) : false;

      string today = TimeToString(TimeCurrent(),TIME_DATE);

      string parts[];

      StringSplit(today,StringGetCharacter(".",0),parts);

      if(ArraySize(parts) == 0)
         return;

      today = "";

      today += parts[1]+"-"+parts[2]+"-"+parts[0];

      if(StringFind(News[i],today) < 0 || (!checkhigh && !checkmedium && !checklow))
         continue;

      color textColor = checkhigh ? OrangeRed : checkmedium ? Orange : Gray;

      objectCreate(OBJ_LABEL,"NEWS"+(string)(i+1),50,ypos,100,100,News[i],16777215,16777215,textColor);

      ypos += 20;
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void objectCreate(ENUM_OBJECT type, string name, int xpos, int ypos, int xsize, int ysize, string text="", color pbgcolor=White, color pbordercolor=White, color pcolor=OrangeRed, int fontsize=8, int corner=4)
  {

   ObjectCreate(0, name, type, 0,0,0);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,xpos);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,ypos);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,xsize);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,ysize);
   ObjectSetInteger(0, name, OBJPROP_COLOR,pcolor);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR,pbordercolor);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,pbgcolor);
   ObjectSetInteger(0, name, OBJPROP_CORNER,corner);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,fontsize);

  }
//+------------------------------------------------------------------+
bool IsTicketClosed(string symbol,double tp)
  {

   bool isClosed = false;

   for(int i=0; i<OrdersHistoryTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
               if(OrderTakeProfit()==tp)
                 {
                  isClosed = true;
                  break;
                 }
     }


   return isClosed;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyGroup(string symbol, datetime opentime, double newSL=0)
  {


   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
               if((int)MathAbs(iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime()) - iBarShift(OrderSymbol(),PERIOD_M1,opentime)) < 2)
                 {
                  if(newSL==0)
                     newSL = OrderOpenPrice();

                  if(OrderType()==OP_BUY && OrderStopLoss() < newSL)
                     bool isMOD = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,OrderTakeProfit(),0,clrNONE);

                  if(OrderType()==OP_SELL && OrderStopLoss() > newSL)
                     bool isMOD = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,OrderTakeProfit(),0,clrNONE);
                 }
     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetGroupTPs(datetime ticketOpenTime, string symbol, double &tps[])
  {


   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
               if((int)MathAbs(iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime()) - iBarShift(OrderSymbol(),PERIOD_M1,ticketOpenTime)) <= 1)
                 {
                  if(!IsFound(OrderTakeProfit(),tps))
                    {
                     AddToArray(tps,OrderTakeProfit());
                    }
                 }
     }


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArraySetItemAsFirst(double elem, double &array[])
  {

   double temparray[];

   for(int i=0; i<ArraySize(array); i++)
     {
      if(array[i] != elem)
         AddToArray(temparray,array[i]);
     }

   ArrayFree(array);
   AddToArray(array,elem);

   for(int j=0; j<ArraySize(temparray); j++)
     {
      AddToArray(array,temparray[j]);
     }
  }
//+------------------------------------------------------------------+
string Request(string subdirectory)
  {

   int timeout = 2000;

   string url = BASE_URL+"/"+subdirectory;

   resu = WebRequest("GET",url,cookie,NULL,timeout,post,0,results,headers);

   return CharArrayToString(results);
  }
//+------------------------------------------------------------------+
