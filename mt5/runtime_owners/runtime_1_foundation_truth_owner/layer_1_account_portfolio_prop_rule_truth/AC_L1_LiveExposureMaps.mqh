#ifndef AC_L1_LIVE_EXPOSURE_MAPS_MQH
#define AC_L1_LIVE_EXPOSURE_MAPS_MQH

string AC_L1LiveSymbolExposureLine(const string symbol,
                                   const int open_count,
                                   const int pending_count,
                                   const double volume,
                                   const double floating_pl,
                                   const int no_sl_count,
                                   const double est_risk)
{
   return AC_L1PadRight(symbol, 14)
      + AC_L1PadLeft(IntegerToString(open_count), 6)
      + AC_L1PadLeft(IntegerToString(pending_count), 8)
      + AC_L1PadLeft(AC_L1VolumeText(volume), 9)
      + AC_L1PadLeft(AC_L1MoneyText(floating_pl), 11)
      + AC_L1PadLeft(IntegerToString(no_sl_count), 7)
      + AC_L1PadLeft(AC_L1MoneyText(est_risk), 11)
      + "\r\n";
}

bool AC_L1LiveSymbolSeen(const string seen,
                         const string symbol)
{
   return (StringFind(seen, "|" + symbol + "|") >= 0);
}

string AC_L1OpenPendingSymbolExposureMap()
{
   string text = AC_L1MapHeader("OPEN / PENDING SYMBOL EXPOSURE MAP");
   text += "Scope:                  live open positions and pending orders only\r\n";
   text += "Risk Source:            OrderCalcProfit estimate to SL when geometry is valid\r\n";
   text += AC_L1PadRight("Symbol", 14)
      + AC_L1PadLeft("Open", 6)
      + AC_L1PadLeft("Pending", 8)
      + AC_L1PadLeft("Volume", 9)
      + AC_L1PadLeft("FloatPL", 11)
      + AC_L1PadLeft("NoSL", 7)
      + AC_L1PadLeft("EstRisk", 11)
      + "\r\n";

   string seen = "|";
   int printed = 0;

   for(int pass = 0; pass < 2; pass++)
   {
      int source_total = (pass == 0 ? ArraySize(AC_L1_POSITIONS) : ArraySize(AC_L1_PENDING));
      for(int i = 0; i < source_total; i++)
      {
         string symbol = (pass == 0 ? AC_L1_POSITIONS[i].symbol : AC_L1_PENDING[i].symbol);
         if(symbol == "" || AC_L1LiveSymbolSeen(seen, symbol)) continue;
         seen += symbol + "|";

         int open_count = 0;
         int pending_count = 0;
         int no_sl_count = 0;
         double volume = 0.0;
         double floating_pl = 0.0;
         double est_risk = 0.0;

         for(int p = 0; p < ArraySize(AC_L1_POSITIONS); p++)
         {
            if(AC_L1_POSITIONS[p].symbol != symbol) continue;
            open_count++;
            volume += AC_L1_POSITIONS[p].volume;
            floating_pl += AC_L1_POSITIONS[p].profit;
            if(AC_L1_POSITIONS[p].stop_loss <= 0.0) no_sl_count++;
            double risk = 0.0;
            if(AC_L1EstimateRiskAtSL(AC_L1_POSITIONS[p].symbol, AC_L1_POSITIONS[p].side, AC_L1_POSITIONS[p].volume, AC_L1_POSITIONS[p].entry_price, AC_L1_POSITIONS[p].stop_loss, risk))
               est_risk += risk;
         }

         for(int q = 0; q < ArraySize(AC_L1_PENDING); q++)
         {
            if(AC_L1_PENDING[q].symbol != symbol) continue;
            pending_count++;
            volume += AC_L1_PENDING[q].volume;
            if(AC_L1_PENDING[q].stop_loss <= 0.0) no_sl_count++;
            double risk = 0.0;
            if(AC_L1EstimateRiskAtSL(AC_L1_PENDING[q].symbol, AC_L1_PENDING[q].type_text, AC_L1_PENDING[q].volume, AC_L1_PENDING[q].price, AC_L1_PENDING[q].stop_loss, risk))
               est_risk += risk;
         }

         text += AC_L1LiveSymbolExposureLine(symbol, open_count, pending_count, volume, floating_pl, no_sl_count, est_risk);
         printed++;
         if(printed >= 30)
         {
            text += "Map Rows Capped:        first 30 live symbols shown\r\n";
            text += "Trade Permission:       FALSE\r\n";
            return text;
         }
      }
   }

   if(printed <= 0) text += "none\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1LiveAssetExposureLine(const string label,
                                  const int open_count,
                                  const int pending_count,
                                  const double volume,
                                  const double floating_pl,
                                  const int no_sl_count,
                                  const double est_risk)
{
   return AC_L1PadRight(label, 14)
      + AC_L1PadLeft(IntegerToString(open_count), 6)
      + AC_L1PadLeft(IntegerToString(pending_count), 8)
      + AC_L1PadLeft(AC_L1VolumeText(volume), 9)
      + AC_L1PadLeft(AC_L1MoneyText(floating_pl), 11)
      + AC_L1PadLeft(IntegerToString(no_sl_count), 7)
      + AC_L1PadLeft(AC_L1MoneyText(est_risk), 11)
      + "\r\n";
}

string AC_L1OpenPendingAssetExposureMap()
{
   int open_count[6];
   int pending_count[6];
   int no_sl_count[6];
   double volume[6];
   double floating_pl[6];
   double est_risk[6];
   for(int i = 0; i < 6; i++)
   {
      open_count[i] = 0;
      pending_count[i] = 0;
      no_sl_count[i] = 0;
      volume[i] = 0.0;
      floating_pl[i] = 0.0;
      est_risk[i] = 0.0;
   }

   for(int p = 0; p < ArraySize(AC_L1_POSITIONS); p++)
   {
      int idx = AC_L1AssetClassIndex(AC_L1_POSITIONS[p].symbol);
      if(idx < 0 || idx > 5) idx = 5;
      open_count[idx]++;
      volume[idx] += AC_L1_POSITIONS[p].volume;
      floating_pl[idx] += AC_L1_POSITIONS[p].profit;
      if(AC_L1_POSITIONS[p].stop_loss <= 0.0) no_sl_count[idx]++;
      double risk = 0.0;
      if(AC_L1EstimateRiskAtSL(AC_L1_POSITIONS[p].symbol, AC_L1_POSITIONS[p].side, AC_L1_POSITIONS[p].volume, AC_L1_POSITIONS[p].entry_price, AC_L1_POSITIONS[p].stop_loss, risk))
         est_risk[idx] += risk;
   }

   for(int q = 0; q < ArraySize(AC_L1_PENDING); q++)
   {
      int idx = AC_L1AssetClassIndex(AC_L1_PENDING[q].symbol);
      if(idx < 0 || idx > 5) idx = 5;
      pending_count[idx]++;
      volume[idx] += AC_L1_PENDING[q].volume;
      if(AC_L1_PENDING[q].stop_loss <= 0.0) no_sl_count[idx]++;
      double risk = 0.0;
      if(AC_L1EstimateRiskAtSL(AC_L1_PENDING[q].symbol, AC_L1_PENDING[q].type_text, AC_L1_PENDING[q].volume, AC_L1_PENDING[q].price, AC_L1_PENDING[q].stop_loss, risk))
         est_risk[idx] += risk;
   }

   string text = AC_L1MapHeader("OPEN / PENDING ASSET EXPOSURE MAP");
   text += "Scope:                  live open positions and pending orders only\r\n";
   text += "Classification Basis:   Layer 1 heuristic fallback; Layer 3 taxonomy link pending\r\n";
   text += AC_L1PadRight("Asset", 14)
      + AC_L1PadLeft("Open", 6)
      + AC_L1PadLeft("Pending", 8)
      + AC_L1PadLeft("Volume", 9)
      + AC_L1PadLeft("FloatPL", 11)
      + AC_L1PadLeft("NoSL", 7)
      + AC_L1PadLeft("EstRisk", 11)
      + "\r\n";

   for(int c = 0; c < 6; c++)
      text += AC_L1LiveAssetExposureLine(AC_L1AssetClassName(c), open_count[c], pending_count[c], volume[c], floating_pl[c], no_sl_count[c], est_risk[c]);

   text += "Trade Permission:       FALSE\r\n";
   return text;
}

#endif