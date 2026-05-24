#ifndef AC_L1_CURRENCY_RISK_MAPS_MQH
#define AC_L1_CURRENCY_RISK_MAPS_MQH

bool AC_L1ForexCurrencyPairParts(const string symbol,
                                 string &base_ccy,
                                 string &quote_ccy)
{
   base_ccy = "";
   quote_ccy = "";
   if(StringLen(symbol) < 6) return false;
   string core = StringSubstr(symbol, 0, 6);
   string known = "|USD|EUR|GBP|JPY|CHF|AUD|NZD|CAD|SGD|ZAR|";
   base_ccy = StringSubstr(core, 0, 3);
   quote_ccy = StringSubstr(core, 3, 3);
   if(StringFind(known, "|" + base_ccy + "|") < 0) return false;
   if(StringFind(known, "|" + quote_ccy + "|") < 0) return false;
   return true;
}

int AC_L1CurrencyRiskIndex(const string ccy)
{
   if(ccy == "USD") return 0;
   if(ccy == "EUR") return 1;
   if(ccy == "GBP") return 2;
   if(ccy == "JPY") return 3;
   if(ccy == "CHF") return 4;
   if(ccy == "AUD") return 5;
   if(ccy == "NZD") return 6;
   if(ccy == "CAD") return 7;
   if(ccy == "SGD") return 8;
   if(ccy == "ZAR") return 9;
   return -1;
}

string AC_L1CurrencyRiskName(const int idx)
{
   if(idx == 0) return "USD";
   if(idx == 1) return "EUR";
   if(idx == 2) return "GBP";
   if(idx == 3) return "JPY";
   if(idx == 4) return "CHF";
   if(idx == 5) return "AUD";
   if(idx == 6) return "NZD";
   if(idx == 7) return "CAD";
   if(idx == 8) return "SGD";
   if(idx == 9) return "ZAR";
   return "Other";
}

string AC_L1CurrencyRiskLine(const string ccy,
                             const int touches,
                             const int risk_rows,
                             const double net50,
                             const double risk50,
                             const int wins,
                             const int losses,
                             const int hard_breaches)
{
   double avg_net = (touches > 0 ? net50 / touches : 0.0);
   double net_over_risk = (risk50 > 0.0 ? net50 / risk50 : 0.0);
   double win_pct = (touches > 0 ? ((double)wins * 100.0) / touches : 0.0);
   return AC_L1PadRight(ccy, 8)
      + AC_L1PadLeft(IntegerToString(touches), 8)
      + AC_L1PadLeft(IntegerToString(risk_rows), 8)
      + AC_L1PadLeft(AC_L1MoneyText(net50), 11)
      + AC_L1PadLeft(AC_L1MoneyText(risk50), 11)
      + AC_L1PadLeft(DoubleToString(net_over_risk, 2), 10)
      + AC_L1PadLeft(AC_L1MoneyText(avg_net), 10)
      + AC_L1PadLeft(AC_L1PercentText(win_pct), 9)
      + AC_L1PadLeft(IntegerToString(hard_breaches), 8)
      + "\r\n";
}

string AC_L1CurrencyResultRiskMap()
{
   int touches[10];
   int risk_rows[10];
   int wins[10];
   int losses[10];
   int hard_breaches[10];
   double net50[10];
   double risk50[10];
   for(int i = 0; i < 10; i++)
   {
      touches[i] = 0;
      risk_rows[i] = 0;
      wins[i] = 0;
      losses[i] = 0;
      hard_breaches[i] = 0;
      net50[i] = 0.0;
      risk50[i] = 0.0;
   }

   int forex_rows = 0;
   int non_forex_rows = 0;
   int risk_eligible_forex_rows = 0;
   double hard_risk_money = AC_L1_EQUITY * 0.002;

   for(int r = 0; r < ArraySize(AC_L1_CLOSED); r++)
   {
      string base_ccy = "";
      string quote_ccy = "";
      if(!AC_L1ForexCurrencyPairParts(AC_L1_CLOSED[r].symbol, base_ccy, quote_ccy))
      {
         non_forex_rows++;
         continue;
      }
      forex_rows++;
      int bi = AC_L1CurrencyRiskIndex(base_ccy);
      int qi = AC_L1CurrencyRiskIndex(quote_ccy);
      if(bi < 0 || qi < 0) continue;

      double half_net = AC_L1_CLOSED[r].net_result * 0.5;
      touches[bi]++;
      touches[qi]++;
      net50[bi] += half_net;
      net50[qi] += half_net;
      if(AC_L1_CLOSED[r].net_result > 0.0)
      {
         wins[bi]++;
         wins[qi]++;
      }
      else if(AC_L1_CLOSED[r].net_result < 0.0)
      {
         losses[bi]++;
         losses[qi]++;
      }

      double risk = 0.0;
      if(AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[r], risk))
      {
         risk_eligible_forex_rows++;
         double half_risk = risk * 0.5;
         risk_rows[bi]++;
         risk_rows[qi]++;
         risk50[bi] += half_risk;
         risk50[qi] += half_risk;
         if(risk > hard_risk_money)
         {
            hard_breaches[bi]++;
            hard_breaches[qi]++;
         }
      }
   }

   string worst_ccy = "none";
   double worst_net = 0.0;
   string worst_risk_ccy = "none";
   double worst_net_risk = 0.0;
   bool first_net = true;
   bool first_risk = true;
   for(int c = 0; c < 10; c++)
   {
      if(touches[c] > 0 && (first_net || net50[c] < worst_net))
      {
         first_net = false;
         worst_net = net50[c];
         worst_ccy = AC_L1CurrencyRiskName(c);
      }
      double nor = (risk50[c] > 0.0 ? net50[c] / risk50[c] : 0.0);
      if(risk_rows[c] > 0 && (first_risk || nor < worst_net_risk))
      {
         first_risk = false;
         worst_net_risk = nor;
         worst_risk_ccy = AC_L1CurrencyRiskName(c);
      }
   }

   string text = AC_L1MapHeader("CURRENCY RESULT / RISK MAP - FOREX ONLY");
   text += "Scope:                  forex-pair rows only; base/quote receive 50% net and 50% estimated risk\r\n";
   text += "Risk Source:            OrderCalcProfit entry-to-SL estimate from Layer 1 money-risk helper\r\n";
   text += "Forex Rows:             " + IntegerToString(forex_rows) + "\r\n";
   text += "Non-Forex Rows Skipped: " + IntegerToString(non_forex_rows) + "\r\n";
   text += "Risk Eligible Forex:    " + IntegerToString(risk_eligible_forex_rows) + "\r\n";
   text += "Worst Currency Net:     " + worst_ccy + " " + AC_L1MoneyText(worst_net) + "\r\n";
   text += "Worst Currency Net/Risk: " + worst_risk_ccy + " " + DoubleToString(worst_net_risk, 2) + "\r\n";
   text += AC_L1PadRight("Currency", 8)
      + AC_L1PadLeft("Touches", 8)
      + AC_L1PadLeft("RiskRows", 8)
      + AC_L1PadLeft("Net50", 11)
      + AC_L1PadLeft("Risk50", 11)
      + AC_L1PadLeft("Net/Risk", 10)
      + AC_L1PadLeft("AvgNet", 10)
      + AC_L1PadLeft("Win%", 9)
      + AC_L1PadLeft("Hard", 8)
      + "\r\n";

   for(int c = 0; c < 10; c++)
      text += AC_L1CurrencyRiskLine(AC_L1CurrencyRiskName(c), touches[c], risk_rows[c], net50[c], risk50[c], wins[c], losses[c], hard_breaches[c]);

   text += "Trade Permission:       FALSE\r\n";
   return text;
}

#endif